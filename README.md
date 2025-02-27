# CRA to Vite Migration Script

A powerful bash script that automatically migrates Create React App projects to Vite for faster development and build times.

## Overview

This script simplifies the process of migrating from Create React App (CRA) to Vite by automatically:

- Updating package.json scripts and dependencies
- Creating proper Vite configuration files
- Migrating index.html from public/ to the root directory
- Updating environment variables from REACT_APP_ to VITE_
- Converting SVG imports to be compatible with Vite
- Handling TypeScript configurations (if applicable)
- Creating documentation about the migration

## Why Migrate to Vite?

- **Faster Development Server**: Vite's dev server starts in milliseconds and HMR updates are nearly instant
- **Improved Build Performance**: Build times are significantly faster than webpack-based CRA
- **Better Developer Experience**: Less waiting, more coding
- **Modern Tooling**: Based on esbuild for development and Rollup for production

## Usage

1. Download the `cra-to-vite.sh` script to your CRA project's root directory
2. Make it executable: `chmod +x cra-to-vite.sh`
3. Run the script: `./cra-to-vite.sh`
4. Follow the prompts
5. After migration, start the dev server with: `npm run dev`

## Requirements

- A Create React App project
- Node.js and npm
- Bash environment (Linux, macOS, Windows with Git Bash or WSL)

## What Gets Changed

- **Scripts**: Updates npm scripts (dev, build, preview)
- **Dependencies**: Removes react-scripts, adds Vite and plugins
- **Configuration**: Creates vite.config.js with React and SVGR support
- **Environment Variables**: Converts from process.env.REACT_APP_* to import.meta.env.VITE_*
- **HTML**: Moves index.html to the root directory with proper modifications
- **TypeScript**: Updates TypeScript configuration if applicable

## After Migration

After running the script, you'll have a fully configured Vite project. The script generates a `VITE_MIGRATION.md` file with details about the changes made and how to work with your migrated project.

## License

MIT

## Contributing

Contributions are welcome! Feel free to submit issues or pull requests.
