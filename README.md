# Flash B2G
FxOSBuilds cli is a tool made on node.js to update production devices  
Shallow-flash Gecko and Gaia on Firefox OS devices from Mozilla's public build server with just one command.

## What does it do?

1. **Downloads build**, matched by `device`, `channel` and `date`, from http://ftp.mozilla.org/pub/mozilla.org/b2g/nightly/
2. **Flash Gecko and Gaia**, a so called *[shallow flash](https://github.com/Mozilla-TWQA/B2G-flash-tool/blob/master/shallow_flash.sh)*)

### Shallow flash?

```
+-------=---+
|   Gaia    | ]                ]
|  -------  | ]- Shallow flash ]
|   Gecko   | ]                ]- Base image flash
|  -------  |                  ]
|   Gonk    |                  ]
|           |
|-----------|
|     ⊙     |
+-----------+
```

Firefox OS has [three layers](http://en.wikipedia.org/wiki/Firefox_OS#Core_technologies), where most development happens in the `Gecko` (browser engine) and `Gaia` (user interface) layers. `Gonk` and lower contain proprietary bits like hardware drivers and RIL and are therefor not build by Mozilla.

## FAQ
Please read this questions before use the tool or submit an issue.

### What devices can be updated with this tool?
TBD

### Why my device is not listed to be updated?
TBD

### My device fails at update
TBD

## Dependencies

* [Node 10.x](http://nodejs.org/download/)
* [ADB](http://developer.android.com/tools/help/adb.html) from the [Android SDK](http://developer.android.com/sdk/index.html)

## Installation

Use the `fxosbuilds` command as [global NPM](http://blog.nodejs.org/2011/03/23/npm-1-0-global-vs-local-installation) command:

```bash
> npm install -g fxosbuilds
```

## Usage

```bash
> fxosbuilds --help

CLI tool for FxOSBuilds updates.
Usage: fxosbuilds [device] [version=central]

Examples:
  fxosbuilds zte-open 2.0                          Flash a ZTE Open with 2.0 build.
  fxosbuilds alcatel-one-touch-fire --folder ~/    Flash an Alcatel One Touch Fire with a nightly build (downloaded to ~/)
  fxosbuilds zte-open --folder ~/ --local          Flash a ZTE Open device with a previously downloaded build in ~/.

Options:
  --device, -i     Device (zte-open, alcatel-one-touch-fire)
  --version, -c    Version (central, aurora, 1.4, …)                                [default: "2.0"]
  --date, -t       Build date (for regression window testing)                       [default: "latest"]
  --dir, -d        Directory to keep downloads (defaults to temp)
  --local, -l      Use local files, skipping FTP (requires --dir)
  --profile, -p    Keep profile (no promises)
  --remotify, -r   Set device into development mode
  --only-remotify  Skip flashing, only set development mode
  --help, -h       Show this help
```

### Settings for `--remotify`

Making life easy for developers (read: not for consumers!). This does not enable remote debugging but also all the little hidden preferences that make development easier, like disabling lockscreen (which would prevent remote debugging) or the remote debugging prompt.

Preferences:

* `'devtools.debugger.forbid-certified-apps': false` Enable debugging for certified apps
* `'devtools.debugger.prompt-connection': false` Disable prompt for remote debugging
* `'b2g.adb.timeout': 0` Disable remote debugging timeout, ([bug 874484](https://bugzilla.mozilla.org/show_bug.cgi?id=874484))
* `'layout.css.report_errors': false` Disable CSS errors in logcat

Settings:

* `'developer.menu.enabled': true`
* `'ftu.manifestURL': null` Disable First-Time-User experience
* `'debugger.remote-mode': 'adb-devtools'` Enable full remote debugging
* `'screen.timeout': 600` 10min screen timeout
* `'lockscreen.locked': false` Unlock screen on launch
* `'lockscreen.enabled': false` Disable lockscreen

## Credits
This tool is based on [Harald Kirschner](https://github.com/digitarald) work done on [flash-b2g](https://github.com/digitarald/flash-b2g). Thanks so much for all you work making that tool. All the credits and eforts goes to you, we only change a few things to adapt it to our needs.
