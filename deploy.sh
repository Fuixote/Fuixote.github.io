#!/bin/bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$REPO_DIR"

load_nvm() {
    export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
    if [ -s "$NVM_DIR/nvm.sh" ]; then
        # Load nvm in non-interactive shells so deploy uses the repo's Node version.
        . "$NVM_DIR/nvm.sh"
        return 0
    fi
    return 1
}

ensure_node() {
    if load_nvm; then
        nvm use >/dev/null
    fi

    if ! command -v node >/dev/null 2>&1; then
        echo "Node.js is required but was not found."
        exit 1
    fi

    local major_version
    major_version="$(node -p "process.versions.node.split('.')[0]")"
    if [ "$major_version" -lt 20 ]; then
        echo "Wrangler requires Node.js v20 or newer. Current version: $(node -v)"
        echo "Tip: install nvm and run 'nvm install', or switch to a Node 20+ shell before deploying."
        exit 1
    fi
}

ensure_node

echo "Using Node $(node -v)"
echo "Deploying production to Cloudflare Pages (branch: main)..."
npx wrangler pages deploy . --project-name fuixote-web --branch main
echo "Done."
