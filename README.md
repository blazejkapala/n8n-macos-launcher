# 🚀 n8n Launcher for macOS

Interactive bash script to launch n8n on macOS with a user-friendly CLI interface.

![macOS](https://img.shields.io/badge/macOS-Compatible-blue)
![Apple Silicon](https://img.shields.io/badge/Apple%20Silicon-M1%2FM2%2FM3-orange)
![License](https://img.shields.io/badge/license-MIT-green)

## ⚡ Installation

### Option 1: Git Clone (Recommended)

```bash
# Clone the repository
git clone https://github.com/blazejkapala/n8n-macos-launcher.git

# Enter directory
cd n8n-macos-launcher

# Make script executable
chmod +x n8n-launcher.sh

# Run the launcher
./n8n-launcher.sh
```

### Option 2: Global Install

Installs to `~/.local/bin` and adds to PATH (run from anywhere):

```bash
curl -fsSL https://raw.githubusercontent.com/blazejkapala/n8n-macos-launcher/main/install.sh | bash
```

After installation, restart terminal and run: `n8n-launcher.sh`

### Option 3: Download to Current Directory

```bash
# Download
curl -fsSL https://raw.githubusercontent.com/blazejkapala/n8n-macos-launcher/main/n8n-launcher.sh -o n8n-launcher.sh

# Make executable
chmod +x n8n-launcher.sh

# Run
./n8n-launcher.sh
```

## ✨ Features

- 🎯 **Two Installation Methods**: Native (Node.js) or Docker
- 🔄 **Automatic Updates**: Detects and installs new n8n versions
- 🐳 **Auto-start Docker**: Launches Docker Desktop if not running
- 🎨 **Beautiful CLI**: Animations, progress bars, colored output
- ✅ **Dependency Management**: Installs Homebrew, Node.js, Docker automatically
- 🍎 **Apple Silicon**: Full M1/M2/M3 support

## 🎯 Installation Methods

| Method | Pros | Cons |
|--------|------|------|
| **Native** | Faster startup, lighter | Requires Node.js v18/v20/v22 |
| **Docker** | Isolated, no version conflicts | Requires Docker Desktop |

## 📖 Usage

```bash
# Standard launch
./n8n-launcher.sh

# Custom port
N8N_PORT=8080 ./n8n-launcher.sh
```

After launch, open: `http://localhost:5678`

### Manual Commands

```bash
# Update n8n
npm install -g n8n@latest        # Native
docker pull n8nio/n8n:latest     # Docker

# Start without launcher
n8n start                        # Native
docker run -it --rm --name n8n -p 5678:5678 -v ~/.n8n:/home/node/.n8n n8nio/n8n  # Docker
```

## 🐛 Troubleshooting

| Problem | Solution |
|---------|----------|
| Node.js version error | Use Docker, or: `brew install node@20 && brew link --overwrite node@20 --force` |
| Port 5678 in use | `lsof -i :5678` to find process, or use different port |
| Permission denied | `chmod +x n8n-launcher.sh` |
| Docker container exists | `docker stop n8n && docker rm n8n` |

## 📂 Data

All n8n data is stored in `~/.n8n` (both Native and Docker).

## 📝 License

MIT
