//
//  ViewController.swift
//  DynamicSections
//
//  Created by Samuel Ryan Goodwin on 10/17/16.
//  Copyright © 2016 Roundwall Software. All rights reserved.
//

import UIKit

protocol DynamicSection {
    var count: Int { get }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    var counter: Counter { get }
    var usesCounter: Bool { get }
}

struct RandomNumberSection: DynamicSection {
    var count: Int
    let counter: Counter
    var usesCounter: Bool
    
    init(counter: Counter) {
        self.count = 1
        self.counter = counter
        self.usesCounter = true
    }
    
    var number: Int {
        return Int(arc4random())
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "This is a cell"
        cell.detailTextLabel?.text = "The number is \(counter.count)"
        return cell
    }
}

struct IncreasingSection: DynamicSection {
    var count: Int {
        return counter.count
    }
    var counter: Counter
    var usesCounter: Bool = true
    
    init(counter: Counter) {
        self.counter = counter
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "This is a cell"
        cell.detailTextLabel?.text = "This is cell \(indexPath.row)"
        return cell
    }
}

class ExpandCollapseSection: DynamicSection {
    var count: Int {
        if counter.count % 2 == 0 {
            return 0
        } else {
            return 5
        }
    }
    var counter: Counter
    var usesCounter: Bool = true
    
    init(counter: Counter) {
        self.counter = counter
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "This is a cell"
        cell.detailTextLabel?.text = "This is cell \(indexPath.row)"
        return cell
    }
}

struct StaticSection: DynamicSection {
    var counter: Counter
    var usesCounter: Bool = false
    
    init(counter: Counter) {
        self.counter = counter
    }
    
    var count = 1
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "This is a cell"
        cell.detailTextLabel?.text = "This is a static section"
        return cell
    }
    
    func reload(completion: @escaping () -> ()) {}
}

class Counter {
    var count = 0
}

class DataSource {
    var sections: [DynamicSection]
    
    var reload: ((UITableView) -> Void)? = nil
    
    init(sections: [DynamicSection]) {
        self.sections = sections
    }
    
    var count: Int {
        return sections.count
    }
    
    subscript(_ index: Int) -> DynamicSection {
        return sections[index]
    }
    
    func update(_ tableView: UITableView) {
        tableView.beginUpdates()
        
        for(index, section) in sections.enumerated() {
            if section.usesCounter {
                tableView.reloadSections(IndexSet(integer: index), with: .automatic)
            }
        }
        
        tableView.endUpdates()
    }
}

class ViewController: UITableViewController {
    let counter = Counter()
    var source: DataSource!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 80.0
        
        source = DataSource(sections: [
            RandomNumberSection(counter: counter),
            StaticSection(counter: counter),
            IncreasingSection(counter: counter)
        ])
    }
    
    @IBAction func reload(_ sender: Any) {
        counter.count+=1
        source.update(tableView)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return source.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return source[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return source[indexPath.section].tableView(tableView, cellForRowAt: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Section \(section)"
    }
}

