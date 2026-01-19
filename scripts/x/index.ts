#!/usr/bin/env bun

import path from "node:path";
import { existsSync, readFileSync } from "node:fs";
import { spawn } from "node:child_process";
import { search } from "@inquirer/prompts";

const runPrompt = async <T>(fn: () => Promise<T>): Promise<T> => {
  try {
    return await fn();
  } catch (error) {
    if (error instanceof Error && error.name === "ExitPromptError") {
      process.exit(0);
    }
    throw error;
  }
};

interface Command {
  cmd: string;
  args?: string[];
}

interface Config {
  aliases: Record<string, Command[]>;
}

const CONFIG_PATH = path.join(process.env.HOME || "", ".config/x/config.json");
const PROJECT_CONFIG_FILE = ".xrc.json";

const PACKAGE_MANAGER_LOCKFILES = [
  { name: "bun", files: ["bun.lock", "bun.lockb"] },
  { name: "pnpm", files: ["pnpm-lock.yaml"] },
  { name: "yarn", files: ["yarn.lock"] },
  { name: "npm", files: ["package-lock.json"] },
];

const MAX_SEARCH_DEPTH = 5;

const fileExists = (filePath: string): boolean => {
  return existsSync(filePath);
};

const loadJsonFile = (
  filePath: string,
): Record<string, unknown> | undefined => {
  if (!fileExists(filePath)) {
    return undefined;
  }

  try {
    const content = readFileSync(filePath, "utf-8");
    return JSON.parse(content) as Record<string, unknown>;
  } catch (error) {
    throw new Error(`Failed to parse ${filePath}: ${String(error)}`);
  }
};

const detectClosestPackageManager = (wd: string): string | undefined => {
  let currentDir = wd;
  let depth = 0;

  while (depth < MAX_SEARCH_DEPTH) {
    for (const { name, files } of PACKAGE_MANAGER_LOCKFILES) {
      for (const file of files) {
        if (fileExists(path.join(currentDir, file))) {
          return name;
        }
      }
    }

    const parentDir = path.dirname(currentDir);
    if (parentDir === currentDir) {
      break;
    }

    currentDir = parentDir;
    depth++;
  }

  return undefined;
};

const walkUpForFile = (wd: string, filename: string): string | undefined => {
  const filePath = path.join(wd, filename);

  if (fileExists(filePath)) {
    return wd;
  }

  const parentDir = path.dirname(wd);
  if (parentDir === wd) {
    return undefined;
  }

  return walkUpForFile(parentDir, filename);
};

const getProjectRoot = (wd: string): string | undefined => {
  return walkUpForFile(wd, "package.json");
};

const loadConfig = (): Config => {
  const globalConfig = loadJsonFile(CONFIG_PATH);
  const defaultConfig: Config = { aliases: {} };

  return {
    ...defaultConfig,
    ...globalConfig,
    aliases: {
      ...defaultConfig.aliases,
      ...((globalConfig?.aliases as Record<string, Command[]>) || {}),
    },
  };
};

const loadProjectConfig = (projectRoot: string): Config | undefined => {
  const projectConfigPath = path.join(projectRoot, PROJECT_CONFIG_FILE);
  const projectConfig = loadJsonFile(projectConfigPath);

  if (!projectConfig || !projectConfig.aliases) {
    return undefined;
  }

  return {
    aliases: projectConfig.aliases as Record<string, Command[]>,
  };
};

const getMergedAliases = (
  projectRoot: string | undefined,
): Record<string, Command[]> => {
  const globalConfig = loadConfig();
  let merged = { ...globalConfig.aliases };

  if (projectRoot) {
    const projectConfig = loadProjectConfig(projectRoot);
    if (projectConfig) {
      merged = { ...projectConfig.aliases, ...merged };
    }
  }

  return merged;
};

const getPackageJsonScripts = (projectRoot: string): string[] | undefined => {
  const packageJsonPath = path.join(projectRoot, "package.json");
  const packageJson = loadJsonFile(packageJsonPath);

  if (!packageJson || !packageJson.scripts) {
    return undefined;
  }

  return Object.keys(packageJson.scripts as Record<string, string>);
};

const resolveCommand = (
  command: string,
  args: string[],
  projectRoot: string,
  packageManager: string,
  aliases: Record<string, Command[]>,
): string[] | undefined => {
  const aliasCommands = aliases[command];

  if (aliasCommands) {
    const scripts = getPackageJsonScripts(projectRoot);

    for (let i = 0; i < aliasCommands.length; i++) {
      const aliasCmd = aliasCommands[i]!;
      const fullArgs = [...(aliasCmd.args || []), ...args];
      const isLast = i === aliasCommands.length - 1;

      if (scripts?.includes(aliasCmd.cmd)) {
        return [packageManager, "run", aliasCmd.cmd, ...fullArgs];
      } else if (isLast) {
        return [packageManager, aliasCmd.cmd, ...fullArgs];
      }
    }
    return undefined;
  }

  const scripts = getPackageJsonScripts(projectRoot);
  if (scripts?.includes(command)) {
    return [packageManager, "run", command, ...args];
  } else {
    return [packageManager, command, ...args];
  }
};

