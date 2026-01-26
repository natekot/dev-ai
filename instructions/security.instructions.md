---
applyTo: "**/*"
---

# Security Instructions

- Validate all external input
- No hardcoded secrets, credentials, or API keys
- Parameterized queries (prevent SQL injection)
- Escape/sanitize output (prevent XSS)
- Use safe string functions in C (`snprintf`, `strncpy`)
