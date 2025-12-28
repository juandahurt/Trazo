import SwiftUI

struct ContentView: View {
    @State var spacing: Float = 5
    
    var debugProperties: some View {
        Group {
            VStack(alignment: .leading) {
                Text("Spacing")
                Slider(value: $spacing, in: 4...50)
            }.padding()
        }
        .background(.black.opacity(0.2))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .frame(width: 150)
        .padding()
        .padding(.bottom)
    }
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            ViewControllerWrapper(spcaing: $spacing)
            debugProperties
        }
            .ignoresSafeArea()
    }
}
