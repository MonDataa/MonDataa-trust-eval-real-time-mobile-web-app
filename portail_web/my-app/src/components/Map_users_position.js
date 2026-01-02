import React, { memo } from "react";
import { MapContainer, TileLayer, Marker, Popup } from "react-leaflet";
import L from "leaflet";
import markerIcon from "leaflet/dist/images/marker-icon.png";
import markerShadow from "leaflet/dist/images/marker-shadow.png";

// Définition d'une icône personnalisée pour corriger l'affichage
const customIcon = new L.Icon({
    iconUrl: markerIcon,
    shadowUrl: markerShadow,
    iconSize: [25, 41],
    iconAnchor: [12, 41],
    popupAnchor: [1, -34],
    shadowSize: [41, 41]
});

const MapUsersPosition = ({ center, zoom, markers }) => {
    return (
        <MapContainer center={center} zoom={zoom} style={{ height: "100%", width: "100%" }}>
            <TileLayer
                url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
                attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
            />
            {markers.length > 0 ? (
                markers.map((marker, index) => (
                    <Marker key={marker.id || index} position={marker.coords} icon={customIcon}>
                        <Popup>
                            <strong>{marker.name}</strong> <br />
                            📧 {marker.email || "Email non disponible"}
                        </Popup>
                    </Marker>
                ))
            ) : (
                <p className="text-center text-danger">❌ Aucun utilisateur trouvé avec une position valide.</p>
            )}
        </MapContainer>
    );
};

export default memo(MapUsersPosition);
