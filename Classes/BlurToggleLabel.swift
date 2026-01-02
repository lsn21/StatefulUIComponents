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
        // Удаляем предыдущее размытое изображение
        blurredImageView?.removeFromSuperview()
        blurredImageView = nil
        
        // Создаем размытое изображение только текста
        guard let blurredView = createBlurredTextImageView() else {
            isBlurred = false
            return
        }
        
        blurredImageView = blurredView
        addSubview(blurredView)
        
        // Прячем оригинальный текст
        super.text = ""
        
        // Анимация появления размытия
        blurredView.alpha = 0
        UIView.animate(withDuration: animationDuration) {
            blurredView.alpha = 1
        }
    }
    
    private func updateNormalState() {
        // Убираем размытое изображение
        UIView.animate(withDuration: animationDuration) {
            self.blurredImageView?.alpha = 0
        } completion: { _ in
            self.blurredImageView?.removeFromSuperview()
            self.blurredImageView = nil
            
            // Восстанавливаем оригинальный текст после анимации
            DispatchQueue.main.async {
                super.text = self._originalText
            }
        }
    }
    
    // MARK: - Blurred Text Image Creation (FIXED - только текст)
    private func createBlurredTextImageView() -> UIImageView? {
        guard let originalText = self.originalText, !originalText.isEmpty else { return nil }
        
        // Сохраняем текущие настройки
        let originalBackgroundColor = backgroundColor
        backgroundColor = .clear
        
        // Рассчитываем размер текста
        let textSize = calculateTextSize()
        
        // Создаем графический контекст только для текста
        UIGraphicsBeginImageContextWithOptions(textSize, false, 0.0)
        defer { UIGraphicsEndImageContext() }
        
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        // Очищаем фон (прозрачный)
        context.clear(CGRect(origin: .zero, size: textSize))
        
        // Рисуем текст в центре области текста
        context.saveGState()
        
        // Создаем атрибутированную строку с теми же атрибутами, что у label
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = self.textAlignment
        paragraphStyle.lineBreakMode = self.lineBreakMode
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: self.font as Any,
            .foregroundColor: self.textColor as Any,
            .paragraphStyle: paragraphStyle
        ]
        
        let attributedString = NSAttributedString(string: originalText, attributes: attributes)
        
        // Рисуем текст в центре области
        let drawingRect = CGRect(origin: .zero, size: textSize)
        attributedString.draw(in: drawingRect)
        
        context.restoreGState()
        
        // Получаем изображение текста
        guard let textImage = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        
        // Восстанавливаем фон
        backgroundColor = originalBackgroundColor
        
        // Создаем CIImage из UIImage
        guard let ciImage = CIImage(image: textImage) else { return nil }
        
        // Применяем размытие
        let filter = CIFilter(name: "CIGaussianBlur")!
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        filter.setValue(blurRadius, forKey: kCIInputRadiusKey)
        
        // Получаем размытое изображение
        guard let outputImage = filter.outputImage else { return nil }
        
        // Создаем UIImage из CIImage
        let context2 = CIContext()
        guard let cgImage = context2.createCGImage(outputImage, from: outputImage.extent) else { return nil }
        let blurredImage = UIImage(cgImage: cgImage)
        
        // Создаем UIImageView для размытого текста
        let blurredImageView = UIImageView(image: blurredImage)
        
        // Позиционируем размытый текст там же, где был оригинальный текст
        blurredImageView.frame = CGRect(
            x: calculateTextOrigin().x,
            y: calculateTextOrigin().y,
            width: textSize.width,
            height: textSize.height
        )
        
        blurredImageView.contentMode = .scaleToFill
        
        return blurredImageView
    }
    
    // MARK: - Text Size Calculation
    private func calculateTextSize() -> CGSize {
        guard let text = originalText, !text.isEmpty else { return .zero }
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = self.textAlignment
        paragraphStyle.lineBreakMode = self.lineBreakMode
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: self.font as Any,
            .paragraphStyle: paragraphStyle
        ]
        
        let attributedString = NSAttributedString(string: text, attributes: attributes)
        
        return attributedString.boundingRect(
            with: CGSize(width: bounds.width, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil
        ).size
    }
    
    private func calculateTextOrigin() -> CGPoint {
        let textSize = calculateTextSize()
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
        switch contentMode {
        case .top, .topLeft, .topRight, .topCenter:
            originY = 0
        case .center, .bottomCenter:
            originY = (labelSize.height - textSize.height) / 2
        case .bottom, .bottomLeft, .bottomRight:
            originY = labelSize.height - textSize.height
        default:
            originY = (labelSize.height - textSize.height) / 2
        }
        
        return CGPoint(x: originX, y: originY)
    }
    
    // MARK: - Text Property Override
    override var text: String? {
        get {
            return super.text
        }
        set {
            _originalText = newValue
            super.text = newValue
        }
    }
    
    // MARK: - Layout Methods
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Обновляем позицию размытого текста при изменении размера
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
