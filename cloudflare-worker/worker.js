export default {
  async fetch(request, env) {
    const url = new URL(request.url);

    if (url.pathname === "/health") {
      return new Response("ok");
    }

    if (url.pathname !== "/v1/analytics" || request.method !== "POST") {
      return new Response("Not found", { status: 404 });
    }

    let payload;
    try {
      payload = await request.json();
    } catch {
      return new Response("Invalid JSON", { status: 400 });
    }

    if (!payload || payload.app !== "raptor-ios" || !Array.isArray(payload.events)) {
      return new Response("Invalid payload", { status: 400 });
    }

    const batchId = String(payload.batchId || crypto.randomUUID());
    const schemaVersion = Number(payload.schemaVersion || 1);
    const app = String(payload.app);
    const platform = String(payload.platform || "ios");

    for (const event of payload.events.slice(0, 1000)) {
      const id = String(event.id || crypto.randomUUID());
      const eventName = String(event.name || "unknown").slice(0, 80);
      const eventTimestamp = String(event.timestamp || new Date().toISOString());
      const properties = event.properties && typeof event.properties === "object" ? event.properties : {};
      const isCategoryTrend = event.isCategoryTrend ? 1 : 0;

      await env.DB.prepare(
        `INSERT OR IGNORE INTO analytics_events
          (id, batch_id, app, platform, schema_version, event_name, event_timestamp, properties_json, is_category_trend)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`
      )
        .bind(
          id,
          batchId,
          app,
          platform,
          schemaVersion,
          eventName,
          eventTimestamp,
          JSON.stringify(properties).slice(0, 4000),
          isCategoryTrend
        )
        .run();
    }

    return Response.json({ ok: true });
  }
};
