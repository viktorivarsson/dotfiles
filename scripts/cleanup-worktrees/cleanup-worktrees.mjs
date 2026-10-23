#!/usr/bin/env bun

import { execFileSync } from "node:child_process";
import {
  existsSync,
  lstatSync,
  mkdirSync,
  readdirSync,
  readFileSync,
  realpathSync,
  rmdirSync,
  statfsSync,
  unlinkSync,
  writeFileSync,
} from "node:fs";
import { randomUUID } from "node:crypto";
import { homedir } from "node:os";
import { join, relative, resolve, sep } from "node:path";
import { pathToFileURL } from "node:url";
import { parseArgs } from "node:util";
import { checkbox, confirm, input, select } from "@inquirer/prompts";

const DAY = 86_400_000;
const DEFAULT_ROOT = join(homedir(), ".t3/worktrees");
const GENERATED = new Set(["node_modules", ".turbo", ".vite", "dist"]);
const SKIP_SCAN = new Set([
  ...GENERATED,
  ".git",
  ".next",
  ".cache",
  ".wrangler",
  ".terraform",
  "coverage",
  "build",
  ".output",
]);

function run(command, args, cwd, input) {
  return execFileSync(command, args, {
    cwd,
    input,
    encoding: "utf8",
    timeout: 30_000,
    maxBuffer: 16 * 1024 * 1024,
    stdio: ["pipe", "pipe", "pipe"],
  });
}

function git(path, args, input) {
  return run(
    "git",
    ["--no-optional-locks", "-C", path, ...args],
    undefined,
    input,
  );
}

function directory(path) {
  return existsSync(path) && lstatSync(path).isDirectory() &&
    !lstatSync(path).isSymbolicLink();
}

function within(parent, child) {
  return child === parent || child.startsWith(parent + sep);
}

export function parseOptions(args) {
  const { values, positionals } = parseArgs({
    args,
    allowPositionals: true,
    options: {
      root: { type: "string", default: DEFAULT_ROOT },
      policy: { type: "string" },
      "t3-db": {
        type: "string",
        default: join(homedir(), ".t3/userdata/statev2.sqlite"),
      },
      days: { type: "string" },
      worktree: { type: "string", multiple: true, default: [] },
      exclude: { type: "string", multiple: true, default: [] },
      apply: { type: "boolean", default: false },
      "all-settled": { type: "boolean", default: false },
      measure: { type: "boolean", default: false },
      "report-dir": {
        type: "string",
        default: join(
          process.env.XDG_STATE_HOME || join(homedir(), ".local/state"),
          "cleanup-worktrees/reports",
        ),
      },
      help: { type: "boolean", default: false },
    },
  });
  const command = positionals[0] ?? "inventory";
  if (positionals.length > 1 || !["inventory", "trim"].includes(command)) {
    throw new Error("Choose inventory or trim.");
  }
  const policy = values.policy ??
    (resolve(values.root) === DEFAULT_ROOT ? "settled" : "age");
  if (!["settled", "age"].includes(policy)) {
    throw new Error("--policy must be settled or age.");
  }
  const days = values.days ?? (policy === "settled" ? "1" : "3");
  if (!/^\d+$/.test(days) || !Number.isSafeInteger(Number(days))) {
    throw new Error("--days must be a nonnegative whole number.");
  }
  for (const name of [...values.worktree, ...values.exclude]) {
    if (
      !/^[a-zA-Z0-9_.-]+\/[a-zA-Z0-9_.-]+$/.test(name) ||
      name.split("/").some((part) => part === "." || part === "..")
    ) {
      throw new Error("Use project/worktree names, such as frontend/t3-1234.");
    }
  }
  if (
    values["all-settled"] && (policy !== "settled" || values.worktree.length)
  ) {
    throw new Error(
      "--all-settled requires settled policy and cannot be combined with --worktree.",
    );
  }
  if (
    values.apply &&
    (command !== "trim" ||
      (!values["all-settled"] && values.worktree.length === 0))
  ) {
    throw new Error(
      "--apply requires trim and either --worktree project/name or --all-settled.",
    );
  }
  const root = resolve(values.root);
  return {
    ...values,
    command,
    policy,
    db: resolve(values["t3-db"]),
    root,
    days: Number(days),
    reportDir: resolve(values["report-dir"]),
  };
}

