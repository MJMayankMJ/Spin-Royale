//
//  DragonViewController.swift
//  Spin Royale
//
//  Created by Mayank Jangid on 3/26/25.
//

import UIKit

class DragonViewController: UIViewController {
    
    // MARK: - IBOutlets (connect these in your storyboard)
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
        
        // Register the EggCell nib.
        let nib = UINib(nibName: "EggCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "EggCell")
        
        collectionView.backgroundColor = .clear
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Fade-in animation for the collection view.
        collectionView.alpha = 0
        UIView.animate(withDuration: 0.5) {
            self.collectionView.alpha = 1
        }
    }
    
    // MARK: - IBActions
    @IBAction func betButtonTapped(_ sender: UIButton) {
        // Read the bet value.
        guard let betText = betTextField.text, let betValue = Int(betText) else {
            print("Invalid bet")
            return
        }
        print("Bet pressed: \(betValue). Starting game...")
        // Set the bet and deduct coins.
        viewModel.betAmount = betValue
        viewModel.coinBalance -= betValue
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
        // Determine which row the tapped cell is in.
        let row = indexPath.item / viewModel.totalColumns
        
        // Process tap only if it is in the active (highlighted) row.
        if row == viewModel.activeRow, let outcome = viewModel.currentRowOutcome {
            let col = indexPath.item % viewModel.totalColumns
            
            // Check the predetermined outcome for the tapped cell.
            if outcome[col] == .skull {
                // Skull tapped: set multiplier to 0 and end the game.
                viewModel.currentMultiplier = 0.0
                viewModel.gameOver = true
            } else {
                // Egg tapped: update multiplier for this row.
                let multiplierIndex = (viewModel.totalRows - 1) - viewModel.activeRow  // bottom row = index 0.
                let rowMultiplier = viewModel.multipliers[multiplierIndex]
                viewModel.currentMultiplier *= rowMultiplier
            }
            
            // Animate the reveal of the active row.
            UIView.transition(with: collectionView,
                              duration: 0.5,
                              options: .transitionCrossDissolve,
                              animations: {
                self.viewModel.revealActiveRow()
                self.collectionView.reloadData()
            }, completion: { _ in
                // If game is over, show the final result alert.
                if self.viewModel.gameOver {
                    let bet = self.viewModel.betAmount
                    let finalAmt = self.viewModel.finalAmount(forBet: bet)
                    let netGain = self.viewModel.netGain(forBet: bet)
                    
                    let message = "Bet: \(bet)\nFinal Amount: \(Int(finalAmt))\nNet Gain: \(Int(netGain))"
                    let alert = UIAlertController(title: "Game Over", message: message, preferredStyle: .alert)
                    
                    // "OK" simply dismisses the alert.
                    let okAction = UIAlertAction(title: "OK", style: .default) { _ in
                        // Dismiss alert; user can enter a new bet.
                    }
                    // "Replay" resets the game with the same bet.
                    let replayAction = UIAlertAction(title: "Replay", style: .default) { _ in
                        self.viewModel.resetGame()
                        self.collectionView.reloadData()
                    }
                    
                    alert.addAction(okAction)
                    alert.addAction(replayAction)
                    self.present(alert, animated: true, completion: nil)
                }
            })
        }
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
