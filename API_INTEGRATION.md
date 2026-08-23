# Public City Gallery API Integration

## API Name

Supabase REST API (PostgREST)

## Purpose

Stores and retrieves sanitized fictional city snapshots for the **Visit
Cities** gallery. A completed local term can publish a deliberately limited
summary; other installations can retrieve, browse, and inspect those public
results asynchronously.

## Endpoints

```text
GET  {SUPABASE_URL}/rest/v1/city_snapshots
POST {SUPABASE_URL}/rest/v1/city_snapshots
```

The GET request adds `select`, `order=created_at.desc`, and `limit=50` query
parameters. The POST request adds `Prefer: return=representation` so the API
returns the inserted row and its database-generated ID.

## Methods

- **GET** — retrieves the newest published cities.
- **POST** — publishes one completed, sanitized city snapshot.

Both requests use Flutter's official `http` package in
`lib/data/gallery/city_gallery_api_service.dart`. The file intentionally shows
`http.get`, `http.post`, `jsonDecode`, and `jsonEncode` directly for the school
API requirement.

## Data Format

JSON. A public row contains only:

```json
{
  "id": "8cbe205b-3304-4a6e-a28a-5e5ad8b27741",
  "city_name": "Harborlight",
  "term_number": 1,
  "starting_pressure": "strained",
  "top_issue": "Water access",
  "selected_candidate_name": "Maya Vargas",
  "candidate_party": "Bayhaven Civic Alliance",
  "final_city_condition": "mixed",
  "outcome_summary": "Public health improved while transport declined.",
  "major_issues": ["Water access", "Transport congestion"],
  "major_events": ["Clinic response", "Water emergency"],
  "created_at": "2026-08-18T09:30:00.000Z"
}
```

The public builder does **not** expose the world seed, entire save file, hidden
candidate capabilities, investigation history, private notes, or secret game
configuration.

## Added Feature

**Public City Gallery / Visit Cities**

- Term Report confirmation and Publish/Publishing/Published/Failed states.
- Sanitized completed-term conversion and HTTP POST.
- Visit Cities loading, success, empty, offline, invalid-response, and server
  failure states.
- Retry support and newest-first city cards.
- A detail page for the selected public snapshot.
- Lightweight local caching of the last successful GET response. Cached cards
  remain visible with an offline notice if the network is unavailable.
- Debug-build JSON response logging with the prefix `[CityGalleryApi]`. Release
  builds do not produce this log.

## Configuration

1. Create a Supabase project.
2. Run [`docs/SUPABASE_CITY_GALLERY.sql`](docs/SUPABASE_CITY_GALLERY.sql) in
   its SQL editor.
3. Copy the project URL and client-safe key. Never use a service-role key,
   secret key, or database password in a client application.
4. Put the values in the git-ignored `config/supabase.local.json`. Use
   `config/supabase.example.json` as the format reference.
5. Run the app with that compile-time configuration:

```powershell
flutter run -d chrome --web-port 7357 `
  --dart-define-from-file=config/supabase.local.json
```

For a release build:

```powershell
flutter build web `
  --dart-define-from-file=config/supabase.local.json
```

These values are kept out of Git, but client configuration is still visible in
a compiled web or mobile application. Row Level Security and least-privilege
database grants are the actual security boundary.

The publishable/anon key is designed for client use and is constrained by Row
Level Security. The SQL grants only public SELECT and sanitized INSERT for this
MVP; no public update or delete policy exists.

## Error Handling

The service maps configuration, network, server, and invalid-response problems
to typed failures. Player screens use short safe messages and never display raw
exceptions or server response bodies. Duplicate publish taps are blocked while
the POST is pending.

## Assignment Screenshots

Useful evidence included in the submission document:

1. `city_gallery_api_service.dart` showing GET, POST, JSON decoding, and JSON
   encoding.
2. A `[CityGalleryApi] GET JSON response:` sample from debug output.
3. Retrieved city cards displayed on the Visit Cities screen.

## Scope

The implemented loop is intentionally **Publish → Retrieve → Browse → View**.
It does not add chat, likes, comments, friend requests, player profiles,
rankings, or real-time multiplayer.
