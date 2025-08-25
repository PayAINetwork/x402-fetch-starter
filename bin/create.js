#!/usr/bin/env node
/* eslint-disable no-console */
import fs from "fs";
import path from "path";
import url from "url";
import { execSync } from "child_process";

const __dirname = path.dirname(url.fileURLToPath(import.meta.url));
const repoRoot = path.join(__dirname, "..");
const templateDir = path.join(repoRoot, "template");

const nameArg = process.argv[2];
const projectName = nameArg && !nameArg.startsWith("-") ? nameArg : "x402-fetch-app";
const targetDir = path.resolve(process.cwd(), projectName);

if (fs.existsSync(targetDir) && fs.readdirSync(targetDir).length) {
  console.error(`\nTarget directory '${projectName}' is not empty. Choose another name or empty it.\n`);
  process.exit(1);
}

// copy template
fs.cpSync(templateDir, targetDir, { recursive: true });

// prefer the app under src/, and ensure its package name matches the project
const appPkgPath = path.join(targetDir, "src", "package.json");
if (fs.existsSync(appPkgPath)) {
  const appPkg = JSON.parse(fs.readFileSync(appPkgPath, "utf8"));
  appPkg.name = projectName.replace(/[^a-zA-Z0-9-_./@]/g, "-");
  fs.writeFileSync(appPkgPath, JSON.stringify(appPkg, null, 2));
}

// if a root package.json exists in the template, remove it to avoid duplicates
const rootPkgPath = path.join(targetDir, "package.json");
try { fs.unlinkSync(rootPkgPath); } catch {}

// init git
try {
  execSync("git init", { stdio: "ignore", cwd: targetDir });
} catch {}

// print next steps
console.log(`
Scaffolded ${projectName}!

Next steps:
  cd ${projectName}/src
  cp .env-local .env  # then edit the values inside .env
  npm i
  npm run dev

Happy building 🏗️
`);