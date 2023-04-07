//
//  HomeViewController.swift
//  TestQiushi
//
//  Created by MJ Lee on 2019/8/13.
//  Copyright © 2019 MJ Lee. All rights reserved.
//

class HomeViewController: UIViewController {
    lazy var tableView = UITableView()
    lazy var items = [Item]()
    static let ItemCellId = "item"
    var page = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.frame = view.bounds
        tableView.delegate = self
        tableView.dataSource = self
//        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Self.ItemCellId)
        view.addSubview(tableView)
        
        let header = MJRefreshNormalHeader(refreshingBlock: self.loadNewData)
        header?.beginRefreshing()
        tableView.mj_header = header
        tableView.mj_footer = MJRefreshAutoNormalFooter(refreshingBlock: self.loadMoreData)
    }
    
    func loadNewData() {
        request(API.imgrank, parameters: ["page": 1]).responseJSON {
            [weak self] response in
            guard let dict = response.result.value else { return }
            let jsons = JSON(dict)["items"].arrayObject
            guard let models = modelArray(from: jsons, Item.self) else { return }
            
            self?.items.removeAll()
            self?.items.append(contentsOf: models)
            
            self?.tableView.reloadData()
            self?.tableView.mj_header.endRefreshing()
            
            self?.page = 1
        }
    }
    
    func loadMoreData() {
        request(API.imgrank, parameters: ["page": page + 1]).responseJSON {
            [weak self] response in
            guard let dict = response.result.value else { return }
            let jsons = JSON(dict)["items"].arrayObject
            guard let models = jsons?.kk.modelArray(Item.self) else { return }
            
            self?.items.append(contentsOf: models)
            
            self?.tableView.reloadData()
            self?.tableView.mj_footer.endRefreshing()
            
            self?.page += 1
        }
    }
}

extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableView.mj_footer.isHidden = items.count == 0
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: Self.ItemCellId, for: indexPath)
        var tmp = tableView.dequeueReusableCell(withIdentifier: Self.ItemCellId)
        if tmp == nil {
            tmp = UITableViewCell(style: .subtitle, reuseIdentifier: Self.ItemCellId)
        }
        let cell = tmp!
        
        let item = items[indexPath.row]
        cell.textLabel?.text = item.user.name
        let url = item.user.thumb.replacingOccurrences(of: ".webp", with: ".png")
        cell.imageView?.kf.setImage(with: URL(string: url))
        
        return cell
    }
}

extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}
