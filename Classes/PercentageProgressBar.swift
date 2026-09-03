//
//  PercentageProgressBar.swift
//  StatefulUIComponents
//
//  Created by Siarhei Lukyanau on 15.07.26.
//

import UIKit

@IBDesignable
public final class PercentageProgressBar: UIView {

    private let trackView = UIView()
    private let progressView = UIView()
    private let progressGradientLayer = CAGradientLayer()
    private let valueLabel = UILabel()

    @IBInspectable public var progress: CGFloat = 0 {
        didSet {
            setNeedsLayout()
            updateAppearance()
        }
    }

    @IBInspectable public var barHeight: CGFloat = 12 {
        didSet {
            invalidateIntrinsicContentSize()
            setNeedsLayout()
        }
    }

    @IBInspectable public var trackColor: UIColor = UIColor.systemGray5 {
        didSet {
            updateAppearance()
        }
    }

    /// Solid fill color, or the start color of the linear gradient when `progressEndColor` / `progressGradientColors` are set.
    @IBInspectable public var progressColor: UIColor = UIColor.systemGreen {
        didSet {
            updateAppearance()
        }
    }

    /// End color of a two-stop linear gradient. Leave unset for a solid `progressColor` fill.
    @IBInspectable public var progressEndColor: UIColor? {
        didSet {
            updateAppearance()
        }
    }

    /// Gradient start X in unit coordinates (0...1). Default is the leading edge.
    @IBInspectable public var gradientStartX: CGFloat {
        get { progressGradientStartPoint.x }
        set { progressGradientStartPoint.x = newValue }
    }

    /// Gradient start Y in unit coordinates (0...1). Default is vertical center.
    @IBInspectable public var gradientStartY: CGFloat {
        get { progressGradientStartPoint.y }
        set { progressGradientStartPoint.y = newValue }
    }

    /// Gradient end X in unit coordinates (0...1). Default is the trailing edge.
    @IBInspectable public var gradientEndX: CGFloat {
        get { progressGradientEndPoint.x }
        set { progressGradientEndPoint.x = newValue }
    }

    /// Gradient end Y in unit coordinates (0...1). Default is vertical center.
    @IBInspectable public var gradientEndY: CGFloat {
        get { progressGradientEndPoint.y }
        set { progressGradientEndPoint.y = newValue }
    }

    @IBInspectable public var textColor: UIColor = UIColor.white {
        didSet {
            valueLabel.textColor = textColor
        }
    }

    @IBInspectable public var textFontSize: CGFloat = 12 {
        didSet {
            updateFont()
        }
    }

    @IBInspectable public var textFont: String = "" {
        didSet {
            updateFont()
        }
    }

    /// Corner radius of the progress bar track (not the view layer).
    /// Named separately because `UIView.cornerRadius` already exists in UIView+IBInspectable.
    @IBInspectable public var barCornerRadius: CGFloat = 6 {
        didSet {
            setNeedsLayout()
        }
    }

    /// Colors of the progress fill gradient. When non-empty, takes precedence over `progressColor` / `progressEndColor`.
    public var progressGradientColors: [UIColor] = [] {
        didSet {
            updateAppearance()
        }
    }

    /// Start point of the linear gradient in unit coordinates (0...1). Default is leading center.
    public var progressGradientStartPoint: CGPoint = CGPoint(x: 0, y: 0.5) {
        didSet {
            updateAppearance()
        }
    }

    /// End point of the linear gradient in unit coordinates (0...1). Default is trailing center.
    public var progressGradientEndPoint: CGPoint = CGPoint(x: 1, y: 0.5) {
        didSet {
            updateAppearance()
        }
    }

