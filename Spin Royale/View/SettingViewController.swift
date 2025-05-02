//
//  SettingViewController.swift
//  Spin Royale
//
//  Created by Mayank Jangid on 5/2/25.
//

import UIKit

class SettingsViewController: UIViewController {
    @IBOutlet weak var imageBackButton: UIImageView!
    @IBOutlet weak var soundSwitch: UISwitch!
    @IBOutlet weak var imageContactUs: UIImageView!
    @IBOutlet weak var imagePrivacyPolicy: UIImageView!

    // MARK: – Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        let muted = SoundManager.isMuted
        soundSwitch.isOn = !muted
        soundSwitch.addTarget(self, action: #selector(soundSwitchChanged), for: .valueChanged)

        [imageBackButton, imageContactUs, imagePrivacyPolicy].forEach { iv in
            iv?.isUserInteractionEnabled = true
        }

        imageBackButton.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(didTapBack))
        )
        imageContactUs.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(didTapComingSoon))
        )
        imagePrivacyPolicy.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(didTapComingSoon))
        )
        
        // ontint or thumb phle se de diya hei --- honestly idk how to do this in storyboard either i am stupid that i have to do this or apple is
        soundSwitch.tintColor = .lightGray       // border color when off
        soundSwitch.backgroundColor = .lightGray      // fill color when off
        soundSwitch.layer.cornerRadius = soundSwitch.bounds.height / 2
        soundSwitch.clipsToBounds = true
    }
    // MARK: – Actions

    @objc private func soundSwitchChanged(_ sender: UISwitch) {
        // Toggle global mute
        SoundManager.setMuted(!sender.isOn)
    }

    @objc private func didTapComingSoon(_ sender: UITapGestureRecognizer) {
        guard let iv = sender.view else { return }
        animateTap(on: iv) {
            let alert = UIAlertController(
                title: "Coming Soon",
                message: "This feature is coming soon!",
                preferredStyle: .alert
            )
            alert.addAction(.init(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }

    @objc private func didTapBack() {
        animateTap(on: imageBackButton) {
            self.dismiss(animated: true)
        }
    }

    // MARK: – Animation Helper
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
