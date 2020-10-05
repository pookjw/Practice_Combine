//
//  Chapter2View.swift
//  Practice_Combine
//
//  Created by Jinwoo Kim on 10/6/20.
//

import SwiftUI

struct Chapter2View: View {
    @ObservedObject var viewModel: Chapter2ViewModel = .init()
    
    var body: some View {
        List {
            ForEach(viewModel.actions.reversed(), id: \.title) { chapterAction in
                Button(chapterAction.title, action: chapterAction.action)
            }
        }
        .navigationTitle(Text("Chapter 2"))
        .onAppear(perform: {
            if viewModel.loadLastAction {
                viewModel.getLastAction()()
            }
        })
    }
}

struct Chapter2View_Previews: PreviewProvider {
    static var previews: some View {
        Chapter2View()
    }
}
