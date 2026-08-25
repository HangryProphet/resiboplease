# Resibo, Please — Android Midterm Release Readiness

Audit date: **August 25, 2026**

This pass stabilized the existing vertical slice. It did not add a new gameplay
system. “Automated” below means covered by the repository test suite; “code
audit” means the relevant route, state transition, validation, or failure path
was inspected. A real Android-device result is never inferred from a web build.

## Release status

**Project checks pass, but an Android APK has not been produced on this PC.**
The installed Flutter SDK cannot find an Android SDK. Install/configure Android
Studio and its SDK, accept licenses, then rerun the APK command. Real-device
testing is also still required before the classroom demonstration.

## Automated checks

| Check | Result | Detail |
| --- | --- | --- |
| `flutter clean` | PASS | Build outputs removed; Flutter retried one temporarily locked `.dart_tool` directory and completed successfully. |
| `flutter pub get` | PASS | Dependencies restored. Available incompatible upgrades were informational only. |
| `flutter analyze` | PASS | No issues found. |
| `flutter test` | PASS | All **153** tests passed, including gallery V2 identity, privacy, ownership, REST-method, and SQL-policy coverage. |
| `flutter build web` | PASS | Production output created at `build/web`. The optional WebAssembly dry run also succeeded. |
| `flutter build apk --release` | BLOCKED | Flutter stopped with `No Android SDK found. Try setting the ANDROID_HOME environment variable.` No APK was generated. |

## Functional audit

| Major system | Result | Evidence and scope |
| --- | --- | --- |
| Main menu and city slots | PASS (automated/code audit) | Phone-layout, How to Play, create/continue/delete confirmation, and save-slot behavior are widget-tested. Routes for menu actions are registered. |
| City creation | PASS (automated) | Seeded issue generation, five unique candidate IDs/names/portraits, gender-compatible names, cross-system references, different-seed variety, and same-seed stability are tested. City names are trimmed, required, and limited to 24 characters in the form. |
| City Brief and Chronicle | PASS (automated/code audit) | Responsive city screens, issue flow, shared event information, Chronicle coverage, and pre-election navigation are exercised by widget/domain tests. |
| Five-candidate investigation | PASS (automated) | Roster, Candidate Hub, Biography citations, four promises, Campaign Trail, Debate, Records, evidence links, bookmarks, investigation costs/unlocks, Receipts Board state, localization, and responsive layouts are covered. Generated cross-references and persistence round trips are validated. |
| CityBook, News, and TV | PASS (automated) | Deterministic contextual posts/comments/reactions, one-event/multiple-framings news, article links, R-8 reports, player pacing, reduced motion, dialogue-sound setting, and disposal are tested. |
| Election | PASS (automated/code audit) | Candidate/issue/confidence selection, single confirmed submission, winner transition, and elected-candidate handoff into the term are covered by the complete MVP widget test. |
| Living City | PASS (automated/code audit) | Deterministic 365-day history, bounded date/state, Day/Week/Month/Year controls, year completion, event prerequisites/cooldowns/chains, map anchors/locations, project reviews, marker/history state, persistence, and final report are covered. |
| Save and reload | PASS (automated) | Save codecs, migrations, generated election snapshots, living-city snapshots, local slots, and completed-run resume are tested. The generated data is restored rather than rerolled. |
| Settings | PASS (automated) | English/Filipino, reduced motion, high contrast, dialogue sounds, SFX on/off and volume, optional music on/off and volume, critical-event interruption, persistence, and reset behavior are covered by controller/widget tests. |
| Audio | PASS (automated/code audit) | All mapped SFX assets resolve; enable/volume settings, missing optional music, context changes, and ducking state are tested. Playback failures are caught and never block gameplay. Physical loudness still needs device verification. |

The automated suite exercises the full ballot-to-term-report loop and targeted
navigation flows. It cannot replace a human Android pass for touch ergonomics,
speaker volume, lifecycle restoration after the OS kills the app, or device GPU
performance.

## Audio audit

- One centralized `GameAudioService` owns short SFX and the optional music
  player. Widgets do not decode a new file independently on every tap.
- Four reusable low-latency SFX players allow short overlaps. Assets are
  preloaded, and a short same-sound throttle limits rapid duplicate taps.
- UI, back, tab, confirmation, error, document, bookmark, receipt, social,
  election, and simulation-event actions use a small coherent vocabulary.
- Music contexts are menu, investigation, and simulation. The same context does
  not restart during Candidate Hub tab/related-page navigation.
- Looping, fades, lifecycle pause/resume, volume, enable/disable, and TV ducking
  are implemented.
- Music files are present at the optional paths, but their provenance is not
  recorded. Missing files are still handled as silence. Confirm or replace the
  current tracks before public distribution; see `AUDIO_ASSET_SOURCES.md`.

## Public City Gallery API audit

