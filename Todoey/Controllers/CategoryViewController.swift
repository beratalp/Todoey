//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Alp Erbil on 5.09.2019.
//  Copyright © 2019 Alp Erbil. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {

    
    
    let realm = try! Realm()
    
    var categoryArray: Results<Category>?

    override func viewDidLoad(){
        super.viewDidLoad()
        
        loadCategories()
        tableView.separatorStyle = .none
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.textLabel?.text = categoryArray?[indexPath.row].name ?? "No categories are added."
        cell.backgroundColor = UIColor(hexString: (categoryArray?[indexPath.row].color) ?? UIColor.white.hexValue())
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categoryArray?[indexPath.row]
        }
    }
    
    func save(category: Category){
        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            print(error)
        }
        tableView.reloadData()
    }
    
    func loadCategories(){
        categoryArray = realm.objects(Category.self)
        tableView.reloadData()
    }
    
    override func updateModel(at indexPath: IndexPath) {
        if let categoryForDeletion = self.categoryArray?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(categoryForDeletion)
                }
            } catch {
                print(error)
            }
        }
    }

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem){
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add", style: .default){(action) in
            let category = Category()
            category.name = textField.text!
            category.color = UIColor.randomFlat().hexValue()
            self.save(category: category)
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new category"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }

}
