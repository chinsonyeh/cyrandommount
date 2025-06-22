# CYRandomMount

CYRandomMount is a World of Warcraft addon that automatically updates a macro to summon a random mount based on whether you are in a flyable area or not. It provides a convenient settings panel to select your favorite flying and ground mounts, and periodically updates the macro to match your current zone.

## Features

- **Automatic Macro Update:** Creates and updates a macro named `CYRandomMount` to summon a random selected mount suitable for your current area (flying or ground).
- **Favorite Mount Selection:** Choose which flying and ground mounts to include in the random selection from your collected and favorited mounts.
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

3. **Use the Macro:**
   - The addon automatically creates a macro named `CYRandomMount`.
   - Place this macro on your action bar.
   - When used, it will summon a random mount appropriate for your current area.

## Notes

- Only mounts that are both collected and marked as favorites will appear in the selection list.
- The macro updates automatically based on your zone and the refresh interval you set.
- If you change your favorite mounts, revisit the settings panel to update your selections.

## Author

- chinsonyeh

## License

This addon is provided as-is, without warranty. Use at your own risk.