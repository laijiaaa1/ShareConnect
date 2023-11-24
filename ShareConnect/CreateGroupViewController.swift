//
//  CreateGroupViewController.swift
//  ShareConnect
//
//  Created by laijiaaa1 on 2023/11/16.
//

import UIKit

class CreateGroupViewController: CreateRequestViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @objc override func requestSelectSegmentTapped() {
        if requestSelectSegment.selectedSegmentIndex == 0 {
            print("public")
        } else {
            print("private")
        }
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "requestCell", for: indexPath) as? RequestCell ?? RequestCell()
        cell.requestLabel.text = "name"
        cell.addBtn.setBackgroundImage(UIImage(systemName: "plus"), for: .normal)
        cell.addBtn.tintColor = .black
        let requestLabels = ["Name", "Description", "Sort", "Start Time", "End Time", "Require", "Number of people"]
        if indexPath.row < requestLabels.count {
            let info = requestLabels[indexPath.row]
            cell.requestLabel.text = info
        }
        if indexPath.row == 3 || indexPath.row == 4 {
            let timePicker = UIDatePicker()
            timePicker.datePickerMode = .dateAndTime
            timePicker.preferredDatePickerStyle = .wheels
            timePicker.addTarget(self, action: #selector(timePickerChanged), for: .valueChanged)
            if indexPath.row == 3 {
                cell.textField.inputView = timePicker
                cell.textField.tag = 1
            } else if indexPath.row == 4 {
                cell.textField.inputView = timePicker
                cell.textField.tag = 2
            }
        }
        if indexPath.row == 6 {
            let stepper = UIStepper()
            stepper.minimumValue = 0
            stepper.maximumValue = 100
            stepper.stepValue = 1
            stepper.addTarget(self, action: #selector(stepperValueChanged), for: .valueChanged)
            cell.textField.inputView = stepper
            cell.textField.tag = 3
            cell.textField.text = "0"
        } else {
            cell.textField.keyboardType = .default
        }
        cell.addBtn.tag = indexPath.row
        return cell
    }
    @objc func stepperValueChanged(sender: UIStepper) {
        if let cell = findCellWithTag(3) {
            cell.textField.text = "\(Int(sender.value))"
        }
    }
}
