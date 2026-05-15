# Raptor Analytics Transparency

This repo shows the exact public version of the code Raptor uses to record anonymous in-app usage trends. It is opt-in, stores events locally, sanitizes event properties through an allowlist, and does not record raw transactions, merchants, cards, names, emails, passcodes, exact location, screenshots, or device fingerprints.

Start here: [`Sources/RaptorAnalyticsTransparency.swift`](Sources/RaptorAnalyticsTransparency.swift)

Small helper buckets used by the tracker: [`Sources/AnalyticsBuckets.swift`](Sources/AnalyticsBuckets.swift)
