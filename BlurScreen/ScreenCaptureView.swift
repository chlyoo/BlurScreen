//
//  ScreenCaptureView.swift
//  BlurScreen
//
//  Created by Peter Lyoo on 2023/05/05.
//

import SwiftUI

struct ScreenCaptureView: View {
    @State private var image: NSImage?
    
    static let monitors = NSScreen.screens.map { $0.localizedName }
    @State private var selectedMonitor = 0


    var body: some View {
        VStack {
            if let image = image {
                Image(nsImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding()
            } else {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundColor(.accentColor)
                    .padding()
            }
            // add button to switch from one monitor to another
            // switch monitor when picked
            Picker("Monitor", selection: $selectedMonitor) {
                ForEach(0 ..< Self.monitors.count) {
                    Text(Self.monitors[$0])
                }
            }
        }.onAppear {
            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                captureScreen()
            }
        }
    }

    func captureScreen() {
        guard let selectedScreen = NSScreen.screens[safe: selectedMonitor],
              let selectedScreenNumber = selectedScreen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? CGDirectDisplayID,
              let imageRef = CGDisplayCreateImage(selectedScreenNumber, rect: selectedScreen.frame)
        else {
            return
        }
        
        // Convert the CGImage to an NSImage
        let size = NSSize(width: imageRef.width, height: imageRef.height)
        let nsImage = NSImage(cgImage: imageRef, size: size)
        setImage(image: gaussianBlur(image: nsImage))
    }

    
    func gaussianBlur(image: NSImage, radius: Int = 5) -> NSImage {
        // crop part of image and apply gaussian blur and merge with original image
        
        let ciImage = CIImage(data: image.tiffRepresentation!)!
        let cropFilter = CIFilter(name: "CICrop")!
        cropFilter.setValue(ciImage, forKey: kCIInputImageKey)
        cropFilter.setValue(CIVector(cgRect: CGRect(x: 0, y: 0, width: 100, height: 100)), forKey: "inputRectangle")
        let croppedImage = cropFilter.outputImage!
        let gaussianBlurFilter = CIFilter(name: "CIGaussianBlur")!
        gaussianBlurFilter.setValue(croppedImage, forKey: kCIInputImageKey)
        gaussianBlurFilter.setValue(radius, forKey: kCIInputRadiusKey)
        let outputImage = gaussianBlurFilter.outputImage!
        let finalImage = outputImage.composited(over:ciImage)
        let rep = NSCIImageRep(ciImage: finalImage)
        let nsImage = NSImage(size: rep.size)
        nsImage.addRepresentation(rep)
        return nsImage
    }
    
    private func setImage(image: NSImage) {
        self.image = image
    }
}

extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

struct ScreenCaptureView_Previews: PreviewProvider {
    static var previews: some View {
        ScreenCaptureView()
    }
}
