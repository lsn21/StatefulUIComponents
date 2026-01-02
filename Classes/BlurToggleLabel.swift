//
//  BlurToggleLabel.swift
//  StatefulUIComponents
//
//  Created by Siarhei Lukyanau on 2.01.26.
//

import UIKit

class BlurToggleLabel: UILabel {
    
    // MARK: - Public Properties
    public var blurRadius: CGFloat = 5.0 {
        didSet {
            if isBlurred {
                updateBlurredState()
            }
        }
    }
    
    public var isBlurred: Bool = false {
        didSet {
            updateAppearance()
        }
    }
    
    public var animationDuration: TimeInterval = 0.3
    
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
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tapGesture!)
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
            .font: self.font as Any,
            .foregroundColor: self.textColor as Any
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
        let context = CIContext()
        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else { return nil }
        
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
            blurredImageView?.center = CGPoint(x: bounds.midX, y: bounds.midY)
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
    
    // MARK: - Deinitialization
    deinit {
        if let tapGesture = tapGesture {
            removeGestureRecognizer(tapGesture)
        }
    }
}
