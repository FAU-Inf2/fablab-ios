
import Foundation
import CoreActionSheetPicker

class ChangeAmountPickerHelper {
    
    // Helper-functions to show the change-amount-picker
    
    class func showChangeAmountPicker(cartEntry: CartEntry, initialValue: Double, delegateSucceedAction: (currentAmount: Double) -> Void, delegateCancelAction: () -> Void, alertChangeAmountAction: (currentAmount: Double) -> Void) {
        
        showChangeAmountPicker(productSearchAlertStrings: false, productName: cartEntry.product.name, productPrice: cartEntry.product.price, productUnit: cartEntry.product.unit, productRounding: cartEntry.product.rounding, initialValue: initialValue, delegateSucceedAction: delegateSucceedAction, delegateCancelAction: delegateCancelAction, alertChangeAmountAction: alertChangeAmountAction)
    }
    
    class func showChangeAmountPicker(cell: ProductCustomCell, initialValue: Double, delegateSucceedAction: (currentAmount: Double) -> Void, delegateCancelAction: () -> Void, alertChangeAmountAction: (currentAmount: Double) -> Void) {
        
        showChangeAmountPicker(productSearchAlertStrings: true, productName: cell.product.name!, productPrice: cell.product.price!, productUnit: cell.product.unit!, productRounding: cell.product.uom!.rounding!, initialValue: initialValue, delegateSucceedAction: delegateSucceedAction, delegateCancelAction: delegateCancelAction, alertChangeAmountAction: alertChangeAmountAction)
    }
    
    class func showChangeAmountPicker(productSearchAlertStrings productSearchAlertStrings: Bool, productName: String, productPrice: Double, productUnit: String, productRounding: Double, initialValue: Double, delegateSucceedAction: (currentAmount: Double) -> Void, delegateCancelAction: () -> Void, alertChangeAmountAction: (currentAmount: Double) -> Void) {
        
        var addToCart = true
        var currentAmount : Double = initialValue
        
        let pickerDelegate = ActionSheetPickerDelegate(unit: productUnit, price: productPrice, rounding: productRounding, didSucceedAction: { (amount: Double) -> Void in
            if addToCart == false {
                currentAmount = amount
                addToCart = true
            } else {
                // if currentAmount has initial value, take the amount value
                if currentAmount == initialValue {
                    currentAmount = amount
                }
                
                // Action if everything is correct:
                delegateSucceedAction(currentAmount: currentAmount)
            }
            }, didCancelAction: { delegateCancelAction()} )
        
        // set current amount
        pickerDelegate.setAmount(initialValue)
        
        // initial selection is also needed, to correctly set current amount
        let picker: ActionSheetCustomPicker = ActionSheetCustomPicker(title: "Menge auswählen".localized, delegate: pickerDelegate, showCancelButton: false, origin: self, initialSelections: [(initialValue/productRounding)-1])
        
        let doneButton: UIBarButtonItem = UIBarButtonItem()

        if productSearchAlertStrings == true {
            doneButton.title = "Hinzufügen".localized
        } else {
            doneButton.title = "Übernehmen".localized
        }
        
        picker.setDoneButton(doneButton)
        picker.addCustomButtonWithTitle("Freitext".localized, actionBlock: {
            addToCart = false
            picker.delegate.actionSheetPickerDidSucceed!(picker, origin: self)
            // Change amount action
            alertChangeAmountAction(currentAmount: currentAmount)})
        picker.tapDismissAction = TapAction.Cancel
        
        picker.showActionSheetPicker()
    }
    
    // Helper-functions to show the freetext-alert-dialog
    
    class func alertChangeAmount(viewController viewController: UIViewController, cartEntry: CartEntry, currentAmount: Double, pickerCancelActionHandler: () -> Void, pickerDoneActionHandlerFinished: (amount: Double) -> Void) {
        
        alertChangeAmount(productSearchAlertStrings: false, viewController: viewController, productName: cartEntry.product.name, productPrice: cartEntry.product.price, productUnit: cartEntry.product.unit, productRounding: cartEntry.product.rounding, currentAmount: currentAmount, pickerCancelActionHandler: pickerCancelActionHandler, pickerDoneActionHandlerFinished: pickerDoneActionHandlerFinished)
    }
    
