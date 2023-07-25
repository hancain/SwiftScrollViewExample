//
//  RefreshableScrollView.swift
//  ScrollViewTest
//
//  Created by Cain, Hannah (H.N.) on 7/13/23.
//

import SwiftUI

struct RefreshableScrollView<Content: View>: View {
    let onStartThreshold: CGFloat = 90
    let iconSize: CGFloat = 25
    let offsetY: CGFloat = -10
    
    var iconOffset: CGFloat {
        -(iconSize + -offsetY)
    }
    
    @Binding var loadingState: LoadingState
    
    @State var refreshState = Refresh(started: false, released: false)
    @State var dynamicPadding: CGFloat = 0
    
    var content: Content
    var onRefresh: () -> Void
    
    init(loadingState: Binding<LoadingState>, @ViewBuilder content: @escaping () -> Content, onRefresh: @escaping () -> Void) {
        self.content = content()
        self.onRefresh = onRefresh
        self._loadingState = loadingState
    }
    
    var body: some View {
        ScrollView {
            VStack {
                ZStack(alignment: .top) {
                    VStack {
                        if refreshState.initial {
                            if !refreshState.started {
                                if !refreshState.released {
                                    withAnimation(.spring()) {
                                        Image(systemName: "arrow.down")
                                            .scaledToFit()
                                            .foregroundColor(Color.gray)
                                            .rotationEffect(.init(degrees: dynamicPadding * 2))
                                            .frame(width: iconSize, height: iconSize,
                                                   alignment: .top)
                                            .opacity(refreshState.initial ? 1.0 : 0.0)
                                            .padding(.bottom, 5)
                                    }
                                }
                            } else {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: Color.gray))
                                    .transition(.opacity)
                                    .frame(width: iconSize, height: iconSize,
                                           alignment: .top)
                                    .padding(.bottom, 5)
                                    .padding(.top, 15)
                            }
                        }
                    } // : VStack
                    .offset(y: iconOffset - 5)
                    .unredacted()
                    
                    content
                } // : ZStack
                .offset(y: dynamicPadding)
            } // : VStack
            .background(GeometryReader { reader -> AnyView in
                DispatchQueue.main.async {
                    refreshState.offset = reader.frame(in: .named("RefreshableScrollView")).minY
                    
                    if !refreshState.started {
                        withAnimation(.spring()) {
                            if refreshState.offset >= 0 {
                                dynamicPadding = refreshState.offset
                            }
                        }
                    } else {
                        withAnimation(.spring()) {
                            dynamicPadding = onStartThreshold / 2
                        }
                    }
                    
                    if dynamicPadding > 0 {
                        refreshState.initial = true
                    } else {
                        refreshState.initial = false
                    }
                    
                    // Once we get past the startThreshold, let's begin the pull to refresh
                    if refreshState.offset > onStartThreshold && !refreshState.started {
                        withAnimation(.spring()) {
                            refreshState.started = true
                            dynamicPadding = onStartThreshold
                        }
                    }
                    
                    // doesn't pull data until user releases past the startThreshold
                    if refreshState.offset == 0 && refreshState.started && !refreshState.released {
                        withAnimation(.spring()) {
                            refreshState.released = true
                        }
                        // pull data
                        self.onRefresh()
                    }
                    
                }
                return AnyView(EmptyView())
            })
        } // : ScrollView
        .coordinateSpace(name: "RefreshableScrollView")
        .onChange(of: self.loadingState) { newValue in
            if newValue == .loaded {
                onResetRefreshState()
            }
        }
    }
    
    func onResetRefreshState() {
        withAnimation(Animation.spring().speed(1.25)) {
            refreshState.started = false
            // wait 0.5 seconds to reset released state to give desired visual (hide arrow)
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) {_ in
                refreshState.released = false
            }
        }
    }
}

struct Refresh {
    var startOffSet: CGFloat = 0
    var offset: CGFloat = 0
    var started: Bool
    var initial: Bool = false
    var released: Bool
}
