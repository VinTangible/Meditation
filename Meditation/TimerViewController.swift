//
//  TimerViewController.swift
//  Meditation
//
//  Created by Vincent Tang on 9/15/18.
//  Copyright © 2018 Vincent Tang. All rights reserved.
//

import UIKit
import AVFoundation

class TimerViewController: UIViewController {
    
    // MARK: Constants
    struct Constants {
        static let timeMeasurement = "min"
        static let bellSoundFileName = "bell"
        static let shortBellSoundFileName = "bell_short"
        static let wavSoundFileType = "wav"
        static let font = "Avenir Book"
        static let fontSize = CGFloat(17)
        static let meditationPickerTag = 1
        static let restPickerTag = 2
        static let meditateImage = "meditate"
        static let restImage = "rest"
        static let alertMessage = "Meditation Complete"
        static let panMin = Float(3)
        static let rewindSkipPercent = Float(0.0001)
        static let secondsInMinute = 60
        static let animationDuration = 0.25
    }
    
    // MARK: Properties
    @IBOutlet weak var timerButton: TimerButton!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var meditationPicker: UIPickerView!
    @IBOutlet weak var restPicker: UIPickerView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var phaseImage: UIImageView!
    
    var elapsedTime = Float(0) {
        didSet {
            timerLabel.text = timeString(time: Int(elapsedTime))
            progressView.progress = elapsedTime / totalTime
        }
    }
    var meditationTime = Int() {
        didSet {
            totalTime = Float(meditationTime + restTime)
        }
    }
    var restTime = Int() {
        didSet {
            totalTime = Float(meditationTime + restTime)
        }
    }
    var totalTime = Float() {
        didSet {
            rewindSkipTime = totalTime * Constants.rewindSkipPercent
        }
    }
    var rewindSkipTime = Float()
    var timer = Timer()
    var alertTimer = Timer()
    var bellPlayer: AVAudioPlayer?
    
    // Meditation time options
    let meditationTimes = [
        5,
        10,
        15
    ]
    
    // Rest time options
    let restTimes = [
        0,
        1,
        2,
        3,
        4,
        5
    ]
    
    // MARK: UserDefault Keys
    struct UserDefaultKey {
        static let meditationTime = "meditationTime"
        static let restTime = "restTime"
        static let weekStats = "weekStats"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load saved meditation and rest times onto picker views
        loadSavedTimes()
        
        // Set initial states of subviews
        setViewStates(running: false, animated: false)
        
        // Round edges of progress bar
        let ratio = progressView.frame.size.height / progressView.frame.size.width * 4
        let cornerRadius = progressView.frame.size.width * ratio
        progressView.layer.cornerRadius = cornerRadius
        progressView.clipsToBounds = true
        
        // Round edges of inside of the progress bar, the actual progress
        progressView.layer.sublayers![1].cornerRadius = cornerRadius
        progressView.subviews[1].clipsToBounds = true
        
        // Add action to timer button
        timerButton.addTarget(self, action: #selector(timerButtonTapped(sender:)), for: .touchUpInside)
        
        // Allow audio to play when phone is in ringer and silent mode
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
        }
        catch {
            fatalError("error: \(error.localizedDescription)")
        }
        
        // Add observer to pause timer when app goes inactive
        NotificationCenter.default.addObserver(self, selector: #selector(resigningActive), name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    // MARK: UI Actions
    @IBAction func timerButtonTapped(sender: UIButton) {
        // If button is tapped when timer is running, then pause timer
        if timerButton.isSelected {
            stopTimer()
        }
        // Otherwise button is tapped when timer is not running, so run timer
        else {
            runTimer()
        }
    }
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        cancel()
    }
    
    @IBAction func handlePan(sender: UIPanGestureRecognizer) {
        // Only handle pan if progress bar is shown
        if !progressView.isHidden {
            // Get the x velocity
            let velocity = Float(sender.velocity(in: self.view).x)
            
            // If velocity meets minimum pan movement, adjust the elapsed time
            if velocity > Constants.panMin || velocity < -Constants.panMin {
                let result = elapsedTime + (rewindSkipTime * velocity)
                
                elapsedTime = result < 0 ? 0 : result > totalTime ? totalTime : result
            }
        }
    }
    
