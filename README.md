# Spin Royale

![SpinRoyale 2](https://github.com/user-attachments/assets/be730957-463c-4a32-abb3-6f898da4f219)

Spin Royale is an iOS slot machine app built with UIKit and Core Data. It offers daily rewards, engaging spin animations, and immersive sound effects for a realistic casino experience.


## Features

- **Daily Rewards:**  
  Receive 10 free spins and 1000 coins every day (based on the local device time). Rewards for coins and spins are collected separately.

- **Slot Machine Gameplay:**  
  Spin the reels and win coins based on matching symbols. Special rewards are given for matching three symbols or three special "⓻" symbols.

- **Animations & Sound Effects:**  
  Enjoy smooth animations (button fade-in and spring animations) alongside realistic sound effects using AVAudioPlayer.

- **Core Data Storage:**  
  All user stats (coins, spins, and daily reward tracking) are persistently stored using Core Data.

- **Clean Architecture:**  
  Designed with separation of concerns, keeping UI code in the view controllers and business logic in dedicated components. (MVVM)

 ## Usage

**Home Screen:**  
Collect your daily rewards and view your current coin and spin balance.

**Slot Screen:**  
Tap the spin button to play the slot machine. The app will decrement your available spins, animate the reels, play sound effects, and update your coin balance based on your results.

## Contributing

Contributions are welcome! Please open an issue or submit a pull request for any improvements or bug fixes.

## Installation

```bash
git clone https://github.com/MJMayankMJ/Spin-Royale.git

