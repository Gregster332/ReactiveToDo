// 
//  ToDoViewController.swift
//  DelegateMethod
//
//  Created by Greg Zenkov on 5/18/23.
//

import UIKit
import RxSwift
import RxCocoa

protocol ToDoViewControllerProtocol: AnyObject {
}

final class ToDoViewController: UIViewController, ToDoViewControllerProtocol {
    
    // MARK: - Properties
    // swiftlint:disable implicitly_unwrapped_optional
    var presenter: ToDoPresenterProtocol!
    // swiftlint:enable implicitly_unwrapped_optional
    private let disposedBag = DisposeBag()
    
    // MARK: - Views
    private let titleLabel = UILabel()
    private let toDoTitleTF = UITextField()
    private let descriptionLabel = UILabel()
    private let descriptionTF = UITextView()
    private let datePicker = UIDatePicker()
    private let saveButton = UIButton(type: .custom)
    private let flaggedLabel = UILabel()
    private let flaggedSwitch = UISwitch()
    private let flaggedStackView = UIStackView()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
        bind()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    // MARK: - Methods

}

// MARK: - Private Methods
private extension ToDoViewController {
    
    func bind() {
//        toDoTitleTF.rx.text
//            .orEmpty
//            .bind(to: presenter.titleText)
//            .disposed(by: disposedBag)
//
//        presenter.titleText
//            .asObserver()
//            .bind(to: toDoTitleTF.rx.text)
//            .disposed(by: disposedBag)
        
        (toDoTitleTF.rx.text.orEmpty <-> presenter.titleText)
            .disposed(by: disposedBag)
        
//        descriptionTF.rx.text
//            .orEmpty
//            .bind(to: presenter.descriptionText)
//            .disposed(by: disposedBag)
        
        (descriptionTF.rx.text.orEmpty <-> presenter.descriptionText)
            .disposed(by: disposedBag)
        (datePicker.rx.date <-> presenter.selectedEndDate)
            .disposed(by: disposedBag)
        
        (flaggedSwitch.rx.isOn <-> presenter.flagged)
            .disposed(by: disposedBag)
//        datePicker.rx.date
//            .bind(to: presenter.selectedEndDate)
//            .disposed(by: disposedBag)
        
        presenter.toDoHandler
            .subscribe(onNext: { [weak self] value in
                if let value = value {
                    self?.saveButton.backgroundColor =  UIColor(named: "blue")
                    self?.saveButton.isEnabled = true
                    self?.flaggedSwitch.isOn = value.flagged
                } else {
                    self?.saveButton.backgroundColor = UIColor.systemGray6
                    self?.saveButton.isEnabled = false
                    self?.flaggedSwitch.isOn = false
                }
            })
            .disposed(by: disposedBag)
        
        saveButton.rx.tap
            .asObservable()
            .subscribe(onNext: { [weak self] todo in
                self?.presenter.saveData()
            })
            .disposed(by: disposedBag)
        
        //presenter.applyInitialDataIfExcided()
    }
    
    func setupView() {
        
        view.do {
            $0.backgroundColor = .white
        }
        
        titleLabel.do {
            $0.textColor = UIColor(named: "textGray")
            $0.font = .rounded(ofSize: 18, weight: .semibold)
            $0.textAlignment = .left
            $0.text = "New reminder"
        }
        
        toDoTitleTF.do {
            $0.backgroundColor = UIColor(named: "textGray2")
            $0.font = UIFont.systemFont(ofSize: 15, weight: .regular)
            $0.placeholder = "Title..."
            $0.layer.cornerRadius = 14
            $0.leftViewMode = .always
            let view = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 15))
            $0.leftView = view
        }
        
        descriptionLabel.do {
            $0.textColor = UIColor(named: "textGray")
            $0.font = .rounded(ofSize: 12, weight: .regular)
            $0.textAlignment = .left
            $0.text = "Description"
        }
        
        descriptionTF.do {
            $0.backgroundColor = UIColor(named: "textGray2")
            $0.font = UIFont.systemFont(ofSize: 15, weight: .regular)
            $0.layer.cornerRadius = 14
            $0.showsVerticalScrollIndicator = false
            $0.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        }
        
        datePicker.do {
            $0.preferredDatePickerStyle = .compact
        }
        
        saveButton.do {
            $0.setTitle("Save", for: .normal)
            $0.titleLabel?.font = .rounded(ofSize: 16, weight: .medium)
            $0.setTitleColor(.black, for: .normal)
            $0.setTitleColor(.black, for: .disabled)
            $0.layer.cornerRadius = 14
        }
        
        flaggedLabel.do {
            $0.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            $0.textAlignment = .left
            $0.textColor = .black
            $0.text = "Flagged"
        }
        
        flaggedSwitch.do {
            $0.isOn = false
        }
        
        flaggedStackView.do {
            $0.axis = .horizontal
            $0.spacing = 20
            $0.distribution = .fill
            $0.alignment = .fill
        }
    }
    
    func setupConstraints() {
        view.addSubview(titleLabel)
        view.addSubview(toDoTitleTF)
        view.addSubview(descriptionLabel)
        view.addSubview(descriptionTF)
        view.addSubview(datePicker)
        view.addSubview(saveButton)
        flaggedStackView.addArrangedSubview(flaggedLabel)
        flaggedStackView.addArrangedSubview(flaggedSwitch)
        view.addSubview(flaggedStackView)
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            $0.trailing.leading.equalToSuperview().inset(32)
        }
        
        toDoTitleTF.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.trailing.leading.equalToSuperview().inset(16)
            $0.height.equalTo(46)
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(toDoTitleTF.snp.bottom).offset(16)
            $0.trailing.leading.equalToSuperview().inset(32)
        }
        
        descriptionTF.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(8)
            $0.trailing.leading.equalToSuperview().inset(16)
            $0.height.equalTo(120)
        }
        
        datePicker.snp.makeConstraints {
            $0.top.equalTo(descriptionTF.snp.bottom).offset(8)
            $0.horizontalEdges.equalToSuperview().inset(16)
        }
        
        flaggedStackView.snp.makeConstraints {
            $0.top.equalTo(datePicker.snp.bottom).offset(8)
            $0.horizontalEdges.equalToSuperview().inset(16)
        }
        
        saveButton.snp.makeConstraints {
            $0.top.equalTo(flaggedStackView.snp.bottom).offset(8)
            $0.trailing.leading.equalToSuperview().inset(16)
            $0.height.equalTo(46)
        }
    }
}

extension UIFont {
    class func rounded(ofSize size: CGFloat, weight: UIFont.Weight) -> UIFont {
        let systemFont = UIFont.systemFont(ofSize: size, weight: weight)
        let font: UIFont
        
        if let descriptor = systemFont.fontDescriptor.withDesign(.rounded) {
            font = UIFont(descriptor: descriptor, size: size)
        } else {
            font = systemFont
        }
        return font
    }
}

infix operator <->
func <-> <T>(property: ControlProperty<T>, variable: BehaviorSubject<T>) -> Disposable {
    let bindToUIDisposable = variable.asObservable()
        .bind(to: property)
    let bindToVariable = property
        .subscribe(onNext: { n in
            variable.onNext(n)
        }, onCompleted:  {
            bindToUIDisposable.dispose()
        })

    return Disposables.create(bindToUIDisposable, bindToVariable)
}
