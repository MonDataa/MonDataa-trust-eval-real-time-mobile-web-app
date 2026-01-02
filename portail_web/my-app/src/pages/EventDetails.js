import React, { useContext, useState } from "react";
import { Container, Card, Spinner, Table, Badge, ProgressBar } from "react-bootstrap";
import { useParams } from "react-router-dom";
import Pagination from "../components/Pagination";
import { DataContext } from "../data/DataContext"; // ✅ Importer le contexte

const EventDetails = () => {
    const { id } = useParams();
    const { events, loading } = useContext(DataContext); // ✅ Utiliser le contexte

    const event = events.find(e => e.id === parseInt(id, 10));

    // 🔹 Pagination pour les confirmations
    const [page, setPage] = useState(0);
    const itemsPerPage = 5;
    const totalPages = event ? Math.ceil((event.confirmations?.length || 0) / itemsPerPage) : 1;

    return (
        <Container className="mt-4">
            {loading ? (
                <Spinner animation="border" role="status" className="d-block mx-auto my-3">
                    <span className="visually-hidden">Chargement...</span>
                </Spinner>
            ) : event ? (
                <Card className="shadow-lg p-4">
                    <h2 className="text-center text-primary">📍 {event.title}</h2>
                    <p><strong>Lieu :</strong> {event.location}, Zone {event.zone || "N/A"}</p>
                    <p><strong>Latitude :</strong> {event.latitude}, <strong>Longitude :</strong> {event.longitude}</p>
                    <p><strong>Date :</strong> {new Date(event.eventTime).toLocaleString()}</p>

                    <p>
                        <strong>Statut :</strong>
                        <Badge bg={event.status === "PENDING" ? "warning" : "success"} className="ms-2">
                            {event.status || "Inconnu"}
                        </Badge>
                    </p>

                    <Card className="shadow p-3 mt-4">
                        <h4 className="text-warning">🔍 Score de Confiance</h4>
                        <ProgressBar now={event.confidenceScore} label={`${event.confidenceScore}%`} />
                    </Card>

                    <Card className="shadow p-3 mt-4">
                        <h4 className="text-info">📋 Liste des Confirmations</h4>
                        {event.confirmations && event.confirmations.length > 0 ? (
                            <>
                                <Table striped bordered hover className="mt-3">
                                    <thead>
                                    <tr>
                                        <th>#</th>
                                        <th>ID Confirmation</th>
                                        <th>Date</th>
                                        <th>Client ID</th>
                                        <th>Statut</th>
                                    </tr>
                                    </thead>
                                    <tbody>
                                    {event.confirmations
                                        .slice(page * itemsPerPage, (page + 1) * itemsPerPage)
                                        .map((conf, index) => (
                                            <tr key={conf.id}>
                                                <td>{index + 1 + page * itemsPerPage}</td>
                                                <td>{conf.id}</td>
                                                <td>{new Date(conf.confirmationTime).toLocaleString()}</td>
                                                <td>{conf.clientId}</td>
                                                <td>
                                                    {conf.status ? (
                                                        <Badge bg="success">Validé</Badge>
                                                    ) : (
                                                        <Badge bg="danger">Non Validé</Badge>
                                                    )}
                                                </td>
                                            </tr>
                                        ))}
                                    </tbody>
                                </Table>

                                {/* 📌 Composant de pagination */}
                                <Pagination page={page} totalPages={totalPages} setPage={setPage} />
                            </>
                        ) : (
                            <p className="text-muted">Aucune confirmation enregistrée.</p>
                        )}
                    </Card>
                </Card>
            ) : (
                <p className="text-center text-danger">⚠️ Événement non trouvé.</p>
            )}
        </Container>
    );
};

export default EventDetails;
