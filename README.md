# BuyFlow

**BuyFlow** is a mobile application for purchase management built with a full-stack architecture:

* **Backend**: Spring Boot (Java)
* **Frontend**: Flutter (Dart)

The application allows users to manage purchases through a mobile interface backed by a robust REST API.

---

## Table of Contents

* [About](#about)
* [Features](#features)
* [Technologies](#technologies)
* [Project Structure](#project-structure)
* [Installation](#installation)
* [Running the Project](#running-the-project)
* [Usage](#usage)
* [Contributing](#contributing)
* [License](#license)

---

## About

BuyFlow is designed to simplify purchase management on mobile devices. It combines a Spring Boot backend responsible for business logic and data persistence with a Flutter mobile frontend that provides a responsive and cross-platform user experience.

---

## Features

> The exact feature set depends on the current implementation. Typical features include:

* User authentication
* Viewing and managing purchases
* Create, update, and delete purchase records
* Communication between Flutter app and REST API
* Cross-platform mobile support (Android / iOS)

---

## Technologies

| Layer                            | Technology                                |
| -------------------------------- | ----------------------------------------- |
| Backend                          | Spring Boot (Java)                        |
| Frontend                         | Flutter (Dart)                            |
| Dependency Management (Backend)  | Maven / Gradle                            |
| Dependency Management (Frontend) | Dart / Pub                                |
| Database                         | MySQL                                     |

---

## Project Structure

```
BuyFlow/
│── backend-springboot/    # Spring Boot API
│── frontend-flutter/     # Flutter mobile application
│── README.md
│── LICENSE
```

---

## Installation

### Prerequisites

Make sure you have the following installed:

* Git
* Java JDK 17+ (or the version required by Spring Boot)
* Flutter SDK
* An IDE or editor (IntelliJ IDEA, Android Studio, VS Code)
* Android Emulator or physical mobile device

### Clone the Repository

```bash
git clone https://github.com/Chahra123/BuyFlow.git
cd BuyFlow
```

---

## Running the Project

### Backend (Spring Boot)

1. Navigate to the backend directory:

```bash
cd backend-springboot
```

2. Configure `application.properties` or `application.yml` if needed (database, ports, credentials).

3. Start the application:

```bash
./mvnw spring-boot:run
# or (Gradle)
./gradlew bootRun
```

The backend API will be available at:

```
http://localhost:8080
```

---

### Frontend (Flutter)

1. Navigate to the Flutter project:

```bash
cd frontend-flutter
```

2. Install dependencies:

```bash
flutter pub get
```

3. Run the application:

```bash
flutter run
```

The application will launch on the connected emulator or physical device.

---

## Usage

Once the application is running:

* Open the mobile app
* Authenticate if required
* Navigate through the purchase management screens
* Perform CRUD operations on purchases

You can enhance this section by adding screenshots or GIFs to illustrate the workflow.

---

## Contributing

Contributions are welcome.

1. Fork the repository
2. Create a feature branch (`feature/my-feature`)
3. Commit your changes with clear messages
4. Push the branch and open a Pull Request

Please follow clean code practices and existing project conventions.

---

## License

This project is licensed under the **CC0-1.0 (Public Domain)** license. See the `LICENSE` file for details.
