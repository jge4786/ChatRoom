class Observable<T> {
    private var listener: ((T) -> Void)?
    
    var value: T {
        didSet {
            listener?(value) // value가 변경되면 listener에 저장된 클로저(함수)에 value를 매개변수로 넘겨서 실행
        }
    }
    
    
    init(_ value: T) {
        self.value = value
    }
    func bind(listener: @escaping (T) -> Void) {
        listener(value)
        self.listener = listener
    }
}
