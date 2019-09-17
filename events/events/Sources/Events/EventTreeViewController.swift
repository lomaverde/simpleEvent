//
//  EventTreeViewController.swift
//  events
//
//  Created by Mei Yu on 9/15/19.
//  Copyright © 2019 mei. All rights reserved.
//

import UIKit

class EventTreeEventCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var startLabel: UILabel!
    @IBOutlet weak var endLabel: UILabel!
    @IBOutlet weak var conflictCountLabel: UILabel!
    
    override func prepareForReuse() {
        nameLabel.text = nil
        startLabel.text = nil
        endLabel.text = nil
        conflictCountLabel.text = nil
    }
    
    func config<V>(with event: V.EventType, viewModel: V) where V: EventsViewModel {
        nameLabel.text = event.title
        startLabel.text = event.start.eventStr
        endLabel.text = event.end.eventStr
    
        let conflicts = viewModel.conflictForEvent(event)
        conflictCountLabel.text = "\(conflicts?.count ?? 0)"
    }
}

class EventTreeViewController: UITableViewController {
    typealias ViewModel = TreeEventsManager.EventsViewModelT

    /// Reusable Cell ID
    let cellId = "TreeEventCell"
    
    /// Events app controller
    var eventsController = TreeEventsManager()

    /// View Models
    var viewModel: ViewModel { return eventsController.eventsViewModel}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            try eventsController.load()
        } catch  {
            Log.error(error, "unable to load events")
        }        
    }

    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numOfDays
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numOfEvents(for: section)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.date(for: section)?.shortEventStr
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as? EventTreeEventCell {
            
            if let event = viewModel.event(section: indexPath.section, row: indexPath.row) {
                cell.config(with: event, viewModel: viewModel)
            }
            return cell
        }
    
        return UITableViewCell()
    }

}
