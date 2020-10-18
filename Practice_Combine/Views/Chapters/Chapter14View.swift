//
//  Chapter14View.swift
//  Practice_Combine
//
//  Created by Jinwoo Kim on 10/18/20.
//

import SwiftUI

struct Chapter14View: View {
    @ObservedObject var viewModel: Chapter14ViewModel = .init()
    
    var body: some View {
        List {
            ForEach(viewModel.actions, id: \.title) { chapterAction in
                Button(chapterAction.title, action: chapterAction.action)
            }
        }
        .navigationTitle(Text("Chapter 14"))
        .onAppear(perform: {
            print("***** Chapter 14 *****")
            if viewModel.loadLastAction {
                viewModel.getLastAction()()
            }
        })
    }
}

struct Chapter14View_Previews: PreviewProvider {
    static var previews: some View {
        Chapter14View()
    }
}
