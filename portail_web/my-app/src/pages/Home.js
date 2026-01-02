import React from "react";
import { Container, Card } from "react-bootstrap";

const Home = () => {
    return (
        <Container className="text-center mt-5">
            <Card className="shadow p-4">
                <h1 className="text-primary">Bienvenue sur l'espace Admin 🚀</h1>
                <p className="text-muted mt-3">
                    Utilisez le menu pour naviguer entre les différentes pages.
                </p>
            </Card>
        </Container>
    );
};

export default Home;
