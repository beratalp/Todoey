//
//  ViewController.swift
//  Todoey
//
//  Created by Alp Erbil on 30.08.2019.
//  Copyright © 2019 Alp Erbil. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController {
    
    var itemArray: Results<Item>?
    let realm = try! Realm()
    
    var selectedCategory: Category? {
        didSet{
            loadItems()
        }
    }

    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad(){
        super.viewDidLoad()
        //searchBar.delegate = self
        
        loadItems()
        tableView.separatorStyle = .none

    }
        
    
    override func viewWillAppear(_ animated: Bool) {
        if let colourHex = selectedCategory?.color {
            title = selectedCategory!.name
            guard let navBar = navigationController?.navigationBar else {
                fatalError("Navigation controller is nil.")
            }
            navBar.barTintColor = UIColor(hexString: colourHex)
            navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: ContrastColorOf(UIColor(hexString: colourHex)!, returnFlat: true)]
            navBar.tintColor = ContrastColorOf(UIColor(hexString: colourHex)!, returnFlat: true)
            searchBar.barTintColor = UIColor(hexString: colourHex)
            
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        guard let originalColor = UIColor(hexString: "1D9BF6") else {
            fatalError()
        }
        navigationController?.navigationBar.barTintColor = originalColor
        navigationController?.navigationBar.tintColor = FlatWhite()
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: FlatWhite()]
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let item = itemArray?[indexPath.row] {
            cell.textLabel?.text = item.title
            if let color = UIColor(hexString: selectedCategory!.color)?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(itemArray!.count)) {
                cell.backgroundColor = color
                cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
            }

            
            cell.accessoryType = item.isDone ? .checkmark : .none
        } else {
            cell.textLabel?.text = "No Items Added"
        }
        

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        if let item = itemArray?[indexPath.row] {
            do {
                try realm.write {
                    item.isDone = !item.isDone
                }
            } catch {
                print(error)
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.reloadData()
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem){
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default){(action) in
            if let currentCategory = self.selectedCategory {
                do {
                    try self.realm.write {
                        let newItem = Item()
                        newItem.title = textField.text!
                        newItem.dateCreated = Date()
                        currentCategory.items.append(newItem)
                    }
                } catch {
                    print(error)
                }
            }
            self.tableView.reloadData()
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
        
    func loadItems(){
        itemArray = selectedCategory?.items.sorted(byKeyPath: "dateCreated", ascending: true)
        tableView.reloadData()
    }
    
    override func updateModel(at indexPath: IndexPath){
        if let item = itemArray?[indexPath.row] {
            try! realm.write {
                realm.delete(item)
            }
        }
    }
}

extension TodoListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        itemArray = itemArray?.filter("title CONTAINS [cd] %@", searchBar.text!).sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
