import React from "react";
import { BrowserRouter as Router, Routes, Route } from "react-router-dom";
import { Container } from "react-bootstrap";
import Navbar from "./components/Navbar"; // Navbar réutilisable
import Footer from "./components/Footer"; // Footer réutilisable
import Home from "./pages/Home";
import UserMap from "./pages/UserMap";
import EventMap from "./pages/EventMap";
import UserList from "./pages/UserList";
import EventList from "./pages/EventList";
import UserProfile from "./pages/UserProfile";
import EventDetails from "./pages/EventDetails";
import Dashboard from "./pages/Dashboard";
import DashboardUsers from "./pages/DashboardUsers";
import { DataProvider } from "./data/DataContext"; // ✅ Import correct

const App = () => {
    return (
        <DataProvider> {/* ✅ Utiliser DataProvider ici */}
            <Router>
                <Navbar />
                <Container className="mt-4">
                    <Routes>
                        <Route path="/" element={<Home />} />
                        <Route path="/user-map" element={<UserMap />} />
                        <Route path="/event-map" element={<EventMap />} />
                        <Route path="/user-list" element={<UserList />} />
                        <Route path="/event-list" element={<EventList />} />
                        <Route path="/users/:id" element={<UserProfile />} />
                        <Route path="/events/:id" element={<EventDetails />} />
                        <Route path="/dashboard" element={<Dashboard />} />
                        <Route path="/dashboardUsers" element={<DashboardUsers />} />
                    </Routes>
                </Container>
                <Footer />
            </Router>
        </DataProvider>
);
};

export default App;