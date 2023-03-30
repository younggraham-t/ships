//
//  ContentView.swift
//  Ships
//
//  Created by Joel Hollingsworth on 4/4/21.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        /*
         * Skipping straight to the GameView.
         * Could replace this with a menu UI that
         * eventually leads to the GameView.
         */
        GameView()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
