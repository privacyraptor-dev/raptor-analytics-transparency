# Privacy Controls

Raptor should expose these controls in the app:

- Support Raptor with anonymous data products
- Do Not Sell or Share My Anonymous Analytical Information
- Opt Out of All Analytics
- Delete Local Analytics Data
- View What Raptor Tracks
- View Aggregate Report

## Opt In

When a user enables anonymous data products, the app can enable:

- Anonymous usage analytics
- Anonymous category trends
- Anonymous aggregate reports
- Anonymous data products

The "Do Not Sell or Share" control should be off while this support mode is active.

## Do Not Sell or Share

When a user turns on "Do Not Sell or Share My Anonymous Analytical Information", Raptor should:

- Disable anonymous usage analytics
- Disable anonymous category trends
- Disable anonymous aggregate reports
- Disable anonymous data products
- Stop future uploads

## Delete Local Analytics Data

Deleting local analytics data removes:

- The local analytics event queue
- The last upload timestamp

It should not delete the user's transactions or budget data unless the user separately chooses to reset the app.
