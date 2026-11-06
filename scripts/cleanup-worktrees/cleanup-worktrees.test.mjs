import assert from "node:assert/strict";
import test from "node:test";
import { execFileSync } from "node:child_process";
import {
  chmodSync,
  existsSync,
  linkSync,
  mkdirSync,
  mkdtempSync,
  readdirSync,
  readFileSync,
  realpathSync,
  rmSync,
  symlinkSync,
  utimesSync,
  writeFileSync,
} from "node:fs";
import { tmpdir } from "node:os";
import { join, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import {
  discover,
  formatFreeSpace,
  inspect,
  interactivePlan,
  loadOrcaState,
  loadThreadState,
  orcaCheck,
  parseOptions,
  removeMeasuredDirectory,
  scanWorktrees,
  settlementCheck,
  trimTree,
} from "./cleanup-worktrees.mjs";

function fixture(t) {
  const base = mkdtempSync(join(tmpdir(), "worktree-cleanup-"));
  // macOS /var and /tmp are symlinks. Match the canonical layout used by the CLI.
  const root = realpathSync(base);
  t.after(() => rmSync(root, { recursive: true, force: true }));
  const repo = join(root, "repo");
  const parent = join(root, "worktrees");
  const path = join(parent, "project", "old");
  mkdirSync(repo);
  const git = (...args) =>
    execFileSync("git", ["-C", repo, ...args], {
      stdio: "pipe",
      env: {
        ...process.env,
        GIT_AUTHOR_DATE: "2000-01-01T00:00:00Z",
        GIT_COMMITTER_DATE: "2000-01-01T00:00:00Z",
      },
    });
  git("init");
  git("config", "user.email", "test@example.invalid");
  git("config", "user.name", "Cleanup test");
  git("config", "commit.gpgsign", "false");
  git("config", "core.hooksPath", "/dev/null");
  writeFileSync(join(repo, "package.json"), "{}");
  writeFileSync(
    join(repo, ".gitignore"),
    "node_modules/\n.turbo/\ndist/\n.env\n.cache/\n",
  );
  git("add", ".");
  git("commit", "-m", "fixture");
  git("worktree", "add", "-b", "fixture", path);
  function file(rel, contents = "keep") {
    mkdirSync(resolve(path, rel, ".."), { recursive: true });
    writeFileSync(join(path, rel), contents);
  }
  file("node_modules/dependency/index.js");
  file("apps/example/package.json", "{}");
  git("-C", path, "add", "apps/example/package.json");
  git("-C", path, "commit", "-m", "workspace");
  file("apps/example/node_modules/other/index.js");
  file(".env");
  file(".cache/private-data");
  const tree = { name: "project/old", path };
  const options = { days: 0, exclude: [], policy: "age" };
  return { root, repo, parent, path, tree, options, file, git };
}

test("CLI defaults to dry-run and requires explicit worktree selection for apply", () => {
  assert.equal(parseOptions([]).apply, false);
  assert.equal(parseOptions([]).days, 1);
  assert.equal(parseOptions([]).policy, "settled");
  assert.equal(parseOptions(["--root", "/tmp/waystone"]).days, 3);
  assert.equal(parseOptions(["--root", "/tmp/waystone"]).policy, "age");
  assert.equal(parseOptions(["trim", "--all-settled", "--apply"]).apply, true);
  assert.throws(() =>
    parseOptions(["trim", "--policy", "age", "--all-settled", "--apply"])
  );
  for (
    const args of [["--apply"], ["trim", "--apply"], ["trim", "--days", "-1"], [
      "trim",
      "--worktree",
      "../old",
    ], ["trim", "--worktree", "project/.."]]
  ) {
    assert.throws(() => parseOptions(args));
  }
});

test("settlement requires every owner to have been settled for a full day", () => {
  const path = "/nonexistent-fixture/worktree";
  const now = Date.parse("2026-10-23T12:00:00Z");
  const old = {
    id: "a",
    path,
    settled: "settled",
    settledAt: "2026-10-22T11:59:00Z",
    active: 0,
  };
  assert.deepEqual(settlementCheck(path, [old], 1, now).blockers, []);
  for (
    const other of [
      { ...old, id: "b", settledAt: "2026-10-22T12:01:00Z" },
      { ...old, id: "b", settled: null },
      { ...old, id: "b", active: 1 },
      { ...old, id: "b", settledAt: null },
    ]
  ) {
    assert.ok(settlementCheck(path, [old, other], 1, now).blockers.length > 0);
  }
  assert.ok(
    settlementCheck(path, [], 1, now).blockers.includes(
      "no T3 thread owns this path",
    ),
  );
});

function stateFixture(f) {
  const db = join(f.root, "state.sqlite");
  const sql = (input) =>
    execFileSync("sqlite3", [db], { input, encoding: "utf8" });
  sql(
    `CREATE TABLE orchestration_v2_projection_threads (thread_id TEXT, deleted_at TEXT, payload_json TEXT);
    CREATE TABLE orchestration_v2_projection_runs (thread_id TEXT, status TEXT);
    INSERT INTO orchestration_v2_projection_threads VALUES ('owner', NULL,
      '${
      JSON.stringify({
        worktreePath: f.path,
        settledOverride: "settled",
        settledAt: "2000-01-01T00:00:00Z",
      }).replaceAll("'", "''")
    }');`,
  );
  return { db, sql };
}

test("settled trimming ignores file age but reloads T3 state before deleting", (t) => {
  const f = fixture(t);
  const state = stateFixture(f);
  const options = { ...f.options, days: 1, policy: "settled", db: state.db };
  assert.deepEqual(inspect(f.tree, options).blockers, []);
  state.sql(
    "INSERT INTO orchestration_v2_projection_runs VALUES ('owner', 'running');",
  );
  assert.throws(() => trimTree(f.tree, options, () => []), /unfinished run/);
  assert.equal(existsSync(join(f.path, "node_modules")), true);
  state.sql("UPDATE orchestration_v2_projection_runs SET status='completed';");
  trimTree(f.tree, options, () => []);
  assert.equal(existsSync(join(f.path, "node_modules")), false);
});

test("missing or unsupported T3 database blocks settled cleanup", (t) => {
  const f = fixture(t);
  const missing = join(f.root, "missing.sqlite");
  assert.throws(() => loadThreadState(missing));
  assert.equal(existsSync(missing), false);
  const state = stateFixture(f);
  state.sql(
    "UPDATE orchestration_v2_projection_threads SET payload_json=json_set(payload_json,'$.settledOverride','future-value');",
  );
  assert.throws(
    () => inspect(f.tree, { ...f.options, policy: "settled", db: state.db }),
    /Unsupported T3/,
  );
  assert.equal(existsSync(join(f.path, "node_modules")), true);
});

test("inventory finds nested dependencies and preserves all files", (t) => {
  const f = fixture(t);
  const report = inspect(f.tree, f.options);
  assert.deepEqual(report.blockers, []);
  assert.deepEqual(report.candidates, [
    "apps/example/node_modules",
    "node_modules",
  ]);
  assert.equal(
    existsSync(join(f.path, "node_modules/dependency/index.js")),
    true,
  );
  assert.equal(discover(f.parent).length, 1);
});

test("trim deletes generated directories while preserving source, environment, and other caches", (t) => {
  const f = fixture(t);
  f.file("dist/output.js");
  f.file(".turbo/cache");
  trimTree(f.tree, f.options, () => []);
  for (
    const rel of ["node_modules", "apps/example/node_modules", "dist", ".turbo"]
  ) {
    assert.equal(existsSync(join(f.path, rel)), false, rel);
  }
  for (
    const rel of [
      "package.json",
      "apps/example/package.json",
      ".env",
      ".cache/private-data",
      ".git",
    ]
  ) {
    assert.equal(existsSync(join(f.path, rel)), true, rel);
  }
});

test("dirty, excluded, recent, and active worktrees cannot be trimmed", (t) => {
  const f = fixture(t);
  assert.throws(
    () => trimTree(f.tree, { ...f.options, days: 14 }, () => []),
    /activity within/,
  );
  assert.throws(
    () =>
      trimTree(f.tree, { ...f.options, exclude: ["project/old"] }, () => []),
    /excluded/,
  );
  assert.throws(
    () => trimTree(f.tree, f.options, () => [join(f.path, "apps/example")]),
    /process/,
  );
  f.file("uncommitted.txt");
  assert.throws(() => trimTree(f.tree, f.options, () => []), /uncommitted/);
  assert.equal(existsSync(join(f.path, "node_modules")), true);
});

test("a tracked file inside ignored output protects that entire directory", (t) => {
  const f = fixture(t);
  f.file("dist/important.txt");
  f.git("-C", f.path, "add", "-f", "dist/important.txt");
  f.git("-C", f.path, "commit", "-m", "tracked output");
  trimTree(f.tree, f.options, () => []);
  assert.equal(existsSync(join(f.path, "dist/important.txt")), true);
});

test("symlinked worktrees and package directories are not followed", (t) => {
  const f = fixture(t);
  symlinkSync(f.path, join(f.parent, "project", "alias"));
  symlinkSync(f.repo, join(f.path, "apps", "linked"));
  mkdirSync(join(f.repo, "node_modules"));
  const report = inspect(f.tree, f.options);
  assert.equal(report.candidates.some((rel) => rel.includes("linked")), false);
  assert.equal(discover(f.parent).length, 1);
  assert.throws(
    () =>
      inspect(
        { ...f.tree, path: join(f.parent, "project", "alias") },
        f.options,
      ),
    /real linked/,
  );
});

test("source mtimes contribute to inactivity even with old commit and index timestamps", (t) => {
  const f = fixture(t);
  const old = new Date(Date.now() - 30 * 86_400_000);
  const gitDir = execFileSync("git", [
    "-C",
    f.path,
    "rev-parse",
    "--absolute-git-dir",
  ], { encoding: "utf8" }).trim();
  for (const rel of ["index", "logs/HEAD"]) {
    utimesSync(join(gitDir, rel), old, old);
  }
  for (
    const rel of [
      "package.json",
      ".gitignore",
      ".env",
      "apps/example/package.json",
    ]
  ) {
    utimesSync(join(f.path, rel), old, old);
  }
  assert.deepEqual(inspect(f.tree, { ...f.options, days: 14 }).blockers, []);
  utimesSync(join(f.path, "package.json"), new Date(), new Date());
  assert.ok(
    inspect(f.tree, { ...f.options, days: 14 }).blockers.includes(
      "activity within 14 days",
    ),
  );
});

test("process inspection failure prevents deletion", (t) => {
  const f = fixture(t);
  assert.throws(() =>
    trimTree(f.tree, f.options, () => {
      throw new Error("lsof failed");
    }), /lsof failed/);
  assert.equal(existsSync(join(f.path, "node_modules")), true);
});

test("unignored output and symlinked dependency directories are preserved", (t) => {
  const f = fixture(t);
  f.file("apps/example/.vite/local-data");
  const external = join(f.root, "external");
  mkdirSync(external);
  writeFileSync(join(external, "keep.txt"), "keep");
  rmSync(join(f.path, "node_modules"), { recursive: true });
  symlinkSync(external, join(f.path, "node_modules"));
  const report = inspect(f.tree, f.options);
  assert.equal(report.candidates.includes("node_modules"), false);
  assert.equal(report.candidates.includes("apps/example/.vite"), false);
  // The unignored output also makes the checkout dirty, preventing any trim.
  assert.throws(() => trimTree(f.tree, f.options, () => []), /uncommitted/);
  assert.equal(existsSync(join(external, "keep.txt")), true);
});

function duBytes(...paths) {
  return execFileSync("/usr/bin/du", ["-sk", ...paths], { encoding: "utf8" })
    .trim().split("\n").reduce(
      (sum, line) => sum + Number(line.split(/\s/)[0]) * 1024,
      0,
    );
}

test("incremental deletion counts allocated bytes once for hardlinks and preserves symlink targets", (t) => {
  const f = fixture(t);
  const path = join(f.path, "node_modules");
  f.file("node_modules/dependency/large.bin", Buffer.alloc(128 * 1024, "data"));
  linkSync(join(path, "dependency/large.bin"), join(path, "hardlink"));
  const external = join(f.root, "external");
  mkdirSync(external);
  writeFileSync(join(external, "keep"), "keep");
  symlinkSync(external, join(path, "linked"));
  symlinkSync(join(f.root, "missing"), join(path, "broken"));
  const expected = duBytes(path);
  const entries = [];
  const result = removeMeasuredDirectory(path, {
    onDeleted: (entry) => entries.push(entry),
  });
  assert.equal(result.reportedBytes, expected);
  assert.equal(
    result.reportedBytes,
    entries.reduce((sum, entry) => sum + entry.reportedBytes, 0),
  );
  assert.equal(result.files, 3);
  assert.equal(result.symlinks, 2);
  assert.equal(result.directories, 2);
  assert.equal(existsSync(join(external, "keep")), true);
  assert.equal(existsSync(path), false);
});

test("partial deletion events account only for entries actually removed", (t) => {
  const f = fixture(t);
  const path = join(f.path, "node_modules");
  const events = [];
  assert.throws(() =>
    removeMeasuredDirectory(path, {
      onDeleted: (entry) => {
        events.push(entry);
        throw new Error("stop after one removal");
      },
    }), /stop after one removal/);
  assert.equal(events.length, 1);
  assert.equal(existsSync(events[0].path), false);
  assert.equal(existsSync(path), true);
});

test("CLI always measures during deletion, logs progress, and saves results without invoking du", (t) => {
  const f = fixture(t);
  f.file(
    "node_modules/dependency/large.bin",
    Buffer.alloc(128 * 1024, "dependency"),
  );
  const expected = duBytes(
    join(f.path, "node_modules"),
    join(f.path, "apps/example/node_modules"),
  );
  const fakeBin = join(f.root, "bin");
  mkdirSync(fakeBin);
  const fakeDu = join(fakeBin, "du");
  writeFileSync(fakeDu, "#!/bin/sh\necho du-must-not-run >&2\nexit 99\n");
  chmodSync(fakeDu, 0o755);
  const reportDir = join(f.root, "reports");
  const script = fileURLToPath(
    new URL("./cleanup-worktrees.mjs", import.meta.url),
  );
  const args = [
    script,
    "trim",
    "--root",
    f.parent,
    "--days",
    "0",
    "--worktree",
    f.tree.name,
    "--report-dir",
    reportDir,
  ];
  const invoke = (extra) =>
    execFileSync(process.execPath, [...args, ...extra], {
      cwd: f.root,
      encoding: "utf8",
      timeout: 30_000,
      env: { ...process.env, PATH: `${fakeBin}:${process.env.PATH}` },
    });
  assert.match(invoke([]), /Nothing deleted/);
  assert.equal(existsSync(reportDir), false);
  assert.equal(existsSync(join(f.path, "node_modules")), true);
  const output = invoke(["--apply"]);
  assert.match(output, /Worktree 1\/1/);
  assert.match(output, /\[1\/2\] Removing/);
  assert.match(output, /Progress:/);
  assert.match(output, /Saved report:/);
  const reports = readdirSync(reportDir);
  assert.equal(reports.length, 1);
  const report = JSON.parse(readFileSync(join(reportDir, reports[0]), "utf8"));
  assert.equal(report.reportedRemovedBytes, expected);
  assert.equal(report.removedDirectories.length, 2);
  assert.equal(
    report.directoryResults.every((result) => result.status === "removed"),
    true,
  );
  assert.deepEqual(report.trimmedWorktrees, [f.tree.name]);
  assert.equal(typeof report.freeSpace.increaseBytes, "number");
  assert.deepEqual(report.errors, []);
  assert.equal(existsSync(join(f.path, ".env")), true);
  assert.equal(existsSync(join(f.path, "package.json")), true);
});

function menuFixture(approved = true, action = "trim") {
  const root = parseOptions([]).root;
  const eligible = {
    name: "project/eligible",
    path: join(root, "project/eligible"),
    blockers: [],
    candidates: ["node_modules"],
    activity: "settled 2d ago",
  };
  const blocked = {
    name: "project/active",
    blockers: ["not settled"],
    candidates: ["node_modules"],
    activity: "active",
  };
  const selections = [action, root];
  const messages = [];
  const ui = {
    select: () => selections.shift(),
    input: (options) => {
      assert.equal(options.default, "1");
      return "1";
    },
    checkbox: (options) => {
      assert.deepEqual(options.choices.map((choice) => choice.value), [
        eligible.name,
      ]);
      return [eligible.name];
    },
    confirm: (options) => {
      assert.equal(options.default, false);
      return approved;
    },
  };
  const dependencies = {
    locations: [{ name: "T3", value: root }],
    scan: () => [eligible, blocked],
    log: (message) => messages.push(message),
  };
  return { ui, dependencies, messages, eligible };
}

test("interactive cleanup confirms a reviewed selection and excludes blocked worktrees", async () => {
  const f = menuFixture();
  const plan = await interactivePlan(f.ui, f.dependencies);
  assert.equal(plan.options.apply, true);
  assert.deepEqual(plan.options.worktree, [f.eligible.name]);
  assert.deepEqual(plan.inventory, [f.eligible]);
  assert.ok(f.messages.some((message) => message.includes("node_modules")));
});

test("interactive cancellation and inventory never authorize deletion", async () => {
  const cancelled = menuFixture(false);
  assert.equal(
    await interactivePlan(cancelled.ui, cancelled.dependencies),
    null,
  );
  const inventory = menuFixture(false, "inventory");
  const plan = await interactivePlan(inventory.ui, inventory.dependencies);
  assert.equal(plan.options.apply, false);
  const exited = menuFixture();
  exited.ui.select = () => "exit";
  assert.equal(await interactivePlan(exited.ui, exited.dependencies), null);
});

test("global launcher uses the dotfiles Bun runtime and preserves relative paths from another directory", (t) => {
  const f = fixture(t);
  const launcher = fileURLToPath(
    new URL("../../bin/cleanup-worktrees", import.meta.url),
  );
  const home = join(f.root, "home");
  const dotfiles = join(home, "code/private/dotfiles");
  const fakeBin = join(f.root, "bin");
  mkdirSync(join(home, "code/private"), { recursive: true });
  mkdirSync(fakeBin);
  symlinkSync(fileURLToPath(new URL("../../", import.meta.url)), dotfiles);
  writeFileSync(join(home, "runtime"), process.execPath);
  writeFileSync(
    join(fakeBin, "proto"),
    `#!/bin/sh
[ "$*" = "--config-mode local --reporter text bin bun" ] || exit 1
[ "$PWD" = "$HOME/code/private/dotfiles" ] || exit 1
cat "$HOME/runtime"
`,
  );
  chmodSync(join(fakeBin, "proto"), 0o755);
  const output = execFileSync(launcher, [
    "inventory",
    "--root",
    "worktrees",
    "--days",
    "0",
  ], {
    cwd: f.root,
    encoding: "utf8",
    timeout: 30_000,
    env: { ...process.env, HOME: home, PATH: `${fakeBin}:${process.env.PATH}` },
  });
  assert.match(output, /project\/old: eligible/);
  assert.match(output, /Nothing deleted/);
  assert.equal(existsSync(join(f.path, "node_modules")), true);
});

test("disk availability labels show gains and losses without calling them cleanup savings", () => {
  assert.equal(
    formatFreeSpace(4 * 1024 ** 3, 3 * 1024 ** 3),
    "3.00 GiB available; 1.00 GiB less than at start",
  );
  assert.equal(
    formatFreeSpace(3 * 1024 ** 3, 4 * 1024 ** 3),
    "4.00 GiB available; 1.00 GiB more than at start",
  );
  assert.equal(
    formatFreeSpace(3 * 1024 ** 3, 3 * 1024 ** 3),
    "3.00 GiB available; unchanged since start",
  );
});

function orcaOwner(path) {
  return {
    path,
    hostId: "local",
    workspaceKind: "git",
    isMainWorktree: false,
    isPinned: false,
    isActive: false,
    liveTerminalCount: 0,
    hasAttachedPty: false,
    unverifiableTerminalCount: 0,
    terminalVerdict: "none",
    status: "inactive",
    agents: [],
    lastActivityAt: 1,
    linkedPR: null,
    linkedItems: [],
  };
}

test("Orca root defaults to safety checks and a three-day cooldown", () => {
  const options = parseOptions([
    "--root",
    join(process.env.HOME, "orca/workspaces"),
  ]);
  assert.equal(options.policy, "orca");
  assert.equal(options.days, 3);
  assert.throws(() => parseOptions(["--policy", "orca", "--all-settled"]));
});

test("Orca checks protect every owner, live agents, terminals and unknown state", () => {
  const path = "/nonexistent-orca-fixture/worktree";
  const owner = orcaOwner(path);
  assert.deepEqual(orcaCheck(path, [owner], 3).blockers, []);
  for (
    const change of [
      { hostId: "remote" },
      { isMainWorktree: true },
      { isPinned: true },
      { isActive: true },
      { liveTerminalCount: 1 },
      { hasAttachedPty: true },
      { unverifiableTerminalCount: 1 },
      { terminalVerdict: "unknown" },
      { status: "working" },
      { agents: undefined },
      { lastActivityAt: 0 },
      { lastActivityAt: Date.now() },
      { isPinned: undefined },
      { agents: [{ state: "working", children: [] }] },
      {
        agents: [{
          state: "done",
          children: [{ state: "working", children: [] }],
        }],
      },
    ]
  ) {
    assert.ok(
      orcaCheck(path, [{ ...owner, ...change }], 3).blockers.length,
      JSON.stringify(change),
    );
  }
  assert.ok(
    orcaCheck(path, [owner, { ...owner, isActive: true }], 0).blockers.length,
  );
  assert.ok(orcaCheck(path, [], 0).blockers.length);
  assert.deepEqual(
    orcaCheck(
      path,
      [{ ...owner, agents: [{ state: "done", children: [] }] }],
      0,
    ).blockers,
    [],
  );
});

test("Orca reader refuses failed, truncated and incomplete host snapshots", () => {
  const response = {
    ok: true,
    result: {
      worktrees: [],
      truncated: false,
      hostScope: { hostIds: ["local"], omittedHostIds: [] },
    },
  };
  assert.deepEqual(loadOrcaState(() => JSON.stringify(response)), []);
  for (
    const result of [
      { ...response.result, truncated: true },
      { ...response.result, truncated: undefined },
      { ...response.result, hostScope: undefined },
      {
        ...response.result,
        hostScope: { hostIds: ["local"], omittedHostIds: ["remote"] },
      },
    ]
  ) {
    assert.throws(() =>
      loadOrcaState(() => JSON.stringify({ ok: true, result }))
    );
  }
  assert.throws(() => loadOrcaState(() => JSON.stringify({ ok: false })));
  assert.throws(() => loadOrcaState(() => "invalid json"));
});

test("Orca inspection retains Git and process protections", (t) => {
  const f = fixture(t);
  const options = { ...f.options, policy: "orca" };
  const owners = [orcaOwner(f.path)];
  assert.deepEqual(
    inspect(f.tree, options, [], undefined, owners).blockers,
    [],
  );
  assert.ok(
    inspect(f.tree, options, [f.path], undefined, owners).blockers.length,
  );
  f.file("untracked.txt");
  assert.ok(inspect(f.tree, options, [], undefined, owners).blockers.length);
});

test("missing Orca CLI skips Orca workspaces without throwing or disabling age scans", (t) => {
  const f = fixture(t);
  const previous = process.env.ORCA_CLI_COMMAND;
  process.env.ORCA_CLI_COMMAND = join(f.root, "missing-orca");
  t.after(() => {
    if (previous === undefined) {
      delete process.env.ORCA_CLI_COMMAND;
    } else {
      process.env.ORCA_CLI_COMMAND = previous;
    }
  });
  const options = parseOptions([
    "--root",
    f.parent,
    "--policy",
    "orca",
    "--days",
    "0",
  ]);
  const messages = [];
  const inventory = scanWorktrees(options, (message) => messages.push(message));
  assert.equal(inventory.length, 1);
  assert.equal(inventory[0].error, undefined);
  assert.deepEqual(inventory[0].candidates, []);
  assert.match(inventory[0].blockers[0], /Orca state unavailable/);
  assert.ok(messages.length);
  const generic = scanWorktrees({ ...options, policy: "age" }, () => {});
  assert.equal(generic[0].error, undefined);
  assert.ok(generic[0].candidates.length);
});

test("Orca state is reloaded before deletion and an unavailable CLI preserves output", (t) => {
  const f = fixture(t);
  const previous = process.env.ORCA_CLI_COMMAND;
  const cli = join(f.root, "orca-cli");
  process.env.ORCA_CLI_COMMAND = cli;
  t.after(() => {
    if (previous === undefined) {
      delete process.env.ORCA_CLI_COMMAND;
    } else {
      process.env.ORCA_CLI_COMMAND = previous;
    }
  });
  const state = join(f.root, "state.json");
  writeFileSync(cli, '#!/bin/sh\ncat "' + state + '"\n');
  chmodSync(cli, 0o755);
  const owner = orcaOwner(f.path);
  const writeState = (workspace) =>
    writeFileSync(
      state,
      JSON.stringify({
        ok: true,
        result: {
          worktrees: [workspace],
          truncated: false,
          hostScope: { hostIds: ["local"], omittedHostIds: [] },
        },
      }),
    );
  const options = { ...f.options, policy: "orca" };
  writeState(owner);
  const reviewed = inspect(f.tree, options);
  assert.deepEqual(reviewed.blockers, []);
  writeState({ ...owner, agents: [{ state: "working", children: [] }] });
  assert.throws(
    () => trimTree(reviewed, options, () => []),
    /live or unverifiable/,
  );
  writeState({ ...owner, linkedPR: { state: "open" } });
  assert.throws(() => trimTree(reviewed, options, () => []), /PR is open/);
  rmSync(cli);
  assert.throws(() => trimTree(reviewed, options, () => []));
  assert.equal(existsSync(join(f.path, "node_modules")), true);
  assert.equal(existsSync(join(f.path, "apps/example/node_modules")), true);
});

test("Orca protects open, closed-unmerged and unknown PRs even with no cooldown", () => {
  const path = "/nonexistent-orca-fixture/worktree";
  const owner = orcaOwner(path);
  for (
    const linkedPR of [
      undefined,
      42,
      { state: "open" },
      { state: "closed" },
      {},
    ]
  ) {
    assert.ok(orcaCheck(path, [{ ...owner, linkedPR }], 0).blockers.length);
  }
  assert.deepEqual(
    orcaCheck(path, [{ ...owner, linkedPR: { state: "merged" } }], 3).blockers,
    [],
  );
  assert.deepEqual(orcaCheck(path, [owner], 3).blockers, []);
  assert.ok(
    orcaCheck(path, [{
      ...owner,
      linkedPR: { state: "merged" },
      lastActivityAt: Date.now(),
    }], 3).blockers.length,
  );
  assert.ok(
    orcaCheck(path, [{ ...owner, linkedGitLabMR: 42 }], 0).blockers.length,
  );
  assert.ok(
    orcaCheck(path, [{
      ...owner,
      linkedItems: [{ provider: "github", type: "pr", number: 42 }],
    }], 0).blockers.length,
  );
});

test("a merged PR does not approve another linked PR", () => {
  const path = "/nonexistent-orca-fixture/worktree";
  const owner = {
    ...orcaOwner(path),
    linkedPR: { state: "merged", number: 42 },
    linkedItems: [{ provider: "github", type: "pr", number: 43 }],
  };
  assert.ok(orcaCheck(path, [owner], 0).blockers.length);
  owner.linkedItems[0].number = 42;
  assert.deepEqual(orcaCheck(path, [owner], 0).blockers, []);
});
