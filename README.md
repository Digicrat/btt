# Overview

This is an initial cut at integrating Emacs with BetterTouchTool (BTT) and it's TouchBar widgets.  I developed this primarily for my own usage, but hopefully others wikl find it useful.  There is certainly much that can be improved or added to this (ie: packaging, modular configuration, major-mode bindings); and I'd be happy to entertain any PRs.

The provided bttpresets have been tested with Aquamacs Emacs, but should be compatible with any emacs variant by simply changing the associated program in BTT when importing.


This configuration uses the BTT Web Server and various hooks to allow Emacs to push updates to the Touch Bar.  Commands are handled with emulated keystrokes, as is standard in BTT.


# Setup
0. Install Aquamacs/Emacs & BetterTouchTool.
1. Clone or download this repository
2. Enable the Web Server in the BTT Configuration.
 * Update the btt-base-url at the top of btt.el if you have enabled encryption, set a password, or are accessing it remotely.
3. Load btt.el in your emacs configuration.  For example, put in your .emacs.el file  (load "~/path/to/btt.el")
4. Import the emacs.bttpreset into BTT (Presets->Import)
5. Enjoy
6. (Optional) Fork this project and create a PR to share any improvements you make with others.

# Details

The presets and functionsn provided can be used as a basis for farther expansion.

The current set of features enabled here include:

- Show filename
- Touch filename to show a list of open buffers (last 10 most recently accessed)
- Show line number
- Click line number to activate goto-line (C-l)
- Show active Major Mode (TODO: Mode-specific options)
- Bookmarks (bm.el) shortcuts.  Press < | > to navigate bookmarks in file, or 'BM' to toggle.  Long press to open a submenu with shortcuts to show all bookmarks or create an annotation.
- Eyebrowse mode support.  Show current eyebrowse workspace name in touchbar.  Press to list available spaces to switch between.
