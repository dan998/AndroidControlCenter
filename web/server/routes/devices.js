"use strict";

const path = require("node:path");
const { execFile } = require("node:child_process");
const express = require("express");

const router = express.Router();
const servicePath = path.join(__dirname, "..", "device-service.ps1");

router.get("/", (_req, res) => {
    execFile(
        "powershell.exe",
        [
            "-NoLogo",
            "-NoProfile",
            "-NonInteractive",
            "-ExecutionPolicy",
            "Bypass",
            "-File",
            servicePath
        ],
        {
            windowsHide: true,
            timeout: 15000,
            maxBuffer: 1024 * 1024,
            encoding: "utf8"
        },
        (error, stdout) => {
            if (error) {
                console.error("Device service failed:", error.message);
                return res.status(503).json({
                    success: false,
                    error: "Device service is temporarily unavailable."
                });
            }

            try {
                const result = JSON.parse(stdout);

                if (
                    result.success !== true ||
                    !Array.isArray(result.devices) ||
                    !Number.isInteger(result.count)
                ) {
                    throw new Error("Invalid device service response.");
                }

                return res.json(result);
            } catch (parseError) {
                console.error("Invalid device service response:", parseError.message);
                return res.status(502).json({
                    success: false,
                    error: "Invalid response from device service."
                });
            }
        }
    );
});

module.exports = router;
