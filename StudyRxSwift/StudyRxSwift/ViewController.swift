//
//  ViewController.swift
//  StudyRxSwift
//
//  Created by 홍경표 on 2021/04/01.
//

import UIKit
import RxSwift

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let observable = Observable.of("Hello", "RxSwift")
        observable.subscribe(onNext: { print("첫번째: \($0)") })
        observable.subscribe(onNext: { print("두번째: \($0)") })
    }


}

