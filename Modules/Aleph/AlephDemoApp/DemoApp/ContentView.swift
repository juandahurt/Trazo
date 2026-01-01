import SwiftUI

struct ContentView: View {
    @State var spacing: Float = 5
    @State var pointSize: Float = 10
    @State var opacity: Float = 1
    
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
    
    var opacityView: some View {
        VStack(alignment: .leading) {
            Text("Opacity")
            Slider(value: $opacity, in: 0...1)
        }.padding()
    }
    
    var debugProperties: some View {
        ScrollView {
            spacingView
            pointSizeView
            opacityView
        }
        .background(.black.opacity(0.2))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .frame(width: 150)
        .padding()
        .padding(.bottom)
    }
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            ViewControllerWrapper(
                spacing: $spacing,
                pointSize: $pointSize,
                opacity: $opacity
            )
            debugProperties
        }
            .ignoresSafeArea()
    }
}
