//
//  LoadingState.swift
//  ScrollViewTest
//
//  Created by Cain, Hannah (H.N.) on 7/20/23.
//

import Foundation
import SwiftUI

enum LoadingState: Equatable {
    case idle
    case loading
    case loaded
    case failed(String)
}
