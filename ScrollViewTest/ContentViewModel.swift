//
//  SwiftUIView.swift
//  ScrollViewTest
//
//  Created by Cain, Hannah (H.N.) on 7/24/23.
//

import Foundation

class ContentViewModel: ObservableObject {
    @Published var state = LoadingState.idle
    @Published var refreshCount: Int = 0
    
    func refreshText() {
        state = .loaded
        
        if state == .loaded {
            refreshCount += 1
        }
    }
    
    func fakeLoad() {
        state = .loading
    }
}
