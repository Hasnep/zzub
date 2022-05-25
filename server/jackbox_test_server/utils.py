import random
from typing import List, TypeVar

T = TypeVar("T")


def shuffle(x: List[T]) -> List[T]:
    return random.sample(x, len(x))
