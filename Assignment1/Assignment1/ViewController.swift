//
//  ViewController.swift
//  Assignment1
//
//  Created by Renzelle Frank V Rodrigueza on 2017-01-20.
//  Copyright © 2017 com.renzellerodrigueza. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController,UIPickerViewDataSource,UIPickerViewDelegate {
   



    @IBOutlet weak var nightModeSwitch: UISwitch!
    @IBOutlet weak var descriptionField: UITextField!
    @IBOutlet weak var timePicker: UIPickerView!
    @IBOutlet weak var currentTimerLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var nightModeLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    var counterFirst = 0
    
    var timer = Timer()
    
    private let secondsComponent = 2
    private let minuteComponent = 1
    private let hourComponent = 0
       private let hourPickerData =
        ["00h","01h","02h","03h","04h","05h","06h","07h","08h","09h","10h","11h","12h","13h","14h","15h","16h","17h","18h","19h","20h",
         "21h","22h","23h","24h"]
    private let secondsPickerData =
        ["00s","01s","02s","03s","04s","05s","06s","07s","08s","09s","10s","11s","12s","13s","14s","15s","16s","17s","18s","19s","20s",
                                      "21s","22s","23s","24s","25s","26s","27s","28s","29s","30s","31s","32s","33s","34s","35s","36s","37s","38s","39s","40s",
                                      "41s","42s","43s","44s","45s","46s","47s","48s","49s","50s","51s","52s","53s","54s","55s","56s","57s","58s","59s","60s"]
    private let minutePickerData =
        ["00m","01m","02m","03m","04m","05m","06m","07m","08m","09m","10m","11m","12m","13m","14m","15m","16m","17m","18m","19m","20m",
                                     "21m","22m","23m","24m","25m","26m","27m","28m","29m","30m","31m","32m","33m","34m","35m","36m","37m","38m","39m","40m",
                                     "41m","42m","43m","44m","45m","46m","47m","48m","49m","50m","51m","52m","53m","54m","55m","56m","57m","58m","59m","60m"]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        nightModeSwitch.setOn(false, animated: true)
        timePicker.dataSource = self
        timePicker.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK:-
    //MARK: Picker Data Sources Methods
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == secondsComponent
        {
            return secondsPickerData.count
        }
        else if component == minuteComponent
        {
            return minutePickerData.count
        }
        else
        {
            return hourPickerData.count
        }
        
    }
    
    //MARK: Picker Delegate Methods
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if component == secondsComponent
        {
           return secondsPickerData[row]
        }
        else if component == minuteComponent
        {
            return minutePickerData[row]
        }
        else
        {
            return hourPickerData[row]
        }
        
    }
    
    
    @IBAction func startTimer(_ sender: UIButton) {
        let titleButton = startButton.titleLabel
        let seconds = timePicker.selectedRow(inComponent: secondsComponent)
        let minutes = timePicker.selectedRow(inComponent: minuteComponent)
        let hours = timePicker.selectedRow(inComponent: hourComponent)
              if titleButton?.text == "Start"
        {
            startButton.setTitle("Pause", for: .normal)
            counterFirst = seconds + (minutes*60) + (hours*60*60)
            let utterance = AVSpeechUtterance(string: "Timer Started")
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
            let synthesizer = AVSpeechSynthesizer()
            synthesizer.speak(utterance)
            
                     timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateCounter), userInfo: nil, repeats: true)
        }
        else if titleButton?.text == "Pause"
        {
            startButton.setTitle("Resume", for: .normal)
            timer.invalidate()
        }
        else
        {
            startButton.setTitle("Pause", for: .normal)
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateCounter), userInfo: nil, repeats: true)
        }
        
    }
    
    func updateCounter() {
        
        if counterFirst > 0 {
           currentTimerLabel.text = "\(counterFirst)s left"
            counterFirst -= 1
            if counterFirst == 60
            {
                let utterance = AVSpeechUtterance(string: "Last One Minute")
                utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
                let synthesizer = AVSpeechSynthesizer()
                synthesizer.speak(utterance)
            }
            if counterFirst == 10
            {
                let utterance = AVSpeechUtterance(string: "Last Ten Seconds")
                utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
                let synthesizer = AVSpeechSynthesizer()
                synthesizer.speak(utterance)
            }
        }
        else
        {
            startButton.setTitle("Start", for: .normal)
            timer.invalidate()
            counterFirst = 0;
            currentTimerLabel.text = "00s left"
            
            let message = " Your Timer for this \(descriptionField.text!) is over"
            let controller = UIAlertController(title: "Times Up!", message:message, preferredStyle: .actionSheet)
            let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            controller.addAction(cancelButton)
            
            present(controller, animated: true, completion: nil)
            let utterance = AVSpeechUtterance(string: "Times Up")
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
            let synthesizer = AVSpeechSynthesizer()
            synthesizer.speak(utterance)
            
            descriptionField.text = ""
        }
    }
    

    @IBAction func resetTimer(_ sender: UIButton) {
        
        startButton.setTitle("Start", for: .normal)
        timer.invalidate()
        counterFirst = 0;
        currentTimerLabel.text = "00s left"
        
    }
    
    @IBAction func onSwitchChanged(_ sender: UISwitch) {
        if sender.isOn
        {
            view.backgroundColor = UIColor.black
            titleLabel.textColor = UIColor.white
            nightModeLabel.textColor = UIColor.white
            timerLabel.textColor = UIColor.white
            descriptionLabel.textColor = UIColor.white
            currentTimerLabel.textColor = UIColor.white
            timePicker.backgroundColor = UIColor.white
            
        }
        else
        {
            view.backgroundColor = UIColor.white
            titleLabel.textColor = UIColor.black
            nightModeLabel.textColor = UIColor.black
            timerLabel.textColor = UIColor.black
            descriptionLabel.textColor = UIColor.black
            currentTimerLabel.textColor = UIColor.black
            timePicker.backgroundColor = UIColor.white

        }
    }

    @IBAction func onFinish(_ sender: UITextField) {
        sender.resignFirstResponder()
    }
    
    @IBAction func onClickOutside(_ sender: UITapGestureRecognizer) {
        descriptionField.resignFirstResponder()
    }
    
    
}

