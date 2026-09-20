# Git-thrift

Family resale tool: scout thrift racks from video, write listings, format them per site, draft buyer replies.
Static site on Render, shared inventory in Supabase, Claude API called straight from the phone.

```
public/        the whole app (index.html, config.js, manifest, icons)
schema.sql     run once in Supabase
render.yaml    Render blueprint (static site, publishes ./public)
```

## 1. Supabase (about 5 minutes)

1. Create a project.
2. SQL Editor → paste `schema.sql` → Run.
3. Add the family (SQL Editor):
   ```sql
   insert into public.members (email) values
     ('you@example.com'), ('wife@example.com'), ('daughter@example.com');
   ```
4. Authentication → Sign In / Providers → Email: leave **Confirm email ON**.
   The family list trusts the email on the account, so it has to be a verified one.
5. Project Settings → API: copy the **Project URL** and the **anon / publishable key**
   into `public/config.js`. Both are safe to commit; row-level security guards the data.
   Never put the `service_role` key in this repo.

## 2. Render

1. Push this folder to a GitHub repo.
2. Render → New → Static Site → pick the repo.
   Build command: leave empty (or `echo ok`). Publish directory: `public`.
   (Or New → Blueprint, which reads `render.yaml`.)
3. Copy the site URL, then in Supabase → Authentication → URL Configuration set
   **Site URL** to it, so confirmation emails link back to the app.

## 3. Claude API key

1. console.anthropic.com → create a key named `git-thrift` in its own workspace
   and set a monthly spend limit on that workspace.
2. Open the app, create your account, confirm the email, sign in.
3. ⚙︎ Settings → paste the key → Save. It is stored in the `settings` table and
   reaches only signed-in family members. Everyone uses it automatically.

If a model name is retired, change `MODEL_VISION` / `MODEL_QUICK` in `public/config.js`.

## 4. Phones

Open the Render URL, sign in, then Share → **Add to Home Screen** (iPhone) or
⋮ → **Install app** (Android). Record rack videos in "Most Compatible" / H.264.

## What's stored where

- Supabase: items (text plus a small thumbnail), house rules, the API key, the members list.
- Not stored: full-size photos and videos. Frames are pulled from the video on the phone
  and sent to Claude; the rack pull list lives only while the app is open.
- Each phone: which sites you cross-post to, and a running count of Claude tokens used.

## Limits to know

- The API key is readable by anyone signed in as a family member. That is fine for family
  and not acceptable for customers. The paid version moves the Claude call behind a
  server (Render web service or Supabase Edge Function) that checks a Stripe plan first.
- Prices are model estimates, not live sold comps.
- Removing someone: delete their row from `members`, and rotate the API key if needed.
