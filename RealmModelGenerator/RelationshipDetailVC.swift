//
//  RelationshipDetailVC.swift
//  RealmModelGenerator
//
//  Created by Zhaolong Zhong on 3/29/16.
//  Copyright © 2016 QuarkWorks. All rights reserved.
//

import Cocoa

class RelationshipDetailVC: NSViewController, RelationshipDetailViewDelegate, Observer {
    static let TAG = NSStringFromClass(RelationshipDetailVC.self)
    
    private var entityNameList:[String] = ["None"]
    
    @IBOutlet weak var relationshipDetailView: RelationshipDetailView! {
        didSet{ self.relationshipDetailView.delegate = self }
    }
    
    weak var relationship:Relationship? {
        didSet{
            if oldValue === self.relationship { return }
            oldValue?.observable.removeObserver(observer: self)
            self.relationship?.observable.addObserver(observer: self)
            self.invalidateViews()
        }
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func invalidateViews() {
        if !self.isViewLoaded || relationship == nil { return }
        guard let relationship = self.relationship else {
            return
        }
        relationshipDetailView.name = relationship.name
        relationshipDetailView.isMany = relationship.isMany
        self.entityNameList = ["None"]
        relationship.entity!.model.entities.forEach{(e) in entityNameList.append(e.name)}
        self.relationshipDetailView.destinationNames = self.entityNameList
        if let destination = relationship.destination {
            relationshipDetailView.selectedIndex = entityNameList.index(of: destination.name)!
        } else {
            relationshipDetailView.selectedIndex = 0
        }
    }
    
    func onChange(observable: Observable) {
        self.invalidateViews()
    }
    
    // MARK: - RelationshipDetailView delegate
    func relationshipDetailView(relationshipDetailView: RelationshipDetailView, shouldChangeRelationshipTextField newValue: String, identifier: NSUserInterfaceItemIdentifier) -> Bool {
        do {
            try self.relationship!.setName(name: newValue)
        } catch {
            Tools.popupAlert(messageText: "Error", buttonTitle: "OK", informativeText: "Unable to rename relationship: \(relationship!.name) to: \(newValue). There is another relationship with the same name.")
            return false
        }
        
        return true
    }
    
    func relationshipDetailView(relationshipDetailView attributeDetailView: RelationshipDetailView, shouldChangeRelationshipCheckBoxFor identifier: NSUserInterfaceItemIdentifier, state: Bool) -> Bool {
        
        self.relationship!.isMany = state
        
        return true
    }
    
    func relationshipDetailView(relationshipDetailView: RelationshipDetailView, selectedDestinationDidChange selectedIndex: Int) -> Bool {
        self.relationship!.destination = self.relationship?.entity.model.entities.filter({$0.name == entityNameList[selectedIndex]}).first
                return true
    }
}
