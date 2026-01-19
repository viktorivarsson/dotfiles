#!/usr/bin/env -S deno run --allow-read --allow-run --allow-env

import * as path from "https://deno.land/std@0.185.0/path/mod.ts";

interface Command {
	cmd: string;
	args?: string[];
}

interface Config {
	aliases: Record<string, Command[]>;
}

const CONFIG_PATH = path.join(Deno.env.get("HOME")!, ".config/x/config.json");
const PROJECT_CONFIG_FILE = ".xrc.json";

const PACKAGE_MANAGER_LOCKFILES = [
	{ name: "bun", files: ["bun.lock", "bun.lockb"] },
	{ name: "pnpm", files: ["pnpm-lock.yaml"] },
	{ name: "yarn", files: ["yarn.lock"] },
	{ name: "npm", files: ["package-lock.json"] },
];

const fileExists = async (filePath: string): Promise<boolean> => {
	try {
		await Deno.stat(filePath);
		return true;
	} catch {
		return false;
	}
};

const loadJsonFile = async (
	filePath: string,
): Promise<Record<string, unknown> | undefined> => {
	if (!(await fileExists(filePath))) {
		return undefined;
	}

	try {
		const content = await Deno.readTextFile(filePath);
		return JSON.parse(content) as Record<string, unknown>;
	} catch (error) {
		throw new Error(`Failed to parse ${filePath}: ${error}`);
	}
};

const detectPackageManager = async (
	wd: string,
): Promise<string | undefined> => {
	for (const { name, files } of PACKAGE_MANAGER_LOCKFILES) {
		for (const file of files) {
			if (await fileExists(path.join(wd, file))) {
				return name;
			}
		}
	}
	return undefined;
};

const walkUpForFile = async (
	wd: string,
	filename: string,
): Promise<string | undefined> => {
	const filePath = path.join(wd, filename);

	if (await fileExists(filePath)) {
		return wd;
	}

	const parentDir = path.dirname(wd);
	if (parentDir === wd) {
		return undefined;
	}

	return walkUpForFile(parentDir, filename);
};

const getProjectRoot = async (wd: string): Promise<string | undefined> => {
	return await walkUpForFile(wd, "package.json");
};

const loadConfig = async (): Promise<Config> => {
	const globalConfig = await loadJsonFile(CONFIG_PATH);
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

const loadProjectConfig = async (
	projectRoot: string,
): Promise<Config | undefined> => {
	const projectConfigPath = path.join(projectRoot, PROJECT_CONFIG_FILE);
	const projectConfig = await loadJsonFile(projectConfigPath);

	if (!projectConfig || !projectConfig.aliases) {
		return undefined;
	}

	return {
		aliases: projectConfig.aliases as Record<string, Command[]>,
	};
};

const getMergedAliases = async (
	projectRoot: string | undefined,
): Promise<Record<string, Command[]>> => {
	const globalConfig = await loadConfig();
	let merged = { ...globalConfig.aliases };

	if (projectRoot) {
		const projectConfig = await loadProjectConfig(projectRoot);
		if (projectConfig) {
			merged = { ...projectConfig.aliases, ...merged };
		}
	}

	return merged;
};

const getPackageJsonScripts = async (
	projectRoot: string,
): Promise<string[] | undefined> => {
	const packageJsonPath = path.join(projectRoot, "package.json");
	const packageJson = await loadJsonFile(packageJsonPath);

	if (!packageJson || !packageJson.scripts) {
		return undefined;
	}

	return Object.keys(packageJson.scripts as Record<string, string>);
};

const resolveCommand = async (
	command: string,
	args: string[],
	projectRoot: string,
	packageManager: string,
	aliases: Record<string, Command[]>,
): Promise<string[] | undefined> => {
	const aliasCommands = aliases[command];

	if (aliasCommands) {
		const scripts = await getPackageJsonScripts(projectRoot);

		for (let i = 0; i < aliasCommands.length; i++) {
			const aliasCmd = aliasCommands[i];
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

	const scripts = await getPackageJsonScripts(projectRoot);
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
	// deno-lint-ignore no-deprecated-deno-api
	const process = Deno.run({
		cmd: commandArgs,
		cwd: projectRoot,
		stdout: "inherit",
		stderr: "inherit",
		stdin: "inherit",
	});

	const status = await process.status();
	process.close();
	return status.code;
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
		for (const script of scripts) {
			console.log(`  ${script}`);
		}
	}
};

const main = async () => {
	const cwd = Deno.cwd();
	const projectRoot = await getProjectRoot(cwd);

	if (!projectRoot) {
		console.error(
			"No package.json found in current directory or parent directories",
		);
		Deno.exit(1);
	}

	const packageManager = await detectPackageManager(projectRoot);
	if (!packageManager) {
		console.error("No package manager lockfile found");
		Deno.exit(1);
	}

	const aliases = await getMergedAliases(projectRoot);
	const args = Deno.args;

	if (args.length === 0) {
		const scripts = await getPackageJsonScripts(projectRoot);
		listCommands(aliases, scripts);
		Deno.exit(0);
	}

	const [command, ...restArgs] = args;
	const commandArgs = await resolveCommand(
		command,
		restArgs,
		projectRoot,
		packageManager,
		aliases,
	);

	if (!commandArgs) {
		console.error(`Alias '${command}' has no valid fallback commands`);
		Deno.exit(1);
	}

	console.log(`Running: ${commandArgs.join(" ")}`);
	const exitCode = await runCommand(commandArgs, projectRoot);
	Deno.exit(exitCode);
};

main();
