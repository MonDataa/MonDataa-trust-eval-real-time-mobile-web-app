import { useEffect, useState } from "react";

const WEBSOCKET_URL = "ws://localhost:8085/mqtt"; // ✅ URL du WebSocket MQTT

const useMqttService = (topic) => {
    const [messages, setMessages] = useState([]);

    useEffect(() => {
        const ws = new WebSocket(WEBSOCKET_URL);

        ws.onopen = () => {
            console.log(`✅ Connecté au WebSocket MQTT sur le topic : ${topic}`);
            ws.send(JSON.stringify({ action: "subscribe", topic }));
        };

        ws.onmessage = (event) => {
            console.log("📡 Nouvel événement MQTT reçu :", event.data);
            try {
                const newEvent = JSON.parse(event.data);
                setMessages((prevMessages) => [...prevMessages, newEvent]);
            } catch (error) {
                console.error("❌ Erreur de parsing MQTT :", error);
            }
        };

        ws.onerror = (error) => {
            console.error("🚨 Erreur WebSocket MQTT :", error);
        };

        ws.onclose = () => {
            console.log("🔌 WebSocket MQTT déconnecté");
        };

        return () => {
            ws.close();
        };
    }, [topic]);

    return messages; // 📡 Retourne les messages MQTT reçus
};

export default useMqttService;