    class func alertChangeAmount(viewController viewController: UIViewController, cell: ProductCustomCell, currentAmount: Double, pickerCancelActionHandler: () -> Void, pickerDoneActionHandlerFinished: (amount: Double) -> Void) {
        
        alertChangeAmount(productSearchAlertStrings: true, viewController: viewController, productName: cell.product.name!, productPrice: cell.product.price!, productUnit: cell.product.unit!, productRounding: cell.product.uom!.rounding!, currentAmount: currentAmount, pickerCancelActionHandler: pickerCancelActionHandler, pickerDoneActionHandlerFinished: pickerDoneActionHandlerFinished)
    }
    
    class func alertChangeAmount(productSearchAlertStrings productSearchAlertStrings: Bool, viewController: UIViewController, productName: String, productPrice: Double, productUnit: String, productRounding: Double, currentAmount: Double, pickerCancelActionHandler: () -> Void, pickerDoneActionHandlerFinished: (amount: Double) -> Void) {
        
        let formatString : String = "%." + String(productRounding.digitsAfterComma) + "f"
        
        var inputTextField: UITextField?
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "Abbrechen".localized, style: .Cancel, handler: { (Void) -> Void in pickerCancelActionHandler()})
        
        let doneActionTitle : String
        if productSearchAlertStrings == true {
            doneActionTitle = "Hinzufügen".localized
        } else {
            doneActionTitle = "Übernehmen".localized
        }
        
        let doneAction: UIAlertAction = UIAlertAction(title: doneActionTitle, style: .Default, handler: { (Void) -> Void in
            var amount: Double = NSString(string: inputTextField!.text!.stringByReplacingOccurrencesOfString(",", withString: ".")).doubleValue
            
            let invalidInput : Bool
            if amount < productRounding || amount > Double(Int.max) {
                invalidInput = true
                amount = currentAmount
            } else {
                invalidInput = false
            }
            
            let wrongRounding : Bool
            let divRes = amount / productRounding
            if divRes.digitsAfterComma != 0 {
                // round the user input down to match rounding.digitsAfterComma
                amount = amount.roundUpToRounding(productRounding)
                wrongRounding = true
            } else {
                wrongRounding = false
            }
                        
            if wrongRounding == true || invalidInput == true {
                let amountString = String(format: formatString, amount)
                
                var errorMsg : String = ""
                var errorTitle : String = ""
                if invalidInput == true {
                    // show different strings in productSearch
                    if productSearchAlertStrings == true {
                        errorTitle = "Fehlerhafte Eingabe".localized
                        errorMsg = "Wert ist ungültig".localized
                        errorMsg += "\n" + "Produkt wurde nicht dem Warenkorb hinzugefügt".localized
                    } else {
                        errorTitle = "Fehlerhafte Eingabe".localized
                        errorMsg = "Wert wurde nicht verändert".localized
                    }
                } else if wrongRounding == true  {
                    // show different strings in productSearch
                    if productSearchAlertStrings == true {
                        errorTitle = "Produkt wurde dem Warenkorb hinzugefügt".localized
                        errorMsg = "Wert wurde aufgerundet auf".localized + ": " + amountString + " " + productUnit
                    } else {
                        errorTitle = "Anzahl wurde geändert".localized
                        errorMsg = "Fehlerhafte Eingabe".localized
                        errorMsg += "\n" + "Wert wurde aufgerundet auf".localized + ": " + amountString + " " + productUnit
                    }
                }
                
                AlertView.showInfoView(errorTitle, message: errorMsg)
            }
            
            // finish changing amount-process
            if invalidInput == false {
                pickerDoneActionHandlerFinished(amount: amount)
            }
        })
        
        let lowestUnit : String = String(format: formatString, productRounding)
        let message = productName + "\n" + "Kleinste Einheit".localized + ": " + lowestUnit + " " + productUnit
        
        let alertController: UIAlertController = UIAlertController(title: "Menge eingeben".localized, message: message, preferredStyle: .Alert)
        alertController.addAction(cancelAction)
        alertController.addAction(doneAction)
        
        alertController.addTextFieldWithConfigurationHandler({ textField -> Void in
            inputTextField = textField
            inputTextField!.text = String(format: formatString, currentAmount)
        })
        
        viewController.presentViewController(alertController, animated: true, completion: nil)
    }


}