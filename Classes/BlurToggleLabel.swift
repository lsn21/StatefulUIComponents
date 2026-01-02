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
            self.alpha = 0
        } completion: { _ in
            self.alpha = 0 // Скрываем оригинальный текст
        }
    }
    
    private func updateNormalState() {
        // Анимация возврата к нормальному состоянию
        UIView.animate(withDuration: animationDuration) {
            self.blurredImageView?.alpha = 0
            self.blurredImageView?.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            self.alpha = 1
        } completion: { _ in
            self.blurredImageView?.removeFromSuperview()
            self.blurredImageView = nil
        }
    }
    
    // MARK: - Blurred Image Creation
    private func createBlurredImageView() -> UIImageView? {
        guard let text = self.text, !text.isEmpty else { return nil }
        
        // Создаем атрибуты текста
        let attributes: [NSAttributedString.Key: Any] = [
            .font: self.font ?? UIFont.systemFont(ofSize: 17),
            .foregroundColor: self.textColor ?? UIColor.black
        ]
        
        // Создаем атрибутированную строку
        let attributedString = NSAttributedString(string: text, attributes: attributes)
        
        // Определяем размер текста с учетом текущих размеров label
        let textSize = attributedString.boundingRect(
            with: CGSize(width: bounds.width, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil
        ).size
        
        // Создаем графический контекст
        UIGraphicsBeginImageContextWithOptions(textSize, false, 0.0)
        defer { UIGraphicsEndImageContext() }
        
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        // Устанавливаем цвет фона если задан
        if blurColor != .clear {
            context.setFillColor(blurColor.cgColor)
            context.fill(CGRect(origin: .zero, size: textSize))
        }
        
        // Рисуем текст
        attributedString.draw(in: CGRect(origin: .zero, size: textSize))
        
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
        let ciContext = CIContext()
        guard let cgImage = ciContext.createCGImage(outputImage, from: outputImage.extent) else { return nil }
        
        let blurredImage = UIImage(cgImage: cgImage)
        
        // Создаем UIImageView для размытого текста
        let blurredImageView = UIImageView(image: blurredImage)
        blurredImageView.frame = CGRect(
            x: (bounds.width - textSize.width) / 2,
            y: (bounds.height - textSize.height) / 2,
            width: textSize.width,
            height: textSize.height
        )
        blurredImageView.contentMode = .center
        
        return blurredImageView
    }
    
    // MARK: - Layout Methods
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Обновляем позицию размытого изображения при изменении layout
        if isBlurred {
            updateBlurredImageViewPosition()
        }
    }
    
    private func updateBlurredImageViewPosition() {
        guard let blurredImageView = blurredImageView else { return }
        
        if let text = self.text, !text.isEmpty {
            let attributes: [NSAttributedString.Key: Any] = [
                .font: self.font ?? UIFont.systemFont(ofSize: 17)
            ]
            
            let attributedString = NSAttributedString(string: text, attributes: attributes)
            let textSize = attributedString.boundingRect(
                with: CGSize(width: bounds.width, height: .greatestFiniteMagnitude),
                options: [.usesLineFragmentOrigin, .usesFontLeading],
                context: nil
            ).size
            
            blurredImageView.frame = CGRect(
                x: (bounds.width - textSize.width) / 2,
                y: (bounds.height - textSize.height) / 2,
                width: textSize.width,
                height: textSize.height
            )
        }
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