export function loadThreadState(db) {
  // Read only the required projection fields. Never modify T3's database.
  const output = run("sqlite3", [
    "-readonly",
    "-json",
    db,
    `
    SELECT t.thread_id AS id,
      json_extract(t.payload_json, '$.worktreePath') AS path,
      json_extract(t.payload_json, '$.settledOverride') AS settled,
      json_extract(t.payload_json, '$.settledAt') AS settledAt,
      EXISTS(SELECT 1 FROM orchestration_v2_projection_runs r
        WHERE r.thread_id = t.thread_id
        AND r.status NOT IN ('completed','cancelled','interrupted','failed','rolled_back')) AS active
    FROM orchestration_v2_projection_threads t
    WHERE t.deleted_at IS NULL
      AND json_type(t.payload_json, '$.worktreePath') = 'text';
  `,
  ]);
  const threads = JSON.parse(output || "[]");
  if (
    !Array.isArray(threads) ||
    threads.some((thread) =>
      typeof thread.id !== "string" || typeof thread.path !== "string" ||
      ![null, "settled", "unsettled"].includes(thread.settled) ||
      !(thread.settledAt === null || typeof thread.settledAt === "string") ||
      ![0, 1].includes(thread.active)
    )
  ) {
    throw new Error("Unsupported T3 thread state; no cleanup performed.");
  }
  return threads;
}

export function settlementCheck(path, threads, days, now = Date.now()) {
  const owners = threads.filter((thread) => {
    let ownerPath = resolve(thread.path);
    if (existsSync(ownerPath)) {
      ownerPath = realpathSync(ownerPath);
    }
    return ownerPath === path;
  });
  if (!owners.length) {
    return {
      blockers: ["no T3 thread owns this path"],
      label: "settlement unknown",
    };
  }
  const blockers = [];
  if (owners.some((thread) => thread.active !== 0)) {
    blockers.push("a T3 thread has an unfinished run");
  }
  if (owners.some((thread) => thread.settled !== "settled")) {
    blockers.push("not all T3 threads are settled");
  }
  const times = owners.map((thread) => Date.parse(thread.settledAt));
  if (times.some((time) => !Number.isFinite(time))) {
    blockers.push("missing or invalid settlement time");
    return {
      blockers,
      label: `${owners.length} T3 threads; settlement time unknown`,
    };
  }
  const age = (now - Math.max(...times)) / DAY;
  if (age < days) {
    blockers.push(`settled for less than ${days} days`);
  }
  return {
    blockers,
    label: `${owners.length} T3 threads; settled ${age.toFixed(1)}d ago`,
  };
}

export function discover(root) {
  const result = [];
  for (const group of readdirSync(root)) {
    if (!directory(join(root, group))) {
      continue;
    }
    for (const name of readdirSync(join(root, group))) {
      const path = join(root, group, name);
      if (directory(path)) {
        result.push({ name: `${group}/${name}`, path });
      }
    }
  }
  return result.sort((a, b) => a.name.localeCompare(b.name));
}

