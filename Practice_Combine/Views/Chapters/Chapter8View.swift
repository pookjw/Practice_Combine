//
//  Chapter8View.swift
//  Practice_Combine
//
//  Created by Jinwoo Kim on 10/10/20.
//

import SwiftUI

struct Chapter8View: View {
    @ObservedObject var viewModel: Chapter8ViewModel = .init()
    
    var body: some View {
        List {
            ForEach(viewModel.actions, id: \.title) { chapterAction in
                Button(chapterAction.title, action: chapterAction.action)
            }
        }
        .navigationTitle(Text("Chapter 8"))
        .onAppear(perform: {
            print("***** Chapter 8 *****")
            if viewModel.loadLastAction {
                viewModel.getLastAction()()
            }
        })
    }
}

struct Chapter78iew_Previews: PreviewProvider {
    static var previews: some View {
        Chapter8View()
    }
}
