import { createClient } from "@supabase/supabase-js";
import ws from "ws";

// Node 20 in Docker has no native WebSocket; @supabase/realtime-js needs this at init
if (typeof globalThis.WebSocket === "undefined") {
  globalThis.WebSocket = ws as unknown as typeof WebSocket;
}

const url = process.env.SUPABASE_URL;
const key = process.env.SUPABASE_SERVICE_ROLE_KEY;

if (!url || !key) {
  console.warn("SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY not set");
}

export const supabase =
  url && key ? createClient(url, key, { auth: { persistSession: false } }) : null;
