const map = L.map("map", { scrollWheelZoom: false }).setView([45.8, 7.5], 6);
L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", { maxZoom: 18, attribution: "&copy; OpenStreetMap contributors" }).addTo(map);
const markerIcon = L.divIcon({ className: "glacier-marker", iconSize: [14, 14], iconAnchor: [7, 7] });
const nameElement = document.querySelector("#glacier-name");
const metaElement = document.querySelector("#glacier-meta");
const stripesElement = document.querySelector("#stripes");
const statusElement = document.querySelector("#status");
const temperatureImage = document.querySelector("#temperature-image");
const precipitationImage = document.querySelector("#precipitation-image");

function selectGlacier(glacier) {
  nameElement.textContent = glacier.name || glacier.rgi_id;
  metaElement.textContent = `${glacier.rgi_id} · ${glacier.region} · ${glacier.latitude.toFixed(3)}°N, ${glacier.longitude.toFixed(3)}°E`;
  temperatureImage.src = glacier.temperature_image;
  precipitationImage.src = glacier.precipitation_image;
  stripesElement.hidden = false;
  statusElement.hidden = true;
  history.replaceState(null, "", `?glacier=${encodeURIComponent(glacier.rgi_id)}`);
}

fetch("data/glaciers.json")
  .then(response => { if (!response.ok) throw new Error("Could not load glacier catalogue"); return response.json(); })
  .then(glaciers => {
    const markers = [];
    glaciers.forEach(glacier => {
      const marker = L.marker([glacier.latitude, glacier.longitude], { icon: markerIcon })
        .addTo(map).bindPopup(`<strong>${glacier.name || glacier.rgi_id}</strong><br>${glacier.rgi_id}`)
        .on("click", () => selectGlacier(glacier));
      markers.push(marker);
    });
    if (markers.length) map.fitBounds(L.featureGroup(markers).getBounds().pad(0.15));
    const requestedId = new URLSearchParams(window.location.search).get("glacier");
    const requested = glaciers.find(glacier => glacier.rgi_id === requestedId);
    if (requested) selectGlacier(requested); else statusElement.textContent = `${glaciers.length} glaciers available.`;
  })
  .catch(error => { statusElement.textContent = error.message; statusElement.classList.add("error"); });