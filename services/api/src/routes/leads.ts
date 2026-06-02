import { Hono } from "hono";
import { z } from "zod";
import { supabase } from "../supabase.js";
import { notifyNewLead } from "../email.js";

const leadSchema = z.object({
  email: z.string().email(),
  name: z.string().min(1).max(200),
  company: z.string().min(1).max(200),
  role: z.string().max(200).optional(),
  message: z.string().max(5000).optional(),
  website: z.string().max(0).optional().default(""), // honeypot — must be empty
  campaign: z.string().max(50).optional(),
  utm_source: z.string().max(100).optional(),
  utm_medium: z.string().max(100).optional(),
  utm_campaign: z.string().max(100).optional(),
});

const rateMap = new Map<string, { count: number; reset: number }>();
const RATE_LIMIT = 10;
const RATE_WINDOW_MS = 60_000;

function rateLimit(ip: string): boolean {
  const now = Date.now();
  const entry = rateMap.get(ip);
  if (!entry || now > entry.reset) {
    rateMap.set(ip, { count: 1, reset: now + RATE_WINDOW_MS });
    return true;
  }
  if (entry.count >= RATE_LIMIT) return false;
  entry.count++;
  return true;
}

export const leadsRoutes = new Hono();

leadsRoutes.post("/v1/leads", async (c) => {
  const ip =
    c.req.header("x-forwarded-for")?.split(",")[0]?.trim() ||
    c.req.header("x-real-ip") ||
    "unknown";

  if (!rateLimit(ip)) {
    return c.json({ error: "Too many requests" }, 429);
  }

  let body: unknown;
  try {
    body = await c.req.json();
  } catch {
    return c.json({ error: "Invalid JSON" }, 400);
  }

  const parsed = leadSchema.safeParse(body);
  if (!parsed.success) {
    return c.json({ error: "Validation failed", details: parsed.error.flatten() }, 400);
  }

  const data = parsed.data;
  if (data.website) {
    return c.json({ ok: true, leadId: "ignored" }, 201);
  }

  if (!supabase) {
    return c.json({ error: "Database not configured" }, 503);
  }

  const { data: row, error } = await supabase
    .from("leads")
    .insert({
      email: data.email,
      name: data.name,
      company: data.company,
      role: data.role ?? null,
      message: data.message ?? null,
      campaign: data.campaign ?? "geoscience",
      utm_source: data.utm_source ?? null,
      utm_medium: data.utm_medium ?? null,
      utm_campaign: data.utm_campaign ?? null,
      ip_hash: null,
    })
    .select("id")
    .single();

  if (error) {
    console.error("Supabase insert error:", error);
    return c.json({ error: "Failed to save lead" }, 500);
  }

  try {
    await notifyNewLead(data);
  } catch (e) {
    console.error("Email notify error:", e);
  }

  return c.json({ ok: true, leadId: row.id }, 201);
});
