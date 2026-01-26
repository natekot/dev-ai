---
applyTo: "**/*.c,**/*.h"
---

# C Language Instructions

## Style
- K&R / 1TBS brace style
- 4-space indentation
- Line length: 80 characters soft limit

## Naming
- `snake_case` for functions and variables
- `UPPER_CASE` for macros and constants
- Prefix with module name for public APIs (e.g., `http_request_send`)

## Memory
- Always pair `malloc`/`free`
- Check for `NULL` returns from allocations
- Initialize pointers to `NULL`
- Use `const` for pointers that don't modify data

## Error Handling
- Return error codes (0 for success, negative for errors)
- Use `errno` appropriately for system errors
- Document error conditions in function comments

## Headers
- Use include guards (`#ifndef HEADER_H` / `#define HEADER_H` / `#endif`)
- Minimal includes - only what's directly needed
- Forward declare structs when possible

## Documentation
- Doxygen-style comments for public APIs
- Brief description of function purpose
- Document parameters, return values, and error conditions
