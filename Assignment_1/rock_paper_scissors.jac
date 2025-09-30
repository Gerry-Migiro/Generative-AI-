"""Rock-Paper-Scissors with AI Commentary - Interface"""

import random;
import from byllm.llm { Model }

# Global LLM model
glob llm = Model(model_name="gemini/gemini-2.0-flash", verbose=False);

# LLM function declaration
def round_commentary(user: str, computer: str) -> str by llm();

obj RPSGame {
    has attempts: int = 3;
    has choices: [str] = ["rock", "paper", "scissors"];

    # Method declarations (no body)
    def play;
    def process_round(user_input: str, computer_choice: str);
}

# -------------------- CLI Entry --------------------

with entry:__main__ {
    game = RPSGame();
    game.play();
}
