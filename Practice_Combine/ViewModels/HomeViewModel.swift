//
//  HomeViewModel.swift
//  Practice_Combine
//
//  Created by Jinwoo Kim on 10/6/20.
//

import SwiftUI
import Combine

final class HomeViewModel: ObservableObject {
    let pushToLastChapter: Bool = true
    
    let listOfChapters: [Int] = [2, 3, 4]
    
    func getView(at index: Int) -> some View {
        switch index {
        case 2:
            return AnyView(Chapter2View())
        case 3:
            return AnyView(Chapter3View())
        case 4:
            return AnyView(Chapter4View())
        default:
            return AnyView(EmptyView())
        }
    }
    
    func getLastView() -> some View {
        guard let lastIndex: Int = listOfChapters.last else {
            return AnyView(EmptyView())
        }
        return AnyView(getView(at: lastIndex))
    }
}
