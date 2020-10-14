//
//  Chapter12View.swift
//  Practice_Combine
//
//  Created by Jinwoo Kim on 10/14/20.
//

import SwiftUI

struct Chapter12View: View {
    @ObservedObject var viewModel: Chapter12ViewModel = .init()
    
    var body: some View {
        List {
            ForEach(viewModel.actions, id: \.title) { chapterAction in
                Button(chapterAction.title, action: chapterAction.action)
            }
        }
        .navigationTitle(Text("Chapter 12"))
        .onAppear(perform: {
            print("***** Chapter 12 *****")
            if viewModel.loadLastAction {
                viewModel.getLastAction()()
            }
        })
    }
}

struct Chapter12View_Previews: PreviewProvider {
    static var previews: some View {
        Chapter12View()
    }
}
