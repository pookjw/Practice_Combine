//
//  HomeView.swift
//  Practice_Combine
//
//  Created by Jinwoo Kim on 10/6/20.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel = HomeViewModel()
    
    var body: some View {
        NavigationView {
            List {
                // Push to Last Chapter when app is loaded
                NavigationLink(
                    "Last Chapter",
                    destination: viewModel.getLastView(),
                    isActive: .constant(viewModel.pushToLastChapter)
                )
                
                // List
                ForEach(viewModel.listOfChapters, id: \.self) { index in
                    NavigationLink(destination: viewModel.getView(at: index)) {
                        Text("Chapter \(index)")
                    }
                }
            }
            .navigationTitle(Text("Combine"))
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
