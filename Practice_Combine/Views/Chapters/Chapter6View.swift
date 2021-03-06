//
//  Chapter6View.swift
//  Practice_Combine
//
//  Created by Jinwoo Kim on 10/6/20.
//

import SwiftUI

struct Chapter6View: View {
    @ObservedObject var viewModel: Chapter6ViewModel = .init()
    
    var body: some View {
        List {
            ForEach(viewModel.actions, id: \.title) { chapterAction in
                Button(chapterAction.title, action: chapterAction.action)
            }
        }
        .navigationTitle(Text("Chapter 6"))
        .onAppear(perform: {
            print("***** Chapter 6 *****")
            if viewModel.loadLastAction {
                viewModel.getLastAction()()
            }
        })
    }
}

struct Chapter6View_Previews: PreviewProvider {
    static var previews: some View {
        Chapter6View()
    }
}
