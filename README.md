# FreeAgent-iOS-Tech-Test-Alex-J
My solution to the FreeAgent iOS Tech Test


This solution is built using RxSwift following an MVVM Architecture with the Coordinator pattern. The UI is built using UIKit with a mixture of Xibs and storyboards. 

Dependency injection has been used to make the View Models testable and Input structs have been used to capture the actions a user can perfrom on any given screen. This also helps cover a but of the UI when testing without explictly having to write UI tests.
