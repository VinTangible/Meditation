//
//  TimerButton.swift
//  Meditation
//
//  Created by Vincent Tang on 9/15/18.
//  Copyright © 2018 Vincent Tang. All rights reserved.
//

import UIKit

class TimerButton: UIButton {

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
        
        guard let playImage = UIImage(named: "play", in: bundle, compatibleWith: self.traitCollection) else {
            fatalError("Image could not load: play")
        }
        
        guard let pauseImage = UIImage(named: "pause", in: bundle, compatibleWith: self.traitCollection) else {
            fatalError("Image could not load: pause")
        }
        
        // Set the button images
        setImage(playImage, for: .normal)
        setImage(playImage, for: [.normal, .highlighted])
        setImage(pauseImage, for: .selected)
        setImage(pauseImage, for: [.selected, .highlighted])
        
        // Add constraints
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(lessThanOrEqualToConstant: playImage.size.height).isActive = true
        widthAnchor.constraint(lessThanOrEqualToConstant: playImage.size.width).isActive = true
    }
}
