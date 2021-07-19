//
//  TimerViewController.swift
//  RSSchool_T8
//
//  Created by Kiryl Kaveryn on 18.07.21.
//

import UIKit

@objc protocol TimerButtonsActions {
    func timerButtonTapped(_ sender: Any)
    func timerSaveButtonTapped(_ sender: Any)
}

class TimerViewController: UIViewController {

    @IBOutlet weak var minValue: UILabel!
    @IBOutlet weak var maxValue: UILabel!
    @IBOutlet weak var currentTimerValue: UILabel!
    @IBOutlet weak var timeControlSlider: UISlider!
    @IBOutlet weak var saveButton: RSButton!
    
    @IBAction func timerSaveButtonTapped(_ sender: Any) {
        self.view.removeFromSuperview()
    }
    
    
    @IBAction func timeControlSliderAction(_ sender: Any) {
        currentTimerValue.text = String(format: "%.2f", timeControlSlider.value) + " s"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
        
        self.saveButton.addTarget(self.parent, action:#selector(timerSaveButtonTapped), for: .touchUpInside)
    }
    
    func configureView() {
        self.view.frame = CGRect(x:0.0, y:self.view.frame.size.height - 333.5, width:self.view.frame.size.width, height:333.5 + 40)
        self.view.layer.cornerRadius = 40.0
        self.view.layer.masksToBounds = false;
        self.view.layer.shadowColor = UIColor.black.cgColor;
        self.view.layer.shadowRadius = 4.0
        self.view.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        self.view.layer.shadowOpacity = 0.25
        self.view.backgroundColor = UIColor.white
    }

}
