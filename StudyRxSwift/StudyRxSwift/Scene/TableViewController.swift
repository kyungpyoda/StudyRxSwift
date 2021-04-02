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
    
    fileprivate var items = PublishSubject<[Item]>()
    
    var disposeBag = DisposeBag()

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchItems()
        items
            .bind(to: tableView.rx.items(cellIdentifier: "ItemCell")) { index, element, cell in
                cell.textLabel?.text = element.name
                cell.detailTextLabel?.text = "\(element.money)"
                DispatchQueue.global().async {
                    let url = URL(string: element.avatar)!
                    let data = try! Data(contentsOf: url)
                    let image = UIImage(data: data)
                    DispatchQueue.main.async {
                        cell.imageView?.image = image
                        cell.layoutSubviews()
                    }
                }
            }
            .disposed(by: disposeBag)
    }
    
    private func fetchItems() {
        _ = Observable<[Item]>.create { emitter in
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
        .take(1)
        .bind(to: items)
    }
}

fileprivate struct Item: Decodable {
    var id: Int
    var avatar: String
    var name: String
    var money: Int
}
