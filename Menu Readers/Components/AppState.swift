import SwiftUI

@Observable
final class AppState {
    var isRedLightMode = false
    var sessionGroupingInterval: TimeInterval = 1800 // 30 minutes default
}
