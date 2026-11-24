"use strict";

document.addEventListener("DOMContentLoaded", () => {
    const serverStatus = document.getElementById("serverStatus");
    const apiStatus = document.getElementById("apiStatus");
    const currentTime = document.getElementById("currentTime");
    const sidebar = document.getElementById("sidebar");
    const menuButton = document.getElementById("menuButton");

    async function checkServer() {
        try {
            const response = await fetch("/api/health", {
                method: "GET",
                cache: "no-store",
                headers: { "Accept": "application/json" }
            });

            if (!response.ok) {
                throw new Error("Health check failed");
            }

            const data = await response.json();

            if (data.success !== true || data.status !== "running") {
                throw new Error("Unexpected health response");
            }

            serverStatus.textContent = "Server online";
            apiStatus.textContent = "Operational";
            apiStatus.classList.remove("unavailable");
        } catch {
            serverStatus.textContent = "Server unavailable";
            apiStatus.textContent = "Offline";
            apiStatus.classList.add("unavailable");
        }
    }

    function updateClock() {
        if (!currentTime) return;

        currentTime.textContent = new Intl.DateTimeFormat(undefined, {
            hour: "2-digit",
            minute: "2-digit",
            second: "2-digit"
        }).format(new Date());
    }

    if (menuButton && sidebar) {
        menuButton.addEventListener("click", () => {
            const isOpen = sidebar.classList.toggle("open");
            menuButton.setAttribute("aria-expanded", String(isOpen));
        });

        sidebar.querySelectorAll(".nav-link").forEach((link) => {
            link.addEventListener("click", () => {
                sidebar.classList.remove("open");
                menuButton.setAttribute("aria-expanded", "false");
            });
        });
    }

    updateClock();
    window.setInterval(updateClock, 1000);

    checkServer();
    window.setInterval(checkServer, 15000);
});
