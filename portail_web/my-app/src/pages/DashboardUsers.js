import React, { useEffect, useState, useCallback } from "react";
import { Container, Card, Table, ProgressBar, Row, Col, Button } from "react-bootstrap";
import { Bar, Pie, Line } from "react-chartjs-2";
import {
    Chart, ArcElement, Tooltip, Legend, BarElement, CategoryScale,
    LinearScale, PointElement, LineElement
} from "chart.js";
import useMqttService from "../services/mqttService"; // 📡 Service MQTT

// 📊 Enregistrement des composants Chart.js
Chart.register(ArcElement, Tooltip, Legend, BarElement, CategoryScale, LinearScale, PointElement, LineElement);

const ClientDashboard = () => {
    const [statistics, setStatistics] = useState(null);
    const [clients, setClients] = useState([]);
    const [selectedClientId, setSelectedClientId] = useState(null);
    const [loading, setLoading] = useState(true);
    const mqttMessages = useMqttService("client_updates"); // 📡 Écoute MQTT en temps réel

    // 📥 Charger les données initiales depuis JSON
    const loadClients = useCallback(async () => {
        setLoading(true);
        try {
            const response = await fetch("/public/users.json"); // ✅ Correction du chemin
            const data = await response.json();
            if (data.clients) {
                setClients(data.clients);
                setStatistics(data.statistics);
                if (data.clients.length > 0) {
                    setSelectedClientId(data.clients[0].id);
                }
            }
        } catch (error) {
            console.error("❌ Erreur lors du chargement des clients :", error);
        }
        setLoading(false);
    }, []);

    // 🔄 Charger les clients au démarrage
    useEffect(() => {
        loadClients();
    }, [loadClients]);

    // 📡 Écoute des mises à jour MQTT en temps réel
    useEffect(() => {
        if (mqttMessages.length > 0) {
            const newClientData = mqttMessages[mqttMessages.length - 1];

            setClients((prevClients) => {
                const clientExists = prevClients.some(client => client.id === newClientData.id);
                const updatedClients = clientExists
                    ? prevClients.map(client => (client.id === newClientData.id ? newClientData : client))
                    : [...prevClients, newClientData];

                // 🔄 Recalcul COMPLET des statistiques
                setStatistics((prevStats) => {
                    if (!prevStats) return prevStats;

                    const totalClients = updatedClients.length;
                    const totalConfidence = updatedClients.reduce((sum, c) => sum + (c.confidenceScore || 0), 0);
                    const averageConfidence = totalClients > 0 ? (totalConfidence / totalClients).toFixed(1) : 0;

                    const totalParticipations = updatedClients.reduce((sum, c) => sum + (c.participations?.length || 0), 0);

                    return {
                        ...prevStats,
                        totalClients,   // 🆕 Nombre total de clients mis à jour
                        averageConfidence, // 🆕 Score de confiance mis à jour
                        totalParticipations // 🆕 Nombre total de participations mis à jour
                    };
                });

                return updatedClients;
            });
        }
    }, [mqttMessages]);

   // 📤 Exportation de l'historique du client sélectionné
        const exportSelectedClientHistory = () => {
            const selectedClient = clients.find(client => client.id === selectedClientId);

            if (!selectedClient || !selectedClient.confidenceHistory) {
                alert("❌ Aucune donnée d'historique disponible pour ce client.");
                return;
            }

            const dataStr = "data:text/json;charset=utf-8," + encodeURIComponent(
                JSON.stringify({
                    clientId: selectedClient.id,
                    username: selectedClient.username,
                    confidenceHistory: selectedClient.confidenceHistory
                }, null, 2)
            );

            const downloadAnchor = document.createElement("a");
            downloadAnchor.href = dataStr;
            downloadAnchor.download = `historique_client_${selectedClient.username}.json`;
            document.body.appendChild(downloadAnchor);
            downloadAnchor.click();
            document.body.removeChild(downloadAnchor);
        };

        // 📤 Exportation de l'historique de tous les événements (tous les clients)
        const exportAllClientsHistory = () => {
            if (!clients.length) {
                alert("❌ Aucune donnée d'historique disponible.");
                return;
            }

            const dataStr = "data:text/json;charset=utf-8," + encodeURIComponent(
                JSON.stringify(clients.map(client => ({
                    clientId: client.id,
                    username: client.username,
                    confidenceHistory: client.confidenceHistory || []
                })), null, 2)
            );

            const downloadAnchor = document.createElement("a");
            downloadAnchor.href = dataStr;
            downloadAnchor.download = "historique_tous_les_clients.json";
            document.body.appendChild(downloadAnchor);
            downloadAnchor.click();
            document.body.removeChild(downloadAnchor);
        };

        // 📌 Calcul des tendances de confiance
        const analyzeConfidenceTrend = (client) => {
            if (!client || !client.confidenceHistory || client.confidenceHistory.length < 2) {
                return "⚠️ Données insuffisantes";
            }
            
            const initialScore = client.confidenceHistory[0];
            const lastScore = client.confidenceScore;

            if (lastScore > initialScore) {
                return `📈 Augmentation (+${(lastScore - initialScore).toFixed(1)}%)`;
            } else if (lastScore < initialScore) {
                return `📉 Diminution (-${(initialScore - lastScore).toFixed(1)}%)`;
            } else {
                return "🔄 Stable";
            }
        };

        // 📊 Configuration des données du graphique pour l'évolution de confiance
        const confidenceAnalysisData = {
            labels: clients.map(client => client.username),
            datasets: [
                {
                    label: "Score de confiance initial",
                    data: clients.map(client => client.confidenceHistory ? client.confidenceHistory[0] : 0),
                    backgroundColor: "rgba(75, 192, 192, 0.6)",
                    borderColor: "rgba(75, 192, 192, 1)",
                    borderWidth: 1,
                },
                {
                    label: "Dernier score de confiance",
                    data: clients.map(client => client.confidenceScore),
                    backgroundColor: "rgba(255, 99, 132, 0.6)",
                    borderColor: "rgba(255, 99, 132, 1)",
                    borderWidth: 1,
                }
            ]
        };

        // 📌 Vérification et correction des données du Pie Chart
        const participationValues = clients.map(client => client.participations ? client.participations.length : 0);

        // 🛠 Si toutes les valeurs sont 0, on met une valeur minimale pour éviter un Pie Chart vide
        const hasValidData = participationValues.some(value => value > 0);
        const adjustedParticipationValues = hasValidData ? participationValues : clients.map((_, index) => (index === 0 ? 1 : 0));

        const participationData = {
            labels: clients.map(client => client.username),
            datasets: [
                {
                    data: adjustedParticipationValues,
                    backgroundColor: ["#ff6384", "#36a2eb", "#ffce56", "#4bc0c0", "#9966ff"],
                    hoverOffset: 4
                }
            ]
        };


    if (loading) {
        return <p className="text-center">⏳ Chargement des statistiques...</p>;
    }

    if (!statistics || !clients.length) {
        return <p className="text-center text-danger">❌ Erreur : Données non disponibles.</p>;
    }

    return (
        <Container className="mt-4">
            <h2 className="text-center text-primary">📊 Tableau de Bord des Clients (Temps Réel)</h2>


            {/* ✅ Statistiques Globales */}
            <Card className="shadow-lg p-4 mt-4">
                <h4 className="text-success">📈 Statistiques Globales</h4>
                <Table striped bordered hover className="mt-3">
                    <tbody>
                        <tr>
                            <td><strong>👥 Nombre Total de Clients</strong></td>
                            <td>{statistics.totalClients}</td>
                        </tr>
                        <tr>
                            <td><strong>🔥 Score de Confiance Moyen</strong></td>
                            <td>
                                <ProgressBar now={statistics.averageConfidence} label={`${statistics.averageConfidence}%`} />
                            </td>
                        </tr>
                        <tr>
                            <td><strong>📌 Nombre Total de Participations</strong></td>
                            <td>{statistics.totalParticipations}</td>
                        </tr>
                    </tbody>
                </Table>
            </Card>


            <Card className="shadow-lg p-4 mt-4">
                <h4 className="text-info">📊 Analyse des Scores de Confiance</h4>
              
                {/* Graphique des évolutions des scores de confiance */}
                <div style={{ height: "300px" }}>
                    <Bar data={confidenceAnalysisData} />
                </div>
            </Card>

            <Card className="shadow-lg p-4 mt-4">
                <h4 className="text-warning">🟡 Répartition des Participations</h4>
                {/* Graphique circulaire des participations */}
                <div style={{ height: "300px" }}>
                    <Pie data={participationData} />
                </div>
            </Card>

            {/* ✅ Sélection de l'utilisateur */}
            <Card className="shadow-lg p-4 mt-4">
                <h4 className="text-primary">📌 Sélectionner un Client</h4>
                <select className="form-select" value={selectedClientId} onChange={(e) => setSelectedClientId(e.target.value)}>
                    {clients.map(client => (
                        <option key={client.id} value={client.id}>{client.username}</option>
                    ))}
                </select>
            </Card>

            <Card className="shadow-lg p-4 mt-4">
                <h4 className="text-secondary">📤 Exportation des Historiques</h4>
                <Row>
                    <Col md={6}>
                        <Button variant="primary" className="w-100 mb-2" onClick={exportSelectedClientHistory}>
                            📥 Exporter l'historique du client sélectionné
                        </Button>
                    </Col>
                    <Col md={6}>
                        <Button variant="danger" className="w-100" onClick={exportAllClientsHistory}>
                            📤 Exporter l'historique de tous les événements
                        </Button>
                    </Col>
                </Row>
            </Card>

            {/* ✅ Historique du Score de Confiance */}
            <Card className="shadow-lg p-4 mt-4">
                <h4 className="text-dark">📈 Historique du Score de Confiance</h4>
                <Row>
                    <Col md={4} className="d-flex flex-column align-items-center justify-content-center">
                        <h5 className="text-dark">🎯 Score Actuel</h5>
                        <h2 className="text-primary">
                            {clients.find(c => c.id === selectedClientId)?.confidenceScore || "N/A"}%
                        </h2>
                    </Col>
                    <Col md={8}>
                        <div style={{ height: "300px" }}>
                            <Line data={{
                                labels: clients.find(c => c.id === selectedClientId)?.confidenceHistory.map((_, i) => `Échantillon ${i + 1}`) || [],
                                datasets: [
                                    {
                                        label: "Historique du Score de Confiance",
                                        data: clients.find(c => c.id === selectedClientId)?.confidenceHistory || [],
                                        borderColor: "#36a2eb",
                                        backgroundColor: "rgba(54, 162, 235, 0.2)",
                                        borderWidth: 2,
                                        tension: 0.3
                                    }
                                ]
                            }} />
                        </div>
                    </Col>
                </Row>
            </Card>
        </Container>
    );
};

export default ClientDashboard;
