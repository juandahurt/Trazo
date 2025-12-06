import SwiftUI

struct ContentView: View {
    @State var debugViewIsPresented = false
    
    var body: some View {
        ViewControllerWrapper()
            .ignoresSafeArea()
    }
}
