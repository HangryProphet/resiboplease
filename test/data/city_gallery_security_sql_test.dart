import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('gallery V2 SQL enforces authenticated ownership and privacy', () {
    final sql = File(
      'docs/SUPABASE_CITY_GALLERY_V2.sql',
    ).readAsStringSync().toLowerCase();

    expect(sql, contains('enable row level security'));
    expect(sql, contains('force row level security'));
    expect(sql, contains('owner_id = (select auth.uid())'));
    expect(sql, contains('is_public or owner_id = (select auth.uid())'));
    expect(sql, contains('for update'));
    expect(sql, contains('for delete'));
    expect(
      sql,
      contains('revoke all on table public.city_snapshots from anon'),
    );
    expect(sql, contains('grant update (is_public)'));
    expect(
      sql,
      isNot(contains('grant insert on table public.city_snapshots to anon')),
    );
    expect(
      sql,
      isNot(contains('grant update on table public.city_snapshots to anon')),
    );
    expect(
      sql,
      isNot(contains('grant delete on table public.city_snapshots to anon')),
    );
  });

  test('player profile schema stores only lightweight identity fields', () {
    final sql = File(
      'docs/SUPABASE_CITY_GALLERY_V2.sql',
    ).readAsStringSync().toLowerCase();
    final profileStart = sql.indexOf(
      'create table if not exists public.player_profiles',
    );
    final profileEnd = sql.indexOf(');', profileStart);
    final definition = sql.substring(profileStart, profileEnd);

    expect(definition, contains('user_id'));
    expect(definition, contains('display_name'));
    expect(definition, contains('display_name_normalized'));
    expect(definition, contains('created_at'));
    expect(definition, contains('updated_at'));
    expect(definition, isNot(contains('email')));
    expect(definition, isNot(contains('password')));
    expect(definition, isNot(contains('phone')));
    expect(definition, isNot(contains('biography')));
    expect(definition, isNot(contains('avatar')));
  });
}
