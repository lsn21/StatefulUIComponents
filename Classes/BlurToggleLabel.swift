//
//  BlurToggleLabel.swift
//  StatefulUIComponents
//
//  Created by Siarhei Lukyanau on 2.01.26.
//

//
//  BlurToggleLabel.swift
//  LoansHelpers
//
//  Created by Siarhei Lukyanau on 31.10.25.
//

import UIKit

@IBDesignable
class BlurToggleLabel: UILabel {
    
    // MARK: - IBInspectable Properties
    
    @IBInspectable var blurRadius: CGFloat = 3.5 {
        didSet {
            if isBlurred {
                updateBlurredState()
            }
        }
    }
    
    @IBInspectable var isBlurred: Bool = false {
        didSet {
            updateAppearance()
        }
    }
    
    @IBInspectable var animationDuration: Double = 0.3
    
    @IBInspectable var enableTapGesture: Bool = true {
        didSet {
            setupTapGesture()
        }
    }
    
    // MARK: - Private Properties
    private var blurredImageView: UIImageView?
    private var tapGesture: UITapGestureRecognizer?
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        isUserInteractionEnabled = true
        setupTapGesture()
    }
    
    // MARK: - Setup Methods
    private func setupTapGesture() {
        if let tapGesture = tapGesture {
            removeGestureRecognizer(tapGesture)
        }
        
        if enableTapGesture {
            tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
            addGestureRecognizer(tapGesture!)
        } else {
            tapGesture = nil
        }
    }
    
    @objc private func handleTap() {
        isBlurred.toggle()
    }
    
    // MARK: - State Management
    private func updateAppearance() {
        if isBlurred {
            updateBlurredState()
        } else {
            updateNormalState()
        }
    }
    
    private func updateBlurredState() {
        // Удаляем предыдущее размытое изображение
        blurredImageView?.removeFromSuperview()
        blurredImageView = nil
        
        // Создаем размытое изображение текста
        guard let blurredView = createBlurredImageView() else {
            isBlurred = false
            return
        }
        
        blurredImageView = blurredView
        addSubview(blurredView)
        
        // Прячем оригинальный текст
        text = ""
        
        // Анимация появления размытия
        blurredView.alpha = 0
        UIView.animate(withDuration: animationDuration) {
            blurredView.alpha = 1
        }
    }
    
    private func updateNormalState() {
        // Возвращаем оригинальный текст
        text = originalText
        
        // Анимация исчезновения размытия
        UIView.animate(withDuration: animationDuration) {
            self.blurredImageView?.alpha = 0
        } completion: { _ in
            self.blurredImageView?.removeFromSuperview()
            self.blurredImageView = nil
        }
    }
    
    // MARK: - Blurred Image Creation
    private func createBlurredImageView() -> UIImageView? {
        guard let originalText = self.originalText, !originalText.isEmpty else { return nil }
        
        // Создаем атрибуты текста
        let attributes: [NSAttributedString.Key: Any] = [
            .font: self.font as Any,
            .foregroundColor: self.textColor as Any
        ]
        
        // Создаем атрибутированную строку
        let attributedString = NSAttributedString(string: originalText, attributes: attributes)
        
        // Определяем размер текста
        let size = attributedString.size()
        
        // Создаем графический контекст
        UIGraphicsBeginImageContext(size)
        defer { UIGraphicsEndImageContext() }
        
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        // Рисуем текст в контексте
        context.saveGState()
        context.translateBy(x: 0, y: 0)
        context.scaleBy(x: 1.0, y: 1.0)
        
        // Рисуем текст
        context.setTextDrawingMode(.fill)
        attributedString.draw(at: CGPoint(x: 0, y: 0))
        context.restoreGState()
        
        // Получаем изображение
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        
        // Создаем CIImage из UIImage
        guard let ciImage = CIImage(image: image) else { return nil }
        
        // Применяем размытие
        let filter = CIFilter(name: "CIGaussianBlur")!
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        filter.setValue(blurRadius, forKey: kCIInputRadiusKey)
        
        // Получаем размытую картинку
        guard let outputImage = filter.outputImage else { return nil }
        
        // Создаем UIImage из CIImage
        let context2 = CIContext()
        guard let cgImage = context2.createCGImage(outputImage, from: outputImage.extent) else { return nil }
        let blurredImage = UIImage(cgImage: cgImage)

        // Создаем UIImageView для размытого текста
        let blurredImageView = UIImageView(image: blurredImage)
        blurredImageView.frame = CGRect(origin: CGPoint(x: 0, y: 6.4), size: size)
        blurredImageView.contentMode = .scaleToFill
        
        return blurredImageView
    }
    
    // MARK: - Original Text Storage
    private var originalText: String? {
        // Сохраняем оригинальный текст перед размытием
        if _originalText == nil {
            _originalText = super.text
        }
        return _originalText
    }
    
    private var _originalText: String?
    
    override var text: String? {
        get {
            return super.text
        }
        set {
            _originalText = newValue
            super.text = newValue
        }
    }
    
    // MARK: - Public Methods
    public func toggleBlur() {
        isBlurred.toggle()
    }
    
    public func setBlurred(_ blurred: Bool, animated: Bool = true) {
        if animated {
            UIView.animate(withDuration: animationDuration) {
                self.isBlurred = blurred
            }
        } else {
            self.isBlurred = blurred
        }
    }
    
    // MARK: - Interface Builder Preparation
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        
        if text == nil || text?.isEmpty == true {
            text = "BlurToggleLabel"
        }
    }
    
    // MARK: - Deinitialization
    deinit {
        if let tapGesture = tapGesture {
            removeGestureRecognizer(tapGesture)
        }
    }
}
