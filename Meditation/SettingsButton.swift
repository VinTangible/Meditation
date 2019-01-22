//
//  SettingsButton.swift
//  Meditation
//
//  Created by Vincent Tang on 11/13/18.
//  Copyright © 2018 Vincent Tang. All rights reserved.
//

import UIKit

class SettingsButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Set up the button image.
        setupButton()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        // Set up the button image.
        setupButton()
    }
    
    override func prepareForInterfaceBuilder() {
        // Set up the button image.
        setupButton()
    }
    
    // MARK: Private Methods
    private func setupButton(){
        
        // Load Button Images
        let bundle = Bundle(for: type(of: self))
        
        guard let settingsImage = UIImage(named: "settings", in: bundle, compatibleWith: self.traitCollection) else {
            fatalError("Image could not load: settings")
        }
        
        // Set the button images
        setImage(settingsImage, for: .normal)
        
        // Add constraints
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(lessThanOrEqualToConstant: settingsImage.size.height).isActive = true
        widthAnchor.constraint(lessThanOrEqualToConstant: settingsImage.size.width).isActive = true
    }
}
