-- Enable required extensions
create extension if not exists "uuid-ossp";

-- 1. Table: users
CREATE TABLE public.users (
  id text NOT NULL,
  products_data jsonb,
  advance jsonb,
  controller_left jsonb,
  controller_right jsonb,
  banking_data jsonb,
  created_at timestamp with time zone,
  first_name text,
  last_name text,
  profile_image_url text,
  CONSTRAINT users_pkey PRIMARY KEY (id)
);

-- 2. Table: Name
CREATE TABLE public.Name (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT Name_pkey PRIMARY KEY (id)
);

-- 3. Table: profiles
CREATE TABLE public.profiles (
  id uuid NOT NULL,
  first_name text,
  last_name text,
  profile_image_url text,
  created_at timestamp with time zone DEFAULT timezone('utc'::text, now()),
  email text,
  phone text,
  profile_image text,
  CONSTRAINT profiles_pkey PRIMARY KEY (id),
  CONSTRAINT profiles_id_fkey FOREIGN KEY (id) REFERENCES auth.users(id)
);

-- 4. Table: receipts
CREATE TABLE public.receipts (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  user_id uuid DEFAULT auth.uid(),
  file_name text,
  file_path text,
  pdf_url text,
  metadata jsonb,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT receipts_pkey PRIMARY KEY (id),
  CONSTRAINT receipts_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id)
);

-- 5. Storage Policies for bucket "pdf"
-- NOTE: Bucket 'pdf' must be created manually in the Supabase dashboard before running these.

INSERT INTO storage.policies (id, bucket_id, name, definition, action, created_at, updated_at)
VALUES (
  uuid_generate_v4(),
  'pdf',
  'Authenticated users can read their own files',
  'auth.role() = ''authenticated'' AND (storage.filename(name))[1] = auth.uid()',
  'read',
  now(),
  now()
);

INSERT INTO storage.policies (id, bucket_id, name, definition, action, created_at, updated_at)
VALUES (
  uuid_generate_v4(),
  'pdf',
  'Authenticated users can write their own files',
  'auth.role() = ''authenticated'' AND (storage.filename(name))[1] = auth.uid()',
  'write',
  now(),
  now()
);