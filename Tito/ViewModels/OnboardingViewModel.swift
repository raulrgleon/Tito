import Foundation
import Combine

class OnboardingViewModel: ObservableObject {
    @Published var currentPage: Int = 0
    @Published var hasCompletedOnboarding: Bool = false
    
    private let keychainService = KeychainService.shared
    
    init() {
        hasCompletedOnboarding = keychainService.loadStreamConfig() != nil
    }
    
    func nextPage() {
        if currentPage < 2 {
            currentPage += 1
        } else {
            completeOnboarding()
        }
    }
    
    func skip() {
        completeOnboarding()
    }
    
    private func completeOnboarding() {
        hasCompletedOnboarding = true
    }
}
