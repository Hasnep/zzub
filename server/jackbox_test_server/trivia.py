import httpx

from typing import Dict, List, Any, Optional
from pydantic import BaseModel, Field

import json

BASE_URL = "https://api.trivia.willfry.co.uk/questions"


class Question(BaseModel):
    question_id: int = Field(alias="id")
    question_type: str = Field(alias="type")
    question_category: str = Field(alias="category")
    question: str
    correct_answer: str = Field(alias="correctAnswer")
    incorrect_answers: List[str] = Field(alias="incorrectAnswers")


async def get_question(categories: Optional[List[str]] = None) -> Question:
    questions = await get_questions(1, categories)
    return questions[0]


async def get_questions(n: int, categories: Optional[List[str]]) -> List[Question]:
    valid_categories = [
        "geography",
        "food_and_drink",
        "general_knowledge",
        "literature",
        "history",
        "movies",
        "music",
        "science",
        "society_and_culture",
        "sport_and_leisure",
    ]
    params = {"limit": n}
    if categories is not None:
        for category in categories:
            if category not in valid_categories:
                raise ValueError(f"Category `{category}` not valid.")
        params["categories"] = ",".join(categories)

    async with httpx.AsyncClient() as http_client:
        response = await http_client.get(BASE_URL, params=params)
        question_dicts: List[Dict[str, Any]] = json.loads(response.text)
        questions = [Question(**q_dict) for q_dict in question_dicts]
        print(questions)
        return questions
