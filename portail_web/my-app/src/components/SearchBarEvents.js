import React from "react";
import { Form } from "react-bootstrap";

const SearchBar = ({ searchField, setSearchField, searchTerm, setSearchTerm, fields }) => {
    return (
        <Form className="mb-3">
            <Form.Group controlId="searchField">
                <Form.Label>🔍 Rechercher par :</Form.Label>
                <Form.Control as="select" value={searchField} onChange={(e) => setSearchField(e.target.value)}>
                    {fields.map(field => (
                        <option key={field.value} value={field.value}>{field.label}</option>
                    ))}
                </Form.Control>
            </Form.Group>

            <Form.Group controlId="searchTerm" className="mt-2">
                <Form.Control
                    type="text"
                    placeholder={`Rechercher par ${fields.find(f => f.value === searchField)?.label || ""}...`}
                    value={searchTerm}
                    onChange={(e) => setSearchTerm(e.target.value)}
                />
            </Form.Group>
        </Form>
    );
};

export default SearchBar;
