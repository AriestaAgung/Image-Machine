//
//  ViewController.swift
//  Image Machine
//
//  Created by odikk on 22/07/21.
//

import UIKit
import iOSDropDown

class MachineListVC: UIViewController {
    
    
    @IBOutlet weak var dropdown: DropDown!
    @IBOutlet weak var machineTableView: UITableView!
    let transparentBG = UIView()
    let sortTableView = UITableView()
    let sortArray = ["Time Added", "Machine Name", "Machine Type"]
    var machines: [MachineEntity]?
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initComponent()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        machineTableView.reloadData()
    }
    
    private func initComponent(){
        dropdown.backgroundColor = Utils.blueBG
        dropdown.textColor = .white
        dropdown.delegate = self
        dropdown.optionArray = sortArray
        dropdown.selectedIndex = 0
        dropdown.text = sortArray.first
        dropdown.didSelect(){ (selectedText , index ,id) in
            self.sortMachines(type: index)
        }
        machines = DBUtils().getAllMachine()
        machineTableView.delegate = self
        machineTableView.dataSource = self
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(addTapped))
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        if #available(iOS 10.0, *) {
            self.machineTableView.refreshControl = refreshControl
        } else {
            self.machineTableView.addSubview(refreshControl)
        }
    }
    
    func sortMachines(type: Int){
        switch type {
        case 0:
            self.machines = DBUtils().getAllMachine()
            machineTableView.reloadData()
        case 1:
            self.machines = machines?.sorted(by: {($0.machineName ?? "") < ($1.machineName ?? "")})
            machineTableView.reloadData()
        case 2:
            self.machines = machines?.sorted(by: {($0.machineType ?? "") < ($1.machineType ?? "")})
            machineTableView.reloadData()
        default:
            self.machines = DBUtils().getAllMachine()
            machineTableView.reloadData()
        }
    }
    
    @objc func refreshData(_ refreshControl: UIRefreshControl) {
        self.machines?.removeAll()
        self.machines = DBUtils().getAllMachine()
        self.dropdown.selectedIndex = 0
        self.dropdown.text = sortArray.first
        self.machineTableView.reloadData()
        self.refreshControl.endRefreshing()
    }
    
    
    @objc private func addTapped(){
        performSegue(withIdentifier: "addSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailMachineSegue" {
//            if let navController = segue.destination as? UINavigationController{
//                if let vc = navController.topViewController as? MachineDetailVC{
            let vc = segue.destination as? MachineDetailVC
            let row = machineTableView.indexPathForSelectedRow?.row
            vc?.machine = machines?[row!]
//                }
                
//            }
        }
    }
    
}

extension MachineListVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let totalCell = machines?.count else {return 0}
        if totalCell == 0 {
            machineTableView.separatorStyle = .none
        } else {
            machineTableView.separatorStyle = .singleLine
        }
        return totalCell
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "machine-cell") as! MachineCell
        
        cell.machineName.text = machines?[indexPath.row].machineName
        cell.machineType.text = machines?[indexPath.row].machineType
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "detailMachineSegue", sender: self)
        machineTableView.deselectRow(at: indexPath, animated: true)
    }
    
    @IBAction func unwindToHome(_ unwindSegue: UIStoryboardSegue) {
        let sourceViewController = unwindSegue.source
        // Use data from the view controller which initiated the unwind segue
    }
}
extension MachineListVC: UITextFieldDelegate{
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return false
    }
}
