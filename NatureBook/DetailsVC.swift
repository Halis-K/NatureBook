//
//  DetailsVC.swift
//  NatureBook
//
//  Created by Halis Kayar on 11.12.2022.
//

import UIKit
import CoreData

class DetailsVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {


    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var placeTextField: UITextField!
    @IBOutlet weak var yearTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    var targetName = ""
    var targetId: UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if targetName != "" {
            saveButton.isHidden = true
            
            // Core Data Verileri Buraya Gelecek
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            let context = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Gallery")
            //Filtreleme
            let idString = targetId?.uuidString // id aldik
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString!)
            fetchRequest.returnsObjectsAsFaults = false //Uygulamanin daha hizli olmasi icin kullaniyoruz
            
            //Veriyi cekerken olusturdugumuz fetchRequest i sabit veya degiskene atayacaz ki bu bize dizi verecek. Bizde bu for loop icerisinde bu diziyi kullanabilecez. Cunku yukaridan gelecek diziyi tek tek incelememizi saglayacak.
            do {
                let results = try context.fetch(fetchRequest)
                for result in results as! [NSManagedObject] {
                    
                    if let name = result.value(forKey: "name") as? String {
                        nameTextField.text = name
                    }
                    if let place = result.value(forKey: "place") as? String {
                        placeTextField.text = place
                    }
                    if let year = result.value(forKey: "year") as? Int {
                        yearTextField.text = String(year)
                    }
                    if let imageData = result.value(forKey: "image") as? Data {
                        let image = UIImage(data: imageData)
                        imageView.image = image
                    }
                }
            } catch {
                print("Error")
            }
            
        } else {
            saveButton.isHidden = false
            saveButton.isEnabled = false
            nameTextField.text = ""
            placeTextField.text = ""
            yearTextField.text = ""
        }
        
        //resim yukleme yapmak icin gorselin tiklanabilir oldugunun kodunu yaziyoruz
        imageView.isUserInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTap))
        imageView.addGestureRecognizer(gestureRecognizer) //gestureRecognizer i bagladik
        
    }
    @IBAction func saveButtonClicked(_ sender: Any) {
        //Veri kaydetme islemi
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let saveData = NSEntityDescription.insertNewObject(forEntityName: "Gallery", into: context)
        
        saveData.setValue(nameTextField.text!, forKey: "name")
        saveData.setValue(placeTextField.text, forKey: "place")
        
        if let year = Int(yearTextField.text!) {
            saveData.setValue(year, forKey: "year")
        }
        
        let imagePress = imageView.image?.jpegData(compressionQuality: 0.5)
        saveData.setValue(imagePress, forKey: "image")
        saveData.setValue(UUID(), forKey: "id")
        
        do {
            try context.save()
            print("Succes")
        } catch {
            print("Error")
        }
        
        NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "newData"), object: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func imageTap() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = (info[.originalImage] as? UIImage)
        saveButton.isEnabled = true
        self.dismiss(animated: true, completion: nil)
    }
    
}
