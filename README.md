# 🦷 Drteeth Mobile App

**Drteeth** es una aplicación móvil multiplataforma desarrollada en Flutter para la gestión odontológica integral de pacientes. Ofrece funcionalidades clave como visualización de citas, tratamientos, historial clínico, manejo de incapacidades, pagos, emergencias dentales y administración del perfil del paciente. La app se comunica con una API REST desarrollada en Node.js y Express, consumiendo datos en tiempo real desde una base de datos MySQL.

---

## 🚀 Tecnologías utilizadas

- **Flutter** + **Dart** — UI moderna, multiplataforma
- **HTTP Client** — Consumo de servicios REST
- **Arquitectura basada en el patrón MVC (Modelo-Vista-Controlador)**
- **Animaciones personalizadas** (Splash, navegación)
- Backend: [Drteeth API (Node.js + Express)](https://github.com/tu_usuario/drteeth-api)

---

## 📲 Funcionalidades principales

- 🔐 Registro e inicio de sesión seguro
- 📅 Gestión de citas médicas
- 💊 Visualización de tratamientos activos
- 🦠 Registro y consulta de incapacidades
- 💳 Gestión de pagos y facturación
- 🚨 Módulo de emergencias dentales
- 👤 Administración del perfil del paciente
- 🔁 Navegación fluida entre pantallas

---

## 🧱 Arquitectura MVC en Flutter

El proyecto sigue una estructura basada en el patrón Modelo-Vista-Controlador (MVC):

- **Modelos:** Representan entidades como citas, tratamientos o discapacidades.
- **Vistas:** Archivos en `lib/Screens/` encargados de la interfaz de usuario.
- **Controladores (Servicios):** Archivos en `lib/Services/` que gestionan la lógica de negocio y las llamadas a la API REST.

Esta separación facilita el mantenimiento, escalabilidad y claridad del código, siguiendo buenas prácticas de desarrollo de software.

---

## 🧭 Estructura del proyecto

