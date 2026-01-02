import React from "react";
import { Form } from "react-bootstrap";

const SearchBar = ({ searchField, setSearchField, searchTerm, setSearchTerm }) => {
    return (
        <Form className="mb-3">
            <Form.Group controlId="searchField">
                <Form.Label>🔍 Rechercher par :</Form.Label>
                <Form.Control as="select" value={searchField} onChange={(e) => setSearchField(e.target.value)}>
                    <option value="username">Nom d'utilisateur</option>
                    <option value="email">Email</option>
                    <option value="locationName">Localisation</option>
                </Form.Control>
            </Form.Group>

            <Form.Group controlId="searchTerm" className="mt-2">
                <Form.Control
                    type="text"
                    placeholder={`Rechercher par ${searchField}...`}
                    value={searchTerm}
                    onChange={(e) => setSearchTerm(e.target.value)}
                />
            </Form.Group>
        </Form>
    );
};

export default SearchBar;
