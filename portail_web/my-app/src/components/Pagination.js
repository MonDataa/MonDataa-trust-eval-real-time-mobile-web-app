import React from "react";
import { Button } from "react-bootstrap";

const Pagination = ({ page, totalPages, setPage }) => {
    return (
        <div className="d-flex justify-content-center mt-3">
            <Button
                variant="primary"
                onClick={() => setPage(page - 1)}
                disabled={page === 0}
                className="me-2"
            >
                ⬅ Précédent
            </Button>
            <span className="align-self-center">Page {page + 1} / {totalPages}</span>
            <Button
                variant="primary"
                onClick={() => setPage(page + 1)}
                disabled={page + 1 >= totalPages}
                className="ms-2"
            >
                Suivant ➡
            </Button>
        </div>
    );
};

export default Pagination;
