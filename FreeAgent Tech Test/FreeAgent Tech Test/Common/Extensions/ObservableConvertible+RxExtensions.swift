import RxSwift
import RxCocoa

public extension ObservableConvertibleType {

    /**
     Instead of just returning an empty observable when a Driver encounters an error, let's at least have an
     assertionFailure to try and catch some of these
     */
    func asDriverOrAssertionFailureInDebugAndEmptyInRelease(_ file: StaticString = #file,
                                                            _ line: UInt = #line) -> SharedSequence<DriverSharingStrategy, E> {
        return asDriver(onErrorRecover: {
            assertionFailure("Error: \($0) in file: \(file) atLine: \(line)")
            return .empty()
        })
    }
}
