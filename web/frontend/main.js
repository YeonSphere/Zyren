// Main JavaScript file for Seoggi Web Application

// DOM Elements
const navLinks = document.querySelectorAll('nav a');
const sections = document.querySelectorAll('main section');
const contactForm = document.querySelector('#contact form');

// Navigation functionality
navLinks.forEach(link => {
    link.addEventListener('click', (e) => {
        e.preventDefault();
        const targetId = link.getAttribute('href').substring(1);
        sections.forEach(section => {
            section.style.display = section.id === targetId ? 'block' : 'none';
        });
    });
});

// Contact form submission
contactForm.addEventListener('submit', (e) => {
    e.preventDefault();
    const formData = new FormData(contactForm);
    const name = formData.get('name');
    const email = formData.get('email');
    const message = formData.get('message');

    // TODO: Implement actual form submission to backend
    console.log('Form submitted:', { name, email, message });
    alert('Thank you for your message. We will get back to you soon!');
    contactForm.reset();
});

// Initialize the page
document.addEventListener('DOMContentLoaded', () => {
    // Show the home section by default
    sections.forEach(section => {
        section.style.display = section.id === 'home' ? 'block' : 'none';
    });
});
