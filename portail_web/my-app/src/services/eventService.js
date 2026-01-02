import axios from "axios";

const BASE_URL = "http://localhost:8085/api/events"; // URL de base des événements

/**
 * Effectue une requête GET avec gestion des erreurs.
 * @param {string} url - L'URL de l'API
 * @param {object} [params={}] - Paramètres optionnels de la requête
 * @returns {Promise<any>} - Résultat de la requête
 */
const fetchData = async (url, params = {}) => {
    try {
        const response = await axios.get(url, { params });
        return response.data;
    } catch (error) {
        console.error(`❌ Erreur lors de la requête à ${url} :`, error);
        throw error;
    }
};

/**
 * Récupère les événements avec pagination et recherche par titre.
 * @param {number} page - Numéro de la page
 * @param {number} size - Nombre d'éléments par page
 * @param {string} title - Titre de l'événement (optionnel)
 * @returns {Promise} - Liste paginée des événements
 */
export const fetchEvents = async (page = 0, size = 8, title = "") => {
    return fetchData(`${BASE_URL}/pages`, { page, size, title });
};

/**
 * Récupère tous les événements sans pagination.
 * @returns {Promise} - Liste complète des événements
 */
export const fetchAllEvents = async () => {
    return fetchData(BASE_URL);
};

/**
 * Récupère les détails complets d'un événement par son ID.
 * @param {number} id - ID de l'événement
 * @returns {Promise} - Détails de l'événement
 */
export const fetchEventDetails = async (id) => {
    return fetchData(`${BASE_URL}/${id}/details`);
};
