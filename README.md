# Health Sync - Personalized Healthcare Management

Health Sync is a comprehensive healthcare management application designed to empower users with personalized health insights, emergency services, and organized medical history tracking. Built with Flutter and a powerful Supabase backend, it integrates AI-driven analysis to provide a seamless healthcare experience.

## 🚀 Core Features

### 🤖 AI Doctor & Health Assistant
An intelligent companion for your health journey, powered by advanced AI models.
- **Symptom Triage**: Input your symptoms via text or voice to receive immediate assessment and guidance.
- **Mental Health Support**: Talk to the AI for stress management and emotional well-being tips.
- **Personalized Recommendations**: Get health tips and lifestyle advice tailored to your medical profile.
- **Voice Integration**: Hands-free interaction using built-in speech-to-text capabilities.

### 🩸 Blood Donation & Emergency Network
A life-saving module that connects donors and recipients within the community.
- **Real-Time Donor Search**: Find active donors by blood group and proximity.
- **Request Management**: Post urgent blood requests and track donor responses.
- **Hospital Directory**: Quick access to a directory of hospital blood banks.
- **Donor Registration**: Easily register as a donor and manage your donation status.

### 📅 Smart Medical Timeline
Your complete medical history, organized and analyzed by AI.
- **Event Categorization**: Automatically separate and view Report Analyses, Prescriptions, and Lab Results.
- **AI Document Analysis**: Upload medical reports to have AI extract key findings and summarize results.
- **Severity Indicators**: At-a-glance severity levels (HIGH, MEDIUM, NORMAL) for all medical events.
- **Key Findings Chips**: Quickly see critical highlights from your reports without reading the full text.

### 📋 Personalized Health Plans
Custom-built wellness strategies based on your unique health data.
- **Tailored Strategies**: Receive health and wellness plans generated specific to your history.
- **Progress Tracking**: Keep tabs on your health goals and upcoming appointments.

---

## 🛠️ Technology Stack

- **Frontend Framework**: [Flutter](https://flutter.dev/) (3.10.3+)
- **State Management**: [Riverpod](https://riverpod.dev/) for robust and testable app state.
- **Database & Auth**: [Supabase](https://supabase.com/) for real-time data sync and secure authentication.
- **Edge Computing**: [Supabase Edge Functions](https://supabase.com/docs/guides/functions) for AI processing and business logic.
- **Notifications**: [Firebase Cloud Messaging (FCM)](https://firebase.google.com/docs/cloud-messaging) for real-time alerts.
- **Navigation**: [GoRouter](https://pub.dev/packages/go_router) for deep linking and declarative routing.

---

## 📁 Project Structure

```text
├── health_sync/          # Flutter Frontend Application
│   ├── lib/
│   │   ├── core/         # Themes, routers, and global constants
│   │   ├── features/     # Logic-separated feature modules
│   │   │   ├── ai_doctor/    # AI Assistant logic and pages
│   │   │   ├── blood/        # Blood donation donor search and requests
│   │   │   ├── timeline/     # Medical history and AI analysis
│   │   │   └── auth/         # Secure login and registration
│   │   ├── shared/       # Global models and reusable widgets
│   │   └── main.dart     # App entry point
│   └── assets/           # Images, logo, and localization files
└── backend/
    └── supabase/
        └── functions/    # Deno Edge Functions (AI Triage, Report Processing)
```

---

## ⚙️ Getting Started

### Prerequisites
- Flutter SDK (v3.10.3+)
- Supabase Project
- Firebase Project (for notifications)

### Installation

1.  **Clone the repository**:
    ```bash
    git clone https://github.com/your-username/health-sync.git
    ```

2.  **Setup Frontend**:
    ```bash
    cd health_sync
    flutter pub get
    ```

3.  **App Configuration**:
    - Add `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) from Firebase.
    - Set up your Supabase environment variables.

4.  **Run the App**:
    ```bash
    flutter run
    ```

---

## 🤝 Contributing
Contributions are what make the open source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

---
*Health Sync - Bridging the gap between technology and personalized care.*
