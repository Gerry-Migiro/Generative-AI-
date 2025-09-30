"""Rock-Paper-Scissors with AI Commentary - Implementation"""

impl RPSGame.play {
    print("Welcome to Rock-Paper-Scissors with AI commentary!");

    while self.attempts > 0 {
        user_input = input("Enter rock, paper, or scissors: ").lower();
        if user_input not in self.choices {
            print("Invalid choice! Try again.");
            continue;
        }

        computer_choice = random.choice(self.choices);

        self.process_round(user_input, computer_choice);

        self.attempts -= 1;
        if self.attempts > 0 {
            print(f"You have {self.attempts} attempts left.\n");
        } else {
            print("Game over! Thanks for playing.");
        }
    }
}

impl RPSGame.process_round(user_input: str, computer_choice: str) {
    print(f"💻 Computer chose: {computer_choice}");

    if user_input == computer_choice {
        print("🤝 It's a tie!");
    } elif (user_input == "rock" and computer_choice == "scissors") or
         (user_input == "paper" and computer_choice == "rock") or
         (user_input == "scissors" and computer_choice == "paper") {
        print("🎉 You win!");
    } else {
        print("💻 Computer wins!");
    }

    # AI hint
    hint = round_commentary(user_input, computer_choice);
    print(f"🤖 AI Hint: {hint}");
}
