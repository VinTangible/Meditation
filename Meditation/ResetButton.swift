//
//  ResetButton.swift
//  Meditation
//
//  Created by Vincent Tang on 12/14/18.
//  Copyright © 2018 Vincent Tang. All rights reserved.
//

import UIKit

class ResetButton: UIButton {
    
    override open var isHighlighted: Bool {
        didSet {
            alpha = isHighlighted ? 0.3 : 1.0
        }
    }
    
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
        
        guard let defaultImage = UIImage(named: "cancel", in: bundle, compatibleWith: self.traitCollection) else {
            fatalError("Image could not load: cancel")
        }
        
        // Set the button images
        setImage(defaultImage, for: .normal)
        
        // Add constraints
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(lessThanOrEqualToConstant: defaultImage.size.height).isActive = true
        widthAnchor.constraint(lessThanOrEqualToConstant: defaultImage.size.width).isActive = true
    }
}
