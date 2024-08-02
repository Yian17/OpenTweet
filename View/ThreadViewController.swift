//
//  ThreadViewController.swift
//  OpenTweet
//
//  Created by Wu Yian on 2024-08-01.
//  Copyright © 2024 OpenTable, Inc. All rights reserved.
//

import Foundation
import UIKit

class ThreadViewController: UIViewController {
    
    // The array of tweets that make up the thread
    private let thread: [TweetModel]
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero)
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(TweetCell.self, forCellReuseIdentifier: TweetCell.Constant.reuseIdentifier)
        return tableView
    }()
    
    // MARK: Init
    init(thread: [TweetModel]) {
        self.thread = thread
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        buildUI()
        setUpConstraint()
    }
    
    // MARK: View Setup
    private func buildUI() {
        view.backgroundColor = .white
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
    }
    
    private func setUpConstraint() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
}

// MARK: - Table Delegate and DataSource
extension ThreadViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        thread.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TweetCell.Constant.reuseIdentifier, for: indexPath) as? TweetCell else {
            return UITableViewCell()
        }
        
        cell.configure(with: TweetViewModel(tweet: thread[indexPath.row]))
        return cell
    }
}
