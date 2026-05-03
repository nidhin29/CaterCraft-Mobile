# 🍽️ CaterCraft - Full-Stack Catering Management Platform

**CaterCraft** is a high-performance, scalable catering management ecosystem. It streamlines role-based management for Admin, Owners, Staff, and Customers through a unified infrastructure.

This repository contains the **Admin Flutter Application**, the central control hub for the entire platform.

---

## 🏗️ Ecosystem Architecture

The CaterCraft platform is composed of four primary components:
1.  **Flutter Mobile App**: High-performance app for Admins, Owners, and Staff.
2.  **Dual React.js Web Portals**: Dedicated portals for detailed Administration and Customer Bookings.
3.  **Node.js Backend**: An event-driven RESTful API powered by MongoDB.
4.  **Infrastructure**: RabbitMQ messaging, Redis caching, and AWS cloud hosting.

---

## 🚀 Key Technological Highlights

### 📨 Event-Driven Messaging (RabbitMQ)
The platform leverages an event-driven architecture using **RabbitMQ** to offload time-intensive tasks:
*   **Asynchronous Notifications**: Emails and FCM Push Notifications are queued and processed by background workers to maintain sub-100ms API response times.
*   **System Reliability**: Decouples core business logic from external service integrations (like Razorpay webhooks).

### 🔐 Secure & Real-time Communication
*   **End-to-End Encryption (E2EE)**: Secure messaging hub for owners and staff, ensuring sensitive event details remain private.
*   **Live Synchronization**: Powered by **Socket.io** for real-time booking status tracking and instant dashboard updates.

### 💰 Financial Engine
*   **Commission Tracking**: Automated calculation of platform commissions (10% per booking).
*   **Razorpay Integration**: Seamless production-ready payment processing with robust webhook handling.

---

## 🛠️ Tech Stack (Ecosystem)

*   **Mobile**: Flutter (Dart) + BLoC State Management
*   **Web**: React.js + Vanilla CSS
*   **Backend**: Node.js + Express + MongoDB
*   **Messaging**: RabbitMQ (AMQP)
*   **Caching**: Redis
*   **Cloud**: AWS (EC2 for Backend, S3 for static Web & Media)
*   **DevOps**: Docker + GitHub Actions (CI/CD)

---

## 📱 Admin App Features (This Repo)

### 🔑 Admin Authentication
*   Secure Login with session token persistence.
*   Splash screen verification with auto-logout safety.

### 👥 Team & Customer Management
*   **Service Provider Oversight**: Approve/Delete catering company profiles.
*   **Customer Database**: Track engagement, service history, and retention metrics.

### 📋 Booking & Revenue Oversight
*   Monitor every booking across the entire platform.
*   Real-time revenue tracking and commission reporting via MongoDB aggregation pipelines.

---

## ⚙️ Getting Started

### Prerequisites
*   Flutter SDK (3.x+)
*   API Base URL configured in `lib/constants/const.dart`

### Installation
1.  **Clone & Install**:
    ```bash
    flutter pub get
    ```
2.  **Code Generation**:
    ```bash
    flutter packages pub run build_runner build
    ```
3.  **Run**:
    ```bash
    flutter run
    ```

---

## 🚢 Deployment (DevOps)

The entire ecosystem is containerized using **Docker** and deployed via **GitHub Actions** to **AWS EC2** (Backend) and **AWS S3** (Web Portals), ensuring consistent delivery across environments.

---

## 👨‍💻 Developer
**Nidhin V Ninan**  
[GitHub](https://github.com/nidhin29) | [Portfolio](https://yourportfolio.com)

---

*Developed with ❤️ for Premium Catering Operations*
