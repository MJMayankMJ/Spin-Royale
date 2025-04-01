# Spin Royale

**Spin Royale** is an iOS casino experience built with UIKit and Core Data (also uses Key Chain for reward collection monitoring), featuring two engaging game modes: a classic slot machine and a thrilling Dragon game. Enjoy daily rewards, immersive animations, and realistic sound effects as you build up your coin balance and spin to win!

## Features

- **Daily Rewards**  
  - Collect **10 free spins** and **1000 coins** every day (based on your local device time).

- **Slot Machine Mode**  
  - **Gameplay:** Spin and win coins by matching symbols.  
  - **Outcomes:** Win coins based on matching symbols with special rewards for perfect matches (including bonus coins for matching three "⓻" symbols).  
  - **Animations & Sound:** Smooth reel animations and immersive sound effects create a realistic slot machine experience.

- **Dragon Game Mode**  
  - **Bet & Play:** Enter a bet amount to start the game.  
  - **Gameplay:** Reveal tiles in rows where eggs boost your multiplier, and skulls end the game.  
  - **Cash Out:** You can cash out your winnings at any point, preserving your current earnings and deducting your bet for the next round.  
  - **Animations & Sound:** Enjoy fluid animations.

- **Core Data Storage**  
  - User statistics (coins, spins, and daily reward tracking) are persistently stored using Core Data, ensuring your progress is saved.

- **Clean Architecture (MVVM)**  
  - The project is organized with separation of concerns, with UI handled in view controllers and business logic in dedicated components.

- **Keyboard Management**  
  - Integrated [IQKeyboardManager](https://github.com/hackiftekhar/IQKeyboardManager) via Swift Package Manager to manage keyboard interactions seamlessly.

## Usage

### Home Screen
- **Daily Rewards:**  
  - Collect your free coins.
  - View your current coin and spin balance.

### Slot Machine Mode
- **Spin to Win:**  
  - Tap the **Spin** button to play the slot machine.
  - Your spins will decrement automatically, and you’ll see animations, sound effects, and coin updates based on your spin outcome.

### Dragon Game Mode
- **Place Your Bet:**  
  - Enter a bet amount and tap the **Bet** button to start the Dragon game.
- **Gameplay:**  
  - Reveal rows of tiles by tapping them.  
  - Eggs boost your multiplier while hitting a skull ends the game.
- **Cash Out:**  
  - You can choose to "Cash out" during play to lock in your winnings.
  - The app deducts your bet immediately and then adds your winnings if you successfully cash out.
- **Replay:**  
  - After a game, choose to replay with the same bet amount (which is re-deducted) or return home.
 
## Contributing

Contributions are welcome! Please open an issue or submit a pull request for any improvements or bug fixes.

## Installation

```bash
git clone https://github.com/MJMayankMJ/Spin-Royale.git

