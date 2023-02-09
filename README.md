![noTunes Logo](/screenshots/app-icon.png)

# Notice

This is a hard-fork of great `noTunes` by Tom Taylor. All credits for such great idea and for initial implementation go to him.
The fork was made to cover _my own purposes_ and probably could be useful for someone else: the major one is an automatic launch on user's login (through UI).

To avoid any possible clashes, the app was renamed to `noTunez`. The documentation below has been adjusted accordingly to the changes introduced. That's totally fine and fully encouraged if these changes are contributed back to the original app.

# noTunez

`noTunez` is a macOS application that will prevent iTunes _or_ Apple Music from launching.

Simply launch the `noTunez` app and iTunes/Music will no longer be able to launch. For example, when bluetooth headphones reconnect.

You can toggle the apps functionality via the menu bar icon with a simple left click.

## Installation

### Homebrew

```bash
brew tap zkondor/dist
brew install --cask notunez
```

## Usage

### Set `noTunez` to launch at startup

Right click the menu bar icon to toggle `Launch at Login`. That's it.

### Toggle `noTunez` Functionality

Left click the menu bar icon to toggle between its active states.

**Enabled (prevents iTunes/Music from opening)**

![noTunez Enabled](/screenshots/menubar-enabled.png)

**Disabled (allows iTunes/Music to open)**

![noTunez Disabled](/screenshots/menubar-disabled.png)

### Hide Menu Bar Icon

Right click the menu bar icon and click `Hide Icon`.

### Restore Menu Bar Icon

[Quit noTunez](#quit-notunez), run the following command in Terminal and re-open the app:

```bash
defaults delete xyz.kondor.noTunez
```

### Quit noTunez

To quit the app either:

**With menu bar icon visible**

Right click the menu bar icon and click quit.

**With menu bar icon hidden**

Quit the app via Activity Monitor or run the following command in Terminal:

```bash
osascript -e 'quit app "noTunez"'
```

### Set replacement for iTunes / Apple Music

Replace `YOUR_MUSIC_APP` with the name of your music app in the following command.
```bash
defaults write xyz.kondor.noTunez replacement /Applications/YOUR_MUSIC_APP.app
```

Then `/Applications/YOUR_MUSIC_APP.app` will launch when iTunes/Music attempts to launch.

The following command will disable the replacement.

```bash
defaults delete xyz.kondor.noTunez replacement
```

## License

The code is available under the [MIT License](https://github.com/zkondor/notunez/blob/master/LICENSE).

- Original implementation (`noTunes`) (c) Tom Taylor
- `Launch at Login` library (c) Sindre Sorhus
