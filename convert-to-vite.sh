#!/bin/bash

# Colors for better output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to show colorful messages
log_info() {
  echo -e "${BLUE}INFO:${NC} $1"
}

log_success() {
  echo -e "${GREEN}SUCCESS:${NC} $1"
}

log_warning() {
  echo -e "${YELLOW}WARNING:${NC} $1"
}

log_error() {
  echo -e "${RED}ERROR:${NC} $1"
  exit 1
}

# Check Node.js version
check_node_version() {
  node_version=$(node -v | cut -d 'v' -f 2)
  major_version=$(echo $node_version | cut -d '.' -f 1)
  
  log_info "Detected Node.js version: $node_version"
  
  if [ $major_version -lt 18 ]; then
    log_warning "Vite 5.x requires Node.js version 18 or higher."
    log_warning "You are currently using Node.js $node_version"
    echo ""
    log_info "You have two options:"
    log_info "1. Update your Node.js version to 18 or higher (recommended)"
    log_info "2. Install an older version of Vite compatible with your Node.js version"
    echo ""
    read -p "Do you want to continue anyway? (y/n): " node_confirm
    
    if [[ $node_confirm != "y" && $node_confirm != "Y" ]]; then
      log_info "Migration cancelled. Please update your Node.js version and try again."
      exit 0
    fi
  fi
}

# Check if the current directory is a React app
check_react_app() {
  if [ ! -f package.json ]; then
    log_error "No package.json found. Please run this script in the root of your React project."
  fi
  
  if ! grep -q "react-scripts" package.json; then
    log_error "This doesn't appear to be a Create React App project. No 'react-scripts' found in package.json."
  fi
  
  log_info "Create React App project detected."
}

# Update package.json
update_package_json() {
  log_info "Updating package.json..."
  
  # Backup package.json
  cp package.json package.json.bak
  
  # Use Node.js to update package.json
  node -e '
    const fs = require("fs");
    const pkg = JSON.parse(fs.readFileSync("package.json", "utf8"));
    
    // Update scripts
    pkg.scripts = pkg.scripts || {};
    pkg.scripts.dev = "vite";
    pkg.scripts.build = "vite build";
    pkg.scripts.preview = "vite preview";
    delete pkg.scripts.eject;
    
    // Keep start for compatibility
    if (pkg.scripts.start) {
      pkg.scripts.start = "vite";
    }
    
    // Write updated package.json
    fs.writeFileSync("package.json", JSON.stringify(pkg, null, 2));
  '
  
  if [ $? -ne 0 ]; then
    mv package.json.bak package.json
    log_error "Failed to update package.json. Reverting changes."
  fi
  
  log_success "package.json updated successfully."
}

# Install dependencies
update_dependencies() {
  log_info "Updating dependencies..."
  
  # Uninstall CRA dependencies
  log_info "Removing react-scripts and related dependencies..."
  npm uninstall react-scripts
  
  # Install Vite and necessary plugins
  log_info "Installing Vite and plugins..."
  npm install --save-dev vite @vitejs/plugin-react
  
  log_success "Dependencies updated successfully."
}

# Create configuration files for Vite
create_vite_config() {
  log_info "Creating Vite configuration files..."
  
  # Create vite.config.js with appropriate configuration
  cat > vite.config.js << EOL
const { defineConfig } = require('vite');
const react = require('@vitejs/plugin-react');
const path = require('path');

module.exports = defineConfig({
  plugins: [
    react()
  ],
  build: {
    outDir: 'build', // Match CRA's build directory
    // Use specific targets instead of browserslist-to-esbuild
    target: ['es2015', 'edge88', 'firefox78', 'chrome87', 'safari13'],
  },
  server: {
    port: 3000, // Match CRA's default port
    open: true,
  },
  resolve: {
    extensions: ['.js', '.jsx', '.ts', '.tsx', '.json'], // Explicitly include JSX extensions
    alias: {
      // Add any aliases you might have in jsconfig/tsconfig
      // '@': path.resolve(__dirname, 'src'),
    }
  },
  // Handle JSX in .js files
  esbuild: {
    loader: 'jsx',
    include: /src\/.*\.jsx?$/,
    exclude: []
  },
  optimizeDeps: {
    esbuildOptions: {
      loader: {
        '.js': 'jsx' // This tells esbuild to treat .js files as .jsx
      }
    }
  }
});
EOL
  
  # Create environment configuration for TypeScript projects
  if [ -f tsconfig.json ]; then
    mkdir -p src/types
    cat > src/types/environment.d.ts << EOL
/// <reference types="vite/client" />

interface ImportMetaEnv {
  readonly VITE_APP_TITLE: string;
  // Add more environment variables as needed
}

interface ImportMeta {
  readonly env: ImportMetaEnv;
}
EOL
    
    # Update TypeScript configuration
    log_info "Updating TypeScript configuration..."
    cat > tsconfig.json << EOL
{
  "compilerOptions": {
    "target": "ESNext",
    "lib": ["DOM", "DOM.Iterable", "ESNext"],
    "allowJs": true,
    "skipLibCheck": true,
    "esModuleInterop": true,
    "allowSyntheticDefaultImports": true,
    "strict": true,
    "forceConsistentCasingInFileNames": true,
    "module": "ESNext",
    "moduleResolution": "Node",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "noEmit": true,
    "jsx": "react-jsx",
    "baseUrl": "."
  },
  "include": ["src", "vite.config.ts", "src/types/environment.d.ts"],
  "references": [{ "path": "./tsconfig.node.json" }]
}
EOL

    cat > tsconfig.node.json << EOL
{
  "compilerOptions": {
    "composite": true,
    "module": "ESNext",
    "moduleResolution": "Node",
    "allowSyntheticDefaultImports": true
  },
  "include": ["vite.config.ts"]
}
EOL
  fi
  
  log_success "Vite configuration files created successfully."
}

