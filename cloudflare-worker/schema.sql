CREATE TABLE IF NOT EXISTS analytics_events (
  id TEXT PRIMARY KEY,
  batch_id TEXT NOT NULL,
  app TEXT NOT NULL,
  platform TEXT NOT NULL,
  schema_version INTEGER NOT NULL,
  event_name TEXT NOT NULL,
  event_timestamp TEXT NOT NULL,
  properties_json TEXT NOT NULL,
  is_category_trend INTEGER NOT NULL,
  received_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_analytics_events_received_at
ON analytics_events(received_at);

CREATE INDEX IF NOT EXISTS idx_analytics_events_event_name
ON analytics_events(event_name);
