# CYRandomMount

CYRandomMount is a World of Warcraft addon that automatically updates a macro to summon a random mount based on whether you are in a flyable area or not. It provides a convenient settings panel to select your favorite flying and ground mounts, and periodically updates the macro to match your current zone.

## Features

- **Automatic Macro Update:** Creates and updates a macro named `CYRandomMount` to summon a random selected mount suitable for your current area (flying or ground).  
  **Macro Update Modes:**
   - **Mode 1:** The macro will update and select a new random mount every time you press the macro button.
   - **Mode 2:** The macro will update and select a new random mount automatically at a fixed interval (Refresh Time).
- **Favorite Mount Selection:** Choose which flying and ground mounts to include in the random selection from your collected mounts.
- **Custom Refresh Interval:** Set how often (in seconds) the macro updates to reflect your current zone's flyability.
- **Settings Panel:** Easily configure your preferences through the in-game settings interface.
- **Legacy Support:** Compatible with both the new and old WoW settings APIs.

## How to Use

1. **Install the Addon:**
   - Place the `CYRandomMount` folder in your `Interface/AddOns` directory.

2. **In-Game Setup:**
   - Type `/cyrandommount` in chat to open the settings panel.
   - Select your favorite flying and ground mounts.
   - Adjust the refresh interval as desired.
   - Choose your preferred macro update mode:
     - **Mode 1:** Update macro every time you use it (immediate update).
     - **Mode 2:** Update macro automatically every set number of refresh interval (periodic update).

3. **Use the Macro:**
   - The addon automatically creates a macro named `CYRandomMount`.
   - Place this macro on your action bar.
   - When used, it will summon a random mount appropriate for your current area.

## Notes

- Only mounts that are collected will appear in the selection list.
- The macro updates automatically based on your zone, the refresh interval, and the selected update mode.

## Author

- chinsonyeh

## License

This addon is provided as-is, without warranty. Use at your own risk.