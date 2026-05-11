#!/usr/bin/env node
"use strict";

const { execSync } = require("child_process");
const { existsSync } = require("fs");
const path = require("path");

// Only run in project context (not global install)
const projectRoot = process.env.INIT_CWD || process.cwd();
const ctxDir = path.join(projectRoot, ".ctx");

if (existsSync(ctxDir)) {
  console.log("graphbrain: .ctx/ already exists — skipping auto-init.");
  process.exit(0);
}

// Check Python 3 availability before attempting init
try {
  execSync("python3 --version", { stdio: "pipe" });
} catch {
  console.warn(
    "graphbrain: Python 3.8+ is required but not found.\n" +
      "  Install from https://python.org then run: npx graphbrain init"
  );
  process.exit(0);
}

console.log("graphbrain: Initializing brain...");

try {
  const packageDir = path.resolve(__dirname, "..");
  execSync(`bash "${path.join(packageDir, "brain-init.sh")}"`, {
    cwd: projectRoot,
    stdio: "inherit",
    env: { ...process.env, AGENTCTX_PACKAGE_DIR: packageDir },
  });
  console.log("graphbrain: Brain initialized successfully.");
} catch (e) {
  console.warn(
    "graphbrain: Auto-init failed. Run `npx graphbrain init` manually."
  );
}
