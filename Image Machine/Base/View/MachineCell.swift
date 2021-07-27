//
//  MachineCell.swift
//  Image Machine
//
//  Created by odikk on 22/07/21.
//

import UIKit

class MachineCell: UITableViewCell {

    @IBOutlet weak var machineName: UILabel!
    @IBOutlet weak var machineType: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
