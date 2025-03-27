//
//  ViewController.swift
//  Spin Royale
//
//  Created by Mayank Jangid on 3/19/25.
//

import UIKit

class SlotViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var labelResult: UILabel!
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
        
        // Spin once on load
        let selectedRows = viewModel.spinSlots()
        for (i, row) in selectedRows.enumerated() {
            pickerView.selectRow(row, inComponent: i, animated: true)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Fade in the spin button
        UIView.animate(withDuration: 0.5,
                       delay: 0.3,
                       options: .curveEaseOut,
                       animations: { self.buttonSpin.alpha = 1 },
                       completion: nil)
    }
    
    // MARK: - IBActions
    @IBAction func spin(_ sender: AnyObject) {
        // 1. Check if the user has spins left
        guard viewModel.canSpin() else {
            labelResult.text = "No spins left"
            return
        }
        
        // 2. Decrement spins
        viewModel.decrementSpin()
        
        // 3. Play sounds and spin
        winSound.pause()
        rattle.play()
        
        let selectedRows = viewModel.spinSlots()
        for (i, row) in selectedRows.enumerated() {
            pickerView.selectRow(row, inComponent: i, animated: true)
        }
        
        // 4. Check win or lose
        let outcome = viewModel.checkWinOrLose(selectedRows: selectedRows)
        labelResult.text = outcome.message
        if outcome.playWinSound {
            winSound.play()
        }
        
        // 5. Animate button and save changes
        animateButton()
        CoreDataManager.shared.saveContext()
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
        setTrim()
        
        labelResult.layer.cornerRadius = 10
        labelResult.layer.masksToBounds = true
        pickerView.layer.cornerRadius = 10
        buttonSpin.layer.cornerRadius = 40
    }
    
    func setTrim() {
        labelResult.layer.borderColor = UIColor.label.cgColor
        pickerView.layer.borderColor = UIColor.label.cgColor
        buttonSpin.layer.borderColor = UIColor.label.cgColor
        
        labelResult.layer.borderWidth = 2
        pickerView.layer.borderWidth = 2
        buttonSpin.layer.borderWidth = 2
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
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 80.0
    }
    
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
            pickerLabel.textAlignment = .center
            pickerLabel.font = UIFont(name: K.emojiFont, size: 75)
        }
        
        // Use the index from viewModel's data to pick the correct emoji from K.imageArray
        let symbolIndex = viewModel.dataArray[component][row]
        pickerLabel.text = K.imageArray[symbolIndex]
        
        return pickerLabel
    }
}
