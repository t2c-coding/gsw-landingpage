# Fabriq brand (from fabriqai.com)

Source: https://www.fabriqai.com/ — Wix theme, 2026-06-02.

## Colors

| Token | Hex | Use |
|-------|-----|-----|
| purple-900 | `#201240` | Headings, primary text |
| purple-700 | `#38266d` | Subtitles |
| purple-500 | `#704cd9` | Accent |
| purple-600 | `#5919c1` | Buttons |
| lavender-100 | `#e2dbf7` | Section backgrounds |
| lavender-200 | `#a994e8` | Panels |
| white | `#ffffff` | Surfaces |
| grey | `#7e7973` | Muted body |

## Typography

- **Headings / UI / buttons:** Poppins (400–700) — matches `poppins` / `poppins-semibold` on site
- **Body:** Wix Madefor Text (400–700) — same as `wix-madefor-text-v2` / `madefor-text` on site
- Loaded via Google Fonts in `BaseLayout.astro`

## Assets in repo

| File | Source |
|------|--------|
| `apps/web/public/favicon.svg` | Wix `03f1b4_19870169a5ca418db25fb2c2cfd9c3fc.svg` (same as fabriqai.com) |
| `apps/web/public/brand/fabriq-grafikk.png` | Wix `Fabriq-grafikk-1-mask-lr.png` full artwork (800×704, resized from 1850×1629) |
| `apps/web/public/brand/clients/geoscienceworld.png` | GeoScienceWorld logo |
| `apps/web/public/brand/clients/nod.png` | Norwegian Offshore Directorate |

**Wordmark:** Wix SVG logos are hotlink-protected; the header uses a Poppins **Fabriq** text mark in `#201240`.

## Pages to ignore

`/about`, `/technology`, `/home` — stale Volaso template content.
