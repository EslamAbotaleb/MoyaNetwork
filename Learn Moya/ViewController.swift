//
//  ViewController.swift
//  Learn Moya
//
//  Created by Islam Abotaleb on 6/12/20.
//  Copyright © 2020 Islam Abotaleb. All rights reserved.
//

import UIKit
import Moya

class ViewController: UITableViewController {
    
    var users = [User]()
    // need provider moya
    let userProvider = MoyaProvider<UserService>()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        userProvider.request(.readUsers) { (result) in
            switch result {
            case .success(let response):
                //                let json = try! JSONSerialization.jsonObject(with: response.data, options: [])
                //                print(json)
                let users = try! JSONDecoder().decode([User].self, from: response.data)
                self.users = users
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            case .failure(let error):
                print(error)
                break
                
            }
        }
    }
    
    @IBAction func didTapAdd() {
        let kilo = User(id: 55, name: "Kilo Loco")
        userProvider.request(.createUser(name: kilo.name)) { (result) in
            switch result {
            case .success(let response):
                let newUser = try! JSONDecoder().decode(User.self, from: response.data)
                self.users.insert(newUser, at: 0)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
        print(kilo)
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let user = users[indexPath.row]
        cell.textLabel?.text = user.name
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user  = users[indexPath.row]
        userProvider.request(.updateUser(id: user.id, name: "[Modified]" + user.name)) { (result) in
            switch result {
            case .success(let response):
                let modifiedUser = try! JSONDecoder().decode(User.self, from: response.data)
                self.users[indexPath.row] = modifiedUser
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
        print(user)
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else {
            return
        }
        let user = users[indexPath.row]
        userProvider.request(.deleteUser(id: user.id)) { (result) in
            switch result {
            case .success(let response):
                self.users.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
            case.failure(let error):
                print(error)
            }
        }
        print(user)
    }
}

