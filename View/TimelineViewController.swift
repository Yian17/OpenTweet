//
//  ViewController.swift
//  OpenTweet
//
//  Created by Olivier Larivain on 9/30/16.
//  Copyright © 2016 OpenTable, Inc. All rights reserved.
//

import UIKit

class TimelineViewController: UIViewController {
    
    // MARK: Constants
    struct Constant {
        static let viewControllerAccessibilityLabel = "Home Feed of Tweets"
        static let backButtonString = "Back"
        static let backButtonAccessibilityLabel = "Back to Home Feed"
    }
    
    let viewmodel = TimelineViewModel()
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero)
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(TweetCell.self, forCellReuseIdentifier: TweetCell.Constant.reuseIdentifier)
        return tableView
    }()
    
    // MARK: Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        fetchTimeline()
        buildUI()
        setUpConstraints()
        setupNavigationBackButton()
        
        // Set accessibility label for the view controller
        self.accessibilityLabel = Constant.viewControllerAccessibilityLabel
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Deselect the previously selected row when returning to this view
        if let path = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: path, animated: true)
        }
    }
    
    // MARK: View Setup
    private func buildUI() {
        view.backgroundColor = .white
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
    }
    
    private func setUpConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func fetchTimeline() {
        viewmodel.fetchTimeline()
    }
    
    private func setupNavigationBackButton() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: Constant.backButtonString, style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.accessibilityLabel = Constant.backButtonAccessibilityLabel
    }

}

// MARK: - Table Delegate and DataSource
extension TimelineViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewmodel.getNumberOfRowsInSection()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TweetCell.Constant.reuseIdentifier, for: indexPath) as? TweetCell else {
            return UITableViewCell()
        }
        
        let tweetViewModel = TweetViewModel(tweet: viewmodel.tweet(at: indexPath.row), isInTimeline: true)
        
        cell.configure(with: tweetViewModel)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentTweet = viewmodel.tweet(at: indexPath.row)
        let thread = viewmodel.thread(for: currentTweet)
        
        // pushing a ThreadViewController for the selected tweet
        let threadViewController = ThreadViewController(thread: thread)
        navigationController?.pushViewController(threadViewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? TweetCell {
            cell.setHighlighted(true, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? TweetCell {
            cell.setHighlighted(false, animated: true)
        }
    }
}
