//
//  PlaceholderTextView.swift
//  StatefulUIComponentsExample
//
//  Created by Siarhei Lukyanau on 23.12.25.
//

import UIKit

// MARK: - Protocol
public protocol PlaceholderProtocol: AnyObject {
    func placeholderDelegate()
}

// MARK: - PlaceholderTextView Class
@IBDesignable
public class PlaceholderTextView: UITextView {
    
    // MARK: - Public Properties
    public weak var placeholderDelegate: PlaceholderProtocol? // ← Изменили имя свойства!
    
    @IBInspectable public var placeholder: String? {
        didSet {
            placeholderLabel.text = placeholder
        }
    }

    @IBInspectable public var placeholderColor: UIColor = .lightGray {
        didSet {
            placeholderLabel.textColor = placeholderColor
        }
    }

    public var placeholderFont: UIFont = UIFont.systemFont(ofSize: 16) {
        didSet {
            placeholderLabel.font = placeholderFont
        }
    }
    
    // MARK: - IBInspectable для шрифта
    @IBInspectable public var placeholderFontName: String? {
        didSet {
            updatePlaceholderFont()
        }
    }
    
    @IBInspectable public var placeholderFontSize: CGFloat = 16 {
        didSet {
            updatePlaceholderFont()
        }
    }

    // MARK: - Private Properties
    private var placeholderLabel: UILabel!

    // MARK: - Initialization
    public override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setupPlaceholder()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupPlaceholder()
    }

    // MARK: - Setup Methods
    private func setupPlaceholder() {
        super.delegate = self // ← Важно: используем super.delegate
        
        // Создаем placeholder label
        placeholderLabel = UILabel()
        placeholderLabel.numberOfLines = 0
        placeholderLabel.textColor = placeholderColor
        placeholderLabel.font = placeholderFont
        placeholderLabel.text = placeholder
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(placeholderLabel)

        // Констрейнты
        NSLayoutConstraint.activate([
            placeholderLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: textContainerInset.top),
            placeholderLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: textContainerInset.left + 5),
            placeholderLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -(textContainerInset.right + 5))
        ])
        
        updatePlaceholderVisibility()
    }
    
    private func updatePlaceholderFont() {
        if let fontName = placeholderFontName, let font = UIFont(name: fontName, size: placeholderFontSize) {
            placeholderFont = font
        } else {
            placeholderFont = UIFont.systemFont(ofSize: placeholderFontSize)
        }
    }
    
    private func updatePlaceholderVisibility() {
        let isHidden = !(text?.isEmpty ?? true)
        placeholderLabel.isHidden = isHidden
    }

    // MARK: - Interface Builder Support
    public override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        updatePlaceholderVisibility()
    }
    
    // MARK: - Text Container Insets
    public override var textContainerInset: UIEdgeInsets {
        didSet {
            // Обновляем констрейнты при изменении insets
            if let placeholderLabel = placeholderLabel {
                NSLayoutConstraint.deactivate(placeholderLabel.constraints)
                NSLayoutConstraint.activate([
                    placeholderLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: textContainerInset.top),
                    placeholderLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: textContainerInset.left + 5),
                    placeholderLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -(textContainerInset.right + 5))
                ])
            }
        }
    }
}

// MARK: - UITextViewDelegate Extension
extension PlaceholderTextView: UITextViewDelegate {
    public func textViewDidChange(_ textView: UITextView) {
        updatePlaceholderVisibility()
        placeholderDelegate?.placeholderDelegate() // ← Вызываем наш кастомный делегат
    }
    
    public func textViewDidBeginEditing(_ textView: UITextView) {
        updatePlaceholderVisibility()
    }
    
    public func textViewDidEndEditing(_ textView: UITextView) {
        updatePlaceholderVisibility()
    }
    
    // Если нужно сохранить возможность использовать стандартный UITextViewDelegate
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // Можно добавить логику или передать вызов внешнему делегату
        return true
    }
}
