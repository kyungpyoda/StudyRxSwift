//
//  ViewController.swift
//  RxSwift+MVVM
//
//  Created by iamchiwon on 05/08/2019.
//  Copyright © 2019 iamchiwon. All rights reserved.
//

import RxSwift
import SwiftyJSON
import UIKit

let MEMBER_LIST_URL = "https://my.api.mockaroo.com/members_with_avatar.json?key=44ce18f0"

class ViewController: UIViewController {
    @IBOutlet var timerLabel: UILabel!
    @IBOutlet var editView: UITextView!
    
    var disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.timerLabel.text = "\(Date().timeIntervalSince1970)"
        }
    }

    private func setVisibleWithAnimation(_ v: UIView?, _ s: Bool) {
        guard let v = v else { return }
        UIView.animate(withDuration: 0.3, animations: { [weak v] in
            v?.isHidden = !s
        }, completion: { [weak self] _ in
            self?.view.layoutIfNeeded()
        })
    }
    
    private func downloadJson(_ url: String) -> Observable<String> {
        return Observable.create() { emitter in
            let url = URL(string: url)!
            let task = URLSession.shared.dataTask(with: url) { (data, _, err) in
                guard err == nil else {
                    emitter.onError(err!)
                    return
                }
                if let data = data, let json = String(data: data, encoding: .utf8) {
                    emitter.onNext(json)
                }
                emitter.onCompleted()
            }
            task.resume()
            return Disposables.create() {
                task.cancel()
            }
        }
    }

    // MARK: SYNC

    @IBOutlet var activityIndicator: UIActivityIndicatorView!

    @IBAction func onLoad() {
        editView.text = ""
        self.setVisibleWithAnimation(self.activityIndicator, true)
        
//        Observable<String>.create() { emitter in
//            let url = URL(string: MEMBER_LIST_URL)!
//            let data = try! Data(contentsOf: url)
//            let str = String(data: data, encoding: .utf8)!
//            emitter.onNext(str)
//            emitter.onCompleted()
//            return Disposables.create()
//        }
//        .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .default))
//        .observeOn(MainScheduler.instance)
//        .subscribe(onNext: { t in
//            self.editView.text = t
//            self.setVisibleWithAnimation(self.activityIndicator, false)
//        })
        
        let jsonObservable = downloadJson(MEMBER_LIST_URL)
        let helloObservable = Observable.just("Hello World")
        _ = Observable.zip(jsonObservable, helloObservable) { $1 + "\n" + $0 }
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { json in
                self.editView.text = json
                self.setVisibleWithAnimation(self.activityIndicator, false)
            })
            .disposed(by: disposeBag)
        
    }
}
