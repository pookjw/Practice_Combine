//
//  Chapter7View.swift
//  Practice_Combine
//
//  Created by Jinwoo Kim on 10/6/20.
//

import SwiftUI

struct Chapter7View: View {
    @ObservedObject var viewModel: Chapter7ViewModel = .init()
    
    var body: some View {
        List {
            ForEach(viewModel.actions, id: \.title) { chapterAction in
                Button(chapterAction.title, action: chapterAction.action)
            }
        }
        .navigationTitle(Text("Chapter 7"))
        .onAppear(perform: {
            print("***** Chapter 7 *****")
            if viewModel.loadLastAction {
                viewModel.getLastAction()()
            }
        })
    }
}

struct Chapter7View_Previews: PreviewProvider {
    static var previews: some View {
        Chapter7View()
    }
}
