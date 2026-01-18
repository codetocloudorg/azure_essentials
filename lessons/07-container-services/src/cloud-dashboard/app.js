// Cloud Dashboard JavaScript
// Code to Cloud - Azure Essentials

document.addEventListener('DOMContentLoaded', function () {
    // Update timestamp
    const timestampEl = document.getElementById('timestamp');
    if (timestampEl) {
        timestampEl.textContent = new Date().toISOString();
    }

    // Simulate live metrics updates
    setInterval(updateMetrics, 5000);

    // Initial animation
    animateCards();
});

function updateMetrics() {
    // Simulate changing metrics
    const latencyEl = document.getElementById('latency');
    if (latencyEl) {
        const latency = 40 + Math.floor(Math.random() * 20);
        latencyEl.textContent = latency + 'ms';
    }

    const requestsEl = document.getElementById('requests');
    if (requestsEl) {
        const requests = (1.1 + Math.random() * 0.3).toFixed(1);
        requestsEl.textContent = requests + 'M';
    }

    // Update timestamp
    const timestampEl = document.getElementById('timestamp');
    if (timestampEl) {
        timestampEl.textContent = new Date().toISOString();
    }
}

function animateCards() {
    const cards = document.querySelectorAll('.status-card');
    cards.forEach((card, index) => {
        card.style.opacity = '0';
        card.style.transform = 'translateY(20px)';

        setTimeout(() => {
            card.style.transition = 'opacity 0.5s ease, transform 0.5s ease';
            card.style.opacity = '1';
            card.style.transform = 'translateY(0)';
        }, index * 100);
    });
}

// Console branding
console.log(`
☁️ Cloud Dashboard
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Code to Cloud | Azure Essentials
Lesson 07: Container Services
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
`);
