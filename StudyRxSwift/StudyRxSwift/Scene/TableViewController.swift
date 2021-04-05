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
    
    private struct Item: Decodable {
        var id: Int
        var avatar: String
        var name: String
        var money: Int
    }
    
    private let mockAPI = "https://my.api.mockaroo.com/piomock.json?key=5db4e260"
    
    private var items = PublishSubject<[Item]>()
    
    var disposeBag = DisposeBag()

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchItems()
        items
            .bind(to: tableView.rx.items(cellIdentifier: "ItemCell")) { index, element, cell in
                cell.textLabel?.text = element.name
                cell.detailTextLabel?.text = "\(element.money)"
                _ = self.loadImage(from: element.avatar)
                    .observe(on: MainScheduler.instance)
                    .subscribe(
                        onNext: { image in
                            cell.imageView?.image = image
                            cell.layoutSubviews()
                            
                        }
                    )
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
    
    private func loadImage(from urlStr: String) -> Observable<UIImage?> {
        return Observable.create { emitter in
            DispatchQueue.global().async {
                if let url = URL(string: urlStr),
                   let data = try? Data(contentsOf: url) {
                    emitter.onNext(UIImage(data: data))
                } else {
                    emitter.onNext(nil)
                }
                emitter.onCompleted()
            }
            
            return Disposables.create()
        }
    }
}
