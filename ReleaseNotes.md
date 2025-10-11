## [1.2.5]
### Features
1. Added `.github/copilot-releasenote.md` — guidelines for writing consistent release notes and changelogs.
2. Added automatic initialization of `CYRandomMountDB` (sets default `macroName` and `RefreshTime`) to avoid nil/db issues on first run.

### Changed
1. Improved macro migration flow: when a stored macro name differs from the default, the addon now attempts to delete the old macro and reset the stored value with better error handling and debug logging.

### Bug Fixes
1. Fixed a stray extra quote in the macro creation body that could prevent macro creation.
2. Various robustness fixes around macro creation and editing to reduce runtime errors.

### Notes
- Files changed (staged): `CYRandomMount.lua`, `.github/copilot-releasenote.md`.
- See `CYRandomMount.lua` for implementation details and debug prints guarded by `ShowDebug`.


