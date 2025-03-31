//
//  ViewController.swift
//  Spin Royale
//
//  Created by Mayank Jangid on 3/19/25.
//

import UIKit

class SlotViewController: UIViewController {
    
    var spinsLabel: UILabel!
    
    // MARK: - IBOutlets
    // Removed labelResult outlet.
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var buttonSpin: UIButton!
    
    // MARK: - Properties
    var userStats: UserStats?
    var viewModel: SlotViewModel!
    
    // For UI animation
    var bounds = CGRect.zero
    
    // For sound effects
    var winSound = SoundManager()
    var rattle = SoundManager()
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pickerView.delegate = self
        pickerView.dataSource = self
        
        // Initialize the view model with the userStats
        viewModel = SlotViewModel(userStats: userStats)
        
        setupUIAndSound()
        
        // Set up the spins display.
        setupNavigationSpinsDisplay()
       // NotificationCenter.default.addObserver(self, selector: #selector(spinsDidChange), name: CoinsManager.spinsDidChangeNotification, object: nil)

        
        // Spin once on load
        let selectedRows = viewModel.spinSlots()
        for (i, row) in selectedRows.enumerated() {
            pickerView.selectRow(row, inComponent: i, animated: true)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Fade in the spin button.
        UIView.animate(withDuration: 0.5,
                       delay: 0.3,
                       options: .curveEaseOut,
                       animations: { self.buttonSpin.alpha = 1 },
                       completion: nil)
        
        // Check if spins have been collected today.
        if let stats = viewModel.userStats, !stats.collectedSpinsToday {
            // Show daily spins alert only once per day.
            let alert = UIAlertController(title: "Daily Spins", message: "Would you like to collect your daily spins?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Collect", style: .default, handler: { _ in
                // Call collectSpins, which updates the stats and saves the day in the Keychain.
                self.viewModel.collectSpins()
                self.updateSpinsUI()
            }))
            alert.addAction(UIAlertAction(title: "Later", style: .cancel))
            present(alert, animated: true)
        }
    }

    
    // MARK: - IBActions
    
    @IBAction func spin(_ sender: AnyObject) {
        // 1. Check if the user has spins left.
        guard viewModel.canSpin() else {
            // Show alert if no spins left.
            let alert = UIAlertController(title: "No Spins Left", message: "You don't have any spins left.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                self.navigationController?.popViewController(animated: true)
            }))
            present(alert, animated: true)
            return
        }
        
        // 2. Decrement spins.
        viewModel.decrementSpin()
        
        // 3. Play sounds and perform the spin.
        winSound.pause()
        rattle.play()
        
        let selectedRows = viewModel.spinSlots()
        for (i, row) in selectedRows.enumerated() {
            pickerView.selectRow(row, inComponent: i, animated: true)
        }
        
        // 4. Check win or lose.
        let outcome = viewModel.checkWinOrLose(selectedRows: selectedRows)
        // For testing, print the outcome message.
        print("Outcome: \(outcome.message)")
        if outcome.playWinSound {
            winSound.play()
        }
        
        // 5. Animate the button.
        animateButton()
        
        // 6. Save changes to Core Data.
        CoreDataManager.shared.saveContext()
        updateSpinsUI()
    }

    func updateSpinsUI() {
        // Update your spins label using the viewModel's dailySpinsRemaining property.
        spinsLabel.text = "\(viewModel.dailySpinsRemaining)"
        print("\(viewModel.dailySpinsRemaining)")
    }

    
    
    // MARK: - UI Setup and Animations
    func setupUIAndSound() {
        // Sound setup
        winSound.setupPlayer(soundName: K.sound, soundType: .m4a)
        rattle.setupPlayer(soundName: K.rattle, soundType: .m4a)
        winSound.volume(1.0)
        rattle.volume(0.1)
        
        // UI setup
        buttonSpin.alpha = 0
        bounds = buttonSpin.bounds
        
        // Removed labelResult UI configuration.
        pickerView.layer.cornerRadius = 10
        buttonSpin.layer.cornerRadius = 40
    }
    
    func animateButton() {
        let shrinkSize = CGRect(
            x: bounds.origin.x,
            y: bounds.origin.y,
            width: bounds.size.width - 15,
            height: bounds.size.height
        )
        
        UIView.animate(
            withDuration: 0.5,
            delay: 0.0,
            usingSpringWithDamping: 0.1,
            initialSpringVelocity: 5,
            options: .curveLinear,
            animations: {
                self.buttonSpin.bounds = shrinkSize
            },
            completion: nil
        )
    }
}

// MARK: - UIPickerViewDataSource / Delegate
extension SlotViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 100
    }
    
//    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
//        return 80.0
//    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 120.0
    }
    
    func pickerView(_ pickerView: UIPickerView,
                    viewForRow row: Int,
                    forComponent component: Int,
                    reusing view: UIView?) -> UIView {
        
        // Create a label for the picker row
        let pickerLabel: UILabel
        if let reusedLabel = view as? UILabel {
            pickerLabel = reusedLabel
        } else {
            pickerLabel = UILabel()
            pickerLabel.textAlignment = .justified
            pickerLabel.font = UIFont(name: K.emojiFont, size: 40)
        }
        
        // Use the index from viewModel's data to pick the correct emoji from K.imageArray
        let symbolIndex = viewModel.dataArray[component][row]
        pickerLabel.text = K.imageArray[symbolIndex]
        
        return pickerLabel
    }
}

extension SlotViewController {
    func setupNavigationSpinsDisplay() {
        // Define container size.
        let containerWidth: CGFloat = 100
        let containerHeight: CGFloat = 30
        let container = UIView(frame: CGRect(x: 0, y: 0, width: containerWidth, height: containerHeight))
        
        // image view for the spins icon.
        let spinsImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular, scale: .medium)
        let symbolImage = UIImage(systemName: "bitcoinsign.circle.fill", withConfiguration: symbolConfig)
        spinsImageView.image = symbolImage
        spinsImageView.tintColor = .systemYellow
        spinsImageView.contentMode = .scaleAspectFit
        container.addSubview(spinsImageView)
        
        //label to display the remaining spins.
        spinsLabel = UILabel(frame: CGRect(x: 30, y: 0, width: containerWidth - 30, height: containerHeight))
        spinsLabel.text = "\(viewModel.userStats?.dailySpinsRemaining ?? 0)"
        spinsLabel.font = UIFont.systemFont(ofSize: 16)
        spinsLabel.textColor = .black
        spinsLabel.textAlignment = .left
        container.addSubview(spinsLabel)
        
        let spinsBarButtonItem = UIBarButtonItem(customView: container)
        navigationItem.rightBarButtonItem = spinsBarButtonItem
        updateSpinsUI()
    }

}
