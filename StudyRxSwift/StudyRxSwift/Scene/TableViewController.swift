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
    
    private var items: [Item] = []
    private let filterItems = PublishSubject<[Item]>()
    
    var disposeBag = DisposeBag()

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }
    
    private func setUp() {
        setUpSearchBar()
        binding()
    }
    
    private func setUpSearchBar() {
        searchBar.rx.text
            .orEmpty
            .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [unowned self] input in
                let filtered = items.filter {
                    $0.name.hasPrefix(input)
                }
                filterItems.onNext(filtered)
            })
            .disposed(by: disposeBag)
    }
    
    private func binding() {
        fetchItems()
            .take(1)
            .subscribe(onNext: { [weak self] in
                self?.items = $0
                self?.filterItems.onNext($0)
            })
            .disposed(by: disposeBag)
        
        filterItems
            .bind(to: tableView.rx.items(cellIdentifier: "ItemCell")) { [unowned self] index, element, cell in
                
                cell.textLabel?.text = element.name
                cell.detailTextLabel?.text = "\(element.money)"
                
                self.loadImage(from: element.avatar)
                    .observe(on: MainScheduler.instance)
                    .subscribe(
                        onNext: { image in
                            cell.imageView?.image = image
                            cell.layoutSubviews()
                            
                        }
                    )
                    .disposed(by: self.disposeBag)
            }
            .disposed(by: disposeBag)
    }
    
    private func fetchItems() -> Observable<[Item]> {
        return Observable<[Item]>.create { emitter in
            weak var task: URLSessionDataTask?
            
            DispatchQueue.global().async { [weak self] in
                guard let urlStr = self?.mockAPI,
                      let url = URL(string: urlStr) else { return }
                task = URLSession.shared.dataTask(with: url) { (data, _, err) in
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
                task?.resume()
            }
            
            return Disposables.create() {
                task?.cancel()
            }
        }
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
