//
//  ContentView.swift
//  Clean Code Navigation-SwiftUI
//
//  Created by Mahi Al Jawad on 10/2/24.
//

// Note: Please make separate files for each of the files and views
// For the sake of readability on the go I have kept in the same file

import SwiftUI

// MARK: Router class for Navigation Control

final class Router: ObservableObject {
    // Add the pushed views you need to control
    public enum Destination: Codable, Hashable {
        case childView1
        case childView2
        case grandChildView
    }
    
    @Published var path = NavigationPath()
    
    func navigate(to destination: Destination) {
        path.append(destination)
    }
    
    func navigateBack() {
        path.removeLast()
    }
    
    func navigateToRoot() {
        path.removeLast(path.count)
    }
}

struct Coordinator: View {
    @StateObject var router = Router()
    
    // For any modal view requires binding
    @State var presentGrandGrandChildSheet: Bool = false
    
    var body: some View {
        NavigationStack(path: $router.path) {
            MainView() // Show Root View here
                .navigationDestination(for: Router.Destination.self) { destination in
                    switch destination {
                    case .childView1: 
                        ChildView1()
                    case .childView2:
                        ChildView2()
                    case .grandChildView:
                        GrandChildView(presentGrandGrandChildView: $presentGrandGrandChildSheet)
                            .sheet(isPresented: $presentGrandGrandChildSheet) {
                                GrandGrandChildView()
                            }
                    }
                }
        }
        .environmentObject(router)
    }
}


struct MainView: View {
    @EnvironmentObject var router: Router
    
    var body: some View {
        VStack {
            Image(systemName: "figure.stand")
                .resizable()
                .frame(width: 50, height: 100)
                .foregroundStyle(.tint)
            Text("Main View").font(.title)
            
            // Navigate using NavigationLink
            NavigationLink(value: Router.Destination.childView1) {
                Text("Go to Child View-1")
                    .foregroundStyle(.blue)
            }
            
            // Navigate inside any action
            Button(action: {
                router.navigate(to: .childView2)
            }, label: {
                Text("Go to Child View-2")
                    .foregroundStyle(.blue)
            })
        }
        .padding()
    }
}

struct ChildView1: View {
    var body: some View {
        VStack {
            HStack(alignment: .bottom) {
                Image(systemName: "figure.stand")
                    .resizable()
                    .frame(width: 50, height: 100)
                    .foregroundStyle(.tint)
                Image(systemName: "figure.stand")
                    .resizable()
                    .frame(width: 40, height: 80)
                    .foregroundStyle(.green)
            }
            Text("Child View-1").font(.title)
        }
    }
}

struct ChildView2: View {
    @EnvironmentObject var router: Router
    
    var body: some View {
        VStack {
            HStack(alignment: .bottom) {
                Image(systemName: "figure.stand")
                    .resizable()
                    .frame(width: 50, height: 100)
                    .foregroundStyle(.tint)
                Image(systemName: "figure.stand")
                    .resizable()
                    .frame(width: 40, height: 80)
                    .foregroundStyle(.red)
            }
            Text("Child View-2").font(.title)
            
            // Navigate inside any action
            Button(action: {
                router.navigate(to: .grandChildView)
            }, label: {
                Text("Go to Grand Child View")
                    .foregroundStyle(.blue)
            })
        }
    }
}

struct GrandChildView: View {
    @EnvironmentObject var router: Router
    @Binding var presentGrandGrandChildView: Bool
    
    var body: some View {
        VStack {
            HStack(alignment: .bottom) {
                Image(systemName: "figure.stand")
                    .resizable()
                    .frame(width: 50, height: 100)
                    .foregroundStyle(.tint)
                Image(systemName: "figure.stand")
                    .resizable()
                    .frame(width: 40, height: 80)
                    .foregroundStyle(.red)
                Image(systemName: "figure.stand")
                    .resizable()
                    .frame(width: 35, height: 70)
                    .foregroundStyle(.green)
            }
            Text("Grand Child View").font(.title)
            
            // Present modal view
            Button(action: {
                // Shows a modally presented view
                presentGrandGrandChildView = true
            }, label: {
                Text("Present modally Grand-Grand Child View")
                    .foregroundStyle(.blue)
            })
        }
    }
}

// Modally presented view
struct GrandGrandChildView: View {
    @EnvironmentObject var router: Router
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            HStack(alignment: .bottom) {
                Image(systemName: "figure.stand")
                    .resizable()
                    .frame(width: 50, height: 100)
                    .foregroundStyle(.tint)
                Image(systemName: "figure.stand")
                    .resizable()
                    .frame(width: 40, height: 80)
                    .foregroundStyle(.red)
                Image(systemName: "figure.stand")
                    .resizable()
                    .frame(width: 35, height: 70)
                    .foregroundStyle(.green)
                Image(systemName: "figure.stand")
                    .resizable()
                    .frame(width: 30, height: 60)
                    .foregroundStyle(.purple)
            }
            Text("Grand-Grand Child View").font(.title)
            
            // Navigates to root view
            Button(action: {
                // Dimisses current view
                dismiss()
                // Navigates to root view
                router.navigateToRoot()
            }, label: {
                Text("Navigate to root view")
                    .foregroundStyle(.blue)
            })
        }
    }
}

#Preview {
    Coordinator()
}
