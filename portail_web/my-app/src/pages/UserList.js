import React, { useEffect, useState, useCallback } from "react";
import { Container, Table, Spinner } from "react-bootstrap";
import { Link } from "react-router-dom";
import Pagination from "../components/Pagination";
import SearchBar from "../components/SearchBar"; // ✅ Import du composant SearchBar
import useMqttService from "../services/mqttService"; // 📡 Service MQTT pour mises à jour

const UserList = () => {
    const [users, setUsers] = useState([]); // Stocker les utilisateurs
    const [filteredUsers, setFilteredUsers] = useState([]); // Utilisateurs filtrés
    const [page, setPage] = useState(0); // Page actuelle
    const [totalPages, setTotalPages] = useState(1); // Nombre total de pages
    const [loading, setLoading] = useState(false); // Indicateur de chargement
    const [searchTerm, setSearchTerm] = useState(""); // Terme de recherche
    const [searchField, setSearchField] = useState("username"); // Champ de recherche
    const mqttMessages = useMqttService(); // 📡 Écoute MQTT pour mises à jour

    // 📥 Charger les utilisateurs depuis le fichier JSON
    const loadUsers = useCallback(async () => {
        setLoading(true);
        try {
            const response = await fetch("/public/users.json"); // 📂 Charge depuis le fichier JSON
            const data = await response.json();

            if (data.clients) {
                setUsers(data.clients);
                setFilteredUsers(data.clients); // Initier les utilisateurs filtrés
                setTotalPages(Math.ceil(data.clients.length / 10)); // 📌 Pagination basée sur 10 utilisateurs/page
            }
        } catch (error) {
            console.error("❌ Erreur lors du chargement des utilisateurs :", error);
        }
        setLoading(false);
    }, []);

    // 🔄 Charger les utilisateurs initiaux
    useEffect(() => {
        loadUsers();
    }, [loadUsers]);

    // 📡 Écoute MQTT pour mise à jour en temps réel
    useEffect(() => {
        if (mqttMessages.length > 0) {
            const newUser = mqttMessages[mqttMessages.length - 1];

            setUsers((prevUsers) => {
                const exists = prevUsers.some(user => user.id === newUser.id);
                if (exists) {
                    return prevUsers.map(user => user.id === newUser.id ? newUser : user);
                } else {
                    return [newUser, ...prevUsers];
                }
            });
        }
    }, [mqttMessages]);

    // 📌 Filtrer les utilisateurs selon le champ de recherche sélectionné
    useEffect(() => {
        if (searchTerm.trim() === "") {
            setFilteredUsers(users);
        } else {
            setFilteredUsers(users.filter(user => {
                const fieldValue = user[searchField] ? user[searchField].toString().toLowerCase() : "";
                return fieldValue.includes(searchTerm.toLowerCase());
            }));
        }
    }, [searchTerm, searchField, users]);

    // 📌 Paginer les utilisateurs filtrés
    const paginatedUsers = filteredUsers.slice(page * 10, (page + 1) * 10);

    return (
        <Container className="mt-4">
            <h2 className="text-center text-primary">👥 Liste des Utilisateurs</h2>

            {/* ✅ Utilisation du composant SearchBar */}
            <SearchBar
                searchField={searchField}
                setSearchField={setSearchField}
                searchTerm={searchTerm}
                setSearchTerm={setSearchTerm}
            />

            {/* Affichage du chargement */}
            {loading && <Spinner animation="border" role="status" className="d-block mx-auto my-3">
                <span className="visually-hidden">Chargement...</span>
            </Spinner>}

            {/* Table des utilisateurs */}
            {!loading && (
                <Table striped bordered hover className="mt-3">
                    <thead>
                    <tr>
                        <th>#</th>
                        <th>Nom d'utilisateur</th>
                        <th>Email</th>
                        <th>UserType</th>
                    </tr>
                    </thead>
                    <tbody>
                    {paginatedUsers.map((user, index) => (
                        <tr key={user.id}>
                            <td>{index + 1 + page * 10}</td>
                            <td>
                                <Link to={`/users/${user.id}`} className="text-decoration-none text-primary">
                                    {user.username}
                                </Link>
                            </td>
                            <td>{user.email}</td>
                            <td>{user.locationName || "Inconnue"}</td>
                        </tr>
                    ))}
                    </tbody>
                </Table>
            )}

            {/* Composant de pagination */}
            <Pagination page={page} totalPages={totalPages} setPage={setPage} />
        </Container>
    );
};

export default UserList;
