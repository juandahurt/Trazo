import SwiftUI

struct ContentView: View {
    @State var debugViewIsPresented = false
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            ViewControllerWrapper()
                .sheet(isPresented: $debugViewIsPresented) {
                    DebugView()
                }
            
            Button {
                debugViewIsPresented.toggle()
            } label: {
                Image(systemName: "ladybug")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .foregroundStyle(.green)
            }
            .padding([.leading, .bottom], 40)
        }.ignoresSafeArea()
    }
}

struct DebugView: View {
    @State var showDirtyTiles = false
    
    var body: some View {
        Toggle(isOn: $showDirtyTiles) {
            Text("Show dirty tyiles")
        }
        .padding()
    }
}
