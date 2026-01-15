# 🚀 n8n Launcher for macOS

Interactive bash script to launch n8n on macOS with a user-friendly CLI interface.

![macOS](https://img.shields.io/badge/macOS-Compatible-blue)
![Apple Silicon](https://img.shields.io/badge/Apple%20Silicon-M1%2FM2%2FM3-orange)
![License](https://img.shields.io/badge/license-MIT-green)

## ✨ Features

- 🎨 Colorful CLI interface with symbols (✓, ✗, ➜, ★)
- ✅ Automatic dependency checking (Homebrew, Node.js, n8n)
- 📦 Interactive installation of missing components
- 🔧 Port configuration and auto-browser opening
- 🍎 Full support for Apple Silicon (M1/M2/M3)
- 🛡️ Safe error handling and interruption support (Ctrl+C)

## 🚀 Quick Start

### Method 1: Direct Run (Recommended)

```bash
curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/n8n-macos-launcher/main/n8n-launcher.sh | bash
```

### Method 2: Download and Run

```bash
# Download
curl -O https://raw.githubusercontent.com/YOUR_USERNAME/n8n-macos-launcher/main/n8n-launcher.sh

# Make executable
chmod +x n8n-launcher.sh

# Run
./n8n-launcher.sh
```

### Method 3: Git Clone

```bash
git clone https://github.com/YOUR_USERNAME/n8n-macos-launcher.git
cd n8n-macos-launcher
chmod +x n8n-launcher.sh
./n8n-launcher.sh
```

## 📖 How It Works

The script automatically:

1. ✓ Checks system (macOS, processor type)
2. ✓ Detects/installs Homebrew
3. ✓ Detects/installs Node.js (requires 18+)
4. ✓ Detects/installs n8n
5. ✓ Configures port and settings
6. ✓ Launches n8n

After launch, n8n will be available at: `http://localhost:5678`

## 🛠️ Configuration

### Custom Port

```bash
export N8N_PORT=8080
./n8n-launcher.sh
```

Or specify when the script prompts you.

### Manual n8n Launch

After first installation, you can launch n8n directly:

```bash
n8n start
```

## 🐛 Troubleshooting

### "Permission denied"

```bash
chmod +x n8n-launcher.sh
```

### Port Already in Use

```bash
# Check what's using the port
lsof -i :5678

# Or use a different port
export N8N_PORT=8080
./n8n-launcher.sh
```

### n8n Won't Start

```bash
# Check Node.js version (requires 18+)
node --version

# Update if needed
brew upgrade node
```

### Homebrew PATH (Apple Silicon)

```bash
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
source ~/.zprofile
```

## 📂 Data Location

n8n data is stored in: `~/.n8n`

---

## 🧪 Testing Guide (For Contributors)

### Basic Testing Scenarios

#### Test 1: Full Installation Flow
```bash
./n8n-launcher.sh
# Answer "y" to all prompts
# Verify n8n launches correctly
# Press Ctrl+C to stop
```

#### Test 2: Repeat Launch
```bash
./n8n-launcher.sh
# Check that it recognizes installed components
# Verify it runs without reinstalling
```

#### Test 3: Interruption Handling
```bash
./n8n-launcher.sh
# Press Ctrl+C at different points
# Verify clean exit without errors
```

#### Test 4: Custom Port
```bash
./n8n-launcher.sh
# Enter port 8080 when prompted
# Verify n8n runs on port 8080
```

### What to Check

**UI/UX:**
- [ ] Colors display correctly
- [ ] Symbols (✓, ✗, ➜, ★) are visible
- [ ] Formatting is readable
- [ ] Questions are clear

**Functionality:**
- [ ] System detection works (macOS, processor type)
- [ ] Homebrew detection/installation works
- [ ] Node.js detection/installation works
- [ ] n8n detection/installation works
- [ ] Port configuration works
- [ ] n8n launches successfully
- [ ] Ctrl+C stops cleanly

### Testing Different Scenarios

**Scenario A: Everything Already Installed**
- Script should detect all components
- Should go straight to configuration
- Should launch n8n without issues

**Scenario B: Missing n8n Only**
```bash
# Uninstall n8n first
npm uninstall -g n8n

# Run script
./n8n-launcher.sh
# Should detect and offer to install n8n
```

**Scenario C: Apple Silicon Specific**
- Verify it detects M1/M2/M3 processor
- Check Homebrew installs to /opt/homebrew
- Confirm PATH is set correctly

### Logging Test Results

```bash
# Run with logging
./n8n-launcher.sh 2>&1 | tee test-log.txt
```

---

## 🌐 Publishing to GitHub

### Step 1: Create Repository

1. Go to https://github.com
2. Click "New repository"
3. Name: `n8n-macos-launcher`
4. Description: `🚀 Interactive n8n launcher for macOS with beautiful CLI`
5. Public
6. Don't initialize with README (you have your own)
7. Create repository

### Step 2: Local Setup

```bash
# Navigate to your files
cd /path/to/your/files

# Initialize git
git init

# Add all files
git add .

# First commit
git commit -m "Initial commit: n8n macOS launcher

- Interactive CLI with colors and symbols
- Automatic dependency checking
- Installation of missing components
- Port configuration
- Apple Silicon support
- Complete documentation"
```

### Step 3: Push to GitHub

```bash
# Set branch to main
git branch -M main

# Add remote (replace YOUR_USERNAME!)
git remote add origin https://github.com/YOUR_USERNAME/n8n-macos-launcher.git

# Push
git push -u origin main
```

### Step 4: Update Links

**IMPORTANT:** Before sharing, update links in these files:

**README.md** - Replace `YOUR_USERNAME` with your GitHub username:
- Lines with `curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/...`
- Git clone command

**install.sh** (if keeping it):
- `REPO_URL` at the beginning

After editing:
```bash
git add README.md install.sh
git commit -m "docs: update GitHub username"
git push
```

### Step 5: Repository Settings

On GitHub:
1. Go to repository Settings
2. Under "About", add:
   - Description: `🚀 Interactive n8n launcher for macOS with beautiful CLI`
   - Topics: `n8n`, `macos`, `workflow-automation`, `bash-script`, `apple-silicon`, `homebrew`, `nodejs`

### Step 6: Optional Enhancements

**Add a Screenshot:**
```bash
# Run the script
./n8n-launcher.sh
# Take a terminal screenshot
# Save as screenshot.png

# Add to repo
git add screenshot.png
git commit -m "docs: add screenshot"
git push
```

Then add to README:
```markdown
## 📸 Screenshot

![n8n Launcher](screenshot.png)
```

**Create a Release:**
1. Go to "Releases" in your repo
2. Click "Create a new release"
3. Tag: `v1.0.0`
4. Title: `v1.0.0 - Initial Release`
5. Describe the release
6. Publish

---

## 📝 License

MIT License - see [LICENSE](LICENSE)

## 🙏 Acknowledgments

- [n8n](https://n8n.io/) - workflow automation tool
- [Homebrew](https://brew.sh/) - package manager
- macOS community

---

**Star ⭐ the project if it helped you!**
