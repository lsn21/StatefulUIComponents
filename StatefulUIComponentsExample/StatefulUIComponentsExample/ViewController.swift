//
//  ViewController.swift
//  StatefulUIComponentsExample
//
//  Created by Siarhei Lukyanau on 22.12.25.
//

import UIKit
import StatefulUIComponents

class ViewController: UIViewController, PlaceholderProtocol {
    
    // MARK: - IBOutlets
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var statefulButton: StatefulUIButton!
    @IBOutlet weak var placeholderTextView: PlaceholderTextView!
    @IBOutlet weak var stateControl: UISegmentedControl!
    @IBOutlet weak var enableSwitch: UISwitch!
    @IBOutlet weak var changeColorsButton: UIButton!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Инициализация пакета
        StatefulUIComponents.initialize()
        
        setupContainerView()
        setupStatefulButton()
        setupPlaceholderTextView()
        setupControls()
    }
    
    // MARK: - Setup methods
    private func setupContainerView() {
        // Используем named color для границы через расширение UIView
        containerView.borderColorName = "PrimaryBorderColor"
        containerView.borderWidthIB = 2.0
        containerView.cornerRadiusIB = 16.0
        
        // Настройка отдельных углов
        containerView.topLeftCorner = true
        containerView.topRightCorner = true
        containerView.bottomLeftCorner = true
        containerView.bottomRightCorner = true
        
        // Тень для контейнера
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.1
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 4
    }
    
    private func setupStatefulButton() {
        // Фон для разных состояний
        statefulButton.normalBackgroundColor = UIColor(named: "AppPrimaryColor")
        statefulButton.highlightedBackgroundColor = UIColor(named: "AppPrimaryColor")?.withAlphaComponent(0.8)
        statefulButton.selectedBackgroundColor = UIColor(named: "AppSecondaryColor")
        statefulButton.disabledBackgroundColor = .systemGray4
        
        // Цвет текста для разных состояний
        statefulButton.normalTitleColor = .white
        statefulButton.highlightedTitleColor = .white.withAlphaComponent(0.9)
        statefulButton.selectedTitleColor = .white
        statefulButton.disabledTitleColor = .systemGray
        
        // Шрифты для разных состояний
        statefulButton.normalFont = UIFont.systemFont(ofSize: 16, weight: .semibold)
        statefulButton.highlightedFont = UIFont.systemFont(ofSize: 16, weight: .bold)
        statefulButton.selectedFont = UIFont.systemFont(ofSize: 16, weight: .bold)
        
        // Граница через named color (из расширения UIView)
        statefulButton.borderColorName = "ButtonBorderColor"
        statefulButton.borderWidthIB = 1.0
        statefulButton.cornerRadiusIB = 10.0
        
        // Устанавливаем заголовок
        statefulButton.setTitle("Нажми меня", for: .normal)
        statefulButton.setTitle("Нажато! 🎉", for: .selected)
    }
    
    private func setupPlaceholderTextView() {
        // Настройка PlaceholderTextView
        placeholderTextView.placeholder = "Введите ваш текст здесь..."
        placeholderTextView.placeholderColor = .systemGray
        placeholderTextView.placeholderFontSize = 14
        placeholderTextView.font = UIFont.systemFont(ofSize: 16)
        
        // Делегат для обработки изменений текста
        placeholderTextView.placeholderDelegate = self
        
        // Стилизация через расширение UIView
        placeholderTextView.borderColorName = "TextFieldBorderColor"
        placeholderTextView.borderWidthIB = 1.0
        placeholderTextView.cornerRadiusIB = 8.0
    }
    
    private func setupControls() {
        stateControl.selectedSegmentIndex = 0
        enableSwitch.isOn = statefulButton.isEnabled
        changeColorsButton.setTitle("Сменить цвета", for: .normal)
        
        // Стилизация кнопки смены цветов
        changeColorsButton.backgroundColor = UIColor(named: "AccentColor")
        changeColorsButton.setTitleColor(.white, for: .normal)
        changeColorsButton.layer.cornerRadius = 8
        
        updateButtonState()
    }
    
    // MARK: - PlaceholderProtocol implementation
    public func placeholderDelegate() {
        print("Текст изменен: \(placeholderTextView.text ?? "")")
        
        // Динамически меняем состояние кнопки в зависимости от текста
        let hasText = !(placeholderTextView.text?.isEmpty ?? true)
        statefulButton.isEnabled = hasText
        enableSwitch.isOn = hasText
        
        if hasText {
            statefulButton.setTitle("Готово!", for: .normal)
        } else {
            statefulButton.setTitle("Введите текст", for: .normal)
        }
    }
    
    // MARK: - IBActions
    @IBAction func stateControlChanged(_ sender: UISegmentedControl) {
        updateButtonState()
    }
    
    @IBAction func enableSwitchChanged(_ sender: UISwitch) {
        statefulButton.isEnabled = sender.isOn
        updateButtonState()
    }
    
    @IBAction func statefulButtonTapped(_ sender: StatefulUIButton) {
        // Переключаем selected состояние при тапе
        sender.isSelected.toggle()
        updateButtonState()
        
        // Скрываем клавиатуру
        placeholderTextView.resignFirstResponder()
        
        showCurrentStateAlert()
    }
    
    @IBAction func changeColorsButtonTapped(_ sender: UIButton) {
        // Динамическое изменение named colors во время выполнения
        toggleColors()
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: - Helper methods
    private func updateButtonState() {
        let stateIndex = stateControl.selectedSegmentIndex
        
        switch stateIndex {
        case 0: // Normal
            statefulButton.isHighlighted = false
            statefulButton.isSelected = false
        case 1: // Highlighted
            statefulButton.isHighlighted = true
            statefulButton.isSelected = false
        case 2: // Selected
            statefulButton.isHighlighted = false
            statefulButton.isSelected = true
        default:
            break
        }
    }
    
    private func toggleColors() {
        // Переключаемся между двумя наборами цветов
        let isPrimarySet = containerView.borderColorName == "PrimaryBorderColor"
        
        if isPrimarySet {
            // Вторичная цветовая схема
            containerView.borderColorName = "SecondaryBorderColor"
            statefulButton.borderColorName = "SecondaryButtonBorderColor"
            placeholderTextView.borderColorName = "SecondaryTextFieldBorderColor"
            statefulButton.normalBackgroundColor = UIColor(named: "AppSecondaryColor")
            changeColorsButton.backgroundColor = UIColor(named: "AppSecondaryColor")
        } else {
            // Первичная цветовая схема
            containerView.borderColorName = "PrimaryBorderColor"
            statefulButton.borderColorName = "ButtonBorderColor"
            placeholderTextView.borderColorName = "TextFieldBorderColor"
            statefulButton.normalBackgroundColor = UIColor(named: "AppPrimaryColor")
            changeColorsButton.backgroundColor = UIColor(named: "AccentColor")
        }
    }
    
    private func showCurrentStateAlert() {
        let state: String
        switch statefulButton.state {
        case .normal: state = "Normal"
        case .highlighted: state = "Highlighted"
        case .selected: state = "Selected"
        case .disabled: state = "Disabled"
        default: state = "Unknown"
        }
        
        let alert = UIAlertController(
            title: "Текущее состояние",
            message: "Кнопка в состоянии: \(state)\nТекст: \(placeholderTextView.text ?? "")",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Touch handling
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        // Скрываем клавиатуру при касании вне текстового поля
        view.endEditing(true)
    }
}

// MARK: - UITextFieldDelegate для скрытия клавиатуры по Return
extension ViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}
