//
//  Chapter11View.swift
//  Practice_Combine
//
//  Created by Jinwoo Kim on 10/14/20.
//

import SwiftUI

struct Chapter11View: View {
    @ObservedObject var viewModel: Chapter11ViewModel = .init()
    
    var body: some View {
        List {
            ForEach(viewModel.actions, id: \.title) { chapterAction in
                Button(chapterAction.title, action: chapterAction.action)
            }
        }
        .navigationTitle(Text("Chapter 11"))
        .onAppear(perform: {
            print("***** Chapter 11 *****")
            if viewModel.loadLastAction {
                viewModel.getLastAction()()
            }
        })
    }
}

struct Chapter11View_Previews: PreviewProvider {
    static var previews: some View {
        Chapter11View()
    }
}
