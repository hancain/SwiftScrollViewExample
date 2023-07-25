//
//  ContentView.swift
//  ScrollViewTest
//
//  Created by Cain, Hannah (H.N.) on 7/13/23.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: ContentViewModel
    
    init(viewModel: ContentViewModel = ContentViewModel()) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        RefreshableScrollView(loadingState: $viewModel.state) {
            screenContent
        } onRefresh: {
            viewModel.fakeLoad()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                viewModel.refreshText()
            }
        }
    }
    
    
    var screenContent : some View {
        VStack {
            Spacer()
            
            Text("Refresh me")
            
            Text("Refresh Count: \(viewModel.refreshCount)")
        }
        .padding(.top, 32)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
