//
//  PopUpCell.swift
//  RealmModelGenerator
//
//  Created by Zhaolong Zhong on 4/7/16.
//  Copyright © 2016 QuarkWorks. All rights reserved.
//

import Cocoa

protocol PopupCellDelegate: AnyObject {
    func popUpCell(popUpCell:PopUpCell, selectedItemDidChangeIndex index:Int)
}

@IBDesignable
class PopUpCell: NibDesignableView {
    static let IDENTIFIER = NSUserInterfaceItemIdentifier("PopUpCell")
    
    @IBOutlet weak var popUpButton: NSPopUpButton!
    
    weak var delegate:PopupCellDelegate?
    
    var row:Int?
    
    @IBOutlet var ibDelegate:Any? {
        set { self.delegate = newValue as? PopupCellDelegate }
        get { return self.delegate }
    }
    
    override func nibDidLoad() {
        super.nibDidLoad()
    }
    
    @IBInspectable var itemTitles:[String] {
        set {
            self.popUpButton.removeAllItems()
            self.popUpButton.addItems(withTitles: newValue)
        }
        
        get {
            return self.popUpButton.itemTitles
        }
    }
    
    @IBInspectable var selectedItemIndex:Int {
        set {
            self.popUpButton.selectItem(at: newValue)
        }
        
        get {
            return self.popUpButton.indexOfSelectedItem
        }
    }
    
    func menuDidClose(menu: NSMenu) {
        self.delegate?.popUpCell(popUpCell: self, selectedItemDidChangeIndex: self.selectedItemIndex)
    }
}
