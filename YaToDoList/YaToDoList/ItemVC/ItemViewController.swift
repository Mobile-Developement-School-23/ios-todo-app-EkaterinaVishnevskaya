//
//  ItemViewController.swift
//  YaToDoList
//
//  Created by Екатерина Вишневская on 14.06.2023.
//

import UIKit

class ItemViewController: UIViewController {
    
    private var scrollVeiwBottomConstraint: NSLayoutConstraint?
    private var fileCache = FileCache()
    
    private var todo: TodoItem = TodoItem(text: "", importance: .normal, done: false)
    
    // MARK: - UIConstants
    private enum Consts {
        static let cornerRadius: CGFloat = 16
        
        static let padding: CGFloat = 16
        
        static let textViewHeight: CGFloat = 120
        
        static let segmentedControlWidth: CGFloat = 150
        static let segmentedControlHeight: CGFloat = 36
        
        static let deleteButtonHeight: CGFloat = 56
    }
    
    // MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Дело"
        fileCache.loadFromCSV(filename: "ToDoList")
        if fileCache.todoList.count > 0 {
            for i in fileCache.todoList.keys {
                todo = fileCache.todoList[i] ?? TodoItem(text: "", importance: .normal, done: false)
            }
        }
        view.backgroundColor = .secondarySystemBackground
        
        if todo.text != "" {
            textView.text = todo.text
        } else {
            textView.textColor = .tertiaryLabel
            textView.text = "Что надо сделать?"
            deleteButton.isEnabled = false
        }
        
