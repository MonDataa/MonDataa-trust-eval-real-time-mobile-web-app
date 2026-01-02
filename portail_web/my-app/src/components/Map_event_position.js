import React, { memo } from "react";
import { MapContainer, TileLayer, Marker, Popup } from "react-leaflet";
import L from "leaflet";
import markerIcon from "leaflet/dist/images/marker-icon.png";
import markerShadow from "leaflet/dist/images/marker-shadow.png";

// Définition d'une icône personnalisée pour les événements
const eventIcon = new L.Icon({
    iconUrl: markerIcon,
    shadowUrl: markerShadow,
    iconSize: [30, 45],
    iconAnchor: [15, 45],
    popupAnchor: [1, -34],
    shadowSize: [45, 45]
});

const Map = ({ center, zoom, markers }) => {
    return (
        <MapContainer center={center} zoom={zoom} style={{ height: "100%", width: "100%" }}>
            <TileLayer
                url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
                attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
            />
            {markers.map((marker, index) => (
                <Marker key={marker.id || index} position={marker.coords} icon={eventIcon}>
                    <Popup>
                        <strong>{marker.name}</strong> <br />
                        📍 {marker.description} <br />
                    </Popup>
                </Marker>
            ))}
        </MapContainer>
    );
};

export default memo(Map);
