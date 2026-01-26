Generate comprehensive tests for the code in $ARGUMENTS.

## Requirements

- Use **pytest** as the testing framework
- Include type hints in test functions
- Use descriptive test names following the pattern: `test_<function>_<scenario>_<expected>`

## Test Coverage

Generate tests for:

1. **Happy Path**: Normal, expected inputs and outputs
2. **Edge Cases**: Boundary values, empty inputs, large inputs
3. **Error Cases**: Invalid inputs, exception handling
4. **Integration Points**: Mocked external dependencies if applicable

## Output Format

Provide the complete test file that can be run with `pytest`. Include:

- Necessary imports
- Fixtures if needed
- Clear docstrings explaining test purpose
- Assertions with helpful failure messages

## Example Structure

```python
import pytest
from <module> import <function>

class TestFunctionName:
    """Tests for function_name."""

    def test_function_with_valid_input_returns_expected(self):
        """Test description."""
        result = function(valid_input)
        assert result == expected, "Helpful message"
```
