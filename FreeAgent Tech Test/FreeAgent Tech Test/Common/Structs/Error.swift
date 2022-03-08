import Foundation

public struct AlertAction {
    public enum ActionStyle {
        case `default`
        case cancel
        case destructive
    }
    
    public typealias Handler = () -> Void
    public let title: String
    public let action: Handler?
    public let style: ActionStyle
    
    public init(title: String,
                action: Handler? = nil) {
        
        self.init(title: title, style: .default, action: action)
    }
    
    public init(title: String,
                style: ActionStyle,
                action: Handler? = nil) {
        
        self.title = title
        self.action = action
        self.style = style
    }
}

public struct AlertViewModel {
    public let title: String
    public let message: String?
    public let actions: [AlertAction]
    
    public init(title: String,
                message: String?,
                actions: [AlertAction]) {
        
        self.title = title
        self.message = message
        self.actions = actions
    }
}

public struct ErrorMessage {
    
    // MARK: - Properties
    public let title: String
    public let description: String?
    public let actions: [AlertAction]
    public let actionTitle: String

    // MARK: - Initialisers
    public init(title: String,
                description: String? = nil,
                actionTitle: String,
                alertAction: (() -> Void)? = nil) {
        
        let alertActions = [AlertAction(title: actionTitle, action: alertAction ?? {})]
        self.init(title: title,
                  description: description,
                  alertActions: alertActions)
    }
    
    public init(title: String,
                description: String? = nil,
                alertActions: [AlertAction]) {
        
        self.title = title
        self.description = description
        self.actions = alertActions
        
        if actions.count >= 1 {
            actionTitle = actions[0].title
        } else {
            actionTitle = "Close"
        }
    }
}
