# CYRandomMount

CYRandomMount is a World of Warcraft addon that intelligently manages mount summoning through a dynamic macro system. It automatically selects and updates a random mount based on your current zone (flying, ground, or special areas like Undermine), ensuring mount variety by avoiding repetition when possible. The addon supports both character-specific and account-wide mount preferences, providing flexible configuration options through an intuitive settings panel.

## Features

- **Multi-Language Support:** Options UI automatically displays in your game client's language (Traditional Chinese, Simplified Chinese, French, German, Spanish, Portuguese, Russian, Korean, Japanese, and English).
- **Automatic Macro Update:** Creates and updates a macro named `CYRandomMount` to summon a random selected mount suitable for your current area (flying, ground, or special zones like Undermine).
  **Macro Update Modes:**
   - **Mode 1:** The macro will update and select a new random mount every time you press the macro button (recommended).
   - **Mode 2:** The macro will update and select a new random mount automatically at a fixed interval (Refresh Time).
- **Mount Variety Guarantee:** When selecting the next random mount, the addon excludes the currently selected mount from the pool (if more than one mount is available), ensuring you get a different mount each time you summon.
- **Per-Character Mount Lists:** Choose between character-specific mount lists or account-wide shared lists for maximum flexibility across your characters.
- **Favorite Mount Selection:** Choose which flying and ground mounts to include in the random selection from your collected mounts. Use the "Select All" and "Deselect All" buttons for quick selection.
- **Mount Search:** Quickly filter mount lists with built-in search boxes. Type to instantly find mounts by name - non-matching mounts are grayed out for easy visual filtering while maintaining full list visibility.
- **Custom Refresh Interval:** Set how often (in seconds) the macro updates to reflect your current zone's flyability (5-30 seconds).
- **Draggable Icon:** A draggable icon in the options UI that can be dragged to your action bar for quick access.
- **Settings Panel:** Easily configure your preferences through the in-game settings interface.

## How to Use

1. **Install the Addon:**
   - Place the `CYRandomMount` folder in your `path_to\World of Warcraft\_retail_\Interface\AddOns` directory.

2. **In-Game Setup:**
   - Type `/cyrandommount` or `/cyrm` in chat to open the settings panel.
   - **Choose List Mode:** Select whether to use character-specific mount lists or account-wide shared lists.
     - **Character-specific:** Each character maintains its own mount preferences.
     - **Account-wide:** All characters share the same mount preferences (recommended for new characters).
   - **Select Mounts:** Choose your favorite flying and ground mounts from your collected mounts.
   - **Configure Update Mode:** Choose how the macro updates:
     - **Mode 1 (Recommended):** Update macro every time you use it for immediate variety.
     - **Mode 2:** Update macro automatically at set intervals.
   - **Set Refresh Interval:** Adjust how often (5-30 seconds) the macro updates in periodic mode.

3. **Use the Macro:**
   - The addon automatically creates a macro named `CYRandomMount`.
   - To use the macro, drag it from the macro UI to your action bar. Alternatively, for quicker access, drag the icon directly from the options UI to your action bar.
   - When used, it will summon a random mount appropriate for your current area.

## Notes

- Only mounts that are collected will appear in the selection list.
- The macro updates automatically based on your zone, the refresh interval, and the selected update mode.

## Author

- chinsonyeh@gmail.com

## License

This addon is provided as-is, without warranty. Use at your own risk.