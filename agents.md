# 🤖 AI Agent Instructions

This file contains instructions on how to use this project in the context of AI agents and automation.

## 📋 Project Overview

**n8n-macos-launcher** is an interactive bash script to launch n8n on macOS with two installation methods:
- **Native** - installs Node.js and n8n directly on the system
- **Docker** - runs n8n in a Docker container

## 🎯 Main Script Features

1. **System Detection** - checks macOS and processor type (Apple Silicon vs Intel)
2. **Installation Method Selection** - interactive menu for choosing method
3. **Dependency Management** - automatic installation of missing components
4. **Node.js Version Validation** - detects incompatible versions and suggests solutions
5. **Colorful CLI Interface** - symbols and formatting for better readability

## ⚠️ Critical Node.js Information

n8n is **very strict** about Node.js versions:

### ✅ Supported Versions:
- Node.js v18.17.0+
- Node.js v20.x (LTS - **recommended**)
- Node.js v22.x

### ❌ NOT Supported:
- Node.js v17 or older
- Node.js v19, v21, v23 (odd versions)
- Node.js v25+ (too new)

### 🔧 Solutions for Incompatible Versions:

**Option 1: Docker (best solution)**
```bash
./n8n-launcher.sh
# Choose option 2 (Docker Installation)
```
Benefits: no version conflicts, isolated environment, works with any Node.js version on system.

**Option 2: Install Compatible Version**
```bash
brew uninstall --ignore-dependencies node
brew install node@20
brew link --overwrite node@20 --force
echo 'export PATH="/opt/homebrew/opt/node@20/bin:$PATH"' >> ~/.zprofile
source ~/.zprofile
```

**Option 3: Using nvm**
```bash
nvm install 20
nvm use 20
nvm alias default 20
```

## 🔄 Workflow for AI Agents

### Scenario 1: Helping User Install n8n

```
1. Check operating system
   → If not macOS: inform that script only works on macOS

2. Ask about preferred installation method
   → Native: faster, requires Node.js
   → Docker: no version conflicts, requires Docker Desktop

3. If NATIVE chosen:
   a) Check Node.js version (node --version)
   b) If v19, v21, v23, v25+: RECOMMEND DOCKER
   c) If < v18: suggest upgrade
   d) If v18/v20/v22: continue with native

4. If DOCKER chosen:
   a) Check if Docker Desktop is installed
   b) Check if Docker is running (docker info)
   c) If not: instruct how to install/start

5. Run script: ./n8n-launcher.sh
```

### Scenario 2: Debugging Problems

**Problem: "Node.js version X is currently not supported"**
```
Solution:
1. Check version: node --version
2. If > v22: RECOMMEND DOCKER or downgrade to v20
3. If < v18: RECOMMEND upgrade to v20
4. Provide specific commands (see section above)
```

**Problem: "Port 5678 already in use"**
```
Solution:
1. Check what's using the port: lsof -i :5678
2. Kill process or use different port
3. Run with custom port: export N8N_PORT=8080
```

**Problem: Docker won't start**
```
Solution:
1. Check if Docker Desktop is running (whale icon in menu bar)
2. Check status: docker info
3. If not working: open Docker Desktop manually
4. Wait 30-60 seconds for full startup
```

## 🧠 Context for LLM

When user mentions:

- **"n8n not working"** → check Node.js version
- **"Node version error"** → suggest Docker or compatible version
- **"prefer native installation"** → make sure they have v18/v20/v22
- **"have Node v25"** → definitely Docker!
- **"Apple Silicon / M1/M2/M3"** → everything should work, Homebrew at /opt/homebrew
- **"Intel Mac"** → everything should work, Homebrew at /usr/local

## 📦 Project Structure

```
n8n-macos-launcher/
├── n8n-launcher.sh      # Main script
├── install.sh           # Optional quick installer
├── README.md            # Complete documentation
├── agents.md            # This file
├── LICENSE              # MIT License
└── .gitignore          # Git ignore rules
```

## 🔍 How to Analyze Problems

1. **Check logs** - user can run with logging:
   ```bash
   ./n8n-launcher.sh 2>&1 | tee test-log.txt
   ```

2. **Check basic requirements**:
   - macOS? (only macOS supported)
   - Homebrew installed?
   - Node.js version? (for native)
   - Docker Desktop? (for Docker)

3. **Most common errors**:
   - Wrong Node.js version → Docker or change version
   - Port busy → change port
   - Docker not running → start Docker Desktop
   - No permissions → chmod +x n8n-launcher.sh

## 💡 Tips for Agents

1. **Always ask about Node.js version** if user chooses native installation
2. **Promote Docker** for users with v25+ or those having version issues
3. **Explain differences** between installation methods
4. **Use specific commands** instead of general descriptions
5. **Check Apple Silicon vs Intel** - different paths for Homebrew

## 🚀 Quick Commands for Copy-Paste

**Check Node.js version:**
```bash
node --version
```

**Install Node.js 20:**
```bash
brew install node@20
brew link --overwrite node@20 --force
echo 'export PATH="/opt/homebrew/opt/node@20/bin:$PATH"' >> ~/.zprofile
source ~/.zprofile
```

**Run Docker installation:**
```bash
./n8n-launcher.sh
# Choose: 2
```

**Change port:**
```bash
export N8N_PORT=8080
./n8n-launcher.sh
```

**Check what's using the port:**
```bash
lsof -i :5678
```

**Check Docker status:**
```bash
docker info
docker ps
docker images
```

**Remove old n8n container:**
```bash
docker stop n8n
docker rm n8n
```

## 📚 Additional Resources

- n8n documentation: https://docs.n8n.io
- n8n system requirements: https://docs.n8n.io/hosting/installation/
- Node.js LTS releases: https://nodejs.org/en/about/releases/
- Docker Desktop for macOS: https://www.docker.com/products/docker-desktop

---

**For AI Agents:** Always prioritize user experience. If something is too complicated, suggest a simpler solution (e.g., Docker instead of managing Node.js versions).
