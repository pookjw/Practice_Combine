//
//  Chapter3View.swift
//  Practice_Combine
//
//  Created by Jinwoo Kim on 10/6/20.
//

import SwiftUI

struct Chapter3View: View {
    @ObservedObject var viewModel: Chapter3ViewModel = .init()
    
    var body: some View {
        List {
            ForEach(viewModel.actions, id: \.title) { chapterAction in
                Button(chapterAction.title, action: chapterAction.action)
            }
        }
        .navigationTitle(Text("Chapter 3"))
        .onAppear(perform: {
            print("***** Chapter 3 *****")
            if viewModel.loadLastAction {
                viewModel.getLastAction()()
            }
        })
    }
}

struct Chapter3View_Previews: PreviewProvider {
    static var previews: some View {
        Chapter3View()
    }
}