    /// Optional color-stop locations in 0...1. Count must match the resolved gradient colors when used.
    public var progressGradientLocations: [NSNumber]? {
        didSet {
            updateAppearance()
        }
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    public override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: max(barHeight, textFontSize + 8))
    }

    public override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        commonInit()
        updateAppearance()
    }

    public override func layoutSubviews() {
        super.layoutSubviews()

        let resolvedBarHeight = min(max(barHeight, 1), bounds.height)
        let barYPosition = (bounds.height - resolvedBarHeight) / 2
        let trackFrame = CGRect(x: 0, y: barYPosition, width: bounds.width, height: resolvedBarHeight)
        let resolvedCornerRadius = max(0, min(barCornerRadius, resolvedBarHeight / 2))
        let progressWidth = trackFrame.width * (clampedProgress / 100)

        trackView.frame = trackFrame
        progressView.frame = CGRect(
            x: trackFrame.minX,
            y: trackFrame.minY,
            width: progressWidth,
            height: trackFrame.height
        )
        progressGradientLayer.frame = progressView.bounds
        valueLabel.frame = bounds.insetBy(dx: 8, dy: 0)

        trackView.layer.cornerRadius = resolvedCornerRadius
        trackView.layer.masksToBounds = true

        progressView.layer.cornerRadius = resolvedCornerRadius
        progressView.layer.masksToBounds = true

        if progressWidth >= trackFrame.width {
            progressView.layer.maskedCorners = [
                .layerMinXMinYCorner,
                .layerMinXMaxYCorner,
                .layerMaxXMinYCorner,
                .layerMaxXMaxYCorner
            ]
        } else {
            progressView.layer.maskedCorners = [
                .layerMinXMinYCorner,
                .layerMinXMaxYCorner
            ]
        }
    }

    /// Configures a linear gradient fill. Pass a single color for a solid fill.
    public func setProgressGradient(
        colors: [UIColor],
        startPoint: CGPoint = CGPoint(x: 0, y: 0.5),
        endPoint: CGPoint = CGPoint(x: 1, y: 0.5),
        locations: [NSNumber]? = nil
    ) {
        progressGradientStartPoint = startPoint
        progressGradientEndPoint = endPoint
        progressGradientLocations = locations
        progressGradientColors = colors
    }

    private var clampedProgress: CGFloat {
        min(max(progress, 0), 100)
    }

    private var resolvedProgressColors: [UIColor] {
        if !progressGradientColors.isEmpty {
            return progressGradientColors
        }

        if let progressEndColor {
            return [progressColor, progressEndColor]
        }

        return [progressColor]
    }

    private func commonInit() {
        if trackView.superview == nil {
            addSubview(trackView)
        }

        if progressView.superview == nil {
            addSubview(progressView)
        }

        if progressGradientLayer.superlayer == nil {
            progressView.layer.insertSublayer(progressGradientLayer, at: 0)
        }

        if valueLabel.superview == nil {
            addSubview(valueLabel)
        }

        isOpaque = false
        clipsToBounds = false

        trackView.isUserInteractionEnabled = false
        progressView.isUserInteractionEnabled = false
        progressView.backgroundColor = .clear
        valueLabel.isUserInteractionEnabled = false

        progressGradientLayer.type = .axial

        valueLabel.textAlignment = .center
        valueLabel.adjustsFontSizeToFitWidth = true
        valueLabel.minimumScaleFactor = 0.7

        updateFont()
        updateAppearance()
    }

    private func updateAppearance() {
        trackView.backgroundColor = trackColor
        valueLabel.textColor = textColor
        valueLabel.text = "\(Int(clampedProgress.rounded()))%"

        let colors = resolvedProgressColors
        progressGradientLayer.colors = colors.map { $0.cgColor }
        progressGradientLayer.startPoint = progressGradientStartPoint
        progressGradientLayer.endPoint = progressGradientEndPoint
        progressGradientLayer.locations = progressGradientLocations

        setNeedsLayout()
    }

    private func updateFont() {
        let resolvedFontSize = max(textFontSize, 1)

        if !textFont.isEmpty, let customFont = UIFont(name: textFont, size: resolvedFontSize) {
            valueLabel.font = customFont
        } else {
            valueLabel.font = UIFont.systemFont(ofSize: resolvedFontSize, weight: .semibold)
        }

        invalidateIntrinsicContentSize()
    }
}
