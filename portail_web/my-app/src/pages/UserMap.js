import React, { useEffect, useState } from "react";
import { Container, Card, Spinner } from "react-bootstrap";
import Map from "../components/Map_users_position"; // Import du composant Map
import useMqttService from "../services/mqttService"; // 📡 Service MQTT

const UserMap = () => {
    const [users, setUsers] = useState([]);
    const [loading, setLoading] = useState(true);
    const mqttMessages = useMqttService("user_positions"); // 📡 Écoute des positions en temps réel

    // 📥 Charger les utilisateurs initiaux depuis le fichier JSON
    useEffect(() => {
        const loadUsers = async () => {
            try {
                const response = await fetch("/public/users.json");
                const data = await response.json();

                if (data.clients) {
                    setUsers(
                        data.clients
                            .filter(user => user.latitude !== 0 && user.longitude !== 0) // ✅ Filtrer ceux avec une position valide
                            .map(user => ({
                                id: user.id,
                                name: user.username,
                                email: user.email || "Non disponible",
                                coords: [user.latitude, user.longitude]
                            }))
                    );
                }
            } catch (error) {
                console.error("❌ Erreur lors du chargement des utilisateurs :", error);
            }
            setLoading(false);
        };

        loadUsers();
    }, []);

    // 📡 Mise à jour en temps réel via MQTT
    useEffect(() => {
        if (mqttMessages.length > 0) {
            const newUser = mqttMessages[mqttMessages.length - 1];

            setUsers((prevUsers) => {
                const exists = prevUsers.some(user => user.id === newUser.id);
                if (exists) {
                    // Met à jour la position de l'utilisateur existant
                    return prevUsers.map(user =>
                        user.id === newUser.id ? { ...user, coords: [newUser.latitude, newUser.longitude] } : user
                    );
                } else {
                    // Ajoute un nouvel utilisateur s'il n'existe pas
                    return [...prevUsers, {
                        id: newUser.id,
                        name: newUser.username,
                        email: newUser.email || "Non disponible",
                        coords: [newUser.latitude, newUser.longitude]
                    }];
                }
            });
        }
    }, [mqttMessages]);

    return (
        <Container className="mt-4">
            <Card className="shadow-lg p-4">
                <Card.Body>
                    <Card.Title className="text-center text-primary">
                        🗺️ Carte des Utilisateurs (Temps Réel)
                    </Card.Title>
                    <Card.Text className="text-center text-muted">
                        Visualisation des utilisateurs avec position GPS en France.
                    </Card.Text>

                    {loading ? (
                        <Spinner animation="border" role="status" className="d-block mx-auto my-3">
                            <span className="visually-hidden">Chargement...</span>
                        </Spinner>
                    ) : (
                        <div className="mt-3" style={{ height: "500px", width: "100%" }}>
                            <Map center={[46.6031, 1.8883]} zoom={6} markers={users} />
                        </div>
                    )}
                </Card.Body>
            </Card>
        </Container>
    );
};

export default UserMap;
