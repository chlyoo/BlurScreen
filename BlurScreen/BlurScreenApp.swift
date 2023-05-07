//
//  BlurScreenApp.swift
//  BlurScreen
//
//  Created by Peter Lyoo on 2023/05/05.
//

import SwiftUI

@main
struct BlurScreenApp: App {
    var body: some Scene {
        WindowGroup {
            ScreenCaptureView()
        }
    }
}