# Migrate public directory and index.html
migrate_index_html() {
  log_info "Migrating public directory and index.html..."
  
  if [ ! -d public ] || [ ! -f public/index.html ]; then
    log_error "Could not find public/index.html. Is this a standard CRA project?"
  fi
  
  # Copy index.html to root
  cp public/index.html ./index.html
  
  # Update index.html for Vite
  # Add module script for entry point
  sed -i.bak '/<\/head>/i\    <script type="module" src="\/src\/index.jsx"></script>' index.html
  
  # Replace %PUBLIC_URL% with empty string (assets are served from root in Vite)
  sed -i.bak 's/%PUBLIC_URL%\///g' index.html
  
  # Remove default CRA comments
  sed -i.bak '/<!-- If you open this file directly in the browser/d' index.html
  sed -i.bak '/<!-- This HTML file is a template/d' index.html
  sed -i.bak '/<!-- You can add webfonts, meta tags, or analytics to this file/d' index.html
  sed -i.bak '/<!-- The build step will place the bundled scripts into the <body> tag/d' index.html
  sed -i.bak '/<!-- To begin the development, run `npm start` or `yarn start`/d' index.html
  sed -i.bak '/<!-- To create a production bundle, use `npm run build` or `yarn build`/d' index.html
  
  # Check if we need to adjust for .tsx instead of .jsx
  if [ -f src/index.tsx ]; then
    sed -i.bak 's/index.jsx/index.tsx/g' index.html
  elif [ -f src/index.js ] && [ ! -f src/index.jsx ]; then
    # If only .js exists (not .jsx), rename it to .jsx
    log_info "Renaming src/index.js to src/index.jsx for JSX support..."
    mv src/index.js src/index.jsx
  fi
  
  # Cleanup backup files
  rm -f index.html.bak
  
  log_success "index.html migrated successfully."
}

# Update source files for Vite compatibility
update_source_files() {
  log_info "Updating source files for Vite compatibility..."
  
  # Update environment variables in all source files
  log_info "Updating environment variables in source files..."
  find src -type f \( -name "*.js" -o -name "*.jsx" -o -name "*.ts" -o -name "*.tsx" \) -exec sed -i.bak 's/process\.env\.REACT_APP_/import.meta.env.VITE_/g' {} \;
  
  # Rename JS files with JSX content to .jsx
  log_info "Checking for JS files with JSX content..."
  for file in $(find src -name "*.js"); do
    # Check if file contains JSX syntax
    if grep -q "<\w[^>]*>" "$file" || grep -q "React\.createElement" "$file"; then
      new_file="${file%.js}.jsx"
      log_info "Renaming $file to $new_file (contains JSX)"
      mv "$file" "$new_file"
    fi
  done
  
  # Handle SVG imports - instead of using the SVGR plugin, update imports directly
  log_info "Updating SVG imports for Vite compatibility..."
  find src -type f \( -name "*.js" -o -name "*.jsx" -o -name "*.ts" -o -name "*.tsx" \) -exec sed -i.bak 's/import { ReactComponent as \([A-Za-z0-9]\+\) } from "\([^"]\+\.svg\)"/import \1 from "\2?url"/' {} \;
  
  # Remove backup files
  find src -name "*.bak" -delete
  
  # Handle .env files
  if [ -f .env ]; then
    log_info "Updating .env files..."
    cp .env .env.bak
    sed -i.bak 's/REACT_APP_/VITE_/g' .env
    rm -f .env.bak
  fi
  
  if [ -f .env.development ]; then
    cp .env.development .env.development.bak
    sed -i.bak 's/REACT_APP_/VITE_/g' .env.development
    rm -f .env.development.bak
  fi
  
  if [ -f .env.production ]; then
    cp .env.production .env.production.bak
    sed -i.bak 's/REACT_APP_/VITE_/g' .env.production
    rm -f .env.production.bak
  fi
  
  log_success "Source files updated successfully."
}