export function inspect(tree, options, cwdPaths = [], threadState) {
  const { path } = tree;
  const blockers = [];
  const candidates = [];
  if (
    !directory(path) || realpathSync(path) !== path ||
    !existsSync(join(path, ".git")) || !lstatSync(join(path, ".git")).isFile()
  ) {
    throw new Error("Expected a real linked Git worktree with a .git file.");
  }
  if (
    realpathSync(git(path, ["rev-parse", "--show-toplevel"]).trim()) !== path
  ) {
    throw new Error("Git worktree root does not match.");
  }
  if (options.exclude.includes(tree.name)) {
    blockers.push("explicitly excluded");
  }
  if (cwdPaths.some((cwd) => within(path, cwd))) {
    blockers.push("a process has its working directory here");
  }
  if (
    git(path, ["status", "--porcelain=v1", "--untracked-files=normal"]).trim()
  ) {
    blockers.push("uncommitted or untracked files");
  }
  let settlement;
  if (options.policy === "settled") {
    settlement = settlementCheck(
      path,
      threadState ?? loadThreadState(options.db),
      options.days,
    );
    blockers.push(...settlement.blockers);
  }
  const tracked = git(path, ["ls-files", "-z"]).split("\0").filter(Boolean);
  const gitDir = realpathSync(
    git(path, ["rev-parse", "--absolute-git-dir"]).trim(),
  );
  let latest = Number(git(path, ["log", "-1", "--format=%ct"]).trim()) * 1000;
  for (const file of ["index", "logs/HEAD"]) {
    const target = join(gitDir, file);
    if (existsSync(target)) {
      latest = Math.max(latest, lstatSync(target).mtimeMs);
    }
  }

  function scan(folder) {
    const packageRoot = existsSync(join(folder, "package.json")) &&
      !lstatSync(join(folder, "package.json")).isSymbolicLink();
    for (const entry of readdirSync(folder, { withFileTypes: true })) {
      const full = join(folder, entry.name);
      const rel = relative(path, full);
      if (entry.isSymbolicLink()) {
        continue;
      }
      if (entry.isDirectory()) {
        if (packageRoot && GENERATED.has(entry.name)) {
          // Only ignored output without tracked descendants may be removed.
          const hasTracked = tracked.some((file) =>
            file === rel || file.startsWith(rel + "/")
          );
          if (!hasTracked) {
            candidates.push(rel);
          }
        }
        if (!SKIP_SCAN.has(entry.name)) {
          scan(full);
        }
      } else if (entry.isFile() && entry.name !== ".git") {
        latest = Math.max(latest, lstatSync(full).mtimeMs);
      }
    }
  }
  scan(path);
  let ignored = new Set();
  if (candidates.length) {
    try {
      ignored = new Set(
        git(
          path,
          ["check-ignore", "-z", "--stdin"],
          candidates.map((rel) => rel + "/\0").join(""),
        )
          .split("\0").filter(Boolean).map((rel) => rel.slice(0, -1)),
      );
    } catch (error) {
      if (error.status !== 1) {
        throw error;
      }
    }
  }
  if (!Number.isFinite(latest)) {
    throw new Error("Could not determine activity time.");
  }
  const ageDays = Math.max(0, (Date.now() - latest) / DAY);
  if (options.policy !== "settled" && ageDays < options.days) {
    blockers.push(`activity within ${options.days} days`);
  }
  const activity = settlement?.label ??
    `observed activity ${ageDays.toFixed(1)}d ago`;
  return {
    ...tree,
    candidates: candidates.filter((rel) => ignored.has(rel)).sort(),
    blockers,
    ageDays,
    activity,
  };
}

export function processDirectories() {
  // Check all visible working directories without traversing node_modules.
  const output = run("lsof", ["-nP", "-d", "cwd", "-Fn"]);
  const paths = output.split("\n").filter((line) => line.startsWith("n/")).map((
    line,
  ) => line.slice(1));
  if (paths.length === 0) {
    throw new Error("lsof returned no working directories.");
  }
  return paths.map((path) => {
    try {
      return realpathSync(path);
    } catch {
      return path;
    }
  });
}

function freeBytes(path) {
  const stats = statfsSync(path);
  return stats.bavail * stats.bsize;
}

function formatBytes(bytes) {
  const magnitude = Math.abs(bytes);
  for (
    const [unit, size] of [["GiB", 1024 ** 3], ["MiB", 1024 ** 2], [
      "KiB",
      1024,
    ]]
  ) {
    if (magnitude >= size) {
      return `${(bytes / size).toFixed(2)} ${unit}`;
    }
  }
  return `${bytes} B`;
}

export function formatFreeSpace(before, after) {
  const difference = after - before;
  if (difference > 0) {
    return `${formatBytes(after)} available; ${
      formatBytes(difference)
    } more than at start`;
  }
  if (difference < 0) {
    return `${formatBytes(after)} available; ${
      formatBytes(-difference)
    } less than at start`;
  }
  return `${formatBytes(after)} available; unchanged since start`;
}

export function removeMeasuredDirectory(target, options = {}) {
  if (!directory(target) || realpathSync(target) !== target) {
    throw new Error(`Expected a real directory: ${target}`);
  }
  const totals = { reportedBytes: 0, files: 0, directories: 0, symlinks: 0 };
  const seenHardlinks = options.seenHardlinks ?? new Set();
  let lastProgress = Date.now();

  function remove(path) {
    const stats = lstatSync(path);
    let kind;
    if (stats.isDirectory()) {
      for (const entry of readdirSync(path)) {
        remove(join(path, entry));
      }
      rmdirSync(path);
      kind = "directories";
    } else {
      unlinkSync(path);
      kind = stats.isSymbolicLink() ? "symlinks" : "files";
    }
    // Count only successful removals. Track hardlinks without retaining every inode.
    const inode = `${stats.dev}:${stats.ino}`;
    let bytes = 0;
    if (!seenHardlinks.has(inode)) {
      bytes = typeof stats.blocks === "number"
        ? stats.blocks * 512
        : stats.size;
      if (!stats.isDirectory() && stats.nlink > 1) {
        seenHardlinks.add(inode);
      }
    }
    totals.reportedBytes += bytes;
    totals[kind]++;
    options.onDeleted?.({ target, path, kind, reportedBytes: bytes });
    if (Date.now() - lastProgress >= 2000) {
      options.onProgress?.(target, { ...totals });
      lastProgress = Date.now();
    }
  }
  remove(target);
  return totals;
}

