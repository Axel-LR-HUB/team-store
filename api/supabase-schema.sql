-- ============================================================
--  TEAM STORE — Schéma Supabase
--  Colle ce SQL dans : Supabase > SQL Editor > New query
-- ============================================================

-- Table des commandes
create table if not exists orders (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid references auth.users(id),
  user_email  text,
  items       jsonb    not null,   -- contenu du panier (produit, taille, qté)
  total_eur   numeric  not null,
  status      text     not null default 'paid',  -- paid | refunded | pending
  created_at  timestamptz not null default now()
);

-- Sécurité : chaque membre ne voit que SES commandes
alter table orders enable row level security;

create policy "Voir ses propres commandes"
  on orders for select
  using (auth.uid() = user_id);

create policy "Créer une commande"
  on orders for insert
  with check (auth.uid() = user_id);

-- Vue admin : toutes les commandes (à utiliser dans Supabase Studio)
create or replace view admin_orders as
  select
    o.id,
    o.user_email,
    o.total_eur,
    o.status,
    o.created_at,
    item->>'name'  as product_name,
    item->>'size'  as size,
    (item->>'qty')::int as qty
  from orders o,
       jsonb_array_elements(o.items) as item
  order by o.created_at desc;

-- ============================================================
--  Note : la table auth.users est créée automatiquement
--  par Supabase Auth — pas besoin de la créer manuellement.
-- ============================================================
