import React from "react";
import { Navbar as BootstrapNavbar, Nav, Container } from "react-bootstrap";
import { Link } from "react-router-dom";

const Navbar = () => {
    return (
        <BootstrapNavbar bg="primary" variant="dark" expand="lg">
            <Container>
                <BootstrapNavbar.Brand as={Link} to="/">
                    🌍 Portail web
                </BootstrapNavbar.Brand>
                <BootstrapNavbar.Toggle aria-controls="basic-navbar-nav" />
                <BootstrapNavbar.Collapse id="basic-navbar-nav">
                    <Nav className="ms-auto">
                        <Nav.Link as={Link} to="/">🏠 Accueil</Nav.Link>
                        <Nav.Link as={Link} to="/user-map">🗺️ Carte Utilisateur</Nav.Link>
                        <Nav.Link as={Link} to="/event-map">🎉 Carte Évènements</Nav.Link>
                        <Nav.Link as={Link} to="/user-list">👥 Liste des Utilisateurs</Nav.Link>
                        <Nav.Link as={Link} to="/event-list">📅 Liste des Évènements</Nav.Link>
                        <Nav.Link as={Link} to="/dashboard">📑 Stats des Évènements</Nav.Link>
                        <Nav.Link as={Link} to="/dashboardUsers">📑 Stats des Utilisateurs</Nav.Link>
                    </Nav>
                </BootstrapNavbar.Collapse>
            </Container>
        </BootstrapNavbar>
    );
};

export default Navbar;
