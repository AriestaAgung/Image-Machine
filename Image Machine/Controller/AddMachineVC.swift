//
//  AddMachineVC.swift
//  Image Machine
//
//  Created by odikk on 22/07/21.
//

import UIKit
import DKImagePickerController
import CoreData

class AddMachineVC: UIViewController {
    
    @IBOutlet weak var machineName: UITextField!
    @IBOutlet weak var machineType: UITextField!
    @IBOutlet weak var lastMaintenanceDateBtn: UIButton!
    @IBOutlet weak var selectImageBtn: UIButton!
    @IBOutlet weak var imageCollectionView: UICollectionView!
    @IBOutlet weak var submitBtn: UIButton!
    var stringDate = ""
    var imageArray = [UIImage]()
    var machine: MachineEntity!
    var imageEntity: ImageEntity!
    var managedObjectContext = DBUtils().context
    
    private lazy var datePicker : UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.autoresizingMask = .flexibleWidth
        if #available(iOS 13, *) {
            datePicker.backgroundColor = .label
        } else {
            datePicker.backgroundColor = .white
        }
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(self.dateChanged), for: .valueChanged)
        return datePicker
    }()
    
    private lazy var toolbar : UIToolbar = {
        let toolBar = UIToolbar()
        toolBar.translatesAutoresizingMaskIntoConstraints = false
        toolBar.barStyle = .default
        toolBar.items = [UIBarButtonItem.init(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.onDoneClicked))]
        toolBar.sizeToFit()
        return toolBar
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initComponent()
        
    }
    
    private func initComponent(){
        imageCollectionView.delegate = self
        imageCollectionView.dataSource = self
        lastMaintenanceDateBtn.addTarget(self, action: #selector(showDatePicker(_:)), for: .touchUpInside)
        submitBtn.layer.cornerRadius = 10
        self.hideKeyboardWhenTappedAround()
    }
    
    
    @objc private func showDatePicker(_ sender: UITextField){
        addDatePicker()
    }
    
    
    @objc private func onDoneClicked(picker : UIDatePicker) {
        datePicker.removeFromSuperview()
        toolbar.removeFromSuperview()
        if stringDate == "" {
            let dateNow = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yyyy"
            stringDate = formatter.string(from: dateNow)
        }
        lastMaintenanceDateBtn.setTitle(" \(stringDate)", for: .normal)
    }
    
    @objc private func dateChanged(picker : UIDatePicker) {
        let date = picker.date
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        stringDate = formatter.string(from: date)
    }
    
    private func addDatePicker() {
        self.view.addSubview(self.datePicker)
        self.view.addSubview(self.toolbar)
        
        NSLayoutConstraint.activate([
            self.datePicker.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            self.datePicker.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            self.datePicker.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            self.datePicker.heightAnchor.constraint(equalToConstant: 300)
        ])
        
        NSLayoutConstraint.activate([
            self.toolbar.bottomAnchor.constraint(equalTo: self.datePicker.topAnchor),
            self.toolbar.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            self.toolbar.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            self.toolbar.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    
    @IBAction func pickImage(_ sender: Any) {
        imageArray.removeAll()
        let picker = DKImagePickerController()
        picker.maxSelectableCount = 10
        picker.assetType = .allPhotos
        picker.showsCancelButton = true
        picker.defaultAssetGroup = .smartAlbumUserLibrary
        picker.didSelectAssets = { (assets: [DKAsset]) in
            for item in assets{
                item.fetchOriginalImage(completeBlock: {(images, info) in
                    self.imageArray.append(images!)
                })
            }
            DispatchQueue.main.async {
                self.imageCollectionView.reloadData()
            }
        }
        if UIDevice.current.userInterfaceIdiom == .pad {
            picker.modalPresentationStyle = .formSheet;
        }
        self.present(picker, animated: true)
    }
    
    @IBAction func submitData(_ sender: Any) {        
        let name = self.machineName.text
        let type = self.machineType.text
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        let date = formatter.date(from: self.lastMaintenanceDateBtn.currentTitle!)
        
        var imgDatas: Data!
        if imageArray.count > 0 {
            let imgData = DBUtils().coreDataObjectFromImages(images: imageArray)
            imgDatas = imgData
        }
        
        DBUtils().saveMachineData(name: name!, type: type!, lastMaintenance: date!, image: imgDatas){
            let dialog = UIAlertController(title: "Saved", message: "Data saved successfully!", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: {_ in
                self.dismiss(animated: true)
            })
            dialog.addAction(okAction)
            self.present(dialog, animated: true)
            
        }
        
        if (machineName.text == nil || machineType.text == nil || stringDate == "")  {
            let dialog = UIAlertController(title: "Alert", message: "Make sure every field is not null", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            dialog.addAction(okAction)
            self.present(dialog, animated: true)
        }
        
    }
    
}

extension AddMachineVC: UITextFieldDelegate{
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return false
    }
}


extension AddMachineVC: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        imageArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "machineImageCell", for: indexPath) as! MachineImageCell
        cell.machineImage.image = imageArray[indexPath.row]
        return cell
    }
    
    
}
