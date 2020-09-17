# i3-media-corner
Grabs a window in i3 and  always moves it to the current workspace

also sets a window class usable in eg. `picom` to make the window transparent

useful for a small media-player-window, that follows focus (browser/vlc/mplayer)

### get usage help
`drag_window help`

### check system for requirements
generates an install script for missing dependencies
`drag_window checkSystem`

### Requirements:
- i3 window manager (must be installed, why else would you want this script?)
- xdotool (checked in `drag_window checkSystem`)
- jq (json-parser, checked in `drag_window checkSystem`)
- xtitle (found somewhere on github, is pretty useful, checked in `drag_window checkSystem`)
- fish shell (nice shell, try it, required)

### Installation
copy script to the `~/.config/fish/functions` directory

now you can use the `drag_window` command, the fish shell automatically updates functions.

## whats great about it
- works with every window
- works with every workspace name
- resource-efficient (only updates when a workspace could have been switched, not on a timer)
- documented (really check the help feature, it's output and the commented code)
- customizable
    - sizes
    - suitable for hotkeys
    - suitable for scripts
    - targetable windows using id-selection
