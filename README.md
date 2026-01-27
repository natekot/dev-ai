# GitHub Copilot Prompts & Instructions

A collection of reusable GitHub Copilot prompts and language-specific instructions for common development tasks. Install once and use across all your projects.

## Quick Start

### Linux / macOS

```bash
./install.sh /path/to/your/project
```

### Windows

```cmd
install.bat C:\path\to\your\project
```

Note: The Windows installer uses directory junctions (no admin required). Source and target must be on the same drive.

## What Gets Installed

### Prompts
| File | Location | Purpose |
|------|----------|---------|
| `review.prompt.md` | `.github/prompts/global/` | Code review prompt |
| `test.prompt.md` | `.github/prompts/global/` | Test generation prompt |
| `explain.prompt.md` | `.github/prompts/global/` | Code explanation prompt |
| `commit-and-push.prompt.md` | `.github/prompts/global/` | Commit workflow prompt |

### Instructions (Language-Specific)
| File | Applies To | Purpose |
|------|------------|---------|
| `global.instructions.md` | All files (`**`) | Global token efficiency guidelines |
| `c.instructions.md` | `*.c`, `*.h` | C language + K&R style |
| `python.instructions.md` | `*.py` | Python guidelines |
| `bash.instructions.md` | `*.sh`, `*.bash` | Bash/Shell guidelines |
| `testing.instructions.md` | `test_*.py`, `*_test.c`, etc. | Testing patterns |
| `security.instructions.md` | All files | Security guidelines |

## Usage After Installation

In VS Code Copilot Chat, invoke prompts using the `/` syntax:

```
/global/review examples/sample.py
/global/test examples/sample.py
/global/explain examples/sample.py
/global/commit-and-push
```

## Managing Installations

```bash
# Linux / macOS
./install.sh /path/to/project --force     # Force overwrite existing files
./install.sh /path/to/project --dry-run   # Preview what would be installed
./install.sh --uninstall /path/to/project # Remove installed symlinks

# Windows
install.bat C:\path\to\project --force     # Force overwrite existing
install.bat C:\path\to\project --dry-run   # Preview what would be installed
install.bat --uninstall C:\path\to\project # Remove installed junctions
```

## Project Structure

```
├── install.sh                     # Installation script (Linux/macOS)
├── install.bat                    # Installation script (Windows)
├── README.md                      # This file
├── examples/                      # Demo files
│   └── sample.py
│
└── .github/                       # Source prompts & instructions
    ├── instructions/              # All instructions (including global)
    │   ├── global.instructions.md
    │   ├── c.instructions.md
    │   ├── python.instructions.md
    │   ├── bash.instructions.md
    │   ├── testing.instructions.md
    │   └── security.instructions.md
    └── prompts/
        ├── review.prompt.md
        ├── test.prompt.md
        ├── explain.prompt.md
        └── commit-and-push.prompt.md
```

### Installation Target Structure

When you run the installer, symlinks (Linux/macOS) or junctions (Windows) are created:

```
your-repo/.github/
├── instructions/
│   ├── global/              ->  dev-ai/.github/instructions/  (link)
│   └── my.instructions.md   (your repo's own instructions, untouched)
└── prompts/
    ├── global/              ->  dev-ai/.github/prompts/  (link)
    └── my-prompt.prompt.md  (your repo's own prompts, untouched)
```

The `global/` subdirectories ensure installed content coexists with your repo-specific files without conflicts. Instructions apply automatically based on file patterns in their `applyTo` frontmatter.

## Available Prompts

### `/global/review`
Performs a comprehensive code review checking for:
- Code quality issues
- Potential bugs
- Security concerns
- Readability and maintainability

### `/global/test`
Generates tests for your code:
- Uses pytest as the testing framework
- Includes happy path and edge case tests
- Creates descriptive test names
- Mocks external dependencies

### `/global/explain`
Explains code with:
- High-level overview
- Step-by-step breakdown of complex logic
- Non-obvious patterns and decisions
- Potential gotchas and edge cases

### `/global/commit-and-push`
Guides you through committing changes:
- Reviews staged changes
- Suggests commit message
- Handles the commit workflow

## Copilot Chat Participants

Type `@` in Copilot Chat to access specialized participants:

| Participant | Purpose | Example |
|-------------|---------|---------|
| `@workspace` | Codebase context | `@workspace how is authentication implemented?` |
| `@terminal` | Terminal/shell expertise | `@terminal list the 5 largest files here` |
| `@vscode` | VS Code settings and features | `@vscode how to enable word wrapping?` |
| `@github` | GitHub features and web search | `@github what are my open PRs?` |

## Further Reading

- [GitHub Copilot Customization](https://docs.github.com/en/copilot/customizing-copilot)
- [GitHub Copilot Prompt Files](https://docs.github.com/en/copilot/tutorials/customization-library/prompt-files)
- [Asking GitHub Copilot Questions in Your IDE](https://docs.github.com/copilot/using-github-copilot/asking-github-copilot-questions-in-your-ide)
