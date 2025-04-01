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
            tileImageView.image = UIImage(named: K.darkTile)
            centerImageView.isHidden = true
            
        case .highlighted:
            tileImageView.image = UIImage(named: K.lightTile)
            centerImageView.isHidden = true
            
        case .egg:
            centerImageView.isHidden = false
            tileImageView.image = UIImage(named: K.darkTile)
            centerImageView.image = UIImage(named: K.eggPNG)
            
            //tileImageView.isHidden = true
            
        case .skull:
            centerImageView.isHidden = false
            tileImageView.image = UIImage(named: K.darkTile)
            centerImageView.image = UIImage(named: K.skullPNG)
        }
    }
}

