(function () {
  var collectorUrl = window.__FARO_COLLECTOR_URL__;
  if (!collectorUrl) {
    return;
  }

  function loadScript(src, onload) {
    var s = document.createElement("script");
    s.src = src;
    s.async = false;
    s.crossOrigin = "anonymous";
    if (onload) {
      s.onload = onload;
    }
    document.head.appendChild(s);
  }

  loadScript("https://unpkg.com/@grafana/faro-web-sdk@^1/dist/bundle/faro-web-sdk.iife.js", function () {
    loadScript("https://unpkg.com/@grafana/faro-web-tracing@^1/dist/bundle/faro-web-tracing.iife.js", function () {
      if (!window.GrafanaFaroWebSdk) {
        return;
      }
      var instrumentations = window.GrafanaFaroWebSdk.getWebInstrumentations({
        captureConsole: true,
      });
      if (window.GrafanaFaroWebTracing) {
        instrumentations.push(new window.GrafanaFaroWebTracing.TracingInstrumentation());
      }
      window.GrafanaFaroWebSdk.initializeFaro({
        url: collectorUrl,
        app: {
          name: "ts-ui-dashboard",
          version: "1.0.0",
          environment: "dev",
        },
        instrumentations: instrumentations,
      });
    });
  });
})();
