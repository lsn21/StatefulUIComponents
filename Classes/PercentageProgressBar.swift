//
//  PercentageProgressBar.swift
//  StatefulUIComponents
//
//  Created by Siarhei Lukyanau on 15.07.26.
//

import UIKit

@IBDesignable
final class PercentageProgressBar: UIView {

    private let trackView = UIView()
    private let progressView = UIView()
    private let valueLabel = UILabel()

    @IBInspectable var progress: CGFloat = 0 {
        didSet {
            setNeedsLayout()
            updateAppearance()
        }
    }

    @IBInspectable var barHeight: CGFloat = 12 {
        didSet {
            invalidateIntrinsicContentSize()
            setNeedsLayout()
        }
    }

    @IBInspectable var trackColor: UIColor = UIColor.systemGray5 {
        didSet {
            updateAppearance()
        }
    }

    @IBInspectable var progressColor: UIColor = UIColor.systemGreen {
        didSet {
            updateAppearance()
        }
    }

    @IBInspectable var textColor: UIColor = UIColor.white {
        didSet {
            valueLabel.textColor = textColor
        }
    }

    @IBInspectable var textFontSize: CGFloat = 12 {
        didSet {
            updateFont()
        }
    }

    @IBInspectable var textFont: String = "" {
        didSet {
            updateFont()
        }
    }

    /// Corner radius of the progress bar track (not the view layer).
    /// Named separately because `UIView.cornerRadius` already exists in UIView+IBInspectable.
    @IBInspectable var barCornerRadius: CGFloat = 6 {
        didSet {
            setNeedsLayout()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: max(barHeight, textFontSize + 8))
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        commonInit()
        updateAppearance()
    }

    override func layoutSubviews() {
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

    private var clampedProgress: CGFloat {
        min(max(progress, 0), 100)
    }

    private func commonInit() {
        if trackView.superview == nil {
            addSubview(trackView)
        }

        if progressView.superview == nil {
            addSubview(progressView)
        }

        if valueLabel.superview == nil {
            addSubview(valueLabel)
        }

        isOpaque = false
        clipsToBounds = false

        trackView.isUserInteractionEnabled = false
        progressView.isUserInteractionEnabled = false
        valueLabel.isUserInteractionEnabled = false

        valueLabel.textAlignment = .center
        valueLabel.adjustsFontSizeToFitWidth = true
        valueLabel.minimumScaleFactor = 0.7

        updateFont()
        updateAppearance()
    }

    private func updateAppearance() {
        trackView.backgroundColor = trackColor
        progressView.backgroundColor = progressColor
        valueLabel.textColor = textColor
        valueLabel.text = "\(Int(clampedProgress.rounded()))%"

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
