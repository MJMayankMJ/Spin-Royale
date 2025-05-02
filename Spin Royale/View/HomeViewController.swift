//
//  HomeViewController.swift
//  Spin Royale
//
//  Created by Mayank Jangid on 3/20/25.
//

import UIKit

class HomeViewController: UIViewController, UIAdaptivePresentationControllerDelegate {

    // MARK: - Outlets
    @IBOutlet weak var labelTotalCoins: UILabel!
    @IBOutlet weak var imageSpinWheel: UIImageView!
    @IBOutlet weak var imageDragon: UIImageView!
    @IBOutlet weak var imageTBD: UIImageView!
    @IBOutlet weak var imageClaim: UIImageView!
    @IBOutlet weak var buttonSettings: UIButton!

    private var viewModel = HomeViewModel()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        //KeychainHelper.shared.resetKeychain() //…don't delete this comment

        setupViewModel()
        setupTapGestures()
        buttonSettings.isUserInteractionEnabled = true
        let settingsTap = UITapGestureRecognizer(target: self, action: #selector(didTapSettings))
        buttonSettings.addGestureRecognizer(settingsTap)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.fetchUserStats()
        updateUI()
    }

    // MARK: - Setup
    private func setupViewModel() {
        viewModel.onUpdate = { [weak self] in
            DispatchQueue.main.async { self?.updateUI() }
        }
        viewModel.fetchUserStats()
        viewModel.checkDailyReward()
        updateUI()
    }

    private func setupTapGestures() {
        let actions: [(UIImageView, Selector)] = [
            (imageSpinWheel, #selector(didTapSpin)),
            (imageDragon,   #selector(didTapDragon)),
            (imageTBD,      #selector(didTapTBD)),
            (imageClaim,    #selector(didTapClaim))
        ]
        for (view, selector) in actions {
            view.isUserInteractionEnabled = true
            view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: selector))
        }
    }

    // MARK: - UI Update
    private func updateUI() {
        labelTotalCoins.text = "\(viewModel.totalCoins)"
        let canClaim = viewModel.canCollectCoins
        imageClaim.alpha = canClaim ? 1 : 0.5
        imageClaim.isUserInteractionEnabled = canClaim
    }

    // MARK: - Actions
    @objc private func didTapSpin() {
        animateTap(on: imageSpinWheel) {
            self.performSegue(withIdentifier: K.homeToSlotVC, sender: nil)
        }
    }

    @objc private func didTapDragon() {
        animateTap(on: imageDragon) {
            self.performSegue(withIdentifier: K.segueToDragonVC, sender: nil)
        }
    }

    @objc private func didTapTBD() {
        animateTap(on: imageTBD) {
            // Navigate to Limbo screen instead of showing an alert
            self.performSegue(withIdentifier: "toLimboVC", sender: nil)
        }
    }

    @objc private func didTapClaim() {
        animateTap(on: imageClaim) {
            self.viewModel.collectCoins()
            let alert = UIAlertController(
                title: "Reward Claimed",
                message: "You have claimed today’s coins!",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }

    // MARK: - Animation Helper
    private func animateTap(on view: UIView, completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0.08,
                       animations: { view.transform = CGAffineTransform(scaleX: 0.95, y: 0.95) },
                       completion: { _ in
            UIView.animate(withDuration: 0.08,
                           animations: { view.transform = .identity },
                           completion: { _ in completion() })
        })
    }
    
    @objc private func didTapSettings() {
        animateTap(on: buttonSettings) {
            self.performSegue(withIdentifier: "toSettingVC", sender: nil)
        }
    }

//    // MARK: - Settings
//    @objc private func didTapSettings() {
//        let sheet = UIAlertController(title: "Settings", message: nil, preferredStyle: .actionSheet)
//        sheet.addAction(UIAlertAction(title: "Mute Game Sound", style: .default) { _ in
//            // TODO: implement mute toggle
//        })
//        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
//        if let pop = sheet.popoverPresentationController {
//            pop.sourceView = buttonSettings
//            pop.sourceRect = buttonSettings.bounds
//        }
//        present(sheet, animated: true)
//    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.homeToSlotVC,
           let slotVC = segue.destination as? SlotViewController {
            slotVC.userStats = viewModel.userStats
            slotVC.presentationController?.delegate = self
        }
        else if segue.identifier == K.segueToDragonVC,
                let dragonVC = segue.destination as? DragonViewController {
            //dragonVC.userStats = viewModel.userStats
        }
        else if segue.identifier == "toLimboVC",
                let limboVC = segue.destination as? LimboViewController {
            // no additional setup needed
        }
    }

    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        viewModel.fetchUserStats()
        updateUI()
    }
}
