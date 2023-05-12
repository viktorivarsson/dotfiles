import * as path from "https://deno.land/std@0.185.0/path/mod.ts";

const getFileInfo = async (filename: string) => {
  try {
    const fileInfo = await Deno.stat(filename);
    return fileInfo;
  } catch {
    return undefined;
  }
};

const getPackageJsonContent = async (wd: string) => {
  const filename = path.join(wd, "package.json");
  const stat = await getFileInfo(filename);

  if (stat?.isFile) {
    const content = await Deno.readTextFile(filename);
    try {
      return JSON.parse(content) as Record<string, unknown>;
    } catch {
      throw new Error(`Invalid json file at ${filename}`);
    }
  }

  return undefined;
};

const walkUpForPackageJson = async (
  wd: string,
): Promise<[wd: string, json: Record<string, unknown>] | undefined> => {
  const packageJson = await getPackageJsonContent(wd);

  if (packageJson) {
    return [wd, packageJson];
  }

  if (path.dirname(wd) === wd) {
    return undefined;
  }

  return walkUpForPackageJson(path.dirname(wd));
};

const getClosestPackageJsonScripts = async (): Promise<
  [wd: string, scripts: string[]]
> => {
  const cwd = Deno.cwd();
  const packageInfo = await walkUpForPackageJson(cwd);

  const wd = packageInfo?.[0];
  const packageJson = packageInfo?.[1];

  if (!wd || !packageJson) {
    throw new Error("No package.json found");
  }

  const scripts = packageJson.scripts;

  if (!scripts) {
    throw new Error("No scripts found in closest package.json");
  }

  return [wd, Object.keys(scripts)];
};

const [wd, scripts] = await getClosestPackageJsonScripts();

console.log(
  `Available scripts: \n${
    scripts.map((s, i) => `[${i + 1}] - ${s}`).join("\n")
  }`,
);

const scriptNumber = prompt("Which script do you want to run?");

if (scriptNumber === null) {
  console.log("No script selected");
  Deno.exit(0);
}

const script = scripts[Number(scriptNumber) - 1];

if (!script) {
  console.log("Invalid script selected");
  Deno.exit(1);
}

const cmd = new Deno.Command("npm", {
  cwd: wd,
  args: ["run", script],
});

cmd.spawn();