        textView.delegate = self
        datePicker.isHidden = true
        setupNavigationBar()
        setupSubviews()
        subscribeToKeyboard()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tapGesture.cancelsTouchesInView = false
        scrollView.addGestureRecognizer(tapGesture)
    }
    
    deinit {
        unsubdcribeToKeyboard()
    }
    
    // MARK: - View Properties
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    private let textView: UITextView = {
        let textView = UITextView()
        textView.layer.cornerRadius = Consts.cornerRadius
        textView.font = Fonts.body
        
        textView.textAlignment = .left
        textView.isEditable = true
        textView.isScrollEnabled = false
        return textView
    }()
    
    private let addNewTodoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = Consts.padding
        stackView.distribution = .fill
        return stackView
    }()
    
    private let importanceLabel: UILabel = {
        let label = UILabel()
        label.text = "Важность"
        label.font = Fonts.body
        return label
    }()
    
    private lazy var importancePickerView: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: ["↓", "нет", "‼"])
        switch todo.importance {
        case .unimportant:
            segmentedControl.selectedSegmentIndex = 0
        case .normal:
            segmentedControl.selectedSegmentIndex = 1
        case .important:
            segmentedControl.selectedSegmentIndex = 2
        }
        
        segmentedControl.addTarget(self, action: #selector(priorityValueChanged), for: .valueChanged)
        return segmentedControl
    }()
    
    private let priorityStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.layoutMargins = UIEdgeInsets(top: Consts.padding,
                                               left: Consts.padding,
                                               bottom: Consts.padding,
                                               right: Consts.padding)
        stackView.isLayoutMarginsRelativeArrangement = true
        return stackView
    }()
    
    private let deadlineLabel: UILabel = {
        let label = UILabel()
        label.text = "Cделать до"
        label.font = Fonts.body
        return label
    }()
    
    private lazy var deadlineDateLabel: UILabel = {
        let label = UILabel()
        label.isHidden = todo.deadline == nil
        label.text = "\((todo.deadline ?? Date()).formatted(.dateTime.day().month().year(.defaultDigits)))"
        label.font = Fonts.footnote
        label.textColor = .blue
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(deadlineDateLabelTapped))
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(tapGesture)
        
        return label
    }()
    
    private let deadlineLabelsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fill
        return stackView
    }()
    
    private lazy var deadlineSwitchView: UISwitch = {
        let deadlineSwitch = UISwitch()
        deadlineSwitch.addTarget(self, action: #selector(UpdateDate), for: .valueChanged)
        deadlineSwitch.isOn = todo.deadline != nil
        return deadlineSwitch
    }()
    
    private let deadlineStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.layoutMargins = UIEdgeInsets(top: Consts.padding,
                                               left: Consts.padding,
                                               bottom: Consts.padding,
                                               right: Consts.padding)
        stackView.isLayoutMarginsRelativeArrangement = true
        return stackView
    }()
    
    private let settingsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.distribution = .fill
        stackView.backgroundColor = .systemBackground
        stackView.layer.cornerRadius = Consts.cornerRadius
        return stackView
    }()
    
    private let dividerView: UIView = {
        let view = UIView()
        view.backgroundColor = .separator
        view.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        return view
    }()
    
    private lazy var secondDividerView: UIView = {
        let view = UIView()
        view.isHidden = true
        view.backgroundColor = .separator
        view.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        return view
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.date = .now + 60*60*24
        datePicker.minimumDate = .now
        datePicker.preferredDatePickerStyle = .inline
        datePicker.layoutMargins = UIEdgeInsets(top: Consts.padding,
                                                left: Consts.padding,
                                                bottom: Consts.padding,
                                                right: Consts.padding)
        datePicker.addTarget(self, action: #selector(deadlineDateChanged), for: .valueChanged)
        return datePicker
    }()
    
    private lazy var deleteButton: UIButton = {
        let button = UIButton()
        button.setTitle("Удалить", for: .normal)
        button.setTitleColor(.red, for: .normal)
        button.setTitleColor(.tertiaryLabel, for: .disabled)
        button.backgroundColor = .systemBackground
        button.layer.cornerRadius = Consts.cornerRadius
        button.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Setup Functions
    private func setupNavigationBar() {
        let saveButton = UIBarButtonItem(title: "Сохранить", style: .done, target: self, action: #selector(saveButtonTapped))
        let cancelButton = UIBarButtonItem(title: "Отменить", style: .plain, target: self, action: #selector(cancelButtonTapped))
        navigationItem.leftBarButtonItem = cancelButton
        navigationItem.rightBarButtonItem = saveButton
    }
    
    private func setupSubviews() {
        view.addSubview(scrollView)
        scrollView.addSubview(addNewTodoStackView)
        
        addNewTodoStackView.addArrangedSubview(textView)
        addNewTodoStackView.addArrangedSubview(settingsStackView)
        addNewTodoStackView.addArrangedSubview(deleteButton)
        
        priorityStackView.addArrangedSubview(importanceLabel)
        priorityStackView.addArrangedSubview(importancePickerView)
        
        deadlineLabelsStackView.addArrangedSubview(deadlineLabel)
        deadlineLabelsStackView.addArrangedSubview(deadlineDateLabel)
        
        deadlineStackView.addArrangedSubview(deadlineLabelsStackView)
        deadlineStackView.addArrangedSubview(deadlineSwitchView)
        
        settingsStackView.addArrangedSubview(priorityStackView)
        settingsStackView.addArrangedSubview(dividerView)
        settingsStackView.addArrangedSubview(deadlineStackView)
        settingsStackView.addArrangedSubview(secondDividerView)
        settingsStackView.addArrangedSubview(datePicker)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        addNewTodoStackView.translatesAutoresizingMaskIntoConstraints = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        settingsStackView.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        priorityStackView.translatesAutoresizingMaskIntoConstraints = false
        importancePickerView.translatesAutoresizingMaskIntoConstraints = false
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        
        let bottomConstraint = scrollView.bottomAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.bottomAnchor,
            constant: -Consts.padding
        )
        
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            bottomConstraint
        ])
        
        NSLayoutConstraint.activate([
            addNewTodoStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: Consts.padding),
            addNewTodoStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: Consts.padding),
            addNewTodoStackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: Consts.padding),
            addNewTodoStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            addNewTodoStackView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor)
        ])
        
        NSLayoutConstraint.activate([
            textView.heightAnchor.constraint(greaterThanOrEqualToConstant: Consts.textViewHeight),
            
            settingsStackView.leadingAnchor.constraint(equalTo: addNewTodoStackView.leadingAnchor),
            settingsStackView.trailingAnchor.constraint(equalTo: addNewTodoStackView.trailingAnchor),
            
            deleteButton.heightAnchor.constraint(equalToConstant: Consts.deleteButtonHeight),
            
            importancePickerView.widthAnchor.constraint(equalToConstant: Consts.segmentedControlWidth),
            importancePickerView.heightAnchor.constraint(equalToConstant: Consts.segmentedControlHeight),
            
            datePicker.widthAnchor.constraint(equalTo: settingsStackView.widthAnchor)
        ])
        
        self.scrollVeiwBottomConstraint = bottomConstraint
    }
    
    private func subscribeToKeyboard() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleKeyboard(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleKeyboard(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    private func unsubdcribeToKeyboard() {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Handlers
    @objc private func saveButtonTapped() {
        print("Save Tapped")
        
        let alert = UIAlertController(title: "", message: "Файл успешно сохранен", preferredStyle: .alert)
        let action = UIAlertAction(title: "Ок", style: .default)
        alert.addAction(action)
        
        
        todo.text = textView.text
        guard todo.text != "" && todo.text != "Что надо сделать?" else {
            alert.title = "Ошибка"
            alert.message = "Некоректное описание задачи"
            present(alert, animated: true, completion: nil)
            return
        }
        
        fileCache.add(item: todo)
        fileCache.saveAsCSV(filename: "ToDoList")
        present(alert, animated: true, completion: nil)
        
    }
    
    @objc private func cancelButtonTapped() {
        print("Cancel Tapped")
    }
    
    @objc private func deleteButtonTapped() {
        print("Delete Tapped")
        
        fileCache.delete(id: todo.id)
        fileCache.saveAsCSV(filename: "ToDoList")
        todo = TodoItem(text: "", importance: .normal, done: false)
        deadlineSwitchView.isOn = false
        importancePickerView.selectedSegmentIndex = 1
        textView.textColor = .tertiaryLabel
        textView.text = "Что надо сделать?"
        deleteButton.isEnabled = false
        deadlineDateLabel.isHidden = !self.deadlineSwitchView.isOn
    }
    
    @objc private func UpdateDate() {
        
        if deadlineSwitchView.isOn == true {
            UIView.animate(withDuration: 0.5) {
                self.deadlineDateLabel.isHidden = !self.deadlineSwitchView.isOn
                let date = Date(timeIntervalSinceNow: 60*60*24)
                self.todo.deadline = date
                self.deadlineDateLabel.text = "\(date.formatted(.dateTime.day().month().year()))"
            }
        } else {
            UIView.animate(withDuration: 0.5) {
                self.deadlineDateLabel.isHidden = !self.deadlineSwitchView.isOn
                self.deadlineDateLabel.text = ""
                self.datePicker.isHidden = !self.deadlineSwitchView.isOn
                self.secondDividerView.isHidden = !self.deadlineSwitchView.isOn
                self.todo.deadline = nil
            }
        }
        
    }
    
    @objc private func deadlineDateLabelTapped() {
        UIView.animate(withDuration: 0.5) {
            self.datePicker.isHidden = false
            self.secondDividerView.isHidden = false
        }
    }
    
    @objc private func deadlineDateChanged(sender: UIDatePicker) {
        deadlineDateLabel.text = "\(sender.date.formatted(.dateTime.day().month().year()))"
        todo.deadline = sender.date
        UIView.animate(withDuration: 0.5) {
            self.datePicker.isHidden = true
            self.secondDividerView.isHidden = true
        }
    }
    
    @objc private func handleTap() {
        view.endEditing(true)
    }
    
    @objc private func handleKeyboard(_ notification: NSNotification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }
        let height = view.convert(keyboardValue.cgRectValue, to: view.window).height
        let keyboardConstant: CGFloat
        if notification.name == UIResponder.keyboardWillShowNotification {
            keyboardConstant = height + Consts.padding
        } else {
            keyboardConstant = Consts.padding
        }
        scrollVeiwBottomConstraint?.constant = -keyboardConstant
        UIView.animate(withDuration: 0.5) {
            self.view.layoutSubviews()
        }
    }
    
    @objc private func priorityValueChanged() {
        print("Priority Value Changed")
        
        switch importancePickerView.selectedSegmentIndex {
        case 0:
            todo.importance = .unimportant
        case 1:
            todo.importance = .normal
        case 2:
            todo.importance = .important
        default:
            todo.importance = .normal
        }
    }
    
}

// MARK: - UITextViewDelegate
extension ItemViewController: UITextViewDelegate {
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if textView.text == "Что надо сделать?" {
            textView.text = nil
            textView.textColor = .label
        }
        deleteButton.isEnabled = true
        deadlineSwitchView.isEnabled = true
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Что надо сделать?"
            textView.textColor = .tertiaryLabel
            deadlineSwitchView.setOn(false, animated: true)
            UpdateDate()
        }
        todo.text = textView.text
    }
}

