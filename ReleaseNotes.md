# Release Notes

## [2.3.1]
### Fixed
- Fixed a bug preventing mount list changes in non-English languages.

## [2.3.0]
### Added
- Added a draggable icon in the options UI. Drag it to your action bar to use it!

## [2.2.0]
### Added
- Added multi-language support for the options UI. The interface now displays in the player's game client language (Traditional Chinese, Simplified Chinese, French, German, Spanish, Portuguese, Russian, Korean, and English).

### Changed
- Both `/cyrm` and `/cyrandommount` can be used in chat to open the settings panel

## [2.1.0]
### Changed
- Improved mount variety: When selecting the next random mount, the addon now excludes the currently selected mount from the pool (if more than one mount is available), ensuring you get a different mount each time you summon

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
