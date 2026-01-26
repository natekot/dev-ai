# Global AI Coding Standards

These guidelines apply to all projects where Claude Code is used.

## Code Style Preferences

- Use clear, descriptive variable names
- Include docstrings for functions
- Prefer explicit over implicit
- Use type hints where the language supports them

## When Reviewing Code

1. Check for common issues: null checks, error handling, edge cases
2. Look for security concerns: input validation, injection risks
3. Assess readability and maintainability
4. Suggest improvements with concrete examples

## When Writing Tests

1. Include both happy path and edge case tests
2. Use descriptive test names that explain what's being tested
3. Mock external dependencies appropriately

## When Explaining Code

1. Start with a high-level overview
2. Break down complex logic step by step
3. Highlight any non-obvious patterns or decisions
4. Note potential gotchas or edge cases

## Security Guidelines

- Never commit secrets, API keys, or credentials
- Validate all user inputs
- Be cautious with destructive operations (rm -rf, force push, etc.)
- Review changes before committing
