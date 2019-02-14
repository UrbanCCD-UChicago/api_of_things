import css from "../css/app.css"
import "phoenix_html"
import socket from "./socket"

if (document.getElementById('map')) {

  // setup the map
  const map = L.map('map').setView([41.87, -87.63], 11);
  L.tileLayer('https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png', {
    attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors &copy; <a href="https://carto.com/attributions">CARTO</a>',
    subdomains: 'abcd',
    maxZoom: 19
  }).addTo(map);

  // create an object to store the observation payloads; indexed by node vsn
  const latestObservations = {};

  // function to update the table... obviously
  function updateTable(data) {
    let tbody = document.getElementById('tbody');
    let content = ``;
    for (let i = 0; i < data.observations.length; i++) {
      let obs = data.observations[i];
      content += `<tr><td>${obs.sensor_path}</td><td>${obs.value}</td><td>${obs.uom}</td></tr>`;
    }
    tbody.innerHTML =content;
  }

  // sets up tracking the node via the topic `node:{vsn}`
  function watchNode(socket, vsn, marker) {
    let topic = `nodes:${vsn}`;
    let channel = socket.channel(topic, {});
    channel.join()
      // if we get an ok response then add the payload to the bank
      .receive('ok', resp => {
        console.log(`joined channel ${vsn}`);
        latestObservations[vsn] = resp;
      })
      // otherwise remove the marker so we don't display a bunch of null data
      .receive('error', resp => {
        console.log(`error joining channel ${vsn}`);
        map.removeLayer(marker);
      });

    // setup the event listener for `latest` pushes from the server
    channel.on('latest', resp => {
      console.log(`received latest for ${vsn}`);
      latestObservations[vsn] = resp;
    });

    // probably unncecessary, but whatever
    return channel;
  }

  // draws the markers as circles instead of the big, clunky pins
  let geojsonMarkerOptions = { radius: 8, fillColor: "#2a5eb2", color: "#000", weight: 1, opacity: 1, fillOpacity: 0.8 };

  // finally we fetch the nodes as geojson so we can draw them to the map
  fetch('/api/nodes?project=chicago&format=geojson')
    .then(resp => {
      return resp.json();
    })
    .then(data => {
      for (let i = 0; i < data.data.length; i++) {
        let obj = data.data[i];
        let props = obj.properties;
        let vsn = props.vsn;

        // add the marker to the map
        let marker = L.geoJSON(obj, {
          pointToLayer: function (_feature, latlng) {
            return L.circleMarker(latlng, geojsonMarkerOptions);
          }
        }).addTo(map);

        // setup the watcher
        watchNode(socket, vsn, marker);

        // bind the marker's click event
        marker.on('click', e => {
          // update the observations table
          updateTable(latestObservations[vsn]);

          // popup some node info
          let popup = L.popup();
          popup.setLatLng(e.latlng);
          popup.setContent(`<strong>Tracking Node ${vsn}</strong><br> ${props.description}<br>Located at ${props.address}`);
          popup.openOn(map);
        });
      }
    });

}