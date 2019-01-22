//
//  WeekStreakTracker.swift
//  Meditation
//
//  Created by Vincent Tang on 1/17/19.
//  Copyright © 2019 Vincent Tang. All rights reserved.
//

import UIKit

class WeekStreakTracker: UIStackView {
    
    // MARK: Constants
    struct Constants {
        static let daysInAWeek = 7
    }

    // MARK: Properties
    private var dayMarkers = [UIImage]()
    
    //MARK: Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTracker()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupTracker()
    }
    
    private func setupTracker() {
        
        for index in 0 ..< Constants.daysInAWeek {
            
        }
        
    }
}
