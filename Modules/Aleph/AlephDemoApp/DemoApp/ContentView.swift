import Aleph
import SwiftUI

struct ContentView: View {
    @State var isDebugSheetPresented = false
    @State var spacing: Float = 5
    @State var pointSize: Float = 10
    @State var opacity: Float = 1
    @State var shapeTextures: [TextureID]
    @State var selectedShapeTexture: TextureID
    
    init() {
        shapeTextures = Aleph.debugTextures
        selectedShapeTexture = Aleph.debugTextures.first!
    }
    
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
    
    var brushShapeView: some View {
        Picker(selection: $selectedShapeTexture) {
            ForEach(shapeTextures, id: \.self) { shapeTextureId in
                Text("\(shapeTextureId)")
            }
        } label: {
            Text("Shape texture")
        }
    }
    
    var debugProperties: some View {
        List {
            spacingView
            pointSizeView
            opacityView
            brushShapeView
        }
        .background(.black.opacity(0.2))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding()
    }
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ViewControllerWrapper(
                spacing: $spacing,
                pointSize: $pointSize,
                opacity: $opacity,
                selectedShapeTexture: $selectedShapeTexture
            )
                .ignoresSafeArea()
            Button("", systemImage: "ladybug") {
                isDebugSheetPresented.toggle()
            }.frame(width: 40, height: 40)
        }
            .sheet(isPresented: $isDebugSheetPresented) {
                debugProperties
            }
    }
}
