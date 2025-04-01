//
//  DragonViewController.swift
//  Spin Royale
//
//  Created by Mayank Jangid on 3/26/25.
//

import UIKit

class DragonViewController: UIViewController {
    
    var coinTotalLabel: UILabel!
    
    // MARK: - IBOutlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var betTextField: UITextField!
    @IBOutlet weak var betButton: UIButton!
    
    // MARK: - ViewModel
    let viewModel = DragonViewModel()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        let nib = UINib(nibName: "EggCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "EggCell")
        
        collectionView.backgroundColor = .clear
        
        // initailly the button is ---- bet
        betButton.setTitle("Bet", for: .normal)
        
        setupNavigationCoinDisplay()
        // coin change
        NotificationCenter.default.addObserver(self, selector: #selector(coinsDidChange), name: CoinsManager.coinsDidChangeNotification, object: nil)
        
        // to dismiss keyboard -- well this cant be done cz than it would create touch issues with the game
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
//        view.addGestureRecognizer(tapGesture)
        betTextField.addCancelButtonOnKeyboard()
    }
    
    deinit {
        // remove observer when view controller is deallocated ....
        NotificationCenter.default.removeObserver(self, name: CoinsManager.coinsDidChangeNotification, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Fade-in animation.
        collectionView.alpha = 0
        UIView.animate(withDuration: 0.5) {
            self.collectionView.alpha = 1
        }
    }
    
    // not needed .... but why not (lets be extra safe)
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Update the coin label with current coin balance from the shared CoinsManager
        coinTotalLabel.text = "\(CoinsManager.shared.userStats?.totalCoins ?? 0)"
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - IBActions
    @IBAction func betButtonTapped(_ sender: UIButton) {
        view.endEditing(true)
        if sender.title(for: .normal) == "Bet" {
            guard let betText = betTextField.text, let betValue = Int(betText) else {
                print("Invalid bet")
                return
            }
            print("Bet pressed: \(betValue). Starting game...")
            viewModel.betAmount = betValue
            
            // Deduct coins immediately.
            CoinsManager.shared.deductCoins(amount: Int64(betValue)) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success():
                        self.viewModel.startGame()
                        self.collectionView.reloadData()
                    case .failure(let error):
                        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(alert, animated: true)
                    }
                }
            }
        } else {
            // The button says "Cash out" – cash out the game.
            cashOutGame()
        }
    }
    
    // Cash out the current game.
    func cashOutGame() {
        // Finalize current winnings.
        let bet = viewModel.betAmount
        let finalAmt = viewModel.finalAmount(forBet: bet)
        let netGain = viewModel.netGain(forBet: bet)
        
        viewModel.revealEntireBoard()
        viewModel.gameOver = true
        
        // Process the cash-out as a game over.
        UIView.transition(with: collectionView,
                          duration: 0.5,
                          options: .transitionCrossDissolve,
                          animations: {
            self.collectionView.reloadData()
        }, completion: { _ in
            self.showGameOverAlert(isCashOut: true, finalAmt: finalAmt, netGain: netGain)
        })
    }
}

// MARK: - UICollectionViewDataSource
extension DragonViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfCells
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EggCell", for: indexPath) as! EggCell
        if let cellData = viewModel.cellData(at: indexPath.item) {
            cell.configureCell(state: cellData.state)
        }
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension DragonViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Determine tapped cell's row.
        let row = indexPath.item / viewModel.totalColumns
        
        // Process tap only on active (highlighted) row.
        if row == viewModel.activeRow {
            let col = indexPath.item % viewModel.totalColumns
            let outcome = viewModel.board[row][col]
            
            if outcome == .skull {
                // Skull tapped: reveal board, game over.
                viewModel.revealEntireBoard()
                viewModel.currentMultiplier = 0.0
                viewModel.gameOver = true
                
                UIView.transition(with: collectionView,
                                  duration: 0.5,
                                  options: .transitionCrossDissolve,
                                  animations: {
                    self.collectionView.reloadData()
                }, completion: { _ in
                    self.showGameOverAlert(isCashOut: false, finalAmt: self.viewModel.finalAmount(forBet: self.viewModel.betAmount), netGain: self.viewModel.netGain(forBet: self.viewModel.betAmount))
                })
            } else {
                // Egg tapped: reveal this row.
                viewModel.revealRow(row)
                
                UIView.transition(with: collectionView,
                                  duration: 0.5,
                                  options: .transitionCrossDissolve,
                                  animations: {
                    self.collectionView.reloadData()
                }, completion: { _ in
                    // Move active row up.
                    self.viewModel.activeRow -= 1
                    if self.viewModel.activeRow >= 0 {
                        self.viewModel.highlightRow(self.viewModel.activeRow)
                        self.collectionView.reloadData()
                        // Change button title to "Cash out" after the first row is revealed.
                        self.betButton.setTitle("Cash out", for: .normal)
                    } else {
                        // No more rows: game complete.
                        self.viewModel.gameOver = true
                        self.showGameOverAlert(isCashOut: false, finalAmt: self.viewModel.finalAmount(forBet: self.viewModel.betAmount), netGain: self.viewModel.netGain(forBet: self.viewModel.betAmount))
                    }
                })
            }
        }
    }
}

