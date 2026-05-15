import Foundation

let raptorAnalyticsUploadURL = URL(string: "https://raptor-analytics.privacy-raptor.workers.dev/v1/analytics")!

enum RaptorAnalyticsEventName: String, Codable, CaseIterable, Identifiable {
    case tabOpened = "tab_opened"
    case onboardingCompleted = "onboarding_completed"
    case setupGuideOpened = "setup_guide_opened"
    case setupGuideStepToggled = "setup_guide_step_toggled"
    case settingsOpened = "settings_opened"
    case privacyDataOpened = "privacy_data_opened"
    case analyticsOptInChanged = "analytics_opt_in_changed"
    case aggregatedReportsChanged = "aggregated_reports_changed"
    case anonymousDataProductsChanged = "anonymous_data_products_changed"
    case budgetItemAddStarted = "budget_item_add_started"
    case budgetItemSaved = "budget_item_saved"
    case budgetItemDeleted = "budget_item_deleted"
    case budgetIncomeEditorOpened = "budget_income_editor_opened"
    case graphModeChanged = "graph_mode_changed"
    case transactionSearchUsed = "transaction_search_used"
    case categoryFilterChanged = "category_filter_changed"
    case transactionEdited = "transaction_edited"
    case transactionAdded = "transaction_added"
    case transactionDeleted = "transaction_deleted"
    case transactionSeeMoreTapped = "transaction_see_more_tapped"
    case categoryColorChanged = "category_color_changed"
    case budgetPressureViewed = "budget_pressure_viewed"
    case paydayWindowViewed = "payday_window_viewed"
    case needsWantsMixViewed = "needs_wants_mix_viewed"
    case walletCoverageViewed = "wallet_coverage_viewed"
    case transactionCorrectionMade = "transaction_correction_made"
    case subscriptionInterestViewed = "subscription_interest_viewed"
    case predictionInterestViewed = "prediction_interest_viewed"
    case appDataReset = "app_data_reset"
    case analyticsDeleted = "analytics_deleted"

    var id: String { rawValue }
}

struct RaptorAnalyticsEvent: Identifiable, Codable, Equatable {
    let id: UUID
    let name: RaptorAnalyticsEventName
    let timestamp: Date
    let properties: [String: String]
    let isCategoryTrend: Bool

    init(
        name: RaptorAnalyticsEventName,
        properties: [String: String] = [:],
        isCategoryTrend: Bool = false,
        timestamp: Date = Date()
    ) {
        self.id = UUID()
        self.name = name
        self.timestamp = timestamp
        self.properties = properties
        self.isCategoryTrend = isCategoryTrend
    }
}

struct RaptorAnalyticsUploadPayload: Codable {
    let app: String
    let platform: String
    let schemaVersion: Int
    let batchId: UUID
    let generatedAt: Date
    let events: [RaptorAnalyticsEvent]
}

struct RaptorAnalyticsConsent {
    var shareAnonymousUsageAnalytics: Bool
    var shareAnonymousCategoryTrends: Bool
    var allowAnonymousAggregatedReports: Bool
    var allowAnonymousDataProducts: Bool
    var doNotSellOrSharePersonalInfo: Bool
}

enum RaptorAnalytics {
    static let storageKey = "raptorAnonymousAnalyticsEvents"
    private static let lastUploadKey = "raptorAnalyticsLastUploadDate"
    private static let maxStoredEvents = 1000
    private static let uploadInterval: TimeInterval = 60 * 60 * 6
    private static var uploadInProgress = false

    private static let allowedPropertyKeys: Set<String> = [
        "tab",
        "step",
        "enabled",
        "item_type",
        "graph",
        "category",
        "color",
        "visible_count",
        "source",
        "purpose",
        "consent",
        "status",
        "window",
        "ratio",
        "field",
        "count_bucket",
        "budget_state",
        "coverage"
    ]

    static func track(
        _ name: RaptorAnalyticsEventName,
        properties: [String: String] = [:],
        isCategoryTrend: Bool = false,
        consent: RaptorAnalyticsConsent
    ) {
        guard canTrack(isCategoryTrend: isCategoryTrend, consent: consent) else { return }

        var currentEvents = events()
        currentEvents.append(
            RaptorAnalyticsEvent(
                name: name,
                properties: sanitizedProperties(properties),
                isCategoryTrend: isCategoryTrend
            )
        )

        if currentEvents.count > maxStoredEvents {
            currentEvents = Array(currentEvents.suffix(maxStoredEvents))
        }

        save(currentEvents)
        uploadIfNeeded(consent: consent)
    }

    static func events() -> [RaptorAnalyticsEvent] {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([RaptorAnalyticsEvent].self, from: data) else {
            return []
        }

        return decoded
    }

    static func deleteAll() {
        UserDefaults.standard.removeObject(forKey: storageKey)
        UserDefaults.standard.removeObject(forKey: lastUploadKey)
    }

    static func uploadIfNeeded(force: Bool = false, consent: RaptorAnalyticsConsent) {
        guard canUpload(consent: consent) else { return }
        guard uploadInProgress == false else { return }

        let currentEvents = events()
        guard currentEvents.isEmpty == false else { return }

        if force == false,
           let lastUploadDate = UserDefaults.standard.object(forKey: lastUploadKey) as? Date,
           Date().timeIntervalSince(lastUploadDate) < uploadInterval {
            return
        }

        let payload = RaptorAnalyticsUploadPayload(
            app: "raptor-ios",
            platform: "ios",
            schemaVersion: 1,
            batchId: UUID(),
            generatedAt: Date(),
            events: currentEvents
        )

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        guard let data = try? encoder.encode(payload) else { return }

        var request = URLRequest(url: raptorAnalyticsUploadURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("1", forHTTPHeaderField: "X-Raptor-Schema-Version")
        request.setValue("raptor-ios", forHTTPHeaderField: "X-Raptor-App")
        request.timeoutInterval = 20

        uploadInProgress = true
        URLSession.shared.uploadTask(with: request, from: data) { _, response, _ in
            uploadInProgress = false

            guard let httpResponse = response as? HTTPURLResponse,
                  200..<300 ~= httpResponse.statusCode else {
                return
            }

            removeUploadedEvents(currentEvents)
            UserDefaults.standard.set(Date(), forKey: lastUploadKey)
        }
        .resume()
    }

    private static func canTrack(isCategoryTrend: Bool, consent: RaptorAnalyticsConsent) -> Bool {
        if isCategoryTrend {
            return consent.shareAnonymousCategoryTrends
        }

        return consent.shareAnonymousUsageAnalytics
    }

    private static func canUpload(consent: RaptorAnalyticsConsent) -> Bool {
        consent.shareAnonymousUsageAnalytics &&
            consent.allowAnonymousAggregatedReports &&
            consent.allowAnonymousDataProducts &&
            consent.doNotSellOrSharePersonalInfo == false
    }

    private static func save(_ events: [RaptorAnalyticsEvent]) {
        if let encoded = try? JSONEncoder().encode(events) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }

    private static func removeUploadedEvents(_ uploadedEvents: [RaptorAnalyticsEvent]) {
        let uploadedIDs = Set(uploadedEvents.map { $0.id })
        let remainingEvents = events().filter { uploadedIDs.contains($0.id) == false }
        save(remainingEvents)
    }

    private static func sanitizedProperties(_ properties: [String: String]) -> [String: String] {
        properties.reduce(into: [:]) { output, pair in
            if allowedPropertyKeys.contains(pair.key) {
                output[pair.key] = String(pair.value.prefix(80))
            }
        }
    }
}
