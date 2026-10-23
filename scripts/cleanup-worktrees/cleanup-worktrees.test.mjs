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
  inspect,
  interactivePlan,
  loadThreadState,
  parseOptions,
  removeMeasuredDirectory,
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
  });
  assert.match(output, /project\/old: eligible/);
  assert.match(output, /Nothing deleted/);
  assert.equal(existsSync(join(f.path, "node_modules")), true);
});
