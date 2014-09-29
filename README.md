# FxOSBuilds cli installer

CLI installer to manage/install/update/download builds from FxOSBuilds site.  Shallow-flash Gecko and Gaia on Firefox OS devices from Mozilla's public build server with just one command.

[![NPM version](http://img.shields.io/npm/v/fxosbuilds.svg?style=flat)](https://www.npmjs.org/package/fxosbuilds)
[![Dependency Status](http://img.shields.io/gemnasium/digitarald/flash-b2g.svg?style=flat)](https://gemnasium.com/digitarald/flash-b2g)

## What does it do?

1. **Downloads build**, matched by `device`, `channel` and `date`, from http://ftp.mozilla.org/pub/mozilla.org/b2g/nightly/
2. **Flash Gecko and Gaia**, a so called *[shallow flash](https://github.com/Mozilla-TWQA/B2G-flash-tool/blob/master/shallow_flash.sh)*)

### Shallow flash?

```
+-----------+
|         ⊙ |
-------------
|           |
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

We just flash only Gaia and Gecko.

### Why shallow updates and not full updates?

Firefox OS has [three layers](http://en.wikipedia.org/wiki/Firefox_OS#Core_technologies), where most development happens in the `Gecko` (browser engine) and `Gaia` (user interface) layers. `Gonk` and lower contain proprietary bits like hardware drivers and RIL and are therefor not build by Mozilla, those proprietary bits (blobs) has copyright. So, thats why we cannot distribute full updates to be installed by CWM or Fastboot. 

*Thank you copyright :)* 

### What are the alternatives?

* **[Build Gecko and Gaia](https://developer.mozilla.org/en-US/Firefox_OS/Building) from source** and [flash them](https://developer.mozilla.org/en-US/Firefox_OS/Installing_on_a_mobile_device) on your phone.

## Dependencies

* [Node 10.x](http://nodejs.org/download/)

## Installation

Use the `fxosbuilds` command as [global NPM](http://blog.nodejs.org/2011/03/23/npm-1-0-global-vs-local-installation) command:

```bash
> npm install -g fxosbuilds
```

## How my device is named?

Check the table and remplace with the codename of your device:

+---------------------------+-------------+
|          Device           |   Codename  |
+-------------+-------------+-------------+
|         ZTE Open          |    inari    |
|   Alcatel One Touch Fire  |    hamachi  |
|        LG Fireweb         |     leo     |
|        Huawei Y300        |    helix    |
|      inFocus Tablet       |   flatfish  |
+---------------------------+-------------+

Usage:

* **Ej: Your device is a ZTE Open**
```bash
> fxosbuild inari
```

* **Ej: Your device is an Alcatel One Touch Fire**
```bash
> fxosbuild hamachi
```

* **Ej: Your device is a inFocus Tablet**
```bash
> fxosbuild flatfish
```


## Usage

```bash
> fxosbuilds --help

Flash/Update your Firefox OS devices from FxOSBuilds public build server (http://downloads.firefoxosbuilds.org/).
Usage: fxosbuilds [device] [channel]

Examples:
  fxosbuilds inari stable                 Flash a inari with stable build.
  fxosbuilds inari --folder ~/            Flash a inari with a nightly build (downloaded to ~/)
  fxosbuilds inari --folder ~/ --local    Flash a inari device with a previously downloaded build in ~/.
  fxosbuilds hamachi aurora --eng         Flash an hamachi device with an aurora engineering build.


Options:
  --device, -i    Device (flame, helix, hamachi, …)       [default: "flame"]
  --channel, -c   Channel (central, aurora, 1.4, …)       [default: "central"]
  --date, -t      Build date (regression window testing)  [default: "latest"]
  --eng, -e       Engineering build (marionette testing)
  --local, -l     Use local files, skipping FTP
  --profile, -p   Keep profile (no promises)
  --remotify, -r  Set device into development mode
  --help          Show this help
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

## Thanks

This cli was inspired on the [digitarald work](https://github.com/digitarald/flash-b2g). Many thanks to him and his idea to wrap scripts with nodejs.