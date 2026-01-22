# GitHub Actions Workflows

This directory contains automated workflows for the CYRandomMount addon.

## Release Workflow

The `release.yml` workflow automatically publishes releases to both GitHub and CurseForge when you push a version tag.

### Setup Instructions

1. **Get CurseForge API Token**
   - Go to [CurseForge API Tokens](https://authors.curseforge.com/account/api-tokens)
   - Generate a new token with "Upload" permission
   - Copy the token

2. **Add Secrets to GitHub**
   - Go to your repository on GitHub
   - Navigate to Settings → Secrets and variables → Actions
   - Click "New repository secret"
   - Add the following secret:
     - Name: `CF_API_TOKEN`
     - Value: Your CurseForge API token

3. **Configure Project ID**
   - Open `.github/workflows/release.yml`
   - Replace `YOUR_PROJECT_ID` with your actual CurseForge project ID
   - You can find this in your project's URL on CurseForge

4. **Game Version (Automatic)**
   - The workflow automatically extracts the Interface version from `CYRandomMount.toc`
   - No manual configuration needed - it reads the `## Interface: 120000` line
   - The extracted version is used directly for CurseForge `game_versions`

### How to Use

1. **Make your changes and commit**
   ```bash
   git add .
   git commit -m "feat: your changes"
   ```

2. **Update version numbers**
   - Update `CYRandomMount.toc` (## Version)
   - Update `ReleaseNotes.md` with new version entry

3. **Create and push a version tag**
   ```bash
   git tag v2.4.0
   git push origin v2.4.0
   ```

4. **Automatic release**
   - GitHub Actions will automatically:
     - Create a release package
     - Create a GitHub Release with the zip file
     - Upload to CurseForge with changelog

### Workflow Details

The workflow performs the following steps:

1. **Checkout code**: Gets the repository code
2. **Extract version**: Extracts version number from the tag
3. **Extract Interface version**: Reads the Interface version from TOC file for CurseForge compatibility
4. **Create package**: Builds a zip file with only necessary addon files
5. **GitHub Release**: Creates a release on GitHub with the package
6. **CurseForge Upload**: Uploads the package to CurseForge with auto-detected game version

### Files Included in Package

The following files are packaged for distribution:
- `CYRandomMount.lua`
- `CYRandomMount.toc`
- `CYRandomMountOptions.lua`
- `ReleaseNotes.md`

Files excluded (via packaging):
- Development scripts (`.ps1` files)
- Git configuration (`.git`, `.gitignore`)
- IDE settings (`.vscode`)
- GitHub workflows (`.github`)
- Local specs and test files

### Troubleshooting

**If the workflow fails:**

1. Check the Actions tab in your GitHub repository for error details
2. Verify your `CF_API_TOKEN` secret is set correctly
3. Ensure the project ID is correct
4. Check that the game version ID is valid for current WoW expansion

**Common issues:**

- **"Invalid API token"**: Re-generate your CurseForge API token
- **"Invalid project ID"**: Verify your CurseForge project ID
- **"Game version not found"**: Update the `game_versions` field with current WoW version ID

### Manual Release (Fallback)

If you need to release manually:

1. Create the package locally:
   ```bash
   mkdir -p release/CYRandomMount
   cp CYRandomMount.lua CYRandomMount.toc CYRandomMountOptions.lua release/CYRandomMount/
   cd release
   zip -r CYRandomMount-v2.4.0.zip CYRandomMount/
   ```

2. Upload to CurseForge manually through the website
3. Create a GitHub Release manually with the zip file