const runCommand = async (
  commandArgs: string[],
  projectRoot: string,
): Promise<number> => {
  const command = commandArgs[0];
  if (!command) {
    console.error("No command specified");
    return 1;
  }

  const child = spawn(command, commandArgs.slice(1), {
    cwd: projectRoot,
    stdio: "inherit",
  });

  return new Promise((resolve) => {
    child.on("close", (code: number | null) => {
      resolve(code ?? 1);
    });
  });
};

const listCommands = (
  aliases: Record<string, Command[]>,
  scripts: string[] | undefined,
): void => {
  console.log("\n\x1b[1;36mAliases:\x1b[0m");
  for (const [alias, commands] of Object.entries(aliases)) {
    const commandList = commands
      .map((c) => {
        let str = c.cmd;
        if (c.args?.length) {
          str += ` ${c.args.join(" ")}`;
        }
        return str;
      })
      .join(" → ");
    console.log(`  ${alias.padEnd(12)} → ${commandList}`);
  }

  if (scripts && scripts.length > 0) {
    console.log("\n\x1b[1;36mPackage scripts:\x1b[0m");
    const sortedScripts = [...scripts].sort();
    for (const script of sortedScripts) {
      console.log(`  ${script}`);
    }
  }
};

const interactiveSelect = async (
  scripts: string[] | undefined,
): Promise<string | undefined> => {
  const choices: Array<{ name: string; value: string }> = [];

  if (scripts && scripts.length > 0) {
    const sortedScripts = [...scripts].sort();
    for (const script of sortedScripts) {
      choices.push({ name: script, value: script });
    }
  }

  if (choices.length === 0) {
    console.log("No scripts available");
    return undefined;
  }

  return await runPrompt(() =>
    search({
      message: "Select a script to run:",
      source: (term) =>
        term ? choices.filter((choice) => choice.name.includes(term)) : choices,
    })
  );
};

const main = async () => {
  const cwd = process.cwd();
  const projectRoot = getProjectRoot(cwd);

  if (!projectRoot) {
    console.error(
      "No package.json found in current directory or parent directories",
    );
    process.exit(1);
  }

  const packageManager = detectClosestPackageManager(cwd);
  if (!packageManager) {
    console.error("No package manager lockfile found");
    process.exit(1);
  }

  const aliases = getMergedAliases(projectRoot);
  const args = process.argv.slice(2);

  if (args.length === 0) {
    const scripts = getPackageJsonScripts(projectRoot);
    const selected = await interactiveSelect(scripts);
    if (!selected) {
      process.exit(0);
    }
    const commandArgs = resolveCommand(
      selected,
      [],
      projectRoot,
      packageManager,
      aliases,
    );
    if (!commandArgs) {
      console.error(`Command '${selected}' has no valid fallback commands`);
      process.exit(1);
    }
    console.log(`Running: ${commandArgs.join(" ")}`);
    const exitCode = await runCommand(commandArgs, projectRoot);
    process.exit(exitCode);
  }

  if (
    args.length === 1 &&
    (args[0] === "-i" || args[0] === "-h" || args[0] === "h")
  ) {
    const scripts = getPackageJsonScripts(projectRoot);
    if (args[0] === "-i") {
      const selected = await interactiveSelect(scripts);
      if (!selected) {
        process.exit(0);
      }
      const commandArgs = resolveCommand(
        selected,
        [],
        projectRoot,
        packageManager,
        aliases,
      );
      if (!commandArgs) {
        console.error(
          `Command '${selected}' has no valid fallback commands`,
        );
        process.exit(1);
      }
      console.log(`Running: ${commandArgs.join(" ")}`);
      const exitCode = await runCommand(commandArgs, projectRoot);
      process.exit(exitCode);
    }
    listCommands(aliases, scripts);
    process.exit(0);
  }

  const command = args[0];
  if (!command) {
    console.error("No command specified");
    process.exit(1);
  }
  const restArgs = args.slice(1);
  const commandArgs = resolveCommand(
    command,
    restArgs,
    projectRoot,
    packageManager,
    aliases,
  );

  if (!commandArgs) {
    console.error(`Alias '${command}' has no valid fallback commands`);
    process.exit(1);
  }

  console.log(`Running: ${commandArgs.join(" ")}`);
  const exitCode = await runCommand(commandArgs, projectRoot);
  process.exit(exitCode);
};

main();
