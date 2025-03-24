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
    @IBOutlet weak var buttonCollectSpins: UIButton!
    
    private var viewModel: HomeViewModel = HomeViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        buttonCollectCoins.isEnabled = viewModel.canCollectCoins
        buttonCollectSpins.isEnabled = viewModel.canCollectSpins
    }
    
    @IBAction func didTapCollectCoins(_ sender: UIButton) {
        viewModel.collectCoins()
    }
    
    @IBAction func didTapCollectSpins(_ sender: UIButton) {
        viewModel.collectSpins()
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == K.homeToSlotVC,
//           let slotVC = segue.destination as? SlotViewController,
//           let userStats = CoreDataManager.shared.fetchUserStats() {
//            // Create a SlotViewModel and pass it to the SlotViewController.
//            let slotVM = SlotViewModel(userStats: userStats)
//            slotVC.viewModel = slotVM
//            slotVC.presentationController?.delegate = self
//        }
//    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
           if segue.identifier == K.homeToSlotVC,
              let slotVC = segue.destination as? SlotViewController {
               slotVC.userStats = self.viewModel.userStats
               // If presenting as a sheet:
               slotVC.presentationController?.delegate = self
           }
       }

}

extension HomeViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        viewModel.fetchUserStats()
        updateUI()
    }
}
