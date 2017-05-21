//
//  SideBarTableViewController.swift
//  Skate Demo
//
//  Created by Callum Carmichael (i7726422) on 17/03/2017.
//  Copyright © 2017 Callum Carmichael (i7726422). All rights reserved.
//

import UIKit


protocol SideBarTableViewControllerDelegate {
    
    func sideBarControlDidSelectRow(_ indexPath: IndexPath)
    
}

class SideBarTableViewController: UITableViewController {

    var delegate: SideBarTableViewControllerDelegate?
    var tableData: Array<String> = []
    
    

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        return tableData.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell:UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: "Cell")

        if cell == nil{
            
            cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
            cell!.backgroundColor = UIColor.clear
            cell!.textLabel?.textColor = UIColor.darkText
            
            let selectedView:UIView = UIView(frame: CGRect(x: 0, y: 0, width: cell!.frame.size.width, height: cell!.frame.size.height))
            
            selectedView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
            
            cell!.selectedBackgroundView = selectedView
            
        }
        
        cell!.textLabel?.text = tableData[indexPath.row]
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.sideBarControlDidSelectRow(indexPath)
        
        
        
    }


}