# Add SVG handling helper
create_svg_helper() {
  log_info "Creating SVG helper file to replace SVGR functionality..."
  
  mkdir -p src/utils
  cat > src/utils/svgr.jsx << EOL
import React from 'react';

/**
 * A simple helper to convert an imported SVG URL to a React component
 * This helps maintain compatibility with the ReactComponent import syntax from CRA
 * 
 * @param {string} url - The URL of the SVG (imported with ?url)
 * @param {Object} props - Props to pass to the img element
 * @returns {React.ReactElement} - An img element with the SVG as its src
 */
export const createSvgComponent = (url, props = {}) => {
  return <img src={url} alt={props.alt || ''} {...props} />;
};

/**
 * Usage:
 * 
 * // Instead of:
 * // import { ReactComponent as Logo } from './logo.svg'
 * 
 * // Do this:
 * import logoUrl from './logo.svg?url'
 * import { createSvgComponent } from './utils/svgr'
 * const Logo = (props) => createSvgComponent(logoUrl, props)
 */
EOL

  log_success "SVG helper file created successfully."
}

# Final cleanup and instructions
final_cleanup() {
  log_info "Performing final cleanup..."
  
  # Remove unnecessary CRA files
  rm -f src/react-app-env.d.ts
  
  # Create a documentation file with migration notes
  cat > VITE_MIGRATION.md << EOL
# CRA to Vite Migration

This project has been migrated from Create React App to Vite.

## New Commands

- \`npm run dev\` - Starts the development server
- \`npm run build\` - Builds the application for production
- \`npm run preview\` - Previews the built application

## Environment Variables

- All environment variables have been renamed from \`REACT_APP_*\` to \`VITE_*\`
- In your code, replace \`process.env.REACT_APP_*\` with \`import.meta.env.VITE_*\`

## SVG Support

- The SVGR plugin is not used in this migration due to compatibility issues
- For SVG files that were previously imported as React components:
  - Replace: \`import { ReactComponent as Logo } from './logo.svg'\`
  - With: 
    ```js
    import logoUrl from './logo.svg?url'
    import { createSvgComponent } from './utils/svgr'
    const Logo = (props) => createSvgComponent(logoUrl, props)
    ```
- If you need full SVGR functionality later, you can install it manually:
  \`npm install vite-plugin-svgr --save-dev\`
  And then update your vite.config.js to include it properly

## File Extensions

- JS files containing JSX have been renamed to .jsx
- This is required for Vite to properly process JSX content

## TypeScript Changes

If you're using TypeScript:
- Types for environment variables are in \`src/types/environment.d.ts\`
- Updated \`tsconfig.json\` with Vite-specific settings

## Common Issues and Solutions

### JSX Processing
If you encounter JSX processing errors:
- Make sure files with JSX syntax use the .jsx extension
- If you add new files with JSX, use the .jsx extension

### SVG Imports
If you have issues with SVG imports:
- Use the provided helper in src/utils/svgr.jsx
- Or import SVGs directly as URLs with \`import logoUrl from './logo.svg?url'\`

### Environment Variables
- Remember that all environment variables must be prefixed with VITE_ now
- They are accessed via import.meta.env.VITE_* instead of process.env.REACT_APP_*

For more information, see the [Vite documentation](https://vitejs.dev/guide/).
EOL
  
  log_success "Final cleanup completed."
  log_success "CRA to Vite migration completed successfully!"
  log_info "Please check the VITE_MIGRATION.md file for important information about the migration."
  log_info "Start your development server with: npm run dev"
}

# Main script execution
main() {
  echo -e "${BLUE}====================================${NC}"
  echo -e "${GREEN}   Create React App to Vite Migration   ${NC}"
  echo -e "${BLUE}====================================${NC}"
  echo ""
  
  check_node_version
  check_react_app
  
  echo ""
  log_warning "This script will modify your project significantly."
  read -p "Do you want to proceed? (y/n): " confirm
  
  if [[ $confirm != "y" && $confirm != "Y" ]]; then
    log_info "Migration cancelled. No changes were made."
    exit 0
  fi
  
  update_package_json
  update_dependencies
  create_vite_config
  migrate_index_html
  update_source_files
  create_svg_helper
  final_cleanup
  
  echo ""
  echo -e "${GREEN}====================================${NC}"
  echo -e "${GREEN}   Migration Completed Successfully!   ${NC}"
  echo -e "${GREEN}====================================${NC}"
}

# Execute main function
main
