//
//  StatefulUIButton.swift
//  Loans-202
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
    @IBInspectable public var normalFont: UIFont? {
        didSet { updateFont() }
    }
    
    @IBInspectable public var highlightedFont: UIFont? {
        didSet { updateFont() }
    }
    
    @IBInspectable public var selectedFont: UIFont? {
        didSet { updateFont() }
    }
    
    @IBInspectable public var disabledFont: UIFont? {
        didSet { updateFont() }
    }
    
    // MARK: - Number of lines
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
        // Добавляем наблюдение за изменениями состояния
        addTarget(self, action: #selector(stateChanged), for: .touchUpInside)
    }
    
    // MARK: - State change handling
    @objc private func stateChanged() {
        updateBackgroundColor()
        updateTitleColor()
        updateFont()
        updateNumberOfLines()
    }
    
    public override var isHighlighted: Bool {
        didSet {
            updateBackgroundColor()
            updateTitleColor()
            updateFont()
            updateNumberOfLines()
        }
    }
    
    public override var isSelected: Bool {
        didSet {
            updateBackgroundColor()
            updateTitleColor()
            updateFont()
            updateNumberOfLines()
        }
    }
    
    public override var isEnabled: Bool {
        didSet {
            updateBackgroundColor()
            updateTitleColor()
            updateFont()
            updateNumberOfLines()
        }
    }
    
    // MARK: - Update methods
    private func updateBackgroundColor() {
        backgroundColor = backgroundColor(for: state)
    }
    
    private func updateTitleColor() {
        setTitleColor(titleColor(for: state), for: state)
    }
    
    private func updateFont() {
        titleLabel?.font = font(for: state)
    }
    
    private func updateNumberOfLines() {
        titleLabel?.numberOfLines = numberOfLines(for: state)
    }
    
    // MARK: - Helper methods
    private func backgroundColor(for state: UIControl.State) -> UIColor? {
        switch state {
        case .highlighted: return highlightedBackgroundColor ?? normalBackgroundColor
        case .selected: return selectedBackgroundColor ?? normalBackgroundColor
        case .disabled: return disabledBackgroundColor ?? normalBackgroundColor
        default: return normalBackgroundColor
        }
    }
    
    private func titleColor(for state: UIControl.State) -> UIColor? {
        switch state {
        case .highlighted: return highlightedTitleColor ?? normalTitleColor
        case .selected: return selectedTitleColor ?? normalTitleColor
        case .disabled: return disabledTitleColor ?? normalTitleColor
        default: return normalTitleColor
        }
    }
    
    private func font(for state: UIControl.State) -> UIFont? {
        switch state {
        case .highlighted: return highlightedFont ?? normalFont
        case .selected: return selectedFont ?? normalFont
        case .disabled: return disabledFont ?? normalFont
        default: return normalFont
        }
    }
    
    private func numberOfLines(for state: UIControl.State) -> Int {
        switch state {
        case .highlighted: return highlightedNumberOfLines
        case .selected: return selectedNumberOfLines
        case .disabled: return disabledNumberOfLines
        default: return normalNumberOfLines
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
}
