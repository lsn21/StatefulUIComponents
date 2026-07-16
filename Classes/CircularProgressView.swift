//
//  CircularProgressView.swift
//  StatefulUIComponents
//
//  Created by Siarhei Lukyanau on 15.07.26.
//

import UIKit

/// Ring progress indicator with a centered percentage label.
/// Configure thickness, track/progress colors, text color and font via Interface Builder.
@IBDesignable
public class CircularProgressView: UIView {

    // MARK: - IBInspectable

    /// Progress value from 0 to 100.
    @IBInspectable public var progress: CGFloat = 0 {
        didSet { updateProgress() }
    }

    /// Ring line thickness.
    @IBInspectable public var lineWidth: CGFloat = 10 {
        didSet {
            trackLayer.lineWidth = lineWidth
            progressLayer.lineWidth = lineWidth
            setNeedsLayout()
        }
    }

    /// Background (track) ring color.
    @IBInspectable public var trackColor: UIColor = UIColor.systemGray5 {
        didSet { trackLayer.strokeColor = trackColor.cgColor }
    }

    /// Filled (progress) ring color.
    @IBInspectable public var progressColor: UIColor = UIColor.systemGreen {
        didSet { progressLayer.strokeColor = progressColor.cgColor }
    }

    /// Percentage label text color.
    @IBInspectable public var textColor: UIColor = UIColor.label {
        didSet { valueLabel.textColor = textColor }
    }

    /// Percentage label font size.
    @IBInspectable public var textFontSize: CGFloat = 20 {
        didSet { updateFont() }
    }

    /// Percentage label font name (e.g. "Sen-Bold"). Empty = system semibold.
    @IBInspectable public var textFontName: String = "" {
        didSet { updateFont() }
    }

    /// Shows "%" after the number when true.
    @IBInspectable public var showsPercentSymbol: Bool = true {
        didSet { updateProgress() }
    }

    // MARK: - Private

    private let trackLayer = CAShapeLayer()
    private let progressLayer = CAShapeLayer()
    private let valueLabel = UILabel()

    private var clampedProgress: CGFloat {
        min(max(progress, 0), 100)
    }

    // MARK: - Init

    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    public override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        commonInit()
        layoutIfNeeded()
        updateProgress()
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        updateRingPaths()
    }

    // MARK: - Setup

    private func commonInit() {
        isOpaque = false
        backgroundColor = .clear

        configureLayer(trackLayer, color: trackColor, end: 1)
        configureLayer(progressLayer, color: progressColor, end: 0)

        if trackLayer.superlayer == nil {
            layer.addSublayer(trackLayer)
        }
        if progressLayer.superlayer == nil {
            layer.addSublayer(progressLayer)
        }

        if valueLabel.superview == nil {
            addSubview(valueLabel)
        }

        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.textAlignment = .center
        valueLabel.adjustsFontSizeToFitWidth = true
        valueLabel.minimumScaleFactor = 0.5
        valueLabel.numberOfLines = 1
        valueLabel.isUserInteractionEnabled = false

        NSLayoutConstraint.activate([
            valueLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            valueLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            valueLabel.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 8),
            valueLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -8)
        ])

        updateFont()
        updateProgress()
    }

    private func configureLayer(_ shapeLayer: CAShapeLayer, color: UIColor, end: CGFloat) {
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = color.cgColor
        shapeLayer.lineWidth = lineWidth
        shapeLayer.lineCap = .round
        shapeLayer.strokeEnd = end
    }

    private func updateRingPaths() {
        let diameter = min(bounds.width, bounds.height) - lineWidth
        guard diameter > 0 else { return }

        let rect = CGRect(
            x: (bounds.width - diameter) / 2,
            y: (bounds.height - diameter) / 2,
            width: diameter,
            height: diameter
        )

        // Start from top (-90°)
        let path = UIBezierPath(
            arcCenter: CGPoint(x: rect.midX, y: rect.midY),
            radius: diameter / 2,
            startAngle: -.pi / 2,
            endAngle: .pi * 1.5,
            clockwise: true
        )

        trackLayer.path = path.cgPath
        progressLayer.path = path.cgPath
        trackLayer.frame = bounds
        progressLayer.frame = bounds
    }

    private func updateProgress() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        progressLayer.strokeEnd = clampedProgress / 100
        CATransaction.commit()

        let valueText = "\(Int(clampedProgress.rounded()))"
        valueLabel.text = showsPercentSymbol ? "\(valueText)%" : valueText
    }

    private func updateFont() {
        let size = max(textFontSize, 1)
        if !textFontName.isEmpty, let customFont = UIFont(name: textFontName, size: size) {
            valueLabel.font = customFont
        } else {
            valueLabel.font = UIFont.systemFont(ofSize: size, weight: .semibold)
        }
    }

    // MARK: - Public API

    /// Animates progress to the given value (0...100).
    public func setProgress(_ value: CGFloat, animated: Bool, duration: TimeInterval = 0.35) {
        let fromValue = progressLayer.presentation()?.strokeEnd ?? progressLayer.strokeEnd
        progress = value
        guard animated else { return }

        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = fromValue
        animation.toValue = clampedProgress / 100
        animation.duration = duration
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        progressLayer.add(animation, forKey: "progress")
        progressLayer.strokeEnd = clampedProgress / 100
    }
}
