//
//  Chapter13View.swift
//  Practice_Combine
//
//  Created by Jinwoo Kim on 10/14/20.
//

import SwiftUI

struct Chapter13View: View {
    @ObservedObject var viewModel: Chapter13ViewModel = .init()
    
    var body: some View {
        List {
            ForEach(viewModel.actions, id: \.title) { chapterAction in
                Button(chapterAction.title, action: chapterAction.action)
            }
        }
        .navigationTitle(Text("Chapter 13"))
        .onAppear(perform: {
            print("***** Chapter 13 *****")
            if viewModel.loadLastAction {
                viewModel.getLastAction()()
            }
        })
    }
}

struct Chapter13View_Previews: PreviewProvider {
    static var previews: some View {
        Chapter13View()
    }
}
