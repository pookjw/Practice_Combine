//
//  Chapter15View.swift
//  Practice_Combine
//
//  Created by Jinwoo Kim on 10/18/20.
//

import SwiftUI

struct Chapter15View: View {
    @ObservedObject var viewModel: Chapter15ViewModel = .init()
    
    var body: some View {
        List {
            ForEach(viewModel.actions, id: \.title) { chapterAction in
                Button(chapterAction.title, action: chapterAction.action)
            }
        }
        .navigationTitle(Text("Chapter 15"))
        .onAppear(perform: {
            print("***** Chapter 15 *****")
            if viewModel.loadLastAction {
                viewModel.getLastAction()()
            }
        })
    }
}

struct Chapter15View_Previews: PreviewProvider {
    static var previews: some View {
        Chapter15View()
    }
}
