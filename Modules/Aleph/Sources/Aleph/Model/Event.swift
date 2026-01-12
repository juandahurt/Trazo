enum InputEvent {
    case touches([Touch])
}

enum SceneLifeCycleEvent {
    case load
}

enum Event {
    case input(InputEvent)
    case lifeCycle(SceneLifeCycleEvent)
}
