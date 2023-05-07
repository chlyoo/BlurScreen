//
//  ScreenCaptureView.swift
//  BlurScreen
//Z
//  Created by Peter Lyoo on 2023/05/05.
//

import SwiftUI

struct ScreenCaptureView: View {
    @State private var selectedScreenID: CGDirectDisplayID = CGMainDisplayID()
    @State private var image: NSImage?
    @State private var cropRect: CGRect = CGRect(x: 130, y: 100, width: 2560-130*2, height: 1340-100)
    @GestureState private var dragOffset = CGSize.zero
    @State private var isLocked = false // added

    var body: some View {
        VStack {
            if let image = image {
                GeometryReader { geometry in
                    let aspectRatio = CGFloat(image.size.width / image.size.height)
                    let height = min(geometry.size.height, geometry.size.width / aspectRatio)
                    let width = height * aspectRatio
                    Image(nsImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: width, height: height)
                        .gesture(isLocked ? nil : DragGesture(minimumDistance: 0, coordinateSpace: .local) // modified
                            .updating($dragOffset, body: { (value, state, _) in
                                state = value.translation
                            })
                            .onChanged({ value in
                                let window = NSApplication.shared.windows.first
                                let windowFrame = window?.frame ?? .zero
                                let imageSize = image.size
                                let xscale = imageSize.width / windowFrame.width
                                let yscale = imageSize.height / windowFrame.height
                                var startX = value.startLocation.x
                                var startY = windowFrame.height - value.startLocation.y
                                var currentX = value.location.x
                                var currentY = windowFrame.height - value.location.y
                                var posX = min(startX, currentX)
                                var posY = min(startY, currentY)
                                var posXz = max(startX, currentX)
                                var posYz = max(startY, currentY)
                                cropRect = CGRect(x: posX * xscale, y: posY * yscale, width: abs(posXz - posX) * xscale, height: abs(posYz - posY) * yscale)
                            })
                        )
                }
                .padding()
            } else {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundColor(.accentColor)
                    .padding()
            }
            
            Picker(selection: $selectedScreenID, label: Text("Select screen:")) {
                ForEach(displayIDs(), id: \.self) { id in
                    Text("Display \(id)")
                        .tag(id)
                }
            } .padding()
            
            Button(action: { isLocked.toggle() }) { // added
                Text(isLocked ? "Unlock" : "Lock Area")
                    .padding(.top)
            }
        }
        .onAppear {
            selectedScreenID = CGMainDisplayID()
            captureScreenTimer()
        }
        .onChange(of: selectedScreenID, perform: { _ in
            captureScreen()
        })
    }
    
    func captureScreenTimer() {
        Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { _ in
            captureScreen()
        }
    }
    
    func captureScreen() {
        let screenFrame = CGDisplayBounds(selectedScreenID)
        let rectFrame = CGRect(x: 0, y: 0, width: screenFrame.width, height: screenFrame.height)
        
        guard let imageRef = CGDisplayCreateImage(selectedScreenID, rect: rectFrame) else {
            return
        }
        
        // Convert the CGImage to an NSImage
        let size = NSSize(width: imageRef.width, height: imageRef.height)
        let nsImage = NSImage(cgImage: imageRef, size: size)
        setImage(image: gaussianBlur(image: nsImage))
    }

    
    private func setImage(image: NSImage) {
        self.image = image
    }
    
    func gaussianBlur(image: NSImage, radius: Int = 5) -> NSImage {
        // crop part of image and apply gaussian blur and merge with original image
        
        let ciImage = CIImage(data: image.tiffRepresentation!)!
        let cropFilter = CIFilter(name: "CICrop")!
        cropFilter.setValue(ciImage, forKey: kCIInputImageKey)
        cropFilter.setValue(CIVector(cgRect: cropRect), forKey: "inputRectangle")
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
    
    private func displayIDs() -> [CGDirectDisplayID] {
        var onlineDisplays: UInt32 = 0
        var onlineDisplayList: UnsafeMutablePointer<CGDirectDisplayID>?
        CGGetOnlineDisplayList(0, nil, &onlineDisplays)
        onlineDisplayList = UnsafeMutablePointer<CGDirectDisplayID>.allocate(capacity: Int(onlineDisplays))
        CGGetOnlineDisplayList(onlineDisplays, onlineDisplayList, &onlineDisplays)
        let ids = Array(UnsafeMutableBufferPointer(start: onlineDisplayList, count: Int(onlineDisplays)))
        onlineDisplayList?.deallocate()
        return ids
    }
    

}

struct ScreenCaptureView_Previews: PreviewProvider {
    static var previews: some View {
        ScreenCaptureView()
    }
}

