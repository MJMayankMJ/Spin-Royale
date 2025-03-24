//
//  ViewController.swift
//  Spin Royale
//
//  Created by Mayank Jangid on 3/19/25.
//

import UIKit

class SlotViewController: UIViewController {
    
    // Connect these from Storyboard
    @IBOutlet weak var labelResult: UILabel!
    @IBOutlet weak var pickerView : UIPickerView!
    @IBOutlet weak var buttonSpin : UIButton!

    // ref of user s data (passed in from HomeVC)
    var userStats: UserStats?

    var bounds    = CGRect.zero
    var dataArray = [[Int](), [Int](), [Int]()]
    var winSound  = SoundManager()
    var rattle    = SoundManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        pickerView.delegate   = self
        pickerView.dataSource = self
        
        loadData()
        setupUIAndSound()
        spinSlots()  // spin once on load ---
    }
    
    // MARK: - Daily Spins Check
    @IBAction func spin(_ sender: AnyObject) {
        // 1. Check if user has spins left
        guard let stats = userStats,
              stats.dailySpinsRemaining > 0 else {
            labelResult.text = "No spins left"
            return
        }
        
        // 2. Decrement spins
        stats.dailySpinsRemaining -= 1
        
        // 3. Play sounds, spin
        winSound.pause()
        rattle.play()
        spinSlots()
        checkWinOrLose()

        animateButton()
        CoreDataManager.shared.saveContext()
    }
    
    func loadData() {
        for i in 0...2 {
            for _ in 0...100 {
                dataArray[i].append(Int.random(in: 0...K.imageArray.count - 1))
            }
        }
    }
    
    func setupUIAndSound() {
        // SOUND
        winSound.setupPlayer(soundName: K.sound, soundType: .m4a)
        rattle.setupPlayer(soundName: K.rattle, soundType: .m4a)
        winSound.volume(1.0)
        rattle.volume(0.1)
        
        // UI
        buttonSpin.alpha = 0
        bounds = buttonSpin.bounds
        setTrim()
        
        labelResult.layer.cornerRadius  = 10
        labelResult.layer.masksToBounds = true
        pickerView.layer.cornerRadius   = 10
        buttonSpin.layer.cornerRadius   = 40
    }
    
    func setTrim() {
        labelResult.layer.borderColor = UIColor.label.cgColor
        pickerView.layer.borderColor  = UIColor.label.cgColor
        buttonSpin.layer.borderColor  = UIColor.label.cgColor
        
        labelResult.layer.borderWidth = 2
        pickerView.layer.borderWidth  = 2
        buttonSpin.layer.borderWidth  = 2
    }
    
    func spinSlots() {
        for i in 0...2 {
            pickerView.selectRow(Int.random(in: 3...97), inComponent: i, animated: true)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration : 0.5,
                       delay        : 0.3,
                       options      : .curveEaseOut,
                       animations   : { self.buttonSpin.alpha = 1 },
                       completion   : nil)
    }
    
//    func checkWinOrLose() {
//        guard let stats = userStats else { return }
//
//        let emoji0 = pickerView.selectedRow(inComponent: 0)
//        let emoji1 = pickerView.selectedRow(inComponent: 1)
//        let emoji2 = pickerView.selectedRow(inComponent: 2)
//        
//        if (dataArray[0][emoji0] == dataArray[1][emoji1]
//            && dataArray[1][emoji1] == dataArray[2][emoji2]) {
//            
//            labelResult.text = K.win
//            winSound.play()
//            stats.totalCoins += 500  // big reward ---- winning
//        } else {
//            labelResult.text = K.lose
//            stats.totalCoins += 50   // base reward ------ loosing
//        }
//    }
    
    func checkWinOrLose() {
        guard let stats = userStats else { return }
        
        // Get the selected rows (indices into dataArray)
        let row0 = pickerView.selectedRow(inComponent: 0)
        let row1 = pickerView.selectedRow(inComponent: 1)
        let row2 = pickerView.selectedRow(inComponent: 2)
        
        // Retrieve the emoji indices from your dataArray
        let index0 = dataArray[0][row0]
        let index1 = dataArray[1][row1]
        let index2 = dataArray[2][row2]
        
        // Map those indices to the actual emoji strings from your constants
        let symbol0 = K.imageArray[index0]
        let symbol1 = K.imageArray[index1]
        let symbol2 = K.imageArray[index2]
        
        var reward = 0
        
        if symbol0 == symbol1 && symbol1 == symbol2 {
            // All three symbols match
            if symbol0 == "⓻" {
                reward = 2000
            } else {
                reward = 1000
            }
            labelResult.text = K.win  // Assuming K.win is your win message
            winSound.play()
        } else if symbol0 == symbol1 || symbol0 == symbol2 || symbol1 == symbol2 {
            // At least two symbols match
            reward = 200
            labelResult.text = "2 In A Row"
        } else {
            // No symbols match
            reward = 50
            labelResult.text = K.lose  // Assuming K.lose is your lose message
        }
        
        // Update the coins based on the reward
        stats.totalCoins += Int64(reward)
    }

    
    func animateButton() {
        let shrinkSize = CGRect(x: bounds.origin.x,
                                y: bounds.origin.y,
                                width: bounds.size.width - 15,
                                height: bounds.size.height)
        
        UIView.animate(withDuration: 0.5,
                       delay: 0.0,
                       usingSpringWithDamping: 0.1,
                       initialSpringVelocity: 5,
                       options: .curveLinear,
                       animations: { self.buttonSpin.bounds = shrinkSize },
                       completion: nil)
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
        
        let pickerLabel = UILabel()
        pickerLabel.textAlignment = .center
        pickerLabel.font = UIFont(name: K.emojiFont, size: 75)
        
        // show the correct emoji from dataArray
        pickerLabel.text = K.imageArray[dataArray[component][row]]
        
        return pickerLabel
    }
}
