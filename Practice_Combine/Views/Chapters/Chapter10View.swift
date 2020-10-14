//
//  Chapter10View.swift
//  Practice_Combine
//
//  Created by Jinwoo Kim on 10/14/20.
//

import SwiftUI

struct Chapter10View: View {
    @ObservedObject var viewModel: Chapter10ViewModel = .init()
    
    var body: some View {
        List {
            ForEach(viewModel.actions, id: \.title) { chapterAction in
                Button(chapterAction.title, action: chapterAction.action)
            }
        }
        .navigationTitle(Text("Chapter 10"))
        .onAppear(perform: {
            print("***** Chapter 10 *****")
            if viewModel.loadLastAction {
                viewModel.getLastAction()()
            }
        })
    }
}

struct Chapter10View_Previews: PreviewProvider {
    static var previews: some View {
        Chapter10View()
    }
}
