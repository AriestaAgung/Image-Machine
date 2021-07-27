//
//  EditMachineVC.swift
//  Image Machine
//
//  Created by odikk on 26/07/21.
//

import UIKit
import DKImagePickerController

class EditMachineVC: UIViewController {
    
    
    @IBOutlet weak var machineName: UITextField!
    @IBOutlet weak var machineType: UITextField!
    @IBOutlet weak var lastMaintenanceBtn: UIButton!
    @IBOutlet weak var selectImgBtn: UIButton!
    @IBOutlet weak var imageCollectionView: UICollectionView!
    @IBOutlet weak var submitBtn: UIButton!
    var machines: MachineEntity!
    var imageArray = [UIImage]()
    var stringDate = ""
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
        machineName.text = machines.machineName
        machineType.text = machines.machineType
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        let date = formatter.string(from: machines.lastMaintenance!)
        lastMaintenanceBtn.setTitle(date, for: .normal)
        lastMaintenanceBtn.addTarget(self, action: #selector(showDatePicker(_:)), for: .touchUpInside)
        if machines.image != nil {
            let imgs = DBUtils().imagesFromCoreData(object: machines.image)!
            imageArray.append(contentsOf: imgs)
        }
        imageCollectionView.delegate = self
        imageCollectionView.dataSource = self
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
        lastMaintenanceBtn.setTitle(" \(stringDate)", for: .normal)
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
    
    @IBAction func pickImages(_ sender: Any) {
        let picker = DKImagePickerController()
        picker.maxSelectableCount = 10
        picker.assetType = .allPhotos
        picker.showsCancelButton = true
        picker.defaultAssetGroup = .smartAlbumUserLibrary
        picker.didSelectAssets = { (assets: [DKAsset]) in
            self.imageArray.removeAll()
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
    
    
    @IBAction func updateMachine(_ sender: Any) {
        let name = self.machineName.text
        let type = self.machineType.text
        let id = self.machines.machineID
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        let date = formatter.date(from: self.lastMaintenanceBtn.currentTitle!)
        
        var imgDatas: Data!
        if imageArray.count > 0{
            let imgData = DBUtils().coreDataObjectFromImages(images: imageArray)
            imgDatas = imgData
        }
        
        DBUtils().updateMachineData(id: Int(id), name: name!, type: type!, codeNumber: Int(id), lastMaintenance: date!, image: imgDatas){
            let dialog = UIAlertController(title: "Saved", message: "Data saved successfully!", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: { _ in
                self.performSegue(withIdentifier: "unwindToHome", sender: self)
            })
            dialog.addAction(okAction)
            self.present(dialog, animated: true)
            print("isi total imgs : \(self.imageArray.count)")
        }
        if (machineName.text == nil || machineType.text == nil || stringDate == "")  {
            let dialog = UIAlertController(title: "Alert", message: "Make sure every field is not null", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            dialog.addAction(okAction)
            self.present(dialog, animated: true)
        }
        
    }
    
    
    
}



extension EditMachineVC: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        imageArray.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "editImageCell", for: indexPath) as! EditImageCell
        cell.machineImage.image = imageArray[indexPath.row]
        return cell
    }
    
    
}
