//
//  StatefulUIButton.swift
//  Loans-202
//
//  Created by Siarhei Lukyanau on 22.12.25.
//

import UIKit

@IBDesignable
public class StatefulUIButton: UIButton {

    // MARK: - Background color per state
    @IBInspectable public var normalBackgroundColor: UIColor = .clear { didSet { updateBackgrounds() } }
    @IBInspectable public var highlightedBackgroundColor: UIColor = .clear { didSet { updateBackgrounds() } }
    @IBInspectable public var selectedBackgroundColor: UIColor = .clear { didSet { updateBackgrounds() } }
    @IBInspectable public var disabledBackgroundColor: UIColor = .clear { didSet { updateBackgrounds() } }

    // MARK: - Title color per state
    @IBInspectable public var normalTitleColor: UIColor = .white { didSet { setTitleColorForAllStates() } }
    @IBInspectable public var highlightedTitleColor: UIColor = .white { didSet { setTitleColorForAllStates() } }
    @IBInspectable public var selectedTitleColor: UIColor = .white { didSet { setTitleColorForAllStates() } }
    @IBInspectable public var disabledTitleColor: UIColor = .white { didSet { setTitleColorForAllStates() } }

    // MARK: - Title font per state
    public var normalTitleFont: UIFont = UIFont.systemFont(ofSize: 17) { didSet { applyFonts() } }
    public var highlightedTitleFont: UIFont? { didSet { applyFonts() } }
    public var selectedTitleFont: UIFont? { didSet { applyFonts() } }
    public var disabledTitleFont: UIFont? { didSet { applyFonts() } }

    // MARK: - Number of lines per state
    @IBInspectable public var normalTitleLines: Int = 1 { didSet { updateTitleLabelLines() } }
    @IBInspectable public var highlightedTitleLines: Int = 1 { didSet { updateTitleLabelLines() } }
    @IBInspectable public var selectedTitleLines: Int = 1 { didSet { updateTitleLabelLines() } }
    @IBInspectable public var disabledTitleLines: Int = 1 { didSet { updateTitleLabelLines() } }

    // MARK: - Caching
    private var backgroundImages: [UIControl.State: UIImage] = [:]

    // MARK: - Init
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        updateBackgrounds()
        setTitleColorForAllStates()
        applyFonts()
        updateTitleLabelLines()
    }

    // MARK: - Helpers
    private func image(with color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        defer { UIGraphicsEndImageContext() }
        guard let ctx = UIGraphicsGetCurrentContext() else { return UIImage() }
        ctx.setFillColor(color.cgColor)
        ctx.fill(rect)
        return UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
    }

    private func updateBackgrounds() {
        backgroundImages[.normal] = image(with: normalBackgroundColor)
        backgroundImages[.highlighted] = image(with: highlightedBackgroundColor)
        backgroundImages[.selected] = image(with: selectedBackgroundColor)
        backgroundImages[.disabled] = image(with: disabledBackgroundColor)
        applyBackgroundImages()
    }

    private func applyBackgroundImages() {
        for (state, img) in backgroundImages {
            self.setBackgroundImage(img, for: state)
        }
        setNeedsLayout()
    }

    private func setTitleColorForAllStates() {
        self.setTitleColor(normalTitleColor, for: .normal)
        self.setTitleColor(highlightedTitleColor, for: .highlighted)
        self.setTitleColor(selectedTitleColor, for: .selected)
        self.setTitleColor(disabledTitleColor, for: .disabled)
    }

    private func applyFonts() {
        setTitleFontForState(.normal, font: normalTitleFont)
        if let hFont = highlightedTitleFont {
            setTitleFontForState(.highlighted, font: hFont)
        } else {
            setTitleFontForState(.highlighted, font: normalTitleFont)
        }
        if let sFont = selectedTitleFont {
            setTitleFontForState(.selected, font: sFont)
        } else {
            setTitleFontForState(.selected, font: normalTitleFont)
        }
        if let dFont = disabledTitleFont {
            setTitleFontForState(.disabled, font: dFont)
        } else {
            setTitleFontForState(.disabled, font: normalTitleFont)
        }
    }

    private func setTitleFontForState(_ state: UIControl.State, font: UIFont) {
        if let title = self.title(for: state) {
            let attributes: [NSAttributedString.Key: Any] = [.font: font]
            let attributed = NSAttributedString(string: title, attributes: attributes)
            self.setAttributedTitle(attributed, for: state)
        }
        self.titleLabel?.font = font
    }

    private func updateTitleLabelLines() {
        // Простой подход: применяем для normal. При необходимости можно расширить per-state.
        self.titleLabel?.numberOfLines = max(1, normalTitleLines)
    }

    // MARK: - IBDesignable preview
    override public func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        commonInit()
    }
}
