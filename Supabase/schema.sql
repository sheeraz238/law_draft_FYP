-- Law Draft: database setup (Supabase / PostgreSQL)

-- 1. Profiles (created automatically at signup)
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text, city text,
  law_firm text default 'Individual',
  enrollment_no text, whatsapp text,
  draft_credits int default 3,
  caselaw_credits int default 10,
  created_at timestamptz default now()
);
alter table public.profiles enable row level security;
drop policy if exists "own profile read" on public.profiles;
create policy "own profile read" on public.profiles for select using (auth.uid() = id);
drop policy if exists "own profile update" on public.profiles;
create policy "own profile update" on public.profiles for update using (auth.uid() = id);
revoke update on public.profiles from authenticated;
grant update (full_name, city, law_firm, enrollment_no, whatsapp) on public.profiles to authenticated;

create or replace function public.handle_new_user() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  insert into public.profiles (id, full_name)
  values (new.id, new.raw_user_meta_data->>'full_name');
  return new;
end;
$$;
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users
for each row execute function public.handle_new_user();

create or replace function public.use_draft_credit() returns int
language plpgsql security definer set search_path = public as $$
declare remaining int;
begin
  update public.profiles set draft_credits = draft_credits - 1
  where id = auth.uid() and draft_credits > 0
  returning draft_credits into remaining;
  if remaining is null then raise exception 'No draft credits left'; end if;
  return remaining;
end;
$$;
revoke all on function public.use_draft_credit() from public, anon;
grant execute on function public.use_draft_credit() to authenticated;

-- 2. Case laws and favorites
create table if not exists public.case_laws (
  id uuid primary key default gen_random_uuid(),
  title text not null, citation text, court text, year int, summary text,
  source_url text, topic text,
  created_at timestamptz default now()
);
alter table public.case_laws enable row level security;
drop policy if exists "case laws read" on public.case_laws;
create policy "case laws read" on public.case_laws for select to authenticated using (true);
grant select on public.case_laws to authenticated;

create table if not exists public.favorites (
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  case_law_id uuid not null references public.case_laws(id) on delete cascade,
  created_at timestamptz default now(),
  primary key (user_id, case_law_id)
);
alter table public.favorites enable row level security;
drop policy if exists "own favorites read" on public.favorites;
create policy "own favorites read" on public.favorites for select to authenticated using (auth.uid() = user_id);
drop policy if exists "own favorites add" on public.favorites;
create policy "own favorites add" on public.favorites for insert to authenticated with check (auth.uid() = user_id);
drop policy if exists "own favorites remove" on public.favorites;
create policy "own favorites remove" on public.favorites for delete to authenticated using (auth.uid() = user_id);
grant select, insert, delete on public.favorites to authenticated;

-- 3. Draft history
create table if not exists public.generated_drafts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  template_id text not null, title text not null, form_data jsonb not null,
  created_at timestamptz default now()
);
alter table public.generated_drafts enable row level security;
drop policy if exists "own drafts read" on public.generated_drafts;
create policy "own drafts read" on public.generated_drafts for select to authenticated using (auth.uid() = user_id);
drop policy if exists "own drafts add" on public.generated_drafts;
create policy "own drafts add" on public.generated_drafts for insert to authenticated with check (auth.uid() = user_id);
drop policy if exists "own drafts remove" on public.generated_drafts;
create policy "own drafts remove" on public.generated_drafts for delete to authenticated using (auth.uid() = user_id);
grant select, insert, delete on public.generated_drafts to authenticated;

-- 4. Legal guides
create table if not exists public.legal_guides (
  id uuid primary key default gen_random_uuid(),
  topic text not null, title text not null, summary text,
  steps jsonb not null default '[]', documents jsonb not null default '[]',
  draft_ids jsonb not null default '[]', keywords jsonb not null default '[]',
  reviewed_by text, reviewed_on date,
  created_at timestamptz default now()
);
alter table public.legal_guides enable row level security;
drop policy if exists "guides read" on public.legal_guides;
create policy "guides read" on public.legal_guides for select to authenticated using (true);
grant select on public.legal_guides to authenticated;

-- 5. Legal updates (headlines with links)
create table if not exists public.legal_updates (
  id uuid primary key default gen_random_uuid(),
  title text not null, source text, category text, url text not null,
  published_on date, created_at timestamptz default now()
);
alter table public.legal_updates enable row level security;
drop policy if exists "updates read" on public.legal_updates;
create policy "updates read" on public.legal_updates for select to authenticated using (true);
grant select on public.legal_updates to authenticated;

-- 6. Draft templates (form + document as JSON)
create table if not exists public.draft_templates (
  id text primary key,
  title text not null, category text not null, tag text, description text,
  form jsonb not null, document jsonb not null,
  published boolean not null default true, sort int not null default 100,
  created_at timestamptz default now()
);
alter table public.draft_templates enable row level security;
drop policy if exists "templates read" on public.draft_templates;
create policy "templates read" on public.draft_templates for select to authenticated using (published = true);
grant select on public.draft_templates to authenticated;