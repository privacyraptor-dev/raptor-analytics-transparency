# Raptor Analytics Transparency

This repository shows the public, human-readable version of how Raptor handles anonymous analytics.

Raptor is designed to be local-first. The app does not upload raw transactions, merchant names, card names, paycheck amounts, passcodes, emails, names, exact location, device fingerprints, or screenshots.

Users can opt out, turn on "Do Not Sell or Share My Anonymous Analytical Information", and delete locally stored analytics from inside the app.

## What Raptor Can Track

Only after a user opts in, Raptor can record product analytics such as:

- Which tabs are opened, such as Budget, Categories, Track, Subscriptions, or Predictions
- Whether onboarding was completed
- Whether the setup guide was opened and which setup steps were checked off
- Whether Settings or Privacy & Data controls were opened
- Whether graph mode was changed, such as Graph or Pie Chart
- Whether search, filters, or "see more" were used
- Whether a transaction was added, edited, deleted, or corrected
- Whether a budget item was added, saved, or deleted
- Broad bucketed budget pressure, such as under budget or over budget ranges
- Broad payday windows, such as 1-3 days or 8-14 days
- Broad count buckets, such as 1-5, 6-15, or 51+
- Category trend labels only when category trend sharing is enabled

## What Raptor Does Not Track

Raptor's analytics layer is not intended to collect:

- Raw transaction records
- Merchant names
- Card names or card numbers
- Paycheck amounts
- Bank account data
- Passcodes
- Names or emails
- Exact location
- Device fingerprints
- Screenshots or image contents
- Individual user profiles for resale

## Upload Rules

Analytics upload only runs when:

- Anonymous usage analytics is enabled
- Anonymous aggregated reports are enabled
- Anonymous data products are enabled
- "Do Not Sell or Share My Anonymous Analytical Information" is off
- There are local events waiting to upload
- Enough time has passed since the last upload

If the user opts out, Raptor stops collecting analytics and deletes the local analytics queue.

## Privacy Rules for Reports

Third-party reports should use only anonymous aggregate data. Reports should avoid small cohorts, round numbers, and remove segments that could identify one person.

This repository is for transparency. The production app may contain additional UI code, but the same privacy boundaries should apply.
