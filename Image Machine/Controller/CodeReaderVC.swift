//
//  CodeReaderVC.swift
//  Image Machine
//
//  Created by odikk on 27/07/21.
//

import UIKit
import MercariQRScanner

class CodeReaderVC: UIViewController {
    
    var machine: MachineEntity!
    var qrScannerView: QRScannerView!


    override func viewDidLoad() {
        super.viewDidLoad()
        qrScannerView = QRScannerView(frame: view.bounds)
        view.addSubview(qrScannerView)
        qrScannerView.configure(delegate: self)
        qrScannerView.startRunning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if qrScannerView != nil {
            qrScannerView.startRunning()
        }
    }
        

    
     //MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "qrDetailSegue"{
            let vc = segue.destination as? MachineDetailVC
            vc?.machine = self.machine
        }
    }
    

}

extension CodeReaderVC: QRScannerViewDelegate{
    func qrScannerView(_ qrScannerView: QRScannerView, didSuccess code: String) {
        var id: Int = 0
        if let allMachine = DBUtils().getAllMachine(){
            for item in allMachine{
                if String(item.machineID) == code  {
                    self.machine = item
                    self.performSegue(withIdentifier: "qrDetailSegue", sender: self)
                    print(item)
                    qrScannerView.stopRunning()
                    id = Int(item.machineID)
                }
            }
            if id == 0 {
                qrScannerView.stopRunning()
                Utils().showToast(vc: self, message: "Not found", time: 2){
                    self.qrScannerView.startRunning()
                }
                qrScannerView.startRunning()
            }
        }
        
        
        
    }
    
    func qrScannerView(_ qrScannerView: QRScannerView, didFailure error: QRScannerError) {
        let dialog = UIAlertController(title: "Failed", message: "Not match", preferredStyle: .alert)
        let action = UIAlertAction(title: "Back", style: .default, handler: {_ in
            self.performSegue(withIdentifier: "unwindToHome", sender: self)
        })
        dialog.addAction(action)
        self.present(dialog, animated: true, completion: nil)
    }
    
    
}
