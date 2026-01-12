class GesturePipeline {
    private let recognizers = [
        TransformRecognizer()
    ]
    
    func process(_ touchMap: [Int: [Touch]]) -> [InputIntent] {
        recognizers.flatMap { $0.recognize(from: touchMap) }
    }
}
