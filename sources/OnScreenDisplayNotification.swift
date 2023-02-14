//
// OnScreenDisplayNotification.swift
// noTunez
//
// (c) 2023 Andrew Sichevoi
//

import Foundation
import Cocoa

func makeOSDNotification(screen: NSScreen = NSScreen.main!) -> OSDNotification {
    let overlay = OSDAppIcon(frame: screen.frame)
    return  OSDNotification(overlay: overlay)
}

class OSDNotification {
    let window: NSWindow

    init(overlay: NSView) {
        self.window = NSWindow(contentRect: NSScreen.main!.frame, styleMask: .borderless, backing: .buffered, defer: false)
        window.backgroundColor = .clear
        window.isOpaque = false
        window.ignoresMouseEvents = true
        window.level = .screenSaver
        window.canHide = false
        window.alphaValue = 0.5

        window.contentView = overlay
    }

    func show() -> Void {
        window.makeKeyAndOrderFront(nil)
    }

    func close() -> Void {
        window.orderOut(nil)
    }
}

class OSDAppIcon: NSView {
    let icon: NSImageView
    static let iconSize = 100

    override init(frame: NSRect) {
        self.icon = NSImageView(image: NSImage(imageLiteralResourceName: "AppIcon"))

        super.init(frame: frame)
        addSubview(self.icon)

        setupConstraints()
        self.icon.image = Self.grayscale(image: icon.image!)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    static func grayscale(image: NSImage) -> NSImage {
        let monochromeFilter = CIFilter(name: "CIColorMonochrome")!
        monochromeFilter.setValue(CIColor(red: 0.75, green: 0.75, blue: 0.75), forKey: "inputColor")
        monochromeFilter.setValue(1.0, forKey: "inputIntensity")
        let ciImage = CIImage(data: image.tiffRepresentation!)!
        monochromeFilter.setValue(ciImage, forKey: "inputImage")
        let outputImage = monochromeFilter.outputImage!
        let outputRep = NSCIImageRep(ciImage: outputImage)

        let outputNSImage = NSImage(size: NSSize(width: iconSize, height: iconSize))
        outputNSImage.addRepresentation(outputRep)

        return outputNSImage
    }

    func setupConstraints() -> Void {
        icon.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            icon.centerXAnchor.constraint(equalTo: centerXAnchor),
            icon.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -CGFloat(Self.iconSize)),
        ])
    }
}
