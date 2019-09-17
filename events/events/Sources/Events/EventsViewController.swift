//
//  EventsViewController.swift
//  events
//
//  Created by Mei Yu on 9/2/19.
//  Copyright © 2019 mei. All rights reserved.
//

import UIKit

/**
 * MVP version of events UI.
 */
class EventsViewController: UITableViewController {
    typealias ViewModel = NestedLoopEventsManager.EventsViewModelT

    /// Reusable Cell ID
    let cellId = "EventItem"

    /// Events app controller
    var eventsController = NestedLoopEventsManager()

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
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        if let event = viewModel.event(section: indexPath.section, row: indexPath.row) {
            let conflict: String = viewModel.hasConflict(event) ? "*conflict*" : ""
            cell.textLabel?.text = "\(event.title) \(conflict)"
            cell.detailTextLabel?.text = "\(event.start.longEventStr) to  \(event.end.longEventStr)"
        }
        return cell
    }
}
