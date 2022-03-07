import RxSwift
import RxCocoa

public extension ObservableConvertibleType {

    /**
     Instead of just returning an empty observable when a Driver encounters an error use an assertion failure to help debug
     */
    func asDriverOrAssertionFailureInDebugAndEmptyInRelease(_ file: StaticString = #file,
                                                            _ line: UInt = #line) -> SharedSequence<DriverSharingStrategy, Element> {
        return asDriver(onErrorRecover: {
            assertionFailure("Error: \($0) in file: \(file) atLine: \(line)")
            return .empty()
        })
    }
}
