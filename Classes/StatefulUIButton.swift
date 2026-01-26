//
//  StatefulUIButton.swift
//  StatefulUIComponents
//
//  Created by Siarhei Lukyanau on 22.12.25.
//

import UIKit

@IBDesignable
public class StatefulUIButton: UIButton {
    
    // MARK: - State-specific properties
    @IBInspectable public var normalBackgroundColor: UIColor? {
        didSet { updateBackgroundColor() }
    }
    
    @IBInspectable public var highlightedBackgroundColor: UIColor? {
        didSet { updateBackgroundColor() }
    }
    
    @IBInspectable public var selectedBackgroundColor: UIColor? {
        didSet { updateBackgroundColor() }
    }
    
    @IBInspectable public var disabledBackgroundColor: UIColor? {
        didSet { updateBackgroundColor() }
    }
    
    @IBInspectable public var normalTitleColor: UIColor? {
        didSet { updateTitleColor() }
    }
    
    @IBInspectable public var highlightedTitleColor: UIColor? {
        didSet { updateTitleColor() }
    }
    
    @IBInspectable public var selectedTitleColor: UIColor? {
        didSet { updateTitleColor() }
    }
    
    @IBInspectable public var disabledTitleColor: UIColor? {
        didSet { updateTitleColor() }
    }
    
    // MARK: - Font properties
    public var normalFont: UIFont? {
        didSet { updateFont() }
    }
    
    public var highlightedFont: UIFont? {
        didSet { updateFont() }
    }
    
    public var selectedFont: UIFont? {
        didSet { updateFont() }
    }
    
    public var disabledFont: UIFont? {
        didSet { updateFont() }
    }
    
    // MARK: - Number of lines (IB compatible)
    @IBInspectable public var normalNumberOfLines: Int = 1 {
        didSet { updateNumberOfLines() }
    }
    
    @IBInspectable public var highlightedNumberOfLines: Int = 1 {
        didSet { updateNumberOfLines() }
    }
    
    @IBInspectable public var selectedNumberOfLines: Int = 1 {
        didSet { updateNumberOfLines() }
    }
    
    @IBInspectable public var disabledNumberOfLines: Int = 1 {
        didSet { updateNumberOfLines() }
    }
    
    // MARK: - Private Properties
    private var originalBackgroundColor: UIColor?
    
    // MARK: - Initialization
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        originalBackgroundColor = backgroundColor
        setupObservers()
    }
    
    // MARK: - Override Methods
    override public func titleColor(for state: UIControl.State) -> UIColor? {
        switch state {
        case .normal:
            return normalTitleColor ?? super.titleColor(for: .normal)
        case .highlighted:
            return highlightedTitleColor ?? normalTitleColor ?? super.titleColor(for: .highlighted)
        case .selected:
            return selectedTitleColor ?? normalTitleColor ?? super.titleColor(for: .selected)
        case .disabled:
            return disabledTitleColor ?? super.titleColor(for: .disabled)
        default:
            return super.titleColor(for: state)
        }
    }
    
    override public var isHighlighted: Bool {
        didSet {
            updateAppearance()
        }
    }
    
    override public var isSelected: Bool {
        didSet {
            updateAppearance()
        }
    }
    
    override public var isEnabled: Bool {
        didSet {
            updateAppearance()
        }
    }
    
    // MARK: - Private Methods
    private func setupObservers() {
        addTarget(self, action: #selector(updateAppearance), for: .touchDown)
        addTarget(self, action: #selector(updateAppearance), for: .touchUpInside)
        addTarget(self, action: #selector(updateAppearance), for: .touchUpOutside)
    }
    
    @objc private func updateAppearance() {
        UIView.animate(withDuration: 0.2) {
            self.updateBackgroundColor()
            self.updateTitleColor()
            self.updateFont()
            self.updateNumberOfLines()
        }
    }
    
    private func updateBackgroundColor() {
        switch state {
        case .normal:
            backgroundColor = normalBackgroundColor ?? originalBackgroundColor
        case .highlighted:
            backgroundColor = highlightedBackgroundColor ?? normalBackgroundColor ?? originalBackgroundColor
        case .selected:
            backgroundColor = selectedBackgroundColor ?? normalBackgroundColor ?? originalBackgroundColor
        case .disabled:
            backgroundColor = disabledBackgroundColor ?? originalBackgroundColor?.withAlphaComponent(0.5)
        default:
            backgroundColor = originalBackgroundColor
        }
    }
    
    private func updateTitleColor() {
        setTitleColor(titleColor(for: state), for: state)
    }
    
    private func updateFont() {
        switch state {
        case .normal:
            titleLabel?.font = normalFont
        case .highlighted:
            titleLabel?.font = highlightedFont ?? normalFont
        case .selected:
            titleLabel?.font = selectedFont ?? normalFont
        case .disabled:
            titleLabel?.font = disabledFont ?? normalFont
        default:
            break
        }
    }
    
    private func updateNumberOfLines() {
        switch state {
        case .normal:
            titleLabel?.numberOfLines = normalNumberOfLines
        case .highlighted:
            titleLabel?.numberOfLines = highlightedNumberOfLines
        case .selected:
            titleLabel?.numberOfLines = selectedNumberOfLines
        case .disabled:
            titleLabel?.numberOfLines = disabledNumberOfLines
        default:
            titleLabel?.numberOfLines = normalNumberOfLines
        }
    }
    
    // MARK: - Interface Builder support
    public override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        updateBackgroundColor()
        updateTitleColor()
        updateFont()
        updateNumberOfLines()
    }
    
    // MARK: - Deinitialization
    deinit {
        removeTarget(self, action: nil, for: .allEvents)
    }
}
