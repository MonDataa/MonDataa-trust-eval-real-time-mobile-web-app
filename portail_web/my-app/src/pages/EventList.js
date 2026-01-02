import React, { useEffect, useState, useCallback } from "react";
import { Container, Table, Spinner } from "react-bootstrap";
import { Link } from "react-router-dom";
import Pagination from "../components/Pagination";
import SearchBar from "../components/SearchBarEvents";
import useMqttService from "../services/mqttService"; // 📡 WebSocket MQTT

const EventList = () => {
    const [events, setEvents] = useState([]); // Stocker les événements
    const [filteredEvents, setFilteredEvents] = useState([]); // Événements filtrés
    const [page, setPage] = useState(0); // Page actuelle
    const [totalPages, setTotalPages] = useState(1); // Nombre total de pages
    const [loading, setLoading] = useState(false); // Indicateur de chargement
    const [searchTerm, setSearchTerm] = useState(""); // Terme de recherche
    const [searchField, setSearchField] = useState("title"); // Champ de recherche
    const mqttMessages = useMqttService("trustevalevents"); // 📡 Écoute MQTT pour mises à jour

    // 📥 Charger les événements depuis le fichier JSON
    const loadEvents = useCallback(async () => {
        setLoading(true);
        try {
            const response = await fetch("/public/events.json"); // 📂 Charge depuis le fichier JSON
            const data = await response.json();

            if (data.events) {
                setEvents(data.events);
                setFilteredEvents(data.events); // Initier les événements filtrés
                setTotalPages(Math.ceil(data.events.length / 10)); // 📌 Pagination basée sur 10 événements/page
            }
        } catch (error) {
            console.error("❌ Erreur lors du chargement des événements :", error);
        }
        setLoading(false);
    }, []);

    // 🔄 Charger les événements initiaux
    useEffect(() => {
        loadEvents();
    }, [loadEvents]);

    // 📡 Écoute MQTT pour mise à jour en temps réel
    useEffect(() => {
        if (mqttMessages.length > 0) {
            const newEvent = mqttMessages[mqttMessages.length - 1];

            setEvents((prevEvents) => {
                const exists = prevEvents.some(event => event.id === newEvent.id);
                if (exists) {
                    return prevEvents.map(event => event.id === newEvent.id ? newEvent : event);
                } else {
                    return [newEvent, ...prevEvents];
                }
            });
        }
    }, [mqttMessages]);

    // 📌 Filtrer les événements selon le champ de recherche sélectionné
    useEffect(() => {
        if (searchTerm.trim() === "") {
            setFilteredEvents(events);
        } else {
            setFilteredEvents(events.filter(event => {
                const fieldValue = event[searchField] ? event[searchField].toString().toLowerCase() : "";
                return fieldValue.includes(searchTerm.toLowerCase());
            }));
        }
    }, [searchTerm, searchField, events]);

    // 📌 Paginer les événements filtrés
    const paginatedEvents = filteredEvents.slice(page * 10, (page + 1) * 10);

    return (
        <Container className="mt-4">
            <h2 className="text-center text-success">📅 Liste des Événements</h2>

            {/* ✅ Utilisation du composant SearchBar */}
            <SearchBar
                searchField={searchField}
                setSearchField={setSearchField}
                searchTerm={searchTerm}
                setSearchTerm={setSearchTerm}
                fields={[
                    { value: "title", label: "Titre" },
                    { value: "location", label: "Lieu" },
                ]}
            />

            {/* Affichage du chargement */}
            {loading && <Spinner animation="border" role="status" className="d-block mx-auto my-3">
                <span className="visually-hidden">Chargement...</span>
            </Spinner>}

            {/* Table des événements */}
            {!loading && (
                <Table striped bordered hover className="mt-3">
                    <thead>
                    <tr>
                        <th>#</th>
                        <th>Titre</th>
                        <th>Lieu</th>
                        <th>Participants</th>
                        <th>Score de Confiance</th>
                    </tr>
                    </thead>
                    <tbody>
                    {paginatedEvents.map((event, index) => (
                        <tr key={event.id}>
                            <td>{index + 1 + page * 10}</td>
                            <td>
                                <Link to={`/events/${event.id}`} className="text-decoration-none text-primary">
                                    {event.title}
                                </Link>
                            </td>
                            <td>{event.location}</td>
                            <td>{event.participants}</td>
                            <td>{event.confidenceScore}</td>
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

export default EventList;
