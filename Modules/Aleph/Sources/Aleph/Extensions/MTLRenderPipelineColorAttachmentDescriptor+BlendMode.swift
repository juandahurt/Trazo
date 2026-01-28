import Metal

extension MTLRenderPipelineColorAttachmentDescriptor {
    func apply(mode: BlendMode) {
        switch mode {
        case .normal:
            isBlendingEnabled = true
            sourceRGBBlendFactor = .sourceAlpha
            destinationRGBBlendFactor = .oneMinusSourceAlpha
            rgbBlendOperation = .add
            sourceAlphaBlendFactor = .one
            destinationAlphaBlendFactor = .one
        case .none:
            isBlendingEnabled = false
        }
    }
}
