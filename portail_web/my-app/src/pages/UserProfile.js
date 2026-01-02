import React, { useContext, useState } from "react";
import { Container, Card, Spinner, Table } from "react-bootstrap";
import { useParams } from "react-router-dom";
import Pagination from "../components/Pagination"; // ✅ Import du composant de pagination
import { DataContext } from "../data/DataContext"; // ✅ Import du contexte

const UserProfile = () => {
    const { id } = useParams();
    const { users, loading } = useContext(DataContext); // ✅ Récupérer les utilisateurs via le contexte

    const user = users.find(u => u.id === parseInt(id, 10));

    // 🔹 Pagination pour les participations
    const [page, setPage] = useState(0);
    const itemsPerPage = 5;
    const totalPages = user ? Math.ceil((user.participations?.length || 0) / itemsPerPage) : 1;
    const paginatedParticipations = user?.participations.slice(page * itemsPerPage, (page + 1) * itemsPerPage) || [];

    return (
        <Container className="mt-4">
            {loading ? (
                <Spinner animation="border" role="status" className="d-block mx-auto my-3">
                    <span className="visually-hidden">Chargement...</span>
                </Spinner>
            ) : user ? (
                <>
                    <Card className="shadow p-4 mb-4">
                        <h2 className="text-center text-primary">Profil de {user.username}</h2>
                        <p><strong>Email :</strong> {user.email}</p>
                        <p><strong>Localisation :</strong> {user.locationName || "Non renseignée"}</p>
                        <p><strong>Score de Confiance :</strong> {user.confidenceScore} / 100</p>
                    </Card>

                    {/* 📅 Affichage des participations avec pagination */}
                    <Card className="shadow p-4 mb-4">
                        <h3 className="text-center text-success">📅 Participations aux Événements</h3>
                        {user.participations.length > 0 ? (
                            <>
                                <Table striped bordered hover className="mt-3">
                                    <thead>
                                    <tr>
                                        <th>#</th>
                                        <th>Titre</th>
                                        <th>Lieu</th>
                                        <th>Score de Confiance</th>
                                    </tr>
                                    </thead>
                                    <tbody>
                                    {paginatedParticipations.map((event, index) => (
                                        <tr key={event.id}>
                                            <td>{index + 1 + page * itemsPerPage}</td>
                                            <td>{event.title}</td>
                                            <td>{event.location}</td>
                                            <td>{event.confidenceScore}%</td>
                                        </tr>
                                    ))}
                                    </tbody>
                                </Table>

                                {/* 📌 Utilisation du composant de pagination */}
                                <Pagination page={page} totalPages={totalPages} setPage={setPage} />
                            </>
                        ) : (
                            <p className="text-center text-muted">Aucune participation.</p>
                        )}
                    </Card>
                </>
            ) : (
                <p className="text-center text-danger">⚠️ Utilisateur non trouvé.</p>
            )}
        </Container>
    );
};

export default UserProfile;
