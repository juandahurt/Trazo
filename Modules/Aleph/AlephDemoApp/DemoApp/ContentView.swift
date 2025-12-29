import SwiftUI

struct ContentView: View {
    @State var spacing: Float = 5
    @State var pointSize: Float = 10
    
    var spacingView: some View {
        VStack(alignment: .leading) {
            Text("Spacing")
            Slider(value: $spacing, in: 4...50)
        }.padding()
    }
    
    var pointSizeView: some View {
        VStack(alignment: .leading) {
            Text("Point size")
            Slider(value: $pointSize, in: 5...50)
        }.padding()
    }
    
    var debugProperties: some View {
        ScrollView {
            spacingView
            pointSizeView
        }
        .background(.black.opacity(0.2))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .frame(width: 150)
        .padding()
        .padding(.bottom)
    }
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            ViewControllerWrapper(spacing: $spacing, pointSize: $pointSize)
            debugProperties
        }
            .ignoresSafeArea()
    }
}
