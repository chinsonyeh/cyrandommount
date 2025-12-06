# Copilot Instructions – Release Note Guidelines
**Version:** v0.1.0  
**Purpose:** Guidelines for writing consistent and professional release notes

## Overview
This document provides guidelines for creating and maintaining `ReleaseNote.md` files in accordance with open source project best practices.

## Copilot prompt for usage
1. To update an existing file to follow the release note format:  
   ```
   Update ReleaseNote.md according to the guidelines in copilot-releasenote.md. Ensure proper formatting, categories, and semantic versioning.
   ```
2. To add new version changes to an existing release note:  
   ```
   Compare changes from master to release-vx.x.x and add a new version entry to ReleaseNote.md following the format and guidelines in copilot-releasenote.md.
   ```
3. To create a new release note from scratch:  
   ```
   Create a new ReleaseNote.md file according to the template and guidelines in copilot-releasenote.md.
   ```

## File Structure Requirements

### 1. File Location and Naming
- **File name:** `ReleaseNote.md` (located at project root)
- **Header:** Always start with `# Release Note`
- **Purpose statement:** Include a brief description of the file's purpose

### 2. Format Template
```markdown
# Release Note

This file documents all notable changes to this project. 

## [Version Number]
### Added
### Changed
### Deprecated  
### Removed
### Fixed
### Security

```

## 3. Version Ordering
- **Latest first:** Always list versions from newest to oldest
- **Keep history:** Preserve all past versions and changes

## 4. Change Categories
Use these standard categories following [Keep a Changelog](https://keepachangelog.com/) convention:

| Category | Description | Example |
|----------|-------------|---------|
| **Added** | New features | `- Added oToHARRIS_FindTopNPeak() function` |
| **Changed** | Changes in existing functionality | `- Modified oToHARRIS_Para_t structure layout` |
| **Deprecated** | Soon-to-be removed features | `- Deprecated PV_OldFunction(), use PV_NewFunction() instead` |
| **Removed** | Removed features | `- Removed legacy oToHARRIS_V1_Process() function` |
| **Fixed** | Bug fixes | `- Fixed memory leak in oToHARRIS_Initialize()` |
| **Security** | Security vulnerability fixes | `- Fixed buffer overflow in image processing` |

## 5. Writing Style Guidelines

### Version Numbers
- Follow [Semantic Versioning](https://semver.org/): `MAJOR.MINOR.PATCH`
- Format: `[1.2.3]` with square brackets

### Change Descriptions
- **Start with action verbs:** Added, Fixed, Changed, Removed, etc.
- **Be specific:** Include function names, file names, or module names
- **Use present tense:** "Add" not "Added" in the description
- **Reference issues/PRs:** Include issue numbers when applicable
- **Follow naming conventions:** Use proper oTo module prefixes and naming rules

### Examples
✅ **Good:**
```markdown
### Added
- Added oToAICALI_ProcessImage() function for enhanced image processing
- Added support for 16-bit image formats in oToAICALI_Utils module

### Fixed  
- Fixed memory alignment issue in oToAICALI_Initialize() function
- Fixed compilation warnings on GCC 11.x
```

❌ **Bad:**
```markdown
### Added
- New function
- Some improvements

### Fixed
- Bug fixes
- Various issues
```

## 6. Special Considerations for C/C++ Projects

### API Changes
- **Breaking changes:** Clearly mark breaking changes with `[BREAKING]` tag
- **API compatibility:** Note when API changes occur
- **Deprecated APIs:** Provide migration guidance

### Example:
```markdown
### Changed
- [BREAKING] Modified oToHARRIS_Para_t structure - added ul_NewField member
- Updated oToAICALI_VERSION_MAJOR to 2 due to API changes

### Deprecated  
- Deprecated PV_OldImageProcess() - use oToAICALI_ProcessImage() instead
  Migration: Replace PV_OldImageProcess(a_pucImage) with oToAICALI_ProcessImage(a_pucImage, &tConfig)
```

## 7. Cross-References
- **Link to commits:** Include commit hashes for significant changes
- **Reference documentation:** Link to updated documentation
- **Migration guides:** Provide links to migration documentation for breaking changes

## Example Complete Release Note
```markdown
# Release Note

This file documents all notable changes to the oToAICali project. The format is based on Keep a Changelog and follows Semantic Versioning.

## [2.1.0]
### Added
- Added oToAICALI_ProcessImageEx() function with extended parameters
- Added support for YUV422 image format processing
- Added oToAICALI_Utils_ValidateConfig() for parameter validation

### Changed
- Improved performance of oToAICALI_ProcessImage() by 15%
- Updated error handling to use standardized oToAICALI error codes

### Fixed
- Fixed memory leak in oToAICALI_Finalize() when called multiple times
- Fixed compilation issue on ARM64 architecture

## [2.0.1] 
### Fixed
- Fixed critical bug in corner detection algorithm
- Fixed documentation typos in oToAICALI.h header file

## [2.0.0]
### Added
- [BREAKING] Complete API redesign for improved usability
- Added comprehensive error handling system
- Added multi-threading support for image processing

### Removed
- [BREAKING] Removed deprecated v1.x API functions
- Removed dependency on legacy image format libraries

### Changed
- [BREAKING] Modified oToAICALI_Para_t structure layout
- Updated minimum C standard requirement to C99
```

---

## Quick Reference Checklist
- [ ] File named `ReleaseNote.md` at project root
- [ ] Header starts with `# Release Note`  
- [ ] Includes purpose statement
- [ ] Versions ordered newest to oldest
- [ ] Uses standard change categories (Added, Changed, Fixed, etc.)
- [ ] Follows semantic versioning
- [ ] Change descriptions are specific and actionable
- [ ] Breaking changes are clearly marked
- [ ] Uses proper oTo naming conventions in descriptions