// MARK: - Game Over Alert
extension DragonViewController {
    // - Parameters:
    //   - isCashOut: True if this ended by cashing out.
    //   - finalAmt: Final winning amount.
    //   - netGain: Net gain (finalAmt - bet).
    private func showGameOverAlert(isCashOut: Bool, finalAmt: Double, netGain: Double) {
        let bet = viewModel.betAmount
        let titleText = isCashOut ? "Cashed Out" : "Game Over"
        let message = "Bet: \(bet)\nFinal Amount: \(Int(finalAmt))\nNet Gain: \(Int(netGain))"
        
        let alert = UIAlertController(title: titleText, message: message, preferredStyle: .alert)
        
        let homeAction = UIAlertAction(title: "Home", style: .default) { _ in
            // If the multiplier > 1.0, add winnings
            if self.viewModel.currentMultiplier > 1.0 {
                CoinsManager.shared.addCoins(amount: Int64(finalAmt)) { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success():
                            print("Winnings added successfully.")
                        case .failure(let error):
                            let errorAlert = UIAlertController(
                                title: "Error",
                                message: error.localizedDescription,
                                preferredStyle: .alert
                            )
                            errorAlert.addAction(UIAlertAction(title: "OK", style: .default))
                            self.present(errorAlert, animated: true)
                        }
                    }
                }
            }
            // Reset the game state
            self.viewModel.resetGame()
            self.betTextField.text = ""
            self.betButton.setTitle("Bet", for: .normal)
            self.collectionView.reloadData()
            
            self.navigationController?.popViewController(animated: true)
        }
        
        // "Replay" action: deduct the bet amount again and add winnings if applicable, then reset the game.
        let replayAction = UIAlertAction(title: "Replay", style: .default) { _ in
            let bet = self.viewModel.betAmount
            let finalAmt = self.viewModel.finalAmount(forBet: bet)
            
            // If the game was won, add winnings.
            if self.viewModel.currentMultiplier > 1.0 {
                CoinsManager.shared.addCoins(amount: Int64(finalAmt)) { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success():
                            print("Winnings added successfully on replay.")
                        case .failure(let error):
                            let errorAlert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                            errorAlert.addAction(UIAlertAction(title: "OK", style: .default))
                            self.present(errorAlert, animated: true)
                        }
                        // Regardless of success, deduct the bet amount for the new game.
                        self.deductBetForReplay(bet: bet)
                    }
                }
            } else {
                // If no winnings, just deduct the bet.
                self.deductBetForReplay(bet: bet)
            }
        }
        
        
        alert.addAction(homeAction)
        alert.addAction(replayAction)
        self.present(alert, animated: true)
    }
}


// MARK: - UICollectionViewDelegateFlowLayout
extension DragonViewController: UICollectionViewDelegateFlowLayout {
    
    private var cellSpacing: CGFloat { return 8 }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let totalColumns = CGFloat(viewModel.totalColumns)  // 3 columns
        let totalRows = CGFloat(viewModel.totalRows)        // 9 rows
        
        let totalHorizontalSpacing = cellSpacing * (totalColumns - 1)
        let totalVerticalSpacing = cellSpacing * (totalRows - 1)
        
        let adjustedWidth = collectionView.bounds.width - totalHorizontalSpacing
        let adjustedHeight = collectionView.bounds.height - totalVerticalSpacing
        
        let cellWidth = adjustedWidth / totalColumns
        let cellHeight = adjustedHeight / totalRows
        
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return cellSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return cellSpacing
    }
}

extension DragonViewController{
    func setupNavigationCoinDisplay() {
        let containerWidth: CGFloat = 100
        let containerHeight: CGFloat = 30
        let container = UIView(frame: CGRect(x: 0, y: 0, width: containerWidth, height: containerHeight))
        
        let coinImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular, scale: .medium)
        let symbolImage = UIImage(systemName: "circle.fill", withConfiguration: symbolConfig)
        
        coinImageView.image = symbolImage
        coinImageView.tintColor = .systemYellow
        coinImageView.contentMode = .scaleAspectFit
        
        container.addSubview(coinImageView)
        
        coinTotalLabel = UILabel(frame: CGRect(x: 30, y: 0, width: containerWidth - 30, height: containerHeight))
        coinTotalLabel.text = "\(CoinsManager.shared.userStats?.totalCoins ?? 0)"
        coinTotalLabel.font = UIFont.systemFont(ofSize: 16)
        coinTotalLabel.textColor = .black
        coinTotalLabel.textAlignment = .left
        container.addSubview(coinTotalLabel)
        
        let coinBarButtonItem = UIBarButtonItem(customView: container)
        navigationItem.rightBarButtonItem = coinBarButtonItem
    }
    
    
    @objc func coinsDidChange() {
        // Update the coin label whenever coins are changed.
        coinTotalLabel.text = "\(CoinsManager.shared.userStats?.totalCoins ?? 0)"
    }
    
    //.... i know i could gave dome somthing better .... but im stupid
    private func deductBetForReplay(bet: Int) {
        CoinsManager.shared.deductCoins(amount: Int64(bet)) { result in
            DispatchQueue.main.async {
                switch result {
                case .success():
                    print("Bet deducted for replay.")
                case .failure(let error):
                    let errorAlert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                    errorAlert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(errorAlert, animated: true)
                }
                // Reset the game state and update UI.
                self.viewModel.resetGame()
                self.betButton.setTitle("Bet", for: .normal)
                self.collectionView.reloadData()
            }
        }
    }
    
}

//MARK: - For keyboard dismissing

extension UITextField {
    func addCancelButtonOnKeyboard() {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44))
        doneToolbar.barStyle = .default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(doneButtonAction))
        
        doneToolbar.items = [flexSpace, done]
        doneToolbar.sizeToFit()
        
        self.inputAccessoryView = doneToolbar
    }
    
    @objc func doneButtonAction() {
        self.resignFirstResponder()
    }
}
