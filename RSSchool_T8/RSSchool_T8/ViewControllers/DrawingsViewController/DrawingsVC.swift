//
//  DrawingsVC.swift
//  RSSchool_T8
//
//  Created by Kiryl Kaveryn on 17.07.21.
//

import UIKit

class DrawingsVC: UIViewController {
    
    @objc var drawing = "Head"
    
    @IBOutlet weak var buttonTree: RSButton!
    @IBOutlet weak var buttonHead: RSButton!
    @IBOutlet weak var buttonLandscape: RSButton!
    @IBOutlet weak var buttonPlanet: RSButton!
    
    @IBAction func buttonTreeAction(_ sender: RSButton) {
        self.drawing = "Tree"
        self.buttonTree.setSelected(true)
        self.buttonHead.setSelected(false)
        self.buttonLandscape.setSelected(false)
        self.buttonPlanet.setSelected(false)
    }
    @IBAction func buttonHeadAction(_ sender: RSButton) {
        self.drawing = "Head"
        self.buttonTree.setSelected(false)
        self.buttonHead.setSelected(true) // default state
        self.buttonLandscape.setSelected(false)
        self.buttonPlanet.setSelected(false)
    }
    @IBAction func buttonLandscapeAction(_ sender: RSButton) {
        self.drawing = "Landscape"
        self.buttonTree.setSelected(false)
        self.buttonHead.setSelected(false)
        self.buttonLandscape.setSelected(true)
        self.buttonPlanet.setSelected(false)
    }
    @IBAction func buttonPlanetAction(_ sender: RSButton) {
        self.drawing = "Planet"
        self.buttonTree.setSelected(false)
        self.buttonHead.setSelected(false)
        self.buttonLandscape.setSelected(false)
        self.buttonPlanet.setSelected(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.buttonTree.selectedMode = true
        self.buttonHead.selectedMode = true
        self.buttonLandscape.selectedMode = true
        self.buttonPlanet.selectedMode = true
        
        self.buttonHead.setSelected(true)

    }
    

}
