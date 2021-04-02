//
//  CounterViewController.swift
//  StudyRxSwift
//
//  Created by 홍경표 on 2021/04/01.
//

import UIKit
import RxSwift
import RxCocoa

class CounterViewController: UIViewController {

    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label3: UILabel!
    
    var items: [Item] = [
        Item(), Item(), Item()
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _ = items[0].num
            .map {
                "\($0)"
            }
            .observe(on: MainScheduler.instance)
            .bind(to: label1.rx.text)
        _ = items[1].num
            .map {
                "\($0)"
            }
            .observe(on: MainScheduler.instance)
            .bind(to: label2.rx.text)
        _ = items[2].num
            .map {
                "\($0)"
            }
            .observe(on: MainScheduler.instance)
            .bind(to: label3.rx.text)
            
    }

    @IBAction func up1(_ sender: Any) {
        _ = items[0].num
            .observe(on: MainScheduler.instance)
            .map {
                $0 + 1
            }
            .take(1)
            .subscribe(onNext: {
                self.items[0].num.onNext($0)
            })
    }
    @IBAction func up2(_ sender: Any) {
        _ = items[1].num
            .observe(on: MainScheduler.instance)
            .map {
                $0 + 1
            }
            .take(1)
            .subscribe(onNext: {
                self.items[1].num.onNext($0)
            })
    }
    @IBAction func up3(_ sender: Any) {
        _ = items[2].num
            .observe(on: MainScheduler.instance)
            .map {
                $0 + 1
            }
            .take(1)
            .subscribe(onNext: {
                self.items[2].num.onNext($0)
            })
    }
    @IBAction func upAll(_ sender: Any) {
        up1(sender)
        up2(sender)
        up3(sender)
    }
    
}

struct Item {
    var num = BehaviorSubject<Int>(value: 0)
}
