import React, { useEffect, useState } from "react";
import { Container, Card, Spinner } from "react-bootstrap";
import Map from "../components/Map_event_position"; // 📌 Import du composant Map
import useMqttService from "../services/mqttService"; // 📡 Import du service MQTT

const EventMap = () => {
    const [loading, setLoading] = useState(true);
    const [events, setEvents] = useState([]);
    const mqttMessages = useMqttService(); // 📡 Récupérer les événements en temps réel via MQTT

    // 🔄 Charger les événements initiaux depuis le fichier JSON
    const loadEvents = async () => {
        try {
            const response = await fetch("/public/events.json");
            const data = await response.json();

            // ✅ Filtrer les événements avec coordonnées valides
            const validEvents = data.events
                .filter(event => event.latitude !== undefined && event.longitude !== undefined)
                .map(event => ({
                    id: event.id,
                    name: event.title,
                    description: event.description,
                    coords: [event.latitude, event.longitude]
                }));

            setEvents(validEvents);
        } catch (error) {
            console.error("❌ Erreur lors du chargement des événements :", error);
        }
        setLoading(false);
    };

    // 🔄 Chargement initial des événements depuis JSON
    useEffect(() => {
        loadEvents();
    }, []);

    // 📡 Ajouter les événements en temps réel via MQTT
    useEffect(() => {
        if (mqttMessages.length > 0) {
            const newEvent = mqttMessages[mqttMessages.length - 1];

            if (newEvent.latitude !== undefined && newEvent.longitude !== undefined) {
                setEvents(prevEvents => [
                    ...prevEvents,
                    {
                        id: newEvent.id,
                        name: newEvent.title || "Événement inconnu",
                        description: newEvent.description || "Pas de description",
                        coords: [newEvent.latitude, newEvent.longitude]
                    }
                ]);
            } else {
                console.warn("⚠️ Événement MQTT ignoré : coordonnées invalides", newEvent);
            }
        }
    }, [mqttMessages]);

    return (
        <Container className="mt-4">
            <Card className="p-4 shadow">
                <h2 className="text-center text-warning">📍 Carte des Événements</h2>
                <p className="text-center">Visualisation des événements en temps réel.</p>

                {loading ? (
                    <Spinner animation="border" role="status" className="d-block mx-auto my-3">
                        <span className="visually-hidden">Chargement...</span>
                    </Spinner>
                ) : (
                    <div className="mt-3" style={{ height: "500px", width: "100%" }}>
                        <Map center={[46.6031, 1.8883]} zoom={6} markers={events} />
                    </div>
                )}
            </Card>
        </Container>
    );
};

export default EventMap;
