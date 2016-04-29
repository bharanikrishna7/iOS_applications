//////////////////////////////////////////////////////////////
//  ViewController.swift                                    //
//  CSE615_HW1_P2                                           //
//                                                          //
//  Created by Venkata Bharani Krishna Chekuri on 2/2/16.   //
//  Copyright © 2016 Venkata Chekuri. All rights reserved.  //
//  SUID : 356579351                                        //
//  Course : CSE 651 - Mobile Application Programming       //
//  Homework : 1                                            //
//////////////////////////////////////////////////////////////

/*
 *  CHANGELOG:
 *  03/02/2015
 *  v1.1 :
 *  - Added functionality to disable UI Interactions for PickerView and TextField when user answers correctly
 *  - Change background in the PickerView, TextField and the entire view when the user answers correctly
 *  - Reset background colors and UI Interactions when the user touches flag image.
 *  - Enable case Insensitive comparison
 *
 *  02/02/2015
 *  v1.0 : Initial release
*/

import UIKit

class ViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {

    // MARK: Properties
    @IBOutlet weak var appLabel: UILabel!
    @IBOutlet weak var flagImage: UIImageView!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var nameResultField: UITextField!
    @IBOutlet weak var namePicker: UIPickerView!
    
    // MARK: Data to be asociated with UIPickerView (namePicker)
    let countryList = [ "Anguilla",
        "Antigua",
        "Aruba",
        "Bahamas",
        "Barbados",
        "Belize",
        "Bermuda",
        "Canada",
        "Cayman Islands",
        "Costa Rica",
        "Cuba",
        "Dominica",
        "Dominican Republic",
        "El Salvador",
        "Grenada",
        "Guatemala",
        "Haiti",
        "Honduras",
        "Jamaica",
        "Martinique",
        "Mexico",
        "Montserrat",
        "Nicaragua",
        "Panama",
        "Puerto Rico",
        "Saint Kitts",
        "Saint Lucia",
        "Saint Vicent",
        "Turks Islands",
        "USA",
        "US Virgin Islands",
        "Virgin Islands" ]
    
    // MARK: Names of the image which will be used to get image from Assets.xcassets
    // to the UIImageView(flagImage)
    let imageFlag = [ "North_America-Anguilla",
        "North_America-Antigua",
        "North_America-Aruba",
        "North_America-Bahamas",
        "North_America-Barbados",
        "North_America-Belize",
        "North_America-Bermuda",
        "North_America-Canada",
        "North_America-Cayman_Is",
        "North_America-Costa_Rica",
        "North_America-Cuba",
        "North_America-Dominica",
        "North_America-Dominican_Rep",
        "North_America-El_Salvador",
        "North_America-Grenada",
        "North_America-Guatemala",
        "North_America-Haiti",
        "North_America-Honduras",
        "North_America-Jamaica",
        "North_America-Martinique",
        "North_America-Mexico",
        "North_America-Montserrat",
        "North_America-Nicaragua",
        "North_America-Panama",
        "North_America-Puerto_Rico",
        "North_America-Saint_Kitts",
        "North_America-Saint_Lucia",
        "North_America-Saint_Vicent",
        "North_America-Turks_Islands",
        "North_America-USA",
        "North_America-US_Virgin_Is.",
        "North_America-Virgin_Islands"
    ]
    
    // A Tuple to associate the flag image with the country name. This will be populated in the viewDidLoad() function.
    var imageName: [(String, String)] = []
    // A Tuple to hold random value extracted from the imageName tuple. This will be used for validating the result with
    // users answer.
    var current: (String, String)? = nil
    
