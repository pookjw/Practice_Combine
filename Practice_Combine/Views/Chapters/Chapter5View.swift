//
//  Chapter5View.swift
//  Practice_Combine
//
//  Created by Jinwoo Kim on 10/6/20.
//

import SwiftUI

struct Chapter5View: View {
    @ObservedObject var viewModel: Chapter5ViewModel = .init()
    
    var body: some View {
        List {
            ForEach(viewModel.actions, id: \.title) { chapterAction in
                Button(chapterAction.title, action: chapterAction.action)
            }
        }
        .navigationTitle(Text("Chapter 5"))
        .onAppear(perform: {
            print("***** Chapter 5 *****")
            if viewModel.loadLastAction {
                viewModel.getLastAction()()
            }
        })
    }
}

struct Chapter5View_Previews: PreviewProvider {
    static var previews: some View {
        Chapter5View()
    }
}
