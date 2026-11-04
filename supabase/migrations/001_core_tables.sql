-- Roles and attendance choices
create type user_role as enum ('owner', 'admin', 'coach', 'parent');
create type attendance_status as enum ('present', 'absent', 'late', 'excused');

-- Staff and parents who log in (linked to Supabase's login system)
create table profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  phone text unique not null,
  full_name text,
  role user_role not null default 'parent',
  created_at timestamptz default now()
);

-- Sports offered (Football, Cricket...)
create table sports (
  id uuid primary key default gen_random_uuid(),
  name text unique not null
);

-- Students (athletes)
create table students (
  id uuid primary key default gen_random_uuid(),
  first_name text not null,
  last_name text,
  date_of_birth date,
  status text not null default 'active' check (status in ('active', 'paused', 'left')),
  joined_on date default current_date,
  created_at timestamptz default now()
);

-- Parents' phone numbers for each student (used to match parents at login)
create table guardians (
  id uuid primary key default gen_random_uuid(),
  student_id uuid not null references students(id) on delete cascade,
  name text,
  phone text not null,
  relation text default 'parent',
  user_id uuid references auth.users(id),
  unique (student_id, phone)
);

-- Batches: a group with a sport, coach and weekly timing
create table batches (
  id uuid primary key default gen_random_uuid(),
  sport_id uuid not null references sports(id),
  name text not null,
  coach_id uuid references profiles(id),
  days_of_week int[] not null default '{}',  -- 1 = Monday ... 7 = Sunday
  start_time time,
  end_time time,
  venue text,
  is_active boolean default true
);

-- Which student is in which batch
create table enrollments (
  id uuid primary key default gen_random_uuid(),
  student_id uuid not null references students(id) on delete cascade,
  batch_id uuid not null references batches(id) on delete cascade,
  start_date date not null default current_date,
  end_date date,
  unique (student_id, batch_id, start_date)
);

-- One class on one date
create table sessions (
  id uuid primary key default gen_random_uuid(),
  batch_id uuid not null references batches(id) on delete cascade,
  date date not null,
  status text not null default 'scheduled' check (status in ('scheduled', 'completed', 'cancelled')),
  unique (batch_id, date)
);

-- Attendance: one row per student per session
create table attendance (
  id uuid primary key default gen_random_uuid(),
  session_id uuid not null references sessions(id) on delete cascade,
  student_id uuid not null references students(id) on delete cascade,
  status attendance_status not null,
  note text,
  marked_by uuid references profiles(id),
  marked_at timestamptz default now(),
  unique (session_id, student_id)
);

-- Lock every table until we write access rules (Lesson 4)
alter table profiles enable row level security;
alter table sports enable row level security;
alter table students enable row level security;
alter table guardians enable row level security;
alter table batches enable row level security;
alter table enrollments enable row level security;
alter table sessions enable row level security;
alter table attendance enable row level security;

-- Starter data
insert into sports (name) values ('Football');