import axios from "axios";

const BASE_URL = "http://localhost:8085/api/users"; // Base commune pour éviter les répétitions

// Définition des endpoints
const API_ENDPOINTS = {
    usersPaginated: `${BASE_URL}/clientspages`,
    userProfile: (id) => `${BASE_URL}/${id}/profile`,
    usersWithPosition: `${BASE_URL}/clients/with-position`
};

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
 * Récupère la liste des utilisateurs avec pagination et recherche par username.
 * @param {number} page - Numéro de la page
 * @param {number} size - Nombre d'éléments par page
 * @param {string} username - Nom d'utilisateur (optionnel)
 * @returns {Promise} - Liste paginée des utilisateurs
 */
export const fetchUsers = async (page = 0, size = 10, username = "") => {
    return fetchData(API_ENDPOINTS.usersPaginated, { page, size, username });
};

/**
 * Récupère le profil d'un utilisateur par son ID.
 * @param {number} id - ID de l'utilisateur
 * @returns {Promise} - Détails du profil utilisateur
 */
export const fetchUserProfile = async (id) => {
    return fetchData(API_ENDPOINTS.userProfile(id));
};

/**
 * Récupère les utilisateurs ayant une position GPS.
 * @returns {Promise} - Liste des utilisateurs avec latitude et longitude
 */
export const fetchUsersWithPosition = async () => {
    return fetchData(API_ENDPOINTS.usersWithPosition);
};
