// Public-safe settings. The anon key is designed to be shipped to browsers;
// row-level security in schema.sql is what protects the data.
// The Claude API key does NOT go here — paste it in the app under Settings (⚙︎).
window.GT_CONFIG = {
  SUPABASE_URL: "https://tuzuaihyyddpgipsggwk.supabase.co",
  SUPABASE_ANON_KEY: "sb_publishable_N7Q7SmX74uYSZZW7ghTXKg_LqJHYRdd",
  MODEL_VISION: "claude-sonnet-5",            // photos, rack scans, listings
  MODEL_QUICK: "claude-haiku-4-5-20251001"    // buyer replies
};
