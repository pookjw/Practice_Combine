//
//  Chapter17View.swift
//  Practice_Combine
//
//  Created by Jinwoo Kim on 10/18/20.
//

import SwiftUI

import SwiftUI

struct Chapter17View: View {
    @ObservedObject var viewModel: Chapter17ViewModel = .init()
    
    var body: some View {
        List {
            ForEach(viewModel.actions, id: \.title) { chapterAction in
                Button(chapterAction.title, action: chapterAction.action)
            }
        }
        .navigationTitle(Text("Chapter 17"))
        .onAppear(perform: {
            print("***** Chapter 17 *****")
            if viewModel.loadLastAction {
                viewModel.getLastAction()()
            }
        })
    }
}

struct Chapter17View_Previews: PreviewProvider {
    static var previews: some View {
        Chapter17View()
    }
}
