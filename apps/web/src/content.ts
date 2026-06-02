export const campaign = {
  geoscience: {
    seo: {
      title: "Fabriq | Expert AI agents for geoscience",
      description:
        "Domain-grounded geologic reasoning with regulatory and map context - not generic chat.",
    },
    hero: {
      title: "Expert AI agent that understands geoscience",
      subtitle:
        "Geologic interpretation, regulatory boundaries, and geographic context in one explainable workflow.",
      cta: "Sign up for an exploratory call",
    },
    proof: {
      sectionTitle: "General models aren't built for expertise work",
      prompt: "What was the goal of Schweinsteiger?",
      narrativeLead:
        "You will most likely get a football-related answer from ChatGPT or Copilot…",
      generalLlm: {
        label: "ChatGPT / Copilot",
        quote:
          "It seems like you're referring to Bastian Schweinsteiger, a former German professional footballer who played as a midfielder. During his career, Schweinsteiger scored many goals, so it's hard to pinpoint one specific goal.",
      },
      bridge: "…while you were probably looking for something like:",
      fabriqCondensed:
        "The goal of the Schweinsteiger prospect (licence PL829) was a commercial hydrocarbon discovery in the Åsgard Fm, tested by well 6204/11-3 in September 2020 - the well was dry and the licence was relinquished.",
      takeaway:
        "General LLMs optimize for broad priors. Domain-grounded agents use your licence blocks, wells, and basin context.",
    },
    why: {
      title: "Why Fabriq",
      bullets: [
        "Subject-matter experts stay in control of AI reasoning - no developer bottleneck",
        "Every answer shows its sources; full provenance for compliance and trust",
        "Model-agnostic - stay on the cutting edge without vendor lock-in",
        "Intelligence woven into existing tools at the edge of the workflow",
      ],
    },
    caseStudy: {
      title: "Exploration geology - new insights from forgotten data",
      metrics: [
        "Research time cut from days to minutes",
        "Decades of relinquishment reports queryable in natural language",
        "Complete source citations for trusted answers",
      ],
      body: "World's first publicly available LLM solution for exploration geology - seismic data, well logs, and interpretations searchable with map-ready context.",
    },
    logos: {
      title: "Trusted by",
      items: [
        { name: "GeoScienceWorld", src: "/brand/clients/geoscienceworld.png" },
        { name: "Norwegian Offshore Directorate", src: "/brand/clients/nod.png" },
      ],
    },
    cta: {
      paragraph:
        "If you'd like to be able to know how to accurately handle regulatory, geographical, and complex geological context in order to find relevant information and show it on a map, then sign up for an exploratory call with us.",
      formTitle: "Book an exploratory call",
      button: "Sign up for an exploratory call",
    },
    form: {
      email: "Work email",
      name: "Name",
      company: "Company",
      role: "Role (e.g. geoscientist, GIS, manager)",
      message: "Message (optional)",
      consent:
        "I agree to be contacted about an exploratory call and accept the privacy policy.",
      success: "Thank you - we'll be in touch shortly.",
      error: "Something went wrong. Please try again or email us directly.",
    },
    footer: "woven by Fabriq",
  },
} as const;
