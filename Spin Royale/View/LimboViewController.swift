//
//  LimboViewController.swift
//  Spin Royale
//
//  Created by Mayank Jangid on 4/28/25.
//
import UIKit

class LimboViewController: UIViewController {
    // MARK: – IBOutlets
    @IBOutlet weak var coinTotalLabel: UILabel!
    @IBOutlet weak var imageBackButton: UIImageView!
    
    @IBOutlet weak var multiplierTextField: UITextField!   // Lf
    @IBOutlet weak var winPercentTextField: UITextField!   //Rf
    @IBOutlet weak var betAmountTextField: UITextField!
    @IBOutlet weak var profitTextField: UITextField!
    
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var minusButton: UIButton!
    @IBOutlet weak var twoXButton: UIButton!
    @IBOutlet weak var fourXButton: UIButton!
    @IBOutlet weak var betButton: UIButton!
    
    // MARK: – ViewModel
    private let viewModel = LimboViewModel()
    
    // MARK: – Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize coin display and start observing coin changes
        coinTotalLabel.text = "\(CoinsManager.shared.userStats?.totalCoins ?? 0)"
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(coinsDidChange),
                                               name: CoinsManager.coinsDidChangeNotification,
                                               object: nil)
        
        // Wire up back-button tap
        imageBackButton.isUserInteractionEnabled = true
        let backTap = UITapGestureRecognizer(target: self, action: #selector(didTapBack))
        imageBackButton.addGestureRecognizer(backTap)
        
        // Sync UI fields to initial ViewModel values
        syncInputsToUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Refresh coin display whenever the view appears
        coinTotalLabel.text = "\(CoinsManager.shared.userStats?.totalCoins ?? 0)"
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self,
                                                  name: CoinsManager.coinsDidChangeNotification,
                                                  object: nil)
    }
    
    // MARK: – Coins Observer
    @objc private func coinsDidChange() {
        coinTotalLabel.text = "\(CoinsManager.shared.userStats?.totalCoins ?? 0)"
    }
    
    // MARK: – Back Button Action
    @objc private func didTapBack() {
        animateTap(on: imageBackButton) {
            if let nav = self.navigationController {
                nav.popViewController(animated: true)
            } else {
                self.dismiss(animated: true)
            }
        }
    }
    
    // MARK: – IBActions
    @IBAction func plusTapped(_ sender: UIButton) {
        updateViewModelFromUI()
        viewModel.targetMultiplier += 0.1
        syncInputsToUI()
    }
    
    @IBAction func minusTapped(_ sender: UIButton) {
        updateViewModelFromUI()
        viewModel.targetMultiplier -= 0.1
        syncInputsToUI()
    }
    
    @IBAction func twoXTapped(_ sender: UIButton) {
        updateViewModelFromUI()
        viewModel.betAmount *= 2
        syncInputsToUI()
    }
    
    @IBAction func fourXTapped(_ sender: UIButton) {
        updateViewModelFromUI()
        viewModel.betAmount *= 4
        syncInputsToUI()
    }
    
    @IBAction func betTapped(_ sender: UIButton) {
        // Read user inputs
        updateViewModelFromUI()
        
        let betCoins = Int64(viewModel.betAmount)
        CoinsManager.shared.deductCoins(amount: betCoins) { result in
            DispatchQueue.main.async {
                switch result {
                case .success():
                    // Play one round
                    let crash = self.viewModel.playRound()
                    if self.viewModel.didWin {
                        let profitCoins = Int64(self.viewModel.profitIfWin)
                        CoinsManager.shared.addCoins(amount: profitCoins) { _ in }
                    }
                    self.showResult(crash: crash)
                case .failure(let error):
                    self.showAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }
    }
    
    // MARK: – Helpers
    private func syncInputsToUI() {
        multiplierTextField.text = String(format: "%.1f", viewModel.targetMultiplier)
        winPercentTextField.text  = String(format: "%.2f%%", viewModel.winPercentage)
        betAmountTextField.text   = String(format: "%.0f", viewModel.betAmount)
        profitTextField.text      = String(format: "%.2f", viewModel.profitIfWin)
    }
    
    private func updateViewModelFromUI() {
        viewModel.targetMultiplier = Double(multiplierTextField.text ?? "") ?? 1.0
        viewModel.betAmount        = Double(betAmountTextField.text ?? "") ?? 0.0
    }
    
    private func showResult(crash: Double) {
        let title: String
        let message: String
        if viewModel.didWin {
            title   = "You Win! 🎉"
            message = String(format: "Crashed at %.2f×\nProfit: %.2f", crash, viewModel.profitIfWin)
        } else {
            title   = "Crashed! 💥"
            message = String(format: "Crashed at %.2f×\nYou lost your bet.", crash)
        }
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(.init(title: "OK", style: .default) { _ in
            // Reset bet amount for next round
            self.viewModel.betAmount = 0
            self.syncInputsToUI()
        })
        present(alert, animated: true)
    }
    
    private func showAlert(title: String, message: String) {
        let a = UIAlertController(title: title, message: message, preferredStyle: .alert)
        a.addAction(.init(title: "OK", style: .default))
        present(a, animated: true)
    }
    
    private func animateTap(on view: UIView, completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0.08,
                       animations: { view.transform = CGAffineTransform(scaleX: 0.95, y: 0.95) },
                       completion: { _ in
            UIView.animate(withDuration: 0.08,
                           animations: { view.transform = .identity },
                           completion: { _ in completion() })
        })
    }
}
