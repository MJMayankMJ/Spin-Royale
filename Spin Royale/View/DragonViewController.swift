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
        viewModel.betAmount = betValue
        viewModel.coinBalance -= betValue
        
        // Start the game by generating the full board and highlighting the bottom row.
        viewModel.startGame()
        collectionView.reloadData()
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
        // Determine which row the tapped cell belongs to.
        let row = indexPath.item / viewModel.totalColumns
        
        // Allow tap only if it's the active (highlighted) row.
        if row == viewModel.activeRow {
            let col = indexPath.item % viewModel.totalColumns
            let outcome = viewModel.board[row][col]
            
            if outcome == .skull {
                // Skull tapped: reveal entire board and mark game over.
                viewModel.revealEntireBoard()
                viewModel.currentMultiplier = 0.0
                viewModel.gameOver = true
                
                UIView.transition(with: collectionView,
                                  duration: 0.5,
                                  options: .transitionCrossDissolve,
                                  animations: {
                    self.collectionView.reloadData()
                }, completion: { _ in
                    self.showGameOverAlert()
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
                        // Highlight the next row.
                        self.viewModel.highlightRow(self.viewModel.activeRow)
                        self.collectionView.reloadData()
                    } else {
                        // No more rows: game complete.
                        self.viewModel.gameOver = true
                        self.showGameOverAlert()
                    }
                })
            }
        }
    }
}
//extension DragonViewController: UICollectionViewDelegate {
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        // testing
//        print("ddone")
//        for i in 0..<viewModel.cells.count {
//            viewModel.cells[i].state = .skull
//        }
//        
//        UIView.transition(with: collectionView,
//                          duration: 0.5,
//                          options: .transitionCrossDissolve,
//                          animations: {
//            self.collectionView.reloadData()
//        }, completion: nil)
//    }
//}


// MARK: - Game Over Alert
extension DragonViewController {
    private func showGameOverAlert() {
        let bet = viewModel.betAmount
        let finalAmt = viewModel.finalAmount(forBet: bet)
        let netGain = viewModel.netGain(forBet: bet)
        
        let message = "Bet: \(bet)\nFinal Amount: \(Int(finalAmt))\nNet Gain: \(Int(netGain))"
        let alert = UIAlertController(title: "Game Over", message: message, preferredStyle: .alert)
        
        // "OK" resets the game completely (user must enter a new bet).
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            // Reset game state (for a fresh start).
            self.viewModel.resetGame()
            self.betTextField.text = ""
            self.collectionView.reloadData()
        }
        
        // "Replay" resets the game with the same bet amount.
        let replayAction = UIAlertAction(title: "Replay", style: .default) { _ in
            self.viewModel.resetGame()
            self.collectionView.reloadData()
        }
        
        alert.addAction(okAction)
        alert.addAction(replayAction)
        present(alert, animated: true, completion: nil)
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
