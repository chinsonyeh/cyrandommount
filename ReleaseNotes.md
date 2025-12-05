# Release Notes

This file documents all notable changes to the CYRandomMount project following [Keep a Changelog](https://keepachangelog.com/) and [Semantic Versioning](https://semver.org/).

## [2.0.0]
### Added
- Added per-character mount list support with character-specific profiles
- Added ListMode selection (Character-specific list vs Account-wide shared list)
- Added automatic profile migration from old data structure to new character-based structure

### Changed
- [BREAKING] Completely restructured `CYRandomMountDB` data model from flat structure to character-keyed profiles
  - Old: `CYRandomMountDB = { FlyingMounts = {}, GroundMounts = {}, ... }`
  - New: `CYRandomMountDB = { Default = {...}, ["CharName-RealmName"] = {...} }`
- [BREAKING] Refactored mount selection functions to read from profile-based storage instead of UI checkboxes
  - `GetRandomSelectedFlyingMount()` now reads from `CYRandomMountDB` profile
  - `GetRandomSelectedGroundMount()` now reads from `CYRandomMountDB` profile
- Changed new character default to use account-wide shared list (ListMode = 2)
- Improved database initialization in `InitCYRandomMountDB()` with automatic migration from legacy format
- Reduced zone change event listeners (removed `ZONE_CHANGED` and `ZONE_CHANGED_INDOORS`, kept only `ZONE_CHANGED_NEW_AREA`)

### Notes
- **Migration**: Existing users will have their data automatically migrated from old format to new character-based format on first load
- **Default Behavior**: New characters automatically use account-wide shared list; existing characters retain character-specific list unless manually switched
