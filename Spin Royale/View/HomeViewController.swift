//
//  HomeViewController.swift
//  Spin Royale
//
//  Created by Mayank Jangid on 3/20/25.
//

import UIKit
import CoreData

class HomeViewController: UIViewController {

    @IBOutlet weak var labelTotalCoins: UILabel!
    @IBOutlet weak var labelTotalSpins: UILabel!
    
    @IBOutlet weak var buttonCollectCoins: UIButton!
    
    private var viewModel: HomeViewModel = HomeViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //KeychainHelper.shared.resetKeychain() //...... dont delete this comment
        
        // Set up a closure to update the UI when the view model changes.
        viewModel.onUpdate = { [weak self] in
            DispatchQueue.main.async {
                self?.updateUI()
            }
        }
        
        viewModel.fetchUserStats()
        viewModel.checkDailyReward()
        updateUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.fetchUserStats()
        updateUI()
    }
    
    func updateUI() {
        labelTotalCoins.text = "\(viewModel.totalCoins)"
        labelTotalSpins.text = "\(viewModel.dailySpinsRemaining)"
        print("\(viewModel.dailySpinsRemaining)")
        
        buttonCollectCoins.isEnabled = viewModel.canCollectCoins
    }
    
    @IBAction func didTapCollectCoins(_ sender: UIButton) {
        viewModel.collectCoins()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
           if segue.identifier == K.homeToSlotVC,
              let slotVC = segue.destination as? SlotViewController {
               slotVC.userStats = self.viewModel.userStats
               // If presenting as a sheet:
               slotVC.presentationController?.delegate = self
           }
        if segue.identifier == K.segueToDragonVC,
           let _ = segue.destination as? DragonViewController {
           // slotVC.userStats = self.viewModel.userStats
        }
       }

}

extension HomeViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        viewModel.fetchUserStats()
        updateUI()
    }
}
