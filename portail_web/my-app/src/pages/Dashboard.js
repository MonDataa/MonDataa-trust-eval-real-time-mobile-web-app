import React, { useEffect, useState } from "react";
import { Container, Card, Table, ProgressBar, Form, Row, Col, Button } from "react-bootstrap";
import { Bar, Pie, Line } from "react-chartjs-2";
import { Chart, ArcElement, Tooltip, Legend, BarElement, CategoryScale, LinearScale, PointElement, LineElement } from "chart.js";
import useMqttService from "../services/mqttService"; // 📡 Service MQTT

// 📊 Enregistrement des composants Chart.js
Chart.register(ArcElement, Tooltip, Legend, BarElement, CategoryScale, LinearScale, PointElement, LineElement);

const Dashboard = () => {
    const [statistics, setStatistics] = useState(null);
    const [events, setEvents] = useState([]);
    const [selectedEventId, setSelectedEventId] = useState(null);
    const [loading, setLoading] = useState(true);
    const mqttMessages = useMqttService("event_updates"); // 📡 Écoute MQTT

    // 📥 Charger les données des événements
    const fetchEventData = async () => {
        setLoading(true);
        try {
            const response = await fetch("/public/events.json");
            const data = await response.json();
            if (data.events && data.events.length > 0) {
                setEvents(data.events);
                setStatistics(data.statistics);
                setSelectedEventId(data.events[0].id); // Sélectionner le premier événement
            }
        } catch (error) {
            console.error("❌ Erreur lors du chargement des événements :", error);
        }
        setLoading(false);
    };

    // 🔄 Chargement initial
    useEffect(() => {
        fetchEventData();
    }, []);

    // 📡 Mise à jour via MQTT
    useEffect(() => {
        if (mqttMessages.length > 0) {
            const newEventData = mqttMessages[mqttMessages.length - 1];

            setEvents((prevEvents) => {
                const exists = prevEvents.some(event => event.id === newEventData.id);
                return exists
                    ? prevEvents.map(event => (event.id === newEventData.id ? newEventData : event))
                    : [...prevEvents, newEventData];
            });
        }
    }, [mqttMessages]);

    if (loading) return <p className="text-center">⏳ Chargement des statistiques...</p>;
    if (!statistics || events.length === 0) return <p className="text-center text-danger">❌ Erreur : Données non disponibles.</p>;

    // 📊 Données des graphiques
    const selectedEvent = events.find(event => event.id === selectedEventId);
    const confidenceScore = selectedEvent?.confidenceScore ?? "Données indisponibles";
    const confidenceHistory = selectedEvent?.confidenceHistory ?? [];

    // 📊 Graphique des scores de confiance
    const barData = {
        labels: events.map(event => event.title),
        datasets: [
            {
                label: "Score de confiance",
                data: events.map(event => event.confidenceScore ?? 0),
                backgroundColor: "rgba(75, 192, 192, 0.6)",
                borderColor: "rgba(75, 192, 192, 1)",
                borderWidth: 1,
            }
        ]
    };

    // 📊 Répartition des participants
    const pieData = {
        labels: events.map(event => event.title),
        datasets: [
            {
                data: events.map(event => event.participants ?? 1),
                backgroundColor: ["#ff6384", "#36a2eb", "#ffce56", "#4bc0c0", "#9966ff"],
                hoverOffset: 4
            }
        ]
    };

    // 📊 Historique de confiance de l'événement sélectionné
    const confidenceHistoryData = {
        labels: confidenceHistory.length > 0 ? confidenceHistory.map((_, i) => `Échantillon ${i + 1}`) : ["Aucune donnée"],
        datasets: [
            {
                label: "Historique du Score de Confiance",
                data: confidenceHistory.length > 0 ? confidenceHistory : [0],
                borderColor: "#36a2eb",
                backgroundColor: "rgba(54, 162, 235, 0.2)",
                borderWidth: 2,
                tension: 0.3
            }
        ]
    };

    // 📤 Exportation de l'historique d'un événement sélectionné
    const exportEventHistory = () => {
        if (!selectedEvent) return;
        const eventData = {
            id: selectedEvent.id,
            title: selectedEvent.title,
            confidenceHistory: selectedEvent.confidenceHistory ?? []
        };
        const blob = new Blob([JSON.stringify(eventData, null, 2)], { type: "application/json" });
        const url = URL.createObjectURL(blob);
        const a = document.createElement("a");
        a.href = url;
        a.download = `event_${selectedEvent.id}_history.json`;
        a.click();
        URL.revokeObjectURL(url);
    };

    // 📤 Exporter l'historique de confiance de tous les événements
    const exportAllEventsHistory = () => {
        const allEventsData = events.map(event => ({
            id: event.id,
            title: event.title,
            confidenceHistory: event.confidenceHistory ?? []
        }));
        const blob = new Blob([JSON.stringify(allEventsData, null, 2)], { type: "application/json" });
        const url = URL.createObjectURL(blob);
        const a = document.createElement("a");
        a.href = url;
        a.download = "all_events_history.json";
        a.click();
        URL.revokeObjectURL(url);
    };

    return (
        <Container className="mt-4">
            <h2 className="text-center text-primary">📊 Tableau de Bord des Événements</h2>

            <Card className="shadow-lg p-4">
                <h4 className="text-success">📈 Statistiques Globales</h4>
                <Table striped bordered hover className="mt-3">
                    <tbody>
                        <tr><td>📌 Nombre Total d'Événements</td><td>{statistics.totalEvents}</td></tr>
                        <tr><td>🔥 Score de Confiance Moyen</td><td><ProgressBar now={statistics.averageConfidence} label={`${statistics.averageConfidence.toFixed(1)}%`} /></td></tr>
                        <tr><td>🏆 Score de Confiance Max</td><td>{statistics.maxConfidence}%</td></tr>
                    </tbody>
                </Table>
            </Card>

            <Card className="shadow-lg p-4 mt-4"><h4 className="text-info">📊 Scores de Confiance</h4><Bar data={barData} /></Card>
            <Card className="shadow-lg p-4 mt-4"><h4 className="text-warning">🟡 Répartition des Participants</h4><Pie data={pieData} /></Card>

            <Card className="shadow-lg p-4 mt-4">
                <h4 className="text-primary">📈 Historique du Score de Confiance</h4>
                <h2 className="text-center text-primary">{confidenceScore}%</h2>
                <Line data={confidenceHistoryData} />
            </Card>

            <Card className="shadow-lg p-4 mt-4">
                <h4 className="text-secondary">📤 Exportation des Historiques</h4>
                <Button className="w-100 mb-2" onClick={exportEventHistory}>📥 Exporter l'historique sélectionné</Button>
                <Button className="w-100" onClick={exportAllEventsHistory}>📤 Exporter tous les événements</Button>
            </Card>
        </Container>
    );
};

export default Dashboard;