    // MARK: Private Methods
    private func runTimer() {        
        // Set timer
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        
        setViewStates(running: true, animated: true)
        
        // Turn off idle timer to prevent sleep when meditating
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    private func stopTimer() {
        timer.invalidate()
        
        // Unselect timer button
        timerButton.isSelected = false
        
        // Turn back on idle timer
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    @objc private func updateTimer() {
        if elapsedTime < totalTime {
            // If meditation is done, play bell sound and transition to rest
            if Int(elapsedTime) >= meditationTime {
                if Int(elapsedTime) == meditationTime {
                    playShortBellSound()
                }
                
                phaseImage.image = UIImage(named: Constants.restImage)
            }
            else {
                phaseImage.image = UIImage(named: Constants.meditateImage)
            }
            
            elapsedTime += 1
        }
        // Stop the timer and play bell sound when meditation time is up
        else {
            stopTimer()
            alertation(title: Constants.alertMessage, message: "")
        }
    }
    
    // Stops timer and resets views to starting state
    private func cancel() {
        stopTimer()
        setViewStates(running: false, animated: true)
    }
    
    private func timeString(time: Int) -> String {
        let minutes = time / 60 % 60
        let seconds = time % 60
        
        return String(format: "%02i:%02i", minutes, seconds)
    }
    
    private func playShortBellSound() {
        guard let url = Bundle.main.url(forResource: Constants.shortBellSoundFileName, withExtension: Constants.wavSoundFileType) else {
            fatalError("Audio could not load: " + Constants.shortBellSoundFileName)
        }
        
        do {
            bellPlayer = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.wav.rawValue)
            bellPlayer!.play()
        } catch let error as NSError {
            fatalError("error: \(error.localizedDescription)")
        }
    }
    
    private func alertation(title: String, message: String) {
        playShortBellSound()
        
        self.alertTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true, block: { (timer) in
            self.playShortBellSound()
        })
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
            
            self.bellPlayer!.stop()
            self.alertTimer.invalidate()
            self.cancel()
            
        }))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    private func enablePickerViews(_ state: Bool) {
        if state == true {
            meditationPicker.alpha = 1
            restPicker.alpha = 1
            
            meditationPicker.isUserInteractionEnabled = true
            restPicker.isUserInteractionEnabled = true
        }
        else {
            meditationPicker.alpha = 0.5
            restPicker.alpha = 0.5
            
            meditationPicker.isUserInteractionEnabled = false
            restPicker.isUserInteractionEnabled = false
            
        }
    }
    
    private func setViewStates(running: Bool, animated: Bool) {
        // When timer is not running, these views are hidden
        transitionView(phaseImage, hidden: !running, animated: animated)
        transitionView(progressView, hidden: !running, animated: animated)
        transitionView(timerLabel, hidden: !running, animated: animated)
        transitionView(resetButton, hidden: !running, animated:animated)
        
        // When timer is not running, gray out picker view selection
        enablePickerViews(!running)
        
        // When timer is running, these states are set
        timerButton.isSelected = running
    }
    
    private func transitionView(_ view: UIView, hidden: Bool, animated: Bool) {
        if animated {
            // Remove any incomplete animations
            view.layer.removeAllAnimations()
            
            // Fade out
            if hidden {
                UIView.animate(withDuration: Constants.animationDuration, animations: {
                    view.alpha = 0
                }, completion: { finished in
                    if finished {
                        view.isHidden = true
                        
                        // Reset phase image to meditate image after phase image animation completes
                        if view == self.phaseImage {
                            self.phaseImage.image = UIImage(named: Constants.meditateImage)
                        }
                        // Reset elapsed time to 0 after time label animation completes
                        else if view == self.timerLabel {
                            self.elapsedTime = 0
                        }
                    }
                })
            }
            
            // Fade in
            else {
                if view.isHidden {
                    view.alpha = 0
                    view.isHidden = false
                }
                
                UIView.animate(withDuration: Constants.animationDuration, animations: {
                    view.alpha = 1
                })
            }
        }
        else {
            view.isHidden = hidden
        }
    }
    
    private func saveMeditationTime(_ time: Int) {
        UserDefaults.standard.set(time, forKey:UserDefaultKey.meditationTime)
    }
    
    private func loadMeditationTime() -> Int? {
        return UserDefaults.standard.value(forKey: UserDefaultKey.meditationTime) as? Int
    }
    
    private func saveRestTime(_ time: Int) {
        UserDefaults.standard.set(time, forKey: UserDefaultKey.restTime)
    }
    
    private func loadRestTime() -> Int? {
        return UserDefaults.standard.value(forKey: UserDefaultKey.restTime) as? Int
    }
    
    private func loadSavedTimes() {
        var defaultRowIndex: Int
        
        // Load saved meditation time
        if let savedMeditationTime = loadMeditationTime() {
            defaultRowIndex = meditationTimes.firstIndex(of: savedMeditationTime) ?? 0
            
            meditationPicker.selectRow(defaultRowIndex, inComponent: 0, animated: false)
            meditationTime = meditationTimes[defaultRowIndex] * Constants.secondsInMinute
        }
        else {
            // If no saved meditation time found, default to first option
            meditationTime = meditationTimes[0] * Constants.secondsInMinute
        }
        
        // Load saved rest time
        if let savedRestTime = loadRestTime() {
            defaultRowIndex = restTimes.firstIndex(of: savedRestTime) ?? 0
            
            restPicker.selectRow(defaultRowIndex, inComponent: 0, animated: false)
            restTime = restTimes[defaultRowIndex] * Constants.secondsInMinute
        }
        else {
            // If no saved rest time found, default to first option
            restTime = restTimes[0] * Constants.secondsInMinute
        }
    }
    
    @objc private func resigningActive() {
        if timer.isValid {
            stopTimer()
        }
    }
}

// MARK: UIPickerViewDataSource functions
extension TimerViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1    // One column
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == Constants.meditationPickerTag {
            return meditationTimes.count
        }
        else {
            return restTimes.count
        }
    }
}

// MARK: UIPickerViewDelegate functions
extension TimerViewController: UIPickerViewDelegate {
    
    // Create label for the options in picker view
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var label = view as? UILabel
        if label == nil {
            label = UILabel()
            
            label?.font = UIFont(name: Constants.font, size: Constants.fontSize)
            label?.textAlignment = .center
        }
        
        // Option text display
        if pickerView.tag == Constants.meditationPickerTag {
            label?.text = String(meditationTimes[row]) + " " + Constants.timeMeasurement
        }
        else {
            if row == 0 {
                // Assumes first row is 0 minutes... TODO: CHANGE?
                label?.text = "None"
            }
            else {
                label?.text = String(restTimes[row]) + " " + Constants.timeMeasurement
            }
        }
        
        return label!
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return (pickerView.superview?.frame.height)!
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == Constants.meditationPickerTag {
            // Get the selected meditation time in seconds
            meditationTime = meditationTimes[row] * Constants.secondsInMinute
            
            // Save selected meditation time
            saveMeditationTime(meditationTimes[row])
        }
        else {
            // Get the selected rest time in seconds
            restTime = restTimes[row] * Constants.secondsInMinute
            
            // Save selected rest time
            saveRestTime(restTimes[row])
        }
    }
}