export function trimTree(tree, options, getCwds = processDirectories) {
  const current = inspect(tree, options, getCwds());
  if (current.blockers.length) {
    throw new Error(`${tree.name}: ${current.blockers.join("; ")}`);
  }
  for (const [index, rel] of current.candidates.entries()) {
    const target = join(tree.path, rel);
    if (
      !directory(target) || realpathSync(target) !== target ||
      !within(tree.path, target)
    ) {
      throw new Error(`Directory changed during cleanup: ${target}`);
    }
    options.log?.(
      `[${index + 1}/${current.candidates.length}] Removing ${target}`,
    );
    const totals = removeMeasuredDirectory(target, options);
    options.onRemoved?.(target, totals);
  }
  return current.candidates;
}

export function saveReport(directory, report) {
  mkdirSync(directory, { recursive: true, mode: 0o700 });
  const name = `${report.startedAt.replaceAll(":", "-")}-${randomUUID()}.json`;
  const path = join(directory, name);
  writeFileSync(path, JSON.stringify(report, null, 2) + "\n", {
    flag: "wx",
    mode: 0o600,
  });
  return path;
}

export function scanWorktrees(options, log = console.log) {
  options.root = realpathSync(options.root);
  const trees = discover(options.root);
  for (const name of options.worktree) {
    if (!trees.some((tree) => tree.name === name)) {
      throw new Error(`Worktree not found: ${name}`);
    }
  }
  const selected = trees.filter((tree) =>
    !options.worktree.length || options.worktree.includes(tree.name)
  );
  const cwds = processDirectories();
  const threads = options.policy === "settled"
    ? loadThreadState(options.db)
    : undefined;
  return selected.map((tree, index) => {
    try {
      const inspection = inspect(tree, options, cwds, threads);
      let status = "eligible";
      if (inspection.blockers.length) {
        status = `SKIP: ${inspection.blockers.join("; ")}`;
      } else if (!inspection.candidates.length) {
        status = "nothing to trim";
      }
      log(
        `[${
          index + 1
        }/${selected.length}] ${tree.name}: ${status}; ${inspection.activity}; ${inspection.candidates.length} directories`,
      );
      return inspection;
    } catch (error) {
      log(
        `[${
          index + 1
        }/${selected.length}] ${tree.name}: ERROR: ${error.message}`,
      );
      return {
        ...tree,
        error: error.message,
        blockers: [error.message],
        candidates: [],
      };
    }
  });
}

