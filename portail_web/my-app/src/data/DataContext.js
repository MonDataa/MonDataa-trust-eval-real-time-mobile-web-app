import React, { createContext, useEffect, useState } from "react";

// ✅ Créer le contexte
export const DataContext = createContext();

export const DataProvider = ({ children }) => {
    const [events, setEvents] = useState([]);
    const [users, setUsers] = useState([]);
    const [loading, setLoading] = useState(true);

    // 📥 Charger les fichiers JSON UNE SEULE FOIS
    useEffect(() => {
        const fetchData = async () => {
            try {
                const [eventResponse, userResponse] = await Promise.all([
                    fetch("/public/events.json").then(res => res.json()),
                    fetch("/public/users.json").then(res => res.json())
                ]);

                setEvents(eventResponse.events || []);
                setUsers(userResponse.clients || []);
            } catch (error) {
                console.error("❌ Erreur lors du chargement des fichiers JSON :", error);
            }
            setLoading(false);
        };

        fetchData();
    }, []);

    return (
        <DataContext.Provider value={{ events, users, loading }}>
            {children}
        </DataContext.Provider>
    );
};
