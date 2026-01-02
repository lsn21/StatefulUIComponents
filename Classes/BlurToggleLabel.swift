//
//  BlurToggleLabel.swift
//  StatefulUIComponents
//
//  Created by Siarhei Lukyanau on 2.01.26.
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
    private var _originalText: String?
    
    // MARK: - Computed Properties
    private var originalText: String? {
        if _originalText == nil {
            _originalText = super.text
        }
        return _originalText
    }
    
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
        blurredImageView?.removeFromSuperview()
        blurredImageView = nil
        
        guard let blurredView = createBlurredTextImageView() else {
            isBlurred = false
            return
        }
        
        blurredImageView = blurredView
        addSubview(blurredView)
        
        super.text = ""
        
        blurredView.alpha = 0
        UIView.animate(withDuration: animationDuration) {
            blurredView.alpha = 1
        }
    }
    
    private func updateNormalState() {
        UIView.animate(withDuration: animationDuration) {
            self.blurredImageView?.alpha = 0
        } completion: { _ in
            self.blurredImageView?.removeFromSuperview()
            self.blurredImageView = nil
            
            DispatchQueue.main.async {
                super.text = self._originalText
            }
        }
    }
    
    // MARK: - Blurred Text Image Creation (IMPROVED - полные атрибуты)
    private func createBlurredTextImageView() -> UIImageView? {
        guard let originalText = self.originalText, !originalText.isEmpty else { return nil }
        
        // Сохраняем текущие настройки
        let originalBackgroundColor = backgroundColor
        backgroundColor = .clear
        
        // Рассчитываем размер текста с учетом всех атрибутов
        let textSize = calculateTextSizeWithAttributes()
        
        // Создаем графический контекст
        UIGraphicsBeginImageContextWithOptions(textSize, false, 0.0)
        defer { UIGraphicsEndImageContext() }
        
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        // Очищаем фон (прозрачный)
        context.clear(CGRect(origin: .zero, size: textSize))
        
        // Рисуем текст с полными атрибутами
        context.saveGState()
        
        // Создаем атрибутированную строку со ВСЕМИ атрибутами UILabel
        let attributedString = createAttributedString(with: originalText)
        
        // Рисуем текст
        let drawingRect = CGRect(origin: .zero, size: textSize)
        attributedString.draw(in: drawingRect)
        
        context.restoreGState()
        
        // Получаем изображение текста
        guard let textImage = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        
        // Восстанавливаем фон
        backgroundColor = originalBackgroundColor
        
        // Применяем размытие
        guard let ciImage = CIImage(image: textImage),
              let filter = CIFilter(name: "CIGaussianBlur") else { return nil }
        
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        filter.setValue(blurRadius, forKey: kCIInputRadiusKey)
        
        guard let outputImage = filter.outputImage else { return nil }
        
        let context2 = CIContext()
        guard let cgImage = context2.createCGImage(outputImage, from: outputImage.extent) else { return nil }
        let blurredImage = UIImage(cgImage: cgImage)
        
        // Создаем UIImageView для размытого текста
        let blurredImageView = UIImageView(image: blurredImage)
        
        // Позиционируем размытый текст
        blurredImageView.frame = CGRect(
            x: calculateTextOrigin().x,
            y: calculateTextOrigin().y,
            width: textSize.width,
            height: textSize.height
        )
        
        blurredImageView.contentMode = .scaleToFill
        
        return blurredImageView
    }
    
    // MARK: - Text Attributes (ВСЕ атрибуты UILabel)
    private func createAttributedString(with text: String) -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = self.textAlignment
        paragraphStyle.lineBreakMode = self.lineBreakMode
        paragraphStyle.lineSpacing = 0 // Можно добавить если нужно
        
        // Базовые атрибуты
        var attributes: [NSAttributedString.Key: Any] = [
            .font: self.font as Any,
            .foregroundColor: self.textColor as Any,
            .paragraphStyle: paragraphStyle
        ]
        
        // Добавляем дополнительные атрибуты если они есть
        if let attributedText = self.attributedText {
            // Если текст уже атрибутированный - используем его атрибуты
            attributedText.enumerateAttributes(in: NSRange(location: 0, length: attributedText.length)) { (attrs, range, stop) in
                for (key, value) in attrs {
                    attributes[key] = value
                }
            }
        } else {
            // Добавляем тени текста если они есть
            if let shadow = self.shadowColor {
                let shadowOffset = self.shadowOffset
                let textShadow = NSShadow()
                textShadow.shadowColor = shadow
                textShadow.shadowOffset = CGSize(width: shadowOffset.width, height: shadowOffset.height)
                textShadow.shadowBlurRadius = 0 // UILabel не поддерживает blur radius для теней
                attributes[.shadow] = textShadow
            }
            
            // Кернинг (если применимо)
            // attributes[.kern] = 0 // Можно настроить если нужно
        }
        
        return NSAttributedString(string: text, attributes: attributes)
    }
    
    // MARK: - Text Size Calculation (Улучшенный расчет)
    private func calculateTextSizeWithAttributes() -> CGSize {
        guard let text = originalText, !text.isEmpty else { return .zero }
        
        let attributedString = createAttributedString(with: text)
        
        let maxSize = CGSize(width: bounds.width, height: CGFloat.greatestFiniteMagnitude)
        let options: NSStringDrawingOptions = [.usesLineFragmentOrigin, .usesFontLeading]
        
        // Учитываем количество строк
        if numberOfLines > 0 {
            let singleLineHeight = attributedString.boundingRect(
                with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude),
                options: options,
                context: nil
            ).height
            
            let maxHeight = singleLineHeight * CGFloat(numberOfLines)
            return attributedString.boundingRect(
                with: CGSize(width: maxSize.width, height: maxHeight),
                options: options,
                context: nil
            ).size
        } else {
            return attributedString.boundingRect(with: maxSize, options: options, context: nil).size
        }
    }
    
    private func calculateTextOrigin() -> CGPoint {
        let textSize = calculateTextSizeWithAttributes()
        let labelSize = bounds.size
        
        var originX: CGFloat = 0
        var originY: CGFloat = 0
        
        // Горизонтальное выравнивание
        switch textAlignment {
        case .left, .natural, .justified:
            originX = 0
        case .center:
            originX = (labelSize.width - textSize.width) / 2
        case .right:
            originX = labelSize.width - textSize.width
        @unknown default:
            originX = 0
        }
        
        // Вертикальное выравнивание
        originY = (labelSize.height - textSize.height) / 2
        
        return CGPoint(x: originX, y: originY)
    }
    
    // MARK: - Text Property Override
    override var text: String? {
        get { return super.text }
        set {
            _originalText = newValue
            super.text = newValue
        }
    }
    
    // MARK: - Attributed Text Support
    override var attributedText: NSAttributedString? {
        get { return super.attributedText }
        set {
            _originalText = newValue?.string
            super.attributedText = newValue
        }
    }
    
    // MARK: - Layout Methods
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if isBlurred {
            updateBlurredState()
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
