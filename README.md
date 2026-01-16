# 🚀 n8n Launcher for macOS

Interactive bash script to launch n8n on macOS with a user-friendly CLI interface.

![macOS](https://img.shields.io/badge/macOS-Compatible-blue)
![Apple Silicon](https://img.shields.io/badge/Apple%20Silicon-M1%2FM2%2FM3-orange)
![License](https://img.shields.io/badge/license-MIT-green)

## ⚡ Quick Install

Run this command in your macOS Terminal:

```bash
curl -fsSL https://raw.githubusercontent.com/blazejkapala/n8n-macos-launcher/main/n8n-launcher.sh | bash
```

That's it! The script will guide you through everything else.

## ✨ Features

- 🎯 **Choose Your Installation Method**: Native or Docker
- 🔄 **Automatic Update Checking**: Detects new n8n versions on every run
- 🎨 Colorful CLI interface with symbols (✓, ✗, ➜, ★)
- ✅ Automatic dependency checking (Homebrew, Node.js, n8n, Docker)
- 📦 Interactive installation of missing components
- 🔧 Port configuration and auto-browser opening
- 🍎 Full support for Apple Silicon (M1/M2/M3)
- 🐳 Docker support for isolated environments
- 🛡️ Safe error handling and interruption support (Ctrl+C)

## 🎯 Installation Methods

The script offers **two installation methods**:

| Method | Pros | Cons |
|--------|------|------|
| **🖥️ Native** | Faster startup, better macOS integration | Requires Node.js v18/v20/v22 |
| **🐳 Docker** | No version conflicts, isolated environment | Requires Docker Desktop |

💡 **Tip:** If you have Node.js version issues, choose Docker!

## 📖 How It Works

The script automatically:

1. ✓ Checks system (macOS, processor type)
2. ✓ Asks you to choose installation method (Native or Docker)
3. ✓ Detects/installs dependencies
4. ✓ Checks for n8n updates and offers to upgrade
5. ✓ Configures port and launches n8n

After launch, n8n will be available at: `http://localhost:5678`

## 🛠️ Configuration

### Custom Port

```bash
export N8N_PORT=8080
./n8n-launcher.sh
```

### Manual n8n Launch

```bash
# Native
n8n start

# Docker
docker run -it --rm --name n8n -p 5678:5678 -v ~/.n8n:/home/node/.n8n n8nio/n8n
```

### Updating n8n

The script **automatically checks for updates** every time you run it!

```bash
./n8n-launcher.sh
# If update available:
# ⚠ New n8n version available!
#   Current: 1.64.3
#   Latest:  1.70.0
# ★ Would you like to update now? (y/n)
```

Manual update:
```bash
# Native
npm install -g n8n@latest

# Docker
docker pull n8nio/n8n:latest
```

## 🐛 Troubleshooting

### Node.js Version Issues

n8n supports **only** these versions:
- ✅ v18.17.0+
- ✅ v20.x (Recommended)
- ✅ v22.x
- ❌ v19, v21, v23, v25+ (NOT supported)

**Solution:** Use Docker installation (no version issues!) or:
```bash
brew install node@20
brew link --overwrite node@20 --force
```

### Port Already in Use

```bash
lsof -i :5678
# Or use different port:
export N8N_PORT=8080
```

### Permission Denied

```bash
chmod +x n8n-launcher.sh
```

### Docker Issues

```bash
# Start Docker Desktop from Applications, then:
docker info

# Remove old container:
docker stop n8n && docker rm n8n
```

### Apple Silicon PATH

```bash
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
source ~/.zprofile
```

## 📂 Data Location

n8n data is stored in: `~/.n8n`

Works with both Native and Docker installations.

## 📝 License

MIT License - see [LICENSE](LICENSE)

---

**⭐ Star this project if it helped you!**
