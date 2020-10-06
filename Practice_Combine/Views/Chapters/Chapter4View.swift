//
//  Chapter4View.swift
//  Practice_Combine
//
//  Created by Jinwoo Kim on 10/6/20.
//

import SwiftUI

struct Chapter4View: View {
    @ObservedObject var viewModel: Chapter4ViewModel = .init()
    
    var body: some View {
        List {
            ForEach(viewModel.actions.reversed(), id: \.title) { chapterAction in
                Button(chapterAction.title, action: chapterAction.action)
            }
        }
        .navigationTitle(Text("Chapter 4"))
        .onAppear(perform: {
            print("***** Chapter 4 *****")
            if viewModel.loadLastAction {
                viewModel.getLastAction()()
            }
        })
    }
}

struct Chapter4View_Previews: PreviewProvider {
    static var previews: some View {
        Chapter4View()
    }
}
