"""
Sample module for demonstrating code review, testing, and explanation commands.

This file contains intentionally imperfect code to showcase what the
review, test, and explain commands can identify and work with.
"""

from typing import Optional
import json


class UserManager:
    """Manages user data with basic CRUD operations."""

    def __init__(self):
        self.users: dict[str, dict] = {}
        self._next_id = 1

    def create_user(self, name: str, email: str, age: int) -> dict:
        """Create a new user and return the user data."""
        user_id = str(self._next_id)
        self._next_id += 1

        # Note: No validation on email format or age range
        user = {
            "id": user_id,
            "name": name,
            "email": email,
            "age": age,
            "active": True
        }
        self.users[user_id] = user
        return user

    def get_user(self, user_id: str) -> Optional[dict]:
        """Retrieve a user by ID."""
        return self.users.get(user_id)

    def update_user(self, user_id: str, **kwargs) -> dict:
        """Update user fields. Returns updated user or raises KeyError."""
        user = self.users[user_id]  # May raise KeyError
        for key, value in kwargs.items():
            if key in user:
                user[key] = value
        return user

    def delete_user(self, user_id: str) -> bool:
        """Delete a user. Returns True if deleted, False if not found."""
        if user_id in self.users:
            del self.users[user_id]
            return True
        return False

    def find_users_by_age(self, min_age: int, max_age: int) -> list[dict]:
        """Find all users within an age range (inclusive)."""
        results = []
        for user in self.users.values():
            if min_age <= user["age"] <= max_age:
                results.append(user)
        return results


def calculate_discount(price: float, discount_percent: float) -> float:
    """
    Calculate discounted price.

    Args:
        price: Original price
        discount_percent: Discount as percentage (e.g., 20 for 20%)

    Returns:
        Discounted price
    """
    # Potential issue: no validation for negative values
    discount_amount = price * (discount_percent / 100)
    return price - discount_amount


def parse_config(config_string: str) -> dict:
    """
    Parse a JSON configuration string.

    Args:
        config_string: JSON string to parse

    Returns:
        Parsed configuration dictionary
    """
    # Simple wrapper - could fail on invalid JSON
    return json.loads(config_string)


def fibonacci(n: int) -> int:
    """
    Calculate the nth Fibonacci number.

    Uses recursive approach (intentionally inefficient for demo purposes).
    """
    if n <= 0:
        return 0
    elif n == 1:
        return 1
    else:
        return fibonacci(n - 1) + fibonacci(n - 2)


def batch_process(items: list, processor, batch_size: int = 10) -> list:
    """
    Process items in batches.

    Args:
        items: List of items to process
        processor: Callable that processes a single item
        batch_size: Number of items per batch

    Returns:
        List of processed results
    """
    results = []
    for i in range(0, len(items), batch_size):
        batch = items[i:i + batch_size]
        for item in batch:
            result = processor(item)
            results.append(result)
    return results


if __name__ == "__main__":
    # Demo usage
    manager = UserManager()

    user1 = manager.create_user("Alice", "alice@example.com", 30)
    user2 = manager.create_user("Bob", "bob@example.com", 25)

    print(f"Created users: {user1}, {user2}")
    print(f"Users aged 25-30: {manager.find_users_by_age(25, 30)}")

    print(f"20% off $100: ${calculate_discount(100, 20)}")
    print(f"Fibonacci(10): {fibonacci(10)}")
