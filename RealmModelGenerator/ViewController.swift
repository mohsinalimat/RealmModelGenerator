//
//  ViewController.swift
//  RealmModelGenerator
//
//  Created by Brandon Erbschloe on 3/2/16.
//  Copyright © 2016 QuarkWorks. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, EntitiesViewControllerDelegate, AttributesRelationViewControllerDelegate {
    static let TAG = NSStringFromClass(ViewController)
    
    static let entitiesViewControllerSegue = "EntitiesViewControllerSegue"
    static let attributesRelationshipsViewControllerSegue = "AttributesRelationshipsViewControllerSegue"
    static let detailsViewControllerSegue = "DetailsViewControllerSegue"
    
    var schema: Schema = Schema(name:"ViewControllerSchema")
    
    @IBOutlet weak var leftDivider: NSView!
    @IBOutlet weak var rightDivider: NSView!
    @IBOutlet weak var detailsContainerView: NSView!
    
    let emptyViewController = NSStoryboard(name: "Main", bundle: nil).instantiateControllerWithIdentifier("EmptyViewController") as! EmptyViewController
    let entityDetailViewController = NSStoryboard(name: "Main", bundle: nil).instantiateControllerWithIdentifier("EntityDetailViewController") as! EntityDetailViewController
    let attributeDetailViewController = NSStoryboard(name: "Main", bundle: nil).instantiateControllerWithIdentifier("AttributeDetailViewController") as! AttributeDetailViewController
    let relationshipDetailViewController = NSStoryboard(name: "Main", bundle: nil).instantiateControllerWithIdentifier("RelationshipDetailViewController") as! RelationshipDetailViewController
    
    let model  = Schema().createModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.view.wantsLayer = true
       
        leftDivider.layer?.backgroundColor = NSColor.grayColor().CGColor
        rightDivider.layer?.backgroundColor = NSColor.grayColor().CGColor
    }
    
    //MARK: - EntitiesViewController delegate
    func entitySelected(entity: Entity?) {
        detailsContainerView.subviews[0].removeFromSuperview()
        if let entity = entity {
            entityDetailViewController.setEntity(entity)
            detailsContainerView.addSubview(entityDetailViewController.view)
        } else {
            
            detailsContainerView.addSubview(emptyViewController.view)
        }
    }
    
    //MARK: - AttributesRelationshipsViewController delegate
    func attributeSelected(attribute: Attribute?) {
        detailsContainerView.subviews[0].removeFromSuperview()
        if let attribute = attribute {
        attributeDetailViewController.setAttribute(attribute)
        detailsContainerView.addSubview(attributeDetailViewController.view)
        } else {
            detailsContainerView.addSubview(emptyViewController.view)
        }
    }
    
    //MARK: - AttributesRelationshipsViewController delegate
    func relationshipSelected(relationship: Relationship?) {
        relationshipDetailViewController.setRelationship(Relationship.init(name: "relationship!", entity: model.createEntity()))
        detailsContainerView.subviews[0].removeFromSuperview()
        detailsContainerView.addSubview(relationshipDetailViewController.view)
    }
    
    @IBAction func returnEmptyState(sender: AnyObject) {
        detailsContainerView.subviews[0].removeFromSuperview()
        detailsContainerView.addSubview(emptyViewController.view)
    }
    
    @IBAction func checkEntityDetail(sender: AnyObject) {
        entityDetailViewController.setEntity(model.createEntity())
        detailsContainerView.subviews[0].removeFromSuperview()
        detailsContainerView.addSubview(entityDetailViewController.view)
    }
    
    @IBAction func checkAttributeDetail(sender: AnyObject) {
        attributeDetailViewController.setAttribute(model.createEntity().createAttribute())
        detailsContainerView.subviews[0].removeFromSuperview()
        detailsContainerView.addSubview(attributeDetailViewController.view)
    }
    
    @IBAction func checkRelationshipDetail(sender: AnyObject) {
        relationshipDetailViewController.setRelationship(Relationship.init(name: "relationship!", entity: model.createEntity()))
        detailsContainerView.subviews[0].removeFromSuperview()
        detailsContainerView.addSubview(relationshipDetailViewController.view)
    }
    
    //MARK: - prepareForSegue
    override func prepareForSegue(segue: NSStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier! {
        case ViewController.entitiesViewControllerSegue:
            if let enititesViewController: EntitiesViewController = segue.destinationController as? EntitiesViewController {
                enititesViewController.defaultSchema = schema
                enititesViewController.delegate = self
            }
            break;
        case ViewController.attributesRelationshipsViewControllerSegue:
            if let attributesRelationshipsViewController: AttributesRelationshipsViewController = segue.destinationController as? AttributesRelationshipsViewController {
                attributesRelationshipsViewController.delegate = self
            }
            break;
        case ViewController.detailsViewControllerSegue:
            break;
        default:
            //TODO: throw an NSAssertion().throw()
            break;
        }
    }
    
    //MARK: - generateFileContent
    func generateFileContent(entity:Entity, language:Language) -> [String] {
        
        switch language {
        case .Swift:
            return SwiftContentGenerator(entity: entity).getContent()
        case .Objc:
            return ObjectCContentGenerator(entity: entity).getContent()
        case .Java:
            return JavaContentGenerator(entity: entity).getContent()
        }
    }
    
    //Called from menu bar
    //TODO: remove after adding ui to generate model
    @IBAction func generateModelExample(sender: AnyObject!) {
        Tools.generateModelExample(schema)
        if let currentModel = schema.getCurrentModel() {
            print(ViewController.TAG + " version after generateSchemaExample = \(currentModel.version)")
        }
    }
    
    //Called from menu bar
    @IBAction func increaseVersion(sender: AnyObject!) {
        if let currentModel = schema.getCurrentModel() {
            print(ViewController.TAG + " version before createNewVersionModel = \(currentModel.version)")
        }
        do {
            try schema.increaseVersion()
        } catch {
            print(ViewController.TAG + " Cannot increase version")
        }
        if let currentModel = schema.getCurrentModel() {
            print(ViewController.TAG + " version after createNewVersionModel = \(currentModel.version)")
        }
    }
    
    //Called from menu bar
    @IBAction func exportToJava(sender: AnyObject!) {
        generateFileModels(.Java)
    }
    
    //Called from menu bar
    @IBAction func exportToObjectC(sender: AnyObject!) {
        generateFileModels(.Objc)
    }
    
    //Called from menu bar
    @IBAction func exportToSwift(sender: AnyObject!) {
        generateFileModels(.Swift)
    }
    
    //MARK: - generate FileModels
    func generateFileModels(language: Language) {
        var files: [FileModel] = []
        var validEnties = true
        for entity in schema.getCurrentModel()!.entities {
            let content = generateFileContent(entity, language: language)
            if !content.first!.isEmpty {
                switch language {
                case .Java:
                    let file = FileModel(name: entity.name, content: content.first!, fileExtension: "java");
                    files.append(file)
                    break
                case .Swift:
                    let file = FileModel(name: entity.name, content: content.first!, fileExtension: "swift");
                    files.append(file)
                    break;
                case .Objc:
                    let hFile = FileModel(name: entity.name, content: content.first!, fileExtension: "h");
                    let mFile = FileModel(name: entity.name, content: content.last!, fileExtension: "m");
                    files.append(hFile)
                    files.append(mFile)
                    break
                }
            } else {
                validEnties = false
            }
        }
        
        if files.count > 0 && validEnties {
            choosePathAndSaveFile(files)
        } else {
            print("There's no entity.")
        }
    }
    
    //MARK: - Show a panel to choose path and save files
    func choosePathAndSaveFile(files: [FileModel])
    {
        let openPanel = NSOpenPanel()
        openPanel.allowsOtherFileTypes = false
        openPanel.treatsFilePackagesAsDirectories = false
        openPanel.canChooseFiles = false
        openPanel.canChooseDirectories = true
        openPanel.canCreateDirectories = true
        openPanel.prompt = "Choose"
        openPanel.beginSheetModalForWindow(view.window!, completionHandler: { (button : Int) -> Void in
            if button == NSFileHandlingPanelOKButton{
                self.saveFile(files, toPath:openPanel.URL!.path!)
            }
        })
    }
    
    //MARK: - Save files to a path
    func saveFile(files: [FileModel], toPath path: String)
    {
        var error : NSError?
        
        for file in files {
            let filePath = "\(path)/\(file.name).\(file.fileExtension)"
            
            do {
                try file.content.writeToFile(filePath, atomically: false, encoding: NSUTF8StringEncoding)
            } catch let nSError as NSError {
                error = nSError
            }
            
            if error != nil{
                NSAlert(error: error!).runModal()
            }
        }
        
        if error == nil{
            //TODO: show success notification
            print("Success")
        }
    }
}