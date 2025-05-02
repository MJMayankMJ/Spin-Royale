//
//  ViewController.swift
//  Spin Royale
//
//  Created by Mayank Jangid on 3/19/25.
//

import UIKit

class SlotViewController: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var buttonSpin: UIButton!
    @IBOutlet weak var imageBackButton: UIImageView!
    @IBOutlet weak var coinTotalLabel: UILabel!

    // MARK: - Properties
    var userStats: UserStats?
    private var viewModel: SlotViewModel!

    // Sound managers
    private var winSound = SoundManager()
    private var rattle = SoundManager()

    // For spin-button animation
    private var originalSpinBounds = CGRect.zero

    // Spins badge
    private let spinsBadgeContainer = UIView()
    private let spinsBadgeImageView = UIImageView()
    private let spinsBadgeLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        coinTotalLabel.text = "\(CoinsManager.shared.userStats?.totalCoins ?? 0)"
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(coinsDidChange),
                                               name: CoinsManager.coinsDidChangeNotification,
                                               object: nil)
        
        
        // Setup picker
        pickerView.delegate = self
        pickerView.dataSource = self
        
        // Initialize view model
        viewModel = SlotViewModel(userStats: userStats)

        setupUIAndSound()
        setupSpinsBadge()
        setupBackButton()

        // Initial random spin
        let rows = viewModel.spinSlots()
        for (component, row) in rows.enumerated() {
            pickerView.selectRow(row, inComponent: component, animated: true)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Fade in spin button
        UIView.animate(withDuration: 0.5,
                       delay: 0.3,
                       options: .curveEaseOut,
                       animations: { self.buttonSpin.alpha = 1.0 },
                       completion: nil)

        // Daily spins alert
        if let stats = viewModel.userStats, !stats.collectedSpinsToday {
            let alert = UIAlertController(
                title: "Daily Spins",
                message: "Would you like to collect your daily spins?",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "Collect", style: .default) { _ in
                self.viewModel.collectSpins()
                self.updateSpinsBadge()
            })
            alert.addAction(UIAlertAction(title: "Later", style: .cancel))
            present(alert, animated: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        coinTotalLabel.text = "\(CoinsManager.shared.userStats?.totalCoins ?? 0)"
    }
    
    @objc private func coinsDidChange() {
        coinTotalLabel.text = "\(CoinsManager.shared.userStats?.totalCoins ?? 0)"
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self,
                                                  name: CoinsManager.coinsDidChangeNotification,
                                                  object: nil)
    }
    
    // MARK: - IBActions
    @IBAction func spin(_ sender: Any) {
        guard viewModel.canSpin() else {
            let alert = UIAlertController(
                title: "No Spins Left",
                message: "You don't have any spins left.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                self.handleBackAction()
            })
            present(alert, animated: true)
            return
        }

        // Decrement and animate
        viewModel.decrementSpin()
        rattle.play()

        let rows = viewModel.spinSlots()
        for (component, row) in rows.enumerated() {
            pickerView.selectRow(row, inComponent: component, animated: true)
        }

        let outcome = viewModel.checkWinOrLose(selectedRows: rows)
        if outcome.playWinSound { winSound.play() }

        animateButtonTap(on: buttonSpin)
        CoreDataManager.shared.saveContext()
        updateSpinsBadge()
    }

    // MARK: - UI Setup
    private func setupUIAndSound() {
        // Sound
        winSound.setupPlayer(soundName: K.sound, soundType: .m4a)
        rattle.setupPlayer(soundName: K.rattle, soundType: .m4a)
        winSound.volume(1.0)
        rattle.volume(0.1)

        // Button appearance
        buttonSpin.alpha = 0
        originalSpinBounds = buttonSpin.bounds
        buttonSpin.layer.cornerRadius = buttonSpin.bounds.height / 2

        // Picker styling
        pickerView.layer.cornerRadius = 10
    }

    // for practice
    private func setupSpinsBadge() {
        guard let superview = view else { return }

        // Container styling
        spinsBadgeContainer.translatesAutoresizingMaskIntoConstraints = false
        spinsBadgeContainer.backgroundColor = UIColor(white: 1.0, alpha: 0.6)
        spinsBadgeContainer.layer.cornerRadius = 15
        superview.addSubview(spinsBadgeContainer)

        // Icon
        spinsBadgeImageView.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .regular)
        spinsBadgeImageView.image = UIImage(systemName: "bitcoinsign.circle.fill", withConfiguration: config)
        spinsBadgeImageView.tintColor = .systemYellow
        spinsBadgeContainer.addSubview(spinsBadgeImageView)

        // Label
        spinsBadgeLabel.translatesAutoresizingMaskIntoConstraints = false
        spinsBadgeLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        spinsBadgeLabel.textColor = .black
        spinsBadgeContainer.addSubview(spinsBadgeLabel)

        // Constraints
        NSLayoutConstraint.activate([
            // Container top-right in safe area
            spinsBadgeContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            spinsBadgeContainer.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            spinsBadgeContainer.heightAnchor.constraint(equalToConstant: 30),

            // Icon leading + centerY
            spinsBadgeImageView.leadingAnchor.constraint(equalTo: spinsBadgeContainer.leadingAnchor, constant: 8),
            spinsBadgeImageView.centerYAnchor.constraint(equalTo: spinsBadgeContainer.centerYAnchor),
            spinsBadgeImageView.widthAnchor.constraint(equalToConstant: 18),
            spinsBadgeImageView.heightAnchor.constraint(equalToConstant: 18),

            // Label next to icon
            spinsBadgeLabel.leadingAnchor.constraint(equalTo: spinsBadgeImageView.trailingAnchor, constant: 6),
            spinsBadgeLabel.trailingAnchor.constraint(equalTo: spinsBadgeContainer.trailingAnchor, constant: -8),
            spinsBadgeLabel.centerYAnchor.constraint(equalTo: spinsBadgeContainer.centerYAnchor)
        ])

        updateSpinsBadge()
    }

    // dont remoe the coin thing here its the one that is actually doing shit... the other thing is not doing ... why
    //idk why ... currently dont have time maybe will figure it out later
    private func updateSpinsBadge() {
        spinsBadgeLabel.text = "\(viewModel.dailySpinsRemaining)"
        coinTotalLabel.text = "\(CoinsManager.shared.userStats?.totalCoins ?? 0)"
    }

    private func setupBackButton() {
        imageBackButton.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapBack))
        imageBackButton.addGestureRecognizer(tap)
    }

    @objc private func didTapBack() {
        animateButtonTap(on: imageBackButton)
        self.handleBackAction()
    }

    private func handleBackAction() {
        if let nav = navigationController {
            nav.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }

    // MARK: - Animations
    private func animateButtonTap(on view: UIView) {
        UIView.animate(withDuration: 0.08,
                       animations: { view.transform = CGAffineTransform(scaleX: 0.95, y: 0.95) },
                       completion: { _ in
            UIView.animate(withDuration: 0.08) {
                view.transform = .identity
            }
        })
    }
}

// MARK: - UIPickerView DataSource & Delegate
extension SlotViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 3 }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int { 100 }
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat { 120 }

    func pickerView(_ pickerView: UIPickerView,
                    viewForRow row: Int,
                    forComponent component: Int,
                    reusing view: UIView?) -> UIView {
        let label: UILabel = (view as? UILabel) ?? UILabel()
        label.textAlignment = .center
        label.font = UIFont(name: K.emojiFont, size: 40)
        let symbolIndex = viewModel.dataArray[component][row]
        label.text = K.imageArray[symbolIndex]
        return label
    }
}
