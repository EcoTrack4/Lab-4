# Reflection — EcoTrack Namibia UX Engineering

**Module:** MPD820S · AI-Augmented Mobile Product Engineering  
**Lab:** Lab 4 — UX Engineering & Conversion Design  
**Date:** April 2026

---

## What Went Well

The most successful aspect of this deliverable was the depth of domain research before any design work began. Understanding the actual Schedule G compliance workflow — the paper forms, the MEFT submission process, the remote field conditions — meant the prototype addressed real problems rather than assumed ones. The offline-first architecture, species-specific dropdowns, and B2G paywall logic all emerged from researching the domain, not from generic UX patterns.

The usability testing also validated our core design decisions. The Schedule G digital form achieved 100% task completion, confirming that the primary workflow (the reason hunters would download the app) was intuitive and efficient. This is the product's "Aha Moment," and it worked.

The B2G conversion model was another strong element. Targeting MEFT rather than individual hunters for monetisation was unconventional, but the paywall screen and conversion map showed how the revenue logic flows: field adoption creates the dataset that makes the ministry dashboard valuable. Usability testing with actual MEFT permit officers confirmed the N$36,000 annual savings messaging resonated.

---

## What Was Difficult

The most challenging element was designing for genuinely low-literacy, low-connectivity users. It is easy to design for an imaginary "average user" — it is much harder to design for a 52-year-old Devil's Claw harvester in Omaheke who has intermittent signal and is logging data in direct sunlight.

This gap became visible in the usability test. The offline sync indicator, which seemed adequate on screen, was effectively invisible in real field conditions. The date picker, which is standard in every app, became unusable with gloves and screen glare. These are problems that only surface when you test with the right people in real conditions — not from desk-based reviews.

Structuring the conversion map was also more complex than expected. Mapping a B2G freemium model to the standard acquisition-to-retention funnel required genuine rethinking of what each stage means when the paying customer (MEFT) is not the same person as the end user (the permit holder). Standard SaaS funnel templates do not account for this split.

---

## What I Would Do Differently

Given more time, I would conduct the usability test in an actual field environment rather than a simulated one — outdoors, with the participant standing rather than seated, with real sun glare. The offline sync confusion would likely have surfaced earlier and more dramatically in those conditions.

I would also prototype the MEDIUM-priority friction points (GPS button, permit OCR) before the test, rather than treating them as post-test backlog. Testing revealed they are real pain points for the lowest-literacy users — the people least likely to persist through friction.

Finally, I would invest more time in the observation grid during testing. Some of the richest data came from what participants did when confused (tapping around, looking at the ceiling, going quiet) — behaviours that were noted informally but not fully captured in the structured grid.

---

## What I Learned

This deliverable reinforced that UX design for compliance and government contexts is fundamentally different from consumer app design. Users do not choose to use EcoTrack out of preference — they are legally required to submit Schedule G returns. This changes the entire design calculus: retention is built into the legal obligation, but trust and reliability are non-negotiable. If a user submits a form and does not know if it reached MEFT, the product has failed them legally, not just experientially.

I also learned that AI-assisted design requires genuine critical evaluation, not just prompt-and-accept. The AI-generated usability task scenarios assumed continuous internet access — a fundamental mismatch with the Namibian field context. Catching and correcting those assumptions before testing was essential. The AI was a fast starting point, not a finished answer.

---

*MPD820S · Lab 4 · EcoTrack Namibia · April 2026*
