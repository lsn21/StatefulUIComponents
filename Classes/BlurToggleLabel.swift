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
    
    @IBInspectable var blurRadius: CGFloat = 5.0 {
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
    
    @IBInspectable var animationDuration: Double = 0.3 {
        didSet {
            // Обновляем анимацию если нужно
        }
    }
    
    @IBInspectable var enableTapGesture: Bool = true {
        didSet {
            setupTapGesture()
        }
    }
    
    @IBInspectable var blurColor: UIColor = .clear {
        didSet {
            if isBlurred {
                updateBlurredState()
            }
        }
    }
    
    // Прозрачность оригинального текста в размытом состоянии
    @IBInspectable var originalTextAlphaWhenBlurred: CGFloat = 0.0 {
        didSet {
            if isBlurred {
                updateBlurredState()
            }
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
        // Удаляем старый жест если есть
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
        
        // Анимация появления размытия
        blurredView.alpha = 0
        blurredView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        
        UIView.animate(withDuration: animationDuration) {
            blurredView.alpha = 1
            blurredView.transform = .identity
            self.alpha = self.originalTextAlphaWhenBlurred
        }
    }
    
    private func updateNormalState() {
        // Анимация возврата к нормальному состоянию
        UIView.animate(withDuration: animationDuration) {
            self.blurredImageView?.alpha = 0
            self.blurredImageView?.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            self.alpha = 1.0
        } completion: { _ in
            self.blurredImageView?.removeFromSuperview()
            self.blurredImageView = nil
        }
    }
    
    // MARK: - Blurred Image Creation
    private func createBlurredImageView() -> UIImageView? {
        guard let text = self.text, !text.isEmpty else { return nil }
        
        // Используем текущие размеры label для создания изображения
        let imageSize = bounds.size
        
        // Создаем графический контекст с прозрачным фоном
        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0.0)
        defer { UIGraphicsEndImageContext() }
        
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        // Очищаем фон (делаем полностью прозрачным)
        context.clear(CGRect(origin: .zero, size: imageSize))
        
        // Если задан цвет фона размытия - рисуем его
        if blurColor != .clear {
            context.setFillColor(blurColor.cgColor)
            context.fill(CGRect(origin: .zero, size: imageSize))
        }
        
        // Рисуем текст в центре label (как он рисуется обычно)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = self.textAlignment
        paragraphStyle.lineBreakMode = self.lineBreakMode
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: self.font ?? UIFont.systemFont(ofSize: 17),
            .foregroundColor: self.textColor ?? UIColor.black,
            .paragraphStyle: paragraphStyle
        ]
        
        let attributedString = NSAttributedString(string: text, attributes: attributes)
        
        // Рассчитываем прямоугольник для текста с учетом выравнивания
        let textRect: CGRect
        if numberOfLines == 1 {
            // Для однострочного текста
            textRect = attributedString.boundingRect(
                with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: imageSize.height),
                options: [.usesLineFragmentOrigin, .usesFontLeading],
                context: nil
            )
        } else {
            // Для многострочного текста
            textRect = attributedString.boundingRect(
                with: CGSize(width: imageSize.width, height: CGFloat.greatestFiniteMagnitude),
                options: [.usesLineFragmentOrigin, .usesFontLeading],
                context: nil
            )
        }
        
        // Позиционируем текст в зависимости от выравнивания
        var drawingRect = CGRect.zero
        drawingRect.size = textRect.size
        
        // Горизонтальное выравнивание
        switch textAlignment {
        case .left:
            drawingRect.origin.x = 0
        case .right:
            drawingRect.origin.x = imageSize.width - textRect.width
        case .center:
            drawingRect.origin.x = (imageSize.width - textRect.width) / 2
        default:
            drawingRect.origin.x = 0
        }
        
        // Вертикальное выравнивание
        drawingRect.origin.y = (imageSize.height - textRect.height) / 2
        
        // Рисуем текст
        attributedString.draw(in: drawingRect)
        
        guard let originalImage = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        
        // Применяем размытие к изображению
        guard let ciImage = CIImage(image: originalImage) else { return nil }
        
        let filter = CIFilter(name: "CIGaussianBlur")!
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        filter.setValue(blurRadius, forKey: kCIInputRadiusKey)
        
        guard let outputImage = filter.outputImage else { return nil }
        
        // Создаем UIImage из CIImage
        let ciContext = CIContext()
        guard let cgImage = ciContext.createCGImage(outputImage, from: outputImage.extent) else { return nil }
        
        let blurredImage = UIImage(cgImage: cgImage)
        
        // Создаем UIImageView для размытого текста
        let blurredImageView = UIImageView(image: blurredImage)
        blurredImageView.frame = bounds
        blurredImageView.contentMode = .center
        blurredImageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        return blurredImageView
    }
    
    // MARK: - Layout Methods
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Обновляем размер размытого изображения при изменении layout
        if isBlurred {
            updateBlurredImageViewFrame()
        }
    }
    
    private func updateBlurredImageViewFrame() {
        blurredImageView?.frame = bounds
    }
    
    // MARK: - Property Observers
    override var text: String? {
        didSet {
            if isBlurred {
                updateBlurredState()
            }
        }
    }
    
    override var font: UIFont! {
        didSet {
            if isBlurred {
                updateBlurredState()
            }
        }
    }
    
    override var textColor: UIColor! {
        didSet {
            if isBlurred {
                updateBlurredState()
            }
        }
    }
    
    override var textAlignment: NSTextAlignment {
        didSet {
            if isBlurred {
                updateBlurredState()
            }
        }
    }
    
    override var numberOfLines: Int {
        didSet {
            if isBlurred {
                updateBlurredState()
            }
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
        
        // Убеждаемся, что свойства установлены правильно для IB
        if text == nil || text?.isEmpty == true {
            text = "BlurToggleLabel"
        }
        
        // Показываем состояние размытия в IB
        if isBlurred {
            updateBlurredState()
        }
    }
    
    // MARK: - Deinitialization
    deinit {
        if let tapGesture = tapGesture {
            removeGestureRecognizer(tapGesture)
        }
    }
}
