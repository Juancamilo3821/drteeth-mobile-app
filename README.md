# Drteeth Mobile App

**Drteeth** es una aplicación móvil multiplataforma desarrollada en Flutter para la gestión odontológica integral de pacientes. Ofrece funcionalidades clave como visualización de citas, tratamientos, historial clínico, manejo de incapacidades, pagos, emergencias dentales y administración del perfil del paciente. La app se comunica con una API REST desarrollada en Node.js y Express, consumiendo datos en tiempo real desde una base de datos MySQL.

---

## Tecnologías utilizadas

- **Flutter** + **Dart** — UI moderna, multiplataforma
- **HTTP Client** — Consumo de servicios REST
- **Arquitectura basada en el patrón MVC (Modelo-Vista-Controlador)**
- **Animaciones personalizadas** (Splash, navegación)
- Backend: [Drteeth API (Node.js + Express)](https://github.com/tu_usuario/drteeth-api)

---

## Funcionalidades principales

- Registro e inicio de sesión seguro
- Gestión de citas médicas
- Visualización de tratamientos activos
- Registro y consulta de incapacidades
- Gestión de pagos y facturación
- Módulo de emergencias dentales
- Administración del perfil del paciente
- Navegación fluida entre pantallas

---

## Arquitectura MVC en Flutter

El proyecto sigue una estructura basada en el patrón Modelo-Vista-Controlador (MVC):

- **Modelos:** Representan entidades como citas, tratamientos o discapacidades.
- **Vistas:** Archivos en `lib/Screens/` encargados de la interfaz de usuario.
- **Controladores (Servicios):** Archivos en `lib/Services/` que gestionan la lógica de negocio y las llamadas a la API REST.

Esta separación facilita el mantenimiento, escalabilidad y claridad del código, siguiendo buenas prácticas de desarrollo de software.

---

## 🧭 Estructura del proyecto
```
![image](https://github.com/user-attachments/assets/10ee6447-3229-4bfe-8562-bb0ecea5306f)


---

## ⚙️ Instalación y ejecución

```bash
git clone https://github.com/tu_usuario/drteeth-mobile-app.git
cd drteeth-mobile-app
flutter pub get
flutter run
```

> Asegúrate de tener configurado un emulador o dispositivo físico antes de correr la app.

---

## 📡 Conexión con el backend

Esta app está conectada a una API REST personalizada. Asegúrate de que el backend esté corriendo localmente en el puerto definido (por defecto `http://10.0.2.2:3000` para emuladores Android).

Repositorio del backend 👉 [drteeth-api](https://github.com/tu_usuario/drteeth-api)

---

