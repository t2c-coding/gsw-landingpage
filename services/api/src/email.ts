import { Resend } from "resend";

const resend = process.env.RESEND_API_KEY
  ? new Resend(process.env.RESEND_API_KEY)
  : null;

export async function notifyNewLead(lead: {
  email: string;
  name: string;
  company: string;
  role?: string;
  message?: string;
  campaign?: string;
}): Promise<void> {
  const to = process.env.LEADS_NOTIFY_EMAIL;
  if (!resend || !to) {
    console.log("[email] Skipped — RESEND_API_KEY or LEADS_NOTIFY_EMAIL not set");
    return;
  }

  await resend.emails.send({
    from: "Fabriq Leads <onboarding@resend.dev>",
    to: [to],
    subject: `New exploratory call: ${lead.company}`,
    text: [
      `Name: ${lead.name}`,
      `Email: ${lead.email}`,
      `Company: ${lead.company}`,
      lead.role ? `Role: ${lead.role}` : "",
      lead.message ? `Message: ${lead.message}` : "",
      lead.campaign ? `Campaign: ${lead.campaign}` : "",
    ]
      .filter(Boolean)
      .join("\n"),
  });
}
