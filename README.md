# Managing SwiftUI View's navigation in Clean-code architecture

Maintaining clean code and adopting best practices in the navigation management of an Application is vital for its readability and manageability.

I've shown the following hierarchy navigation with a demo SwiftUI application.

<img width="818" alt="Screenshot 2024-02-10 at 9 09 40 PM" src="https://github.com/MahiAlJawad/Clean-Code-Navigation-SwiftUI/assets/30589979/6c0747b9-4645-4682-903d-71961b67498c">

With this approach, you can do the following with ease and in a manageable manner:

* Push any views from any other view with a single line of code
* Pop back to root view with a single line of code
* Handle all navigations inside a manageable Coordinator, which gives you readability of the hierarchy

We assume you know the basic concept of `@EnvironmentObject` and bindings in SwiftUI.

## Output simulation

https://github.com/MahiAlJawad/Clean-Code-Navigation-SwiftUI/assets/30589979/96ffdd00-aad7-4a15-92de-bef4a5961b6d

## Code demonstration

Let's write a simple `Router` class to manage navigation:

```swift
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
```

Now you can move to any view with a single line of code.

Such as navigate to `childView2` with a single statement: `router.navigate(to: .childView2`
Or navigate to Root view with a statement: `router.navigateToRoot()`

Now we make a `Coordinate` to coordinate or manage different views:

```swift
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
```

If any view pushes any `destination: Destination` with the `router: Router` the `destination` inside the `.navigationDestination` gets an update of the change using the `NavigationStack(path: )`. And then we handle the case accordingly by showing the appropriate view.

The usage in other views are as follows:

```swift
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
```



