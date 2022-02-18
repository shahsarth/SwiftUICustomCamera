//
//  ContentView.swift
//  SwiftUICustomCamera
//
//  Created by Sarth Shah on 2/18/22.
//

import SwiftUI

struct ContentView: View {
    @State private var selection = 0
    @State private var resetNavigationID = UUID()

    
    @ViewBuilder
    var body: some View {
        let selectable = Binding(        // << proxy binding to catch tab tap
            get: { self.selection },
            set: { self.selection = $0
                self.resetNavigationID = UUID()
        })
                TabView(selection: selectable){

                    self.HomeTab()
                        .tabItem {
                            Image(systemName: "house.fill")
                            Text("Home")
                        }.tag(0)
                    
                    self.CamTab()
                        .tabItem {
                            Image(systemName: "camera")
                            Text("Live")
                        }.tag(1)
                }
            
            }
    private func HomeTab() -> some View {
        HomeView()
            .font(.system(size: 30, weight: .bold, design: .rounded))
            .id(self.resetNavigationID)
    }
    
    private func CamTab() -> some View {
        CustomCameraPhotoView()
            .font(.system(size: 30, weight: .bold, design: .rounded))
            .id(self.resetNavigationID)
    }
            
        
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
