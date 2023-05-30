//
//  RedViewController.swift
//  DelegateMethod
//
//  Created by Greg Zenkov on 5/22/23.
//

import UIKit
import RxSwift
import RxCocoa
import RxFlow

class SomeNewViewController: UIViewController, Stepper {
    
    private let button = UIButton()
    private(set) var steps = PublishRelay<Step>()
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("dsdsds")
        setup()
        //bind()
        
    }
    
    func setup() {
        view.backgroundColor = .white
        
        button.backgroundColor = .white
        button.setTitle("Tap", for: .normal)
        button.setTitleColor(.red, for: .normal)
        view.addSubview(button)
        
        button.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalTo(50)
        }
        
    }
    
//    func bind() {
//        button.rx.tap
//            .subscribe { [weak self] _ in
//                self?.steps.accept(AppStep.main)
//            }
//            .disposed(by: disposeBag)
//    }
}