    // MARK: Associating data with the Picker (namePicker)
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // MARK: Number of elements in UIPickerView is declared using this function
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return imageName.count;
    }
    
    // MARK: The current Value in the picker view
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return imageName[row].1
    }
    
    // MARK: Setting the value in the UITextField (nameResultField) from the value in pickerView (namePicker) when the picker
    // view's row has been selected
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        nameResultField.text = imageName[row].1
        
        textFieldShouldReturn(nameResultField)                      // This function will be required to process result. For more details refer to the function
        textFieldDidEndEditing(nameResultField)                     // This function will be required to process result. For more details refer to the function
    }
    
    // MARK: This function will check the textField (nameResultField) and if the done is hit in keyboard it will
    // check for the user's answer with the result and return answer.
    func textFieldDidEndEditing(nameResultField: UITextField) {
        // We are checking whether the interactions are enabled to get proper results. Because if the interactions are disabled
        // we get result like "COUNTRY NAME - CORRECT - INCORRECT" which is not expected
        // The comparison is not case sensitive
        if((nameResultField.text?.caseInsensitiveCompare(current!.1) == NSComparisonResult.OrderedSame) && nameResultField.userInteractionEnabled && namePicker.userInteractionEnabled) {
            nameResultField.text = "\(nameResultField.text!) - CORRECT"
            
            // When the user's answer is correct we are changing the View Background to green with Alpha set to 0.90
            view.backgroundColor = UIColor.greenColor().colorWithAlphaComponent(0.90)
            
            // When the user's answer is correct we are disabling user interactions and changing background colors of the View Component
            nameResultField.userInteractionEnabled = false
            namePicker.userInteractionEnabled = false
            namePicker.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.5)
            nameResultField.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.5)
        }
        
        // If the user's answer is wrong the text field will update to "COUNTRY NAME - INCORRECT"
        if(nameResultField.userInteractionEnabled && namePicker.userInteractionEnabled && nameResultField.text != "") {
        nameResultField.text = "\(nameResultField.text!) - INCORRECT"
        }
    }
    
    // This function will make sure the keyboard will go down when the done key is hit on the keyboard.
    func textFieldShouldReturn(nameResultField: UITextField) -> Bool {
        nameResultField.resignFirstResponder()
        return true
    }
    
    // This is the first function which is processed when the app loads
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        super.viewDidLoad()
        
        // Enabling Picker
        namePicker.dataSource = self
        namePicker.delegate = self
        nameResultField.delegate = self
        
        // Enabling the text field and picker user interactions and changing their background color
        nameResultField.userInteractionEnabled = true
        namePicker.userInteractionEnabled = true
        namePicker.backgroundColor = UIColor(white: 1, alpha: 0)
        nameResultField.backgroundColor = UIColor(white: 1, alpha: 1)
        
        // Set Default background Color
        view.backgroundColor = UIColor.grayColor()
        
        // Create tap gesture recognizer. This is required for enabling the requirement which includes
        // "hit the flag image to reset the app screen"
        let tapGesture = UITapGestureRecognizer(target: self, action: "tapGesture:")
        
        // Add the tap gesture to flagImage (UIImageView);
        flagImage.addGestureRecognizer(tapGesture)
        
        // Making the flagImage (UIImageView) can be interacted with by user
        flagImage.userInteractionEnabled = true
        
        // Add values to the tuple from imageFlag and countryList arrays
        for index in 0...imageFlag.count-1 {
            imageName.append((imageFlag[index], countryList[index]))
        }
        
        // Have a placeholder in Text Field (nameResultField)
        nameResultField.placeholder = "Country Name"
        
        // Randomly extract a row from tuple imageName
        current = imageName[Int(arc4random_uniform(UInt32(imageName.count)))]
        
        // Set the flagImage (UIImageView) to the file name stored in current.0
        flagImage.image = UIImage(named: current!.0)
    }
    
    // MARK: Function will reset the entire screen i.e: The Text Field, Picker and the Flag image when the Flag image is clicked by the user
    func tapGesture(gesture: UIGestureRecognizer){
        if let flagImage = gesture.view as? UIImageView
        {
            nameResultField.userInteractionEnabled = true
            namePicker.userInteractionEnabled = true
            namePicker.backgroundColor = UIColor(white: 1, alpha: 0)
            nameResultField.backgroundColor = UIColor(white: 1, alpha: 1)
            
            nameResultField.placeholder = "Country Name"
            current = imageName[Int(arc4random_uniform(UInt32(imageName.count)))]
            flagImage.image = UIImage(named: current!.0)
            nameResultField.text = nil
            
            // Making animated false will directly change the picker to the given value without any spinning animation
            namePicker.selectRow(0, inComponent: 0, animated: true)
            
            view.backgroundColor = UIColor.grayColor()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

