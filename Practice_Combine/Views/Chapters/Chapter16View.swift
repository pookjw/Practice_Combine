//
//  Chapter16View.swift
//  Practice_Combine
//
//  Created by Jinwoo Kim on 10/18/20.
//

import SwiftUI

struct Chapter16View: View {
    @ObservedObject var viewModel: Chapter16ViewModel = .init()
    
    var body: some View {
        List {
            ForEach(viewModel.actions, id: \.title) { chapterAction in
                Button(chapterAction.title, action: chapterAction.action)
            }
        }
        .navigationTitle(Text("Chapter 16"))
        .onAppear(perform: {
            print("***** Chapter 16 *****")
            if viewModel.loadLastAction {
                viewModel.getLastAction()()
            }
        })
    }
}

struct Chapter16View_Previews: PreviewProvider {
    static var previews: some View {
        Chapter16View()
    }
}

