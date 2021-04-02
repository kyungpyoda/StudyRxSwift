//
//  TableViewController.swift
//  StudyRxSwift
//
//  Created by 홍경표 on 2021/04/02.
//

import UIKit
import RxSwift
import RxCocoa

class TableViewController: UIViewController {
    
    private let mockAPI = "https://my.api.mockaroo.com/piomock.json?key=5db4e260"
    
    fileprivate var items: [Item] = []
    var disposeBag = DisposeBag()

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        fetchItems()
    }
    
    private func fetchItems() {
        Observable<[Item]>.create { emitter in
            let url = URL(string: self.mockAPI)!
            let task = URLSession.shared.dataTask(with: url) { (data, _, err) in
                guard err == nil else {
                    emitter.onError(err!)
                    return
                }
                if let data = data,
                   let decoded = try? JSONDecoder().decode([Item].self, from: data) {
                    emitter.onNext(decoded)
                }
                emitter.onCompleted()
            }
            task.resume()
            return Disposables.create() {
                task.cancel()
            }
        }
        .observe(on: MainScheduler.instance)
        .subscribe(onNext: {
            print($0)
            self.items = $0
            self.tableView.reloadData()
        })
        .disposed(by: disposeBag)
    }
}

extension TableViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "ItemCell")
        let item = items[indexPath.row]
        _ = Observable<UIImage?>.create { emitter in
            DispatchQueue.global().async {
                let url = URL(string: item.avatar)!
                let data = try! Data(contentsOf: url)
                let image = UIImage(data: data)
                emitter.onNext(image)
            }
            return Disposables.create()
        }
        .observe(on: MainScheduler.instance)
        .subscribe(onNext: {
            cell.imageView?.image = $0
            cell.layoutSubviews()
        })
        cell.textLabel?.text = item.name
        cell.detailTextLabel?.text = "\(item.money)"
        return cell
    }
    
    
}

fileprivate struct Item: Decodable {
    var id: Int
    var avatar: String
    var name: String
    var money: Int
}
