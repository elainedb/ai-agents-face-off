import type { Video } from '../../domain/models';

export function buildLeafletHtml(videos: Video[]): string {
  const located = videos.filter((v) => v.lat != null && v.lng != null);
  const center = located.length > 0 ? [located[0].lat, located[0].lng] : [20, 0];
  const zoom = located.length > 0 ? 3 : 1;
  const markersJs = located
    .map(
      (v) => `L.marker([${v.lat}, ${v.lng}]).addTo(map).bindPopup(${JSON.stringify(v.title)}).on('click', function() {
        window.ReactNativeWebView && window.ReactNativeWebView.postMessage(${JSON.stringify(v.id)});
      });`,
    )
    .join('\n');

  return `<!DOCTYPE html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no" />
  <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
  <style>html, body, #map { height: 100%; margin: 0; padding: 0; }</style>
</head>
<body>
  <div id="map"></div>
  <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
  <script>
    var map = L.map('map').setView([${center[0]}, ${center[1]}], ${zoom});
    L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
      attribution: '&copy; OpenStreetMap contributors'
    }).addTo(map);
    ${markersJs}
  </script>
</body>
</html>`;
}
