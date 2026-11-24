"use strict";

const path = require("node:path");
const express = require("express");
const helmet = require("helmet");
const deviceRoutes = require("./routes/devices");
require("dotenv").config({ path: path.join(__dirname, "..", ".env") });

const app = express();

const PORT = Number.parseInt(process.env.PORT || "4170", 10);
const HOST = process.env.HOST || "127.0.0.1";

if (!Number.isInteger(PORT) || PORT < 1 || PORT > 65535) {
    throw new Error("Invalid PORT configuration.");
}

app.disable("x-powered-by");
app.use(helmet());
app.use(express.json({ limit: "32kb" }));

app.use("/api/devices", deviceRoutes);

app.get("/api/health", (_req, res) => {
    res.json({
        success: true,
        application: "Android Control Center",
        service: "web-api",
        status: "running",
        timestamp: new Date().toISOString()
    });
});

app.use(express.static(path.join(__dirname, "..", "public"), {
    index: "index.html",
    dotfiles: "deny"
}));

app.use("/api", (_req, res) => {
    res.status(404).json({
        success: false,
        error: "API endpoint not found."
    });
});

app.use((err, _req, res, _next) => {
    console.error("Server error:", err.message);

    res.status(500).json({
        success: false,
        error: "Internal server error."
    });
});

app.listen(PORT, HOST, () => {
    console.log(`Android Control Center web server running at http://${HOST}:${PORT}`);
    console.log(`Health check: http://${HOST}:${PORT}/api/health`);
});

