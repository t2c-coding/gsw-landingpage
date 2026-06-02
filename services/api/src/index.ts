import { serve } from "@hono/node-server";
import { Hono } from "hono";
import { cors } from "hono/cors";
import { leadsRoutes } from "./routes/leads.js";
import { supabase } from "./supabase.js";

const app = new Hono();

const webOrigin = process.env.WEB_ORIGIN ?? "http://localhost:4321";

app.use(
  "*",
  cors({
    origin: webOrigin,
    allowMethods: ["GET", "POST", "OPTIONS"],
    allowHeaders: ["Content-Type"],
  })
);

app.route("/", leadsRoutes);

app.get("/health", async (c) => {
  let db: "connected" | "disconnected" = "disconnected";
  if (supabase) {
    const { error } = await supabase.from("leads").select("id").limit(1);
    db = error ? "disconnected" : "connected";
  }
  const ok = db === "connected";
  return c.json({ ok, db }, ok ? 200 : 503);
});

const port = Number(process.env.PORT ?? 3000);
console.log(`API listening on :${port}`);
serve({ fetch: app.fetch, port });
