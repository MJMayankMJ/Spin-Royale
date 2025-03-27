//
//  EggCell.swift
//  Spin Royale
//
//  Created by Mayank Jangid on 3/26/25.
//

import UIKit

enum EggCellState {
    case normal         // Dark tile, no center image
    case highlighted    // Light tile, no center image
    case egg            // Dark tile with egg image
    case skull          // Dark tile with skull image
}

class EggCell: UICollectionViewCell {
    
    // MARK: - Outlets (connect these in your EggCell.xib)
    @IBOutlet weak var tileImageView: UIImageView!
    @IBOutlet weak var centerImageView: UIImageView!
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        configureCell(state: .normal)
    }
    
    // MARK: - Configuration
    func configureCell(state: EggCellState) {
        switch state {
        case .normal:
            tileImageView.image = UIImage(named: K.darkTile)      // Dark tile image asset
            centerImageView.isHidden = true
            
        case .highlighted:
            tileImageView.image = UIImage(named: K.lightTile)     // Light tile image asset
            centerImageView.isHidden = true
            
        case .egg:
            tileImageView.image = UIImage(named: K.darkTile)
            centerImageView.image = UIImage(named: K.eggPNG)       // Egg image asset
            centerImageView.isHidden = false
            
        case .skull:
            tileImageView.image = UIImage(named: K.darkTile)
            centerImageView.image = UIImage(named: K.skullPNG)     // Skull image asset
            centerImageView.isHidden = false
        }
    }
}

