import Metal

extension MTLRenderPipelineColorAttachmentDescriptor {
    func apply(mode: BlendMode) {
        switch mode {
        case .normal:
            isBlendingEnabled = true
            sourceRGBBlendFactor = .one
            destinationRGBBlendFactor = .oneMinusSourceAlpha
            rgbBlendOperation = .add
            sourceAlphaBlendFactor = .one
            destinationAlphaBlendFactor = .oneMinusSourceAlpha
            alphaBlendOperation = .add
        case .lighten:
            isBlendingEnabled = true
            rgbBlendOperation = .max
            alphaBlendOperation = .max
            sourceRGBBlendFactor = .one
            destinationRGBBlendFactor = .one
            sourceAlphaBlendFactor = .one
            destinationAlphaBlendFactor = .one
        case .none:
            isBlendingEnabled = false
        }
    }
}
