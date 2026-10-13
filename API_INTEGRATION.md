# Public City Gallery API Integration V2

> **October 2026 source audit:** V2 and
> `docs/SUPABASE_CITY_GALLERY_V2.sql` are the authoritative client/database
> contract. The repository implementation was inspected, but the live Supabase
> project and network operations were not exercised during this audit.

## API

**Supabase REST API (PostgREST)** with **Supabase Anonymous Auth** for a hidden,
stable owner identity.

The player supplies only a 3–24 character display name. There is no email,
password, phone number, avatar, biography, friends list, or messaging system.
Normal local gameplay never requires community identity setup.

## Features

- Create/fetch the current anonymous player's display-name profile.
- Publish a sanitized completed city as Public or Private.
- Retrieve public cities for Explore.
- Retrieve both public and private owned cities for My Cities.
- Search player display names with a debounced server-side partial query.
- Retrieve only one searched player's public cities.
- Change an owned snapshot between Public and Private.
- Delete an owned uploaded snapshot without deleting the local save.
- Cache the last successful public list, owned list, and matching profile.

## Explicit REST operations

The database integration remains explicit in
`lib/data/gallery/city_gallery_api_service.dart` for the school API requirement:

```text
GET    {SUPABASE_URL}/rest/v1/city_snapshots?is_public=eq.true
GET    {SUPABASE_URL}/rest/v1/city_snapshots?owner_id=eq.<auth-user-id>
POST   {SUPABASE_URL}/rest/v1/city_snapshots
PATCH  {SUPABASE_URL}/rest/v1/city_snapshots?id=eq.<snapshot-id>
DELETE {SUPABASE_URL}/rest/v1/city_snapshots?id=eq.<snapshot-id>

GET    {SUPABASE_URL}/rest/v1/player_profiles?user_id=eq.<auth-user-id>
GET    {SUPABASE_URL}/rest/v1/player_profiles?display_name_normalized=ilike.*query*
POST   {SUPABASE_URL}/rest/v1/player_profiles
```

The file intentionally retains direct `http.get`, `http.post`, `http.patch`,
`http.delete`, `jsonEncode`, and `jsonDecode` calls. `supabase_flutter` is used
only to create, persist, and refresh the anonymous authentication session.
PostgREST requests use the client-safe project key as `apikey` and the current
user access token as the Bearer token, allowing `auth.uid()` RLS checks.

## Public city JSON

Retrieved rows contain the sanitized city data plus ownership presentation:

```json
{
  "id": "8cbe205b-3304-4a6e-a28a-5e5ad8b27741",
  "owner_id": "server-controlled-auth-user-id",
  "is_public": true,
  "player_profiles": {"display_name": "Kazuma"},
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

The POST body omits `id` and `owner_id`. PostgreSQL assigns `owner_id` from
`auth.uid()`, column grants prevent clients from inserting/updating that field,
and RLS independently verifies ownership. The builder cannot serialize the
world seed, save file, hidden candidate capabilities, investigation history,
bookmarks, or private notes.

## Supabase setup

1. Open the intended Supabase project.
2. In **Authentication → Providers**, enable **Anonymous Sign-Ins**. Supabase
   may display this as an Anonymous provider/settings switch.
3. For a publicly exposed build, also configure CAPTCHA/Turnstile and review
   anonymous sign-in rate limits to reduce automated account creation.
4. Run [`docs/SUPABASE_CITY_GALLERY_V2.sql`](docs/SUPABASE_CITY_GALLERY_V2.sql)
   in the SQL Editor.
5. Do **not** rerun the old V1 SQL after V2.
6. Copy the project URL and client-safe publishable/legacy anon key. Never use a
   service-role key, secret key, database password, or server credential.
7. Store values in the git-ignored `config/supabase.local.json` using
   `config/supabase.example.json` as the shape.

Run locally:

```powershell
flutter run -d chrome --web-port 7357 `
  --dart-define-from-file=config/supabase.local.json
```

Build:

```powershell
flutter build apk --release `
  --dart-define-from-file=config/supabase.local.json
```

Client keys remain extractable from a compiled app by design. RLS and narrow
database grants—not obscuring the publishable key—are the security boundary.

## Migration behavior

The V2 script is safe to run over the existing table structure, but V1 rows do
not contain trustworthy ownership. Inside one transaction it:

1. creates `player_profiles`;
2. adds `owner_id` and `is_public` when missing;
3. deletes only legacy `city_snapshots` rows where `owner_id is null`;
4. makes ownership mandatory and adds the owner foreign key/indexes;
5. removes every old gallery/profile policy;
6. creates the V2 RLS policies and least-privilege column grants.

Back up legacy development rows before running it if they matter. They cannot
be assigned to a player securely after the fact, so completed cities must be
republished. Rerunning the V2 script later does not delete correctly owned rows.

## RLS summary

`player_profiles`:

- SELECT: authenticated sessions may search display names.
- INSERT: only a row whose `user_id = auth.uid()`.
- UPDATE: only the same user's row.
- Stored public fields: user ID, display name, normalized name, timestamps.

`city_snapshots`:

- SELECT: `is_public = true OR owner_id = auth.uid()`.
- INSERT: authenticated only and `owner_id = auth.uid()`.
- UPDATE: owner only; database grants restrict the client to `is_public`.
- DELETE: owner only.
- The unauthenticated `anon` database role receives no table privileges.

An Anonymous Auth user uses the `authenticated` database role and has a stable
`auth.uid()` for the persisted session. The raw UUID is never displayed.

## Offline and error handling

- Cached Explore/My Cities lists may be shown after a network/server failure.
- Owned cache rows are filtered against the current authenticated user ID.
- Publish, privacy changes, profile creation, and deletion are never reported as
  successful while offline; there is no fake queued-write system.
- Duplicate name, unavailable configuration, auth failure, timeout, malformed
  JSON, RLS denial, and deleted-row conditions map to short player-safe states.
- Raw Postgres/Supabase response bodies and credentials are not displayed.

## Current limitations

- Anonymous identity belongs to one local Supabase session. Clearing app/browser
  data, signing out, or moving to another device loses access to that anonymous
  identity and its private uploads because there is deliberately no recovery
  email/password.
- There are no friends, follows, chat, likes, comments, avatars, profiles beyond
  display name, or rankings.
- A live deployment must be checked after applying SQL; repository tests verify
  request filtering and policy definitions but cannot prove dashboard state.
