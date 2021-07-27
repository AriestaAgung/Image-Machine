//
//  MachineDetailVC.swift
//  Image Machine
//
//  Created by odikk on 22/07/21.
//

import UIKit

class MachineDetailVC: UIViewController {
    
    @IBOutlet weak var machineName: UILabel!
    @IBOutlet weak var machineType: UILabel!
    @IBOutlet weak var maintenanceDate: UILabel!
    @IBOutlet weak var photoCollectionView: UICollectionView!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var navItem: UINavigationItem!
    var machine: MachineEntity?
    var machineImages = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initComponent()
        self.hidesBottomBarWhenPushed = true
        self.navItem.title = machine?.machineName
        self.navItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(backButton))
    }
    
    @objc private func backButton(){
        self.dismiss(animated: true, completion: nil)
    }
    
    
    private func initComponent(){
        photoCollectionView.delegate = self
        photoCollectionView.dataSource = self
        machineName.text = machine?.machineName
        machineType.text = machine?.machineType
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        let date = formatter.string(from: (machine?.lastMaintenance)!)
        maintenanceDate.text = date
        guard let images = DBUtils().imagesFromCoreData(object: machine?.image) else { return }
        machineImages.append(contentsOf: images)
        print(machineImages.count)
        self.navigationController?.navigationBar.isHidden = false
        self.hidesBottomBarWhenPushed = true

    }
    
    @IBAction func editTap(_ sender: Any) {
        performSegue(withIdentifier: "editMachineSegue", sender: self)
    }
    @IBAction func deleteTap(_ sender: UIButton) {
        let dialog = UIAlertController(title: "Delete Machine", message: "Are you sure want to delete this Machine?", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Yes", style: .destructive, handler: { ACTION in
            self.navigationController?.popViewController(animated: true)
            if let id =  self.machine?.machineID{
                DBUtils().deleteMachineData(id: Int(id))
            }
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        dialog.addAction(okAction)
        dialog.addAction(cancelAction)
        self.present(dialog, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editMachineSegue"{
            if let vc = segue.destination as? EditMachineVC{
                vc.machines = self.machine
            }
        }
    }
    
    @objc func imageTapped(_ sender: UITapGestureRecognizer) {
        let imageView = sender.view as! UIImageView
        let newImageView = UIImageView(image: imageView.image)
        newImageView.frame = UIScreen.main.bounds
        newImageView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)
        newImageView.contentMode = .scaleAspectFit
        newImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage))
        newImageView.addGestureRecognizer(tap)
        self.view.addSubview(newImageView)
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = true
        
    }

    @objc func dismissFullscreenImage(_ sender: UITapGestureRecognizer) {
        self.navigationController?.isNavigationBarHidden = false
        self.tabBarController?.tabBar.isHidden = false
        sender.view?.removeFromSuperview()
        
        
    }
    
}

extension MachineDetailVC: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return machineImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "machineDetailImageCell", for: indexPath) as! MachineDetaiImageCell
        cell.machineImage.image = machineImages[indexPath.row]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! MachineDetaiImageCell
        cell.machineImage.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        cell.machineImage.addGestureRecognizer(tapGesture)
    }
    
    
}
