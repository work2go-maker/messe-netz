-- Messe-Chat Fi Europe 2026: zwei neue Tabellen im Supabase-Projekt me2room (bestehende m2r_-Tabellen bleiben unberuehrt)
create table public.messe_members (
  id uuid primary key,
  room text not null default 'fie2026' check (char_length(room) <= 40),
  name text not null check (char_length(name) between 1 and 60),
  firma text not null default '' check (char_length(firma) <= 80),
  stand text not null default '' check (char_length(stand) <= 20),
  lang text not null default 'en' check (char_length(lang) between 2 and 5),
  created_at timestamptz not null default now()
);
create table public.messe_messages (
  id bigint generated always as identity primary key,
  room text not null default 'fie2026' check (char_length(room) <= 40),
  member_id uuid not null references public.messe_members(id) on delete cascade,
  name text not null check (char_length(name) between 1 and 60),
  firma text not null default '' check (char_length(firma) <= 80),
  stand text not null default '' check (char_length(stand) <= 20),
  lang text not null check (char_length(lang) between 2 and 5),
  text text not null check (char_length(text) between 1 and 800),
  created_at timestamptz not null default now()
);
create index messe_messages_room_created on public.messe_messages(room, created_at desc);
alter table public.messe_members enable row level security;
alter table public.messe_messages enable row level security;
create policy "messe members read" on public.messe_members for select to anon, authenticated using (true);
create policy "messe members join" on public.messe_members for insert to anon, authenticated with check (true);
create policy "messe messages read" on public.messe_messages for select to anon, authenticated using (true);
create policy "messe messages send" on public.messe_messages for insert to anon, authenticated with check (true);
alter publication supabase_realtime add table public.messe_messages;
alter publication supabase_realtime add table public.messe_members;
-- Nach der Messe loeschen:  drop table public.messe_messages; drop table public.messe_members;

-- Zusatz Messe-Netz: Profil-Felder und "Dazulernen" (angesehene Staende)
alter table public.messe_members add column if not exists bietet text[] not null default '{}';
alter table public.messe_members add column if not exists sucht text[] not null default '{}';
alter table public.messe_members add column if not exists about text not null default '' check (char_length(about) <= 400);
create table public.messe_views (
  id bigint generated always as identity primary key,
  room text not null default 'fie2026' check (char_length(room) <= 40),
  viewer uuid not null,
  stand text not null check (char_length(stand) <= 20),
  created_at timestamptz not null default now()
);
alter table public.messe_views enable row level security;
create policy "messe views read" on public.messe_views for select to anon, authenticated using (true);
create policy "messe views add" on public.messe_views for insert to anon, authenticated with check (true);