| Area | Result | Detail |
| --- | --- | --- |
| POST | PASS (automated) | Creates the minimal player profile and sends only sanitized snapshot fields; database ownership is omitted from the city body. |
| GET | PASS (automated) | Retrieves filtered public/owned cities and server-side player search results with typed parsing. |
| PATCH / DELETE | PASS (automated) | Owner-matched requests toggle only privacy or delete only the uploaded snapshot; another local session is rejected before a request. |
| JSON safety | PASS (automated) | Invalid response shapes, malformed rows, excessive field lengths, excessive lists, server errors, and non-HTTPS configuration become safe typed failures. |
| UI states | PASS (automated/code audit) | Loading, success, empty, configuration, offline, invalid-response, failure, and Retry treatments exist. |
| Offline cache | PASS (automated/code audit) | Public and owned lists are cached separately; owned rows are filtered to the current authenticated ID. Writes require a connection. |
| Live Supabase project | NOT VERIFIED HERE | Apply the V2 SQL, enable Anonymous Sign-Ins, then test live GET/POST/PATCH/DELETE without exposing credentials. |

Network failure remains isolated from the local save and simulation. Public API
errors shown to players do not expose keys, database details, or private save
content.

## Security audit

- Repository scan found no committed service-role key, database password,
  private server key, GitHub token, service-account JSON, or hardcoded password.
- `config/supabase.local.json` is ignored by `/config/*.local.json`; only the
  placeholder example file is tracked. Flutter runtime configuration uses
  compile-time `SUPABASE_URL` and `SUPABASE_ANON_KEY` values.
- The client requires HTTPS and inspects JWT payloads to reject a
  `service_role` key. Only a publishable/anon client key is appropriate.
- `PublicCitySnapshot` contains a deliberately small public schema. It cannot
  serialize the world seed, full save, hidden candidate values, investigation
  history, bookmarks, or private notes.
- Remote text and list lengths are bounded and trimmed. Content is rendered as
  Flutter text, not executable HTML; arbitrary remote media URLs are not part
  of the schema.
- API response diagnostics run only in debug mode, are truncated, and contain
  public snapshot responses—not headers or authorization keys. No private save
  or hidden-candidate debug logging was found.
- `docs/SUPABASE_CITY_GALLERY_V2.sql` enables/forces RLS, removes every old
  gallery policy, denies the unauthenticated database role, exposes only player
  name/ID/timestamps, enforces `auth.uid()` ownership, hides private rows from
  other users, and restricts client UPDATE privileges to `is_public`.

Important: repository SQL proves the intended policy, not the state of the
deployed database. Before the demo, rerun/review that SQL in the correct
Supabase project and confirm RLS is enabled in the dashboard. Never use a
service-role key in the APK.

## Android audit

- Application label: `Resibo, Please`.
- Android namespace/application ID: `com.resiboplease.game`.
- `MainActivity` package and location match that namespace.
- Internet permission is declared for the optional gallery.
- Flutter manages min/target/compile SDK versions and the activity handles the
  normal Flutter configuration changes with hardware acceleration enabled.
- Declared fonts, production images, SFX, dialogue audio, and optional music
  directories resolve during analysis/tests/web compilation. The production
  expanded map is about 3.3 MB; alternate map files are not declared in
  `pubspec.yaml` and therefore are not packaged merely because they remain in
  the working tree.
- Release currently uses debug signing intentionally for a classroom/demo APK.
  This is not acceptable for Play Store/public distribution; use a private
  release/upload keystore later.

### Build this APK on the development PC

1. Install Android Studio with Android SDK, Platform Tools, Build Tools, and a
   current Android SDK platform.
2. Point Flutter to it if discovery fails:
   `flutter config --android-sdk "C:\\Users\\<you>\\AppData\\Local\\Android\\Sdk"`.
3. Run `flutter doctor --android-licenses`, accept the licenses, then confirm
   `flutter doctor -v` shows a working Android toolchain.
4. Run `flutter build apk --release`.
5. Confirm the artifact at
   `build/app/outputs/flutter-apk/app-release.apk`, then install and test that
   exact release artifact on a physical phone.

### Mandatory physical-device path

```text
Launch
→ Start New City
→ City Brief
→ Candidate Roster
→ Biography
→ Debate
→ CityBook
→ Records
→ Vote
→ Living City
→ Day / Week / Month / Year
→ Open Event
→ Chronicle
→ News
→ TV Broadcast
→ Term Report
→ Publish City Snapshot
→ Visit Cities
→ Close App completely
→ Reopen
→ Continue Save
```

During this pass, verify SFX loudness, dialogue toggle, music-safe silence,
Filipino text, reduced motion, back behavior, API offline behavior, map pan/zoom,
Day 365, and restoration of candidate/event/project state. This checklist is
currently **pending** because no Android SDK/device was available here.

## Remaining non-blocking issues

- Confirm the license/source of the three current music files or replace them
  with properly licensed tracks before public distribution.
- Confirm or replace the pre-existing reporter dialogue-blip asset before a
  public commercial release.
- Replace the default Flutter launcher icon with a Resibo, Please icon when the
  final brand icon is approved.
- Configure production signing before any public/app-store release.
- Run a live Supabase GET/POST and verify deployed RLS in the classroom project.
- Perform the exact release-APK physical-device checklist above.
- Alternate large city-map files remain as development/reference assets but are
  not declared for packaging. They may be archived later after the approved
  map is final.

Once the release APK passes the complete device path, freeze features for the
midterm and limit changes to crashes, broken controls, severe visual problems,
API/security failures, and release blockers.
