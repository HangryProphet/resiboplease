# Audio Asset Sources

This file records the origin and intended use of audio committed to **Resibo,
Please**. Do not add audio whose redistribution rights are unclear.

## Kenney UI Audio

- Pack: **UI Audio** by Kenney
- Official source: <https://kenney.nl/assets/ui-audio>
- License: **Creative Commons CC0 1.0 Universal (public domain dedication)**
- Attribution: not required; credit is included here for provenance.
- Download used for this project: the official archive linked from the source
  page.

The source files were renamed to describe their game-wide purpose. They remain
short OGG effects and are reused through the centralized `GameAudioService`.

| Project asset | Original Kenney file | Main use |
| --- | --- | --- |
| `ui_tap.ogg` | `click1.ogg` | ordinary game buttons |
| `ui_back.ogg` | `click2.ogg` | back and close navigation |
| `ui_tab.ogg` | `click3.ogg` | tabs and segmented navigation |
| `ui_confirm.ogg` | `switch1.ogg` | settings and confirmations |
| `ui_error.ogg` | `switch8.ogg` | blocked or invalid actions |
| `document_open.ogg` | `switch12.ogg` | evidence and document readers |
| `bookmark.ogg` | `switch5.ogg` | evidence bookmarks |
| `notification.ogg` | `switch15.ogg` | ordinary city developments |
| `critical_alert.ogg` | `switch26.ogg` | critical city events |
| `chat_message.ogg` | `switch3.ogg` | comments and message reveals |
| `social_reaction.ogg` | `switch4.ogg` | social reactions |
| `receipt_found.ogg` | `switch18.ogg` | newly discovered paid evidence |
| `vote_select.ogg` | `switch2.ogg` | ballot candidate selection |
| `ballot_drop.ogg` | `switch31.ogg` | final ballot confirmation |
| `positive_event.ogg` | `switch17.ogg` | beneficial city developments |
| `negative_event.ogg` | `switch35.ogg` | harmful city developments |

The pack's original license text is also stored at
`assets/audio/sfx/KENNEY_UI_AUDIO_LICENSE.txt`.

## Existing dialogue sound

`assets/audio/dialogue/reporter_robot_blip.wav` predates this stabilization
pass and is used only for the fictional R-8 reporter's optional typewriter
dialogue blip. It is not one of the selected Kenney UI effects. Its original
project provenance should be confirmed before a public commercial release; it
may be replaced independently without changing the shared SFX mappings.

## Background music policy

The runtime safely checks for the following optional files:

- `assets/audio/music/menu/menu_theme.ogg`
- `assets/audio/music/investigation/investigation_theme.ogg`
- `assets/audio/music/simulation/simulation_theme.ogg`

OGG files currently exist at those paths, but their source and redistribution
license have not been recorded in this repository. Treat them as local
classroom placeholders until the user confirms their provenance. Removing them
does not stop the game from launching. Properly licensed tracks at those paths
enable looping, phase-aware playback, volume control, fades, lifecycle
pause/resume, and TV ducking.

Do not commit commercial game, anime, film, or other copyrighted placeholder
music. Any classroom-only local placeholder must be removed and replaced with
original, CC0, or appropriately licensed royalty-free music before a public
release.
