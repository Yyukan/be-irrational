# Be Irrational

Be Irrational is an iPhone and iPad app for the things you would like to do, not a schedule.
Wishes are grouped into scopes of your life ("Take care of my health"); each scope holds the
occupations you would do now, with a progress ring and a day counter. Things can be put aside for
Someday, marked Completed or sent to the Trash.

## How to use it

| Where | What |
| --- | --- |
| Now tab, **+** | add a scope, or pick one of the suggested scopes |
| a scope, **+** | add an occupation |
| an occupation | set its progress; arrows (or a horizontal swipe) go to the next and previous one |
| swipe a row left | move it to Someday, Completed or Trash (on a scope: all its occupations) |
| swipe a row right | edit title and note |
| **Edit** | reorder, delete a scope, trash an occupation |
| Trash tab, **Empty** | delete the trashed occupations for good |

Everything stays on the device. Version 1.3 opens the Core Data store of 1.2
(`Documents/DataModel.sqlite`, same `DataModel` model), so an update keeps all the data.

## How to build

Needs Xcode 26.6 or later (iOS 26 SDK) and [XcodeGen](https://github.com/yonaskolb/XcodeGen)
(`brew install xcodegen`).

```sh
open BeIrrational.xcodeproj    # pick a simulator or your device, then ⌘R
```

Signing is automatic with team `G6LUHT349V`. The project is generated from `project.yml`; after
adding, moving or removing files, run `xcodegen generate` and commit the result. The scheme runs
the Release build; debug builds take launch arguments for sample data (see `App/Launch.swift`).

The app icon is drawn by `tools/build-app-icon.py` (`/usr/bin/python3`, Pillow);
`--sketches` also writes the alternatives to `docs/icon-sketches/` (not committed).

## How to test

```sh
# everything (unit + UI)
xcodebuild -project BeIrrational.xcodeproj -scheme BeIrrational \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' test

# unit tests only
xcodebuild -project BeIrrational.xcodeproj -scheme BeIrrational \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  -only-testing:BeIrrationalTests test
```

The unit tests run on in-memory stores and on `Tests/Fixtures/Legacy-1.2.sqlite`, a store written
by the original Objective-C app. The UI tests use an in-memory store with sample data.

## Release

`scripts/screenshots.sh` takes the App Store screenshots; `scripts/resubmit.sh [--upload]`
archives and uploads a build. Texts for App Store Connect are in `assets/app-store-texts.md`.
