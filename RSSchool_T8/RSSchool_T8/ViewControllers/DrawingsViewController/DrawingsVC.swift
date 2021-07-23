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
        self.buttonTree.isSelected = true
        self.buttonHead.isSelected = false
        self.buttonLandscape.isSelected = false
        self.buttonPlanet.isSelected = false
    }
    @IBAction func buttonHeadAction(_ sender: RSButton) {
        self.drawing = "Head"
        self.buttonTree.isSelected = false
        self.buttonHead.isSelected = true // default state
        self.buttonLandscape.isSelected = false
        self.buttonPlanet.isSelected = false
    }
    @IBAction func buttonLandscapeAction(_ sender: RSButton) {
        self.drawing = "Landscape"
        self.buttonTree.isSelected = false
        self.buttonHead.isSelected = false
        self.buttonLandscape.isSelected = true
        self.buttonPlanet.isSelected = false
    }
    @IBAction func buttonPlanetAction(_ sender: RSButton) {
        self.drawing = "Planet"
        self.buttonTree.isSelected = false
        self.buttonHead.isSelected = false
        self.buttonLandscape.isSelected = false
        self.buttonPlanet.isSelected = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // change buttons to "selectable"
        self.buttonTree.selectableState = true
        self.buttonHead.selectableState = true
        self.buttonLandscape.selectableState = true
        self.buttonPlanet.selectableState = true
        
        self.buttonHead.isSelected = true

    }
    

}