export function cleanup(options, inventory = scanWorktrees(options)) {
  const candidates = inventory.filter((tree) =>
    !tree.blockers.length && tree.candidates.length &&
    (!options.worktree.length || options.worktree.includes(tree.name))
  );
  const report = {
    version: 2,
    startedAt: new Date().toISOString(),
    root: options.root,
    policy: options.policy,
    days: options.days,
    eligibleWorktrees: candidates.length,
    reportedRemovedBytes: 0,
    files: 0,
    directories: 0,
    symlinks: 0,
    removedDirectories: [],
    trimmedWorktrees: [],
    directoryResults: [],
    errors: [],
  };
  const before = freeBytes(options.root);
  console.log(
    `${
      options.apply ? "APPLY" : "DRY RUN"
    }: ${candidates.length} eligible worktrees; free space ${
      formatBytes(before)
    }.`,
  );
  if (!options.apply) {
    if (options.command === "trim") {
      for (const tree of candidates) {
        for (const rel of tree.candidates) {
          console.log(`  ${tree.name}/${rel}`);
        }
      }
    }
    console.log(
      "Nothing deleted. Measurement is automatic during deletion. Run cleanup-worktrees for the menu.",
    );
    if (inventory.some((tree) => tree.error)) {
      process.exitCode = 1;
    }
    return report;
  }
  // An inventory error makes an apply incomplete. Resolve it before starting a batch.
  if (inventory.some((tree) => tree.error)) {
    throw new Error(
      "Inventory contains errors; no cleanup performed. Select valid worktrees explicitly.",
    );
  }
  const results = new Map();
  const seenHardlinks = new Set();
  function progress() {
    console.log(
      `Progress: ${report.files} files, ${report.directories} directories, ${report.symlinks} symlinks removed; ${
        formatBytes(report.reportedRemovedBytes)
      } of deleted file blocks counted (may be shared); disk: ${
        formatFreeSpace(before, freeBytes(options.root))
      }.`,
    );
  }
  for (const [index, tree] of candidates.entries()) {
    console.log(`Worktree ${index + 1}/${candidates.length}: ${tree.name}`);
    try {
      trimTree(tree, {
        ...options,
        seenHardlinks,
        log: console.log,
        onDeleted: (entry) => {
          report.reportedRemovedBytes += entry.reportedBytes;
          report[entry.kind]++;
          if (!report.trimmedWorktrees.includes(tree.name)) {
            report.trimmedWorktrees.push(tree.name);
          }
          if (!results.has(entry.target)) {
            const result = {
              path: entry.target,
              reportedBytes: 0,
              status: "partial",
            };
            results.set(entry.target, result);
            report.directoryResults.push(result);
          }
          results.get(entry.target).reportedBytes += entry.reportedBytes;
        },
        onProgress: progress,
        onRemoved: (path, totals) => {
          report.removedDirectories.push(path);
          results.get(path).status = "removed";
          console.log(
            `Removed ${path}: ${
              formatBytes(totals.reportedBytes)
            } of file blocks counted (may be shared).`,
          );
          progress();
        },
      });
    } catch (error) {
      report.errors.push({ worktree: tree.name, message: error.message });
      console.error(`${tree.name}: ERROR: ${error.message}`);
      break;
    }
  }
  const after = freeBytes(options.root);
  report.freeSpace = {
    beforeBytes: before,
    afterBytes: after,
    increaseBytes: after - before,
  };
  report.completedAt = new Date().toISOString();
  console.log(
    `Finished: ${report.removedDirectories.length} generated directories trimmed in ${report.trimmedWorktrees.length} worktrees; ${
      formatBytes(report.reportedRemovedBytes)
    } of deleted file blocks counted (may be shared).`,
  );
  console.log(
    `Free space: ${formatBytes(before)} before; ${
      formatFreeSpace(before, after)
    }.`,
  );
  console.log(
    "Reported sizes can include APFS shared blocks. Other disk activity can affect the free-space change.",
  );
  console.log(`Saved report: ${saveReport(options.reportDir, report)}`);
  if (report.errors.length) {
    process.exitCode = 1;
  }
  return report;
}

function expandHome(path) {
  if (path === "~") {
    return homedir();
  }
  return path.startsWith("~/") ? join(homedir(), path.slice(2)) : resolve(path);
}

export function findLocations() {
  const bases = new Set([homedir(), process.cwd()]);
  const code = join(homedir(), "code");
  if (directory(code)) {
    for (const group of readdirSync(code)) {
      const path = join(code, group);
      if (!directory(path)) {
        continue;
      }
      bases.add(path);
      for (const name of readdirSync(path)) {
        const child = join(path, name);
        if (directory(child) && !name.startsWith(".")) {
          bases.add(child);
        }
      }
    }
  }
  for (const name of ["config.toml", "local.toml"]) {
    const path = join(homedir(), ".config/waystone", name);
    if (existsSync(path)) {
      const config = Bun.TOML.parse(readFileSync(path, "utf8"));
      for (const root of config.roots ?? []) {
        if (typeof root.path === "string") {
          bases.add(expandHome(root.path));
        }
      }
    }
  }
  const locations = [];
  if (directory(DEFAULT_ROOT)) {
    locations.push({
      name: "T3 worktrees · settled for at least 1 day",
      value: DEFAULT_ROOT,
    });
  }
  const seen = new Set();
  for (const base of bases) {
    const path = join(base, ".waystone/worktrees");
    if (directory(path) && !seen.has(realpathSync(path))) {
      seen.add(realpathSync(path));
      locations.push({ name: `Waystone · ${path}`, value: path });
    }
  }
  return locations;
}

