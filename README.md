# WASD-Pad: The Ambidextrous KWin Task Switcher

A WASD-key enabled thumbnail grid task switcher for KDE Plasma 6.

Easily traverse large thumbnail grids in 2D with the left hand (assumes QWERTY layout). 

Coming v2: hands-free, telekinetic operation 😎.


## Features

- **WASD Navigation**: Navigate the grid using W/A/S/D keys
  - W (or Up): Move up
  - A (or Left): Move left
  - S (or Down): Move down
  - D (or Right): Move right
- **Compatible with Alt+Tab**: Works with the default Plasma task switcher shortcut
- **Compatible with Arrow Keys**: Traditional arrow key navigation is still available

## Installation

```bash
# Get the source code.
git clone https://github.com/boborrob/wasd-pad

# Go to the local repo. Make sure you're there.
cd wasd-pad
echo $PWD

# Create a custom tabbox directory where KWin expects to find it.
mkdir -p ~/.local/share/kwin/tabbox/wasd-pad/contents/ui

# Copy the files from the local repo to the custom directory.
cp -r ./* ~/.local/share/kwin/tabbox/wasd-pad/
```

## Activation

1. Open **System Settings** → **Window Management** → **Task Switcher**
2. Under "Visualization", select **"WASD-Pad"**
3. Click **Apply**

## Usage

1. Press **Alt+Tab** (or your configured task switcher shortcut)
2. Use **W/A/S/D** to navigate through the thumbnail grid
5. Press **Tab** to cycle forward, **Shift+Tab** to cycle backward

## Requirements

- KDE Plasma 6.x
- KWin (the KDE window manager)

## Files

```
wasd-pad/
├── metadata.json      # Package metadata
└── contents/
    └── ui/
        └── main.qml   # Main switcher UI
```

## License

GPL-3.0 license
