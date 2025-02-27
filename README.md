# 🚀 CRA to Vite Migration Script

<div align="center">

![CRA to Vite](https://img.shields.io/badge/CRA%20→%20Vite-Migration-brightgreen?style=for-the-badge)
![Bash Script](https://img.shields.io/badge/Bash-Script-black?style=for-the-badge&logo=gnu-bash&logoColor=white)
![React](https://img.shields.io/badge/React-Friendly-blue?style=for-the-badge&logo=react)

**Supercharge your React app by migrating from Create React App to Vite in seconds!**
by Roberto Bendinelli
</div>

## ✨ Why Vite?

| Feature | CRA (webpack) | Vite | Winner |
|---------|--------------|------|--------|
| Dev Server Startup | ⏱️ 20+ seconds | ⚡ Under 300ms | Vite 🏆 |
| Hot Module Reload | ⏱️ Seconds | ⚡ Instant | Vite 🏆 |
| Build Time | ⏱️ Minutes | ⚡ Seconds | Vite 🏆 |
| Configuration | 😓 Complex | 😊 Simple | Vite 🏆 |

## 🔥 One Command Migration

```bash
./cra-to-vite.sh
```

That's it! The script handles everything else.

## 🛠️ What Gets Migrated

- **📦 Dependencies**: Remove CRA, add Vite + plugins
- **⚙️ Configuration**: Generate optimized vite.config.js
- **📝 Scripts**: Update npm scripts for Vite workflow
- **🌐 Environment Variables**: REACT_APP_ → VITE_
- **🖼️ SVG Imports**: Keep your SVG components working
- **📄 HTML**: Move index.html to project root
- **🔤 TypeScript**: Update TS config (if applicable)

## 📋 Before & After

```diff
  # Package.json
- "scripts": {
-   "start": "react-scripts start",
-   "build": "react-scripts build",
-   "eject": "react-scripts eject"
- }
+ "scripts": {
+   "dev": "vite",
+   "build": "vite build",
+   "preview": "vite preview"
+ }

  # Environment Variables
- process.env.REACT_APP_API_URL
+ import.meta.env.VITE_API_URL

  # SVG Imports
- import Logo from './logo.svg';
+ import Logo from './logo.svg?react';
```

## 🚦 Getting Started

1. **Download** the script to your CRA project
   ```bash
   curl -O https://raw.githubusercontent.com/yourusername/cra-to-vite/main/cra-to-vite.sh
   ```

2. **Make it executable**
   ```bash
   chmod +x cra-to-vite.sh
   ```

3. **Run it**
   ```bash
   ./cra-to-vite.sh
   ```

4. **Start your new Vite app**
   ```bash
   npm run dev
   ```

## 📊 Benefits You'll See Immediately

- **⚡ Lightning-fast startup**: No more waiting for webpack
- **🔄 Instant HMR**: Changes appear immediately
- **🏎️ Faster builds**: Production builds in a fraction of the time
- **🧰 Simpler tooling**: Less configuration, more development

## 🤔 Requirements

- A Create React App project
- Node.js & npm/yarn
- Bash environment

## 📜 License

GNU

---

<div align="center">

**Supercharge your React development today!**

[Report Issues](https://github.com/yourusername/cra-to-vite/issues) • [Contribute](https://github.com/yourusername/cra-to-vite/pulls) • [Share Feedback](https://github.com/yourusername/cra-to-vite/discussions)

</div>