export async function interactivePlan(
  ui = { checkbox, confirm, input, select },
  dependencies = {},
) {
  const log = dependencies.log ?? console.log;
  const locations = dependencies.locations ?? findLocations();
  const scan = dependencies.scan ?? scanWorktrees;
  const action = await ui.select({
    message: "Worktree cleanup",
    choices: [
      { name: "Review and clean up worktrees", value: "trim" },
      { name: "Show inventory", value: "inventory" },
      { name: "Exit", value: "exit" },
    ],
  });
  if (action === "exit") {
    return null;
  }
  let root = await ui.select({
    message: "Which worktree location?",
    choices: [
      ...locations,
      { name: "Another folder...", value: "custom" },
    ],
  });
  if (root === "custom") {
    root = expandHome(
      await ui.input({
        message: "Folder containing project/worktree folders",
        validate: (value) =>
          directory(expandHome(value)) || "Enter an existing directory.",
      }),
    );
  }
  const options = parseOptions([action, "--root", root]);
  const days = await ui.input({
    message: options.policy === "settled"
      ? "Minimum days since all threads settled"
      : "Minimum days since observed activity",
    default: String(options.days),
    validate: (value) =>
      /^\d+$/.test(value) && Number.isSafeInteger(Number(value)) ||
      "Enter a nonnegative whole number.",
  });
  options.days = Number(days);
  const inventory = scan(options, log);
  if (action === "inventory") {
    return { options, inventory };
  }
  const eligible = inventory.filter((tree) =>
    !tree.blockers.length && tree.candidates.length
  );
  if (!eligible.length) {
    log("No eligible generated directories to trim.");
    return null;
  }
  log(
    "Space toggles a worktree; a selects all. Source, branches, and T3 history stay in place.",
  );
  const selected = await ui.checkbox({
    message: "Select worktrees to trim",
    choices: eligible.map((tree) => ({
      name:
        `${tree.name} · ${tree.candidates.length} generated directories · ${tree.activity}`,
      value: tree.name,
    })),
    required: true,
  });
  const reviewed = inventory.filter((tree) => selected.includes(tree.name));
  for (const tree of reviewed) {
    log(`${tree.name}: ${tree.candidates.join(", ")}`);
  }
  const count = reviewed.reduce((sum, tree) => sum + tree.candidates.length, 0);
  if (
    !await ui.confirm({
      message:
        `Delete ${count} generated directories in ${selected.length} worktrees? Sizes will be counted during deletion.`,
      default: false,
    })
  ) {
    log("Cancelled. Nothing deleted.");
    return null;
  }
  options.worktree = selected;
  options.apply = true;
  return { options, inventory: reviewed };
}

export async function main(args) {
  if (args.length === 0 && process.stdin.isTTY && process.stdout.isTTY) {
    const plan = await interactivePlan();
    if (plan) {
      cleanup(plan.options, plan.inventory);
    }
    return;
  }
  const options = parseOptions(args);
  if (options.help) {
    console.log(`Usage: cleanup-worktrees [inventory|trim] [options]
Run with no arguments in a terminal for the interactive menu.
  --root PATH       Worktree parent, default ~/.t3/worktrees
  --policy POLICY   settled for T3's default root, age for other roots
  --days N          Minimum days since settlement (default 1) or activity (default 3)
  --t3-db PATH      T3 statev2.sqlite, read-only
  --worktree P/W    Select a project/worktree; repeat for more
  --exclude P/W     Protect a project/worktree; repeat for more
  --all-settled     Apply to all eligible settled worktrees
  --report-dir P    Local apply report directory
  --apply           Delete; otherwise dry-run

Measurement is always on during deletion. --measure is accepted for older commands.
Progress includes removed files, running reported size, and free-space change.
Only ignored node_modules, .turbo, .vite and dist at package roots are eligible.
Source, branches, and T3 history remain. APFS blocks may be shared.`);
    return;
  }
  cleanup(options);
}

if (
  process.argv[1] &&
  import.meta.url === pathToFileURL(resolve(process.argv[1])).href
) {
  try {
    await main(process.argv.slice(2));
  } catch (error) {
    if (error instanceof Error && error.name === "ExitPromptError") {
      console.log("Cancelled. Nothing deleted.");
    } else {
      console.error(error.message);
      process.exitCode = 1;
    }
  }
}
