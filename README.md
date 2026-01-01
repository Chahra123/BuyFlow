# 🛒 BuyFlow - Unified Purchase & Stock Management

[![Flutter](https://img.shields.io/badge/Flutter-3.10.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Spring Boot](https://img.shields.io/badge/Spring_Boot-2.5.3-6DB33F?logo=springboot&logoColor=white)](https://spring.io/projects/spring-boot)
[![MySQL](https://img.shields.io/badge/MySQL-8.0-4479A1?logo=mysql&logoColor=white)](https://www.mysql.com/)
[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](LICENSE)

**BuyFlow** is a comprehensive and modern solution for purchase and stock management. It combines an intuitive mobile interface developed with **Flutter** and a robust, secure backend powered by **Spring Boot**.

![BuyFlow Mockup](assets/buyflow_mockup.png)

---

## 🚀 Key Features

### 📱 Mobile Application (Frontend)
- **Dynamic Dashboard**: Real-time visualization of stock statistics via interactive charts (`fl_chart`).
- **Product Management**: View, add, and modify products with categories.
- **Stock Movements**: Precise tracking of goods inflow and outflow.
- **Secure Authentication**: Login, registration, and password recovery (JWT).
- **Multi-language**: Full support for French and English.

### ⚙️ Backend (API)
- **REST Architecture**: Clean and documented API for seamless integration.
- **Advanced Security**: Endpoint protection via **Spring Security** and **JWT**.
- **Supplier Management**: Centralized database for all actors in the purchase flow.
- **Invoicing & Payments**: Comprehensive module for financial tracking of transactions.
- **Statistics**: Dedicated endpoints for aggregating stock and performance data.

---

## 🛠️ Technical Stack

| Component | Technology |
| :--- | :--- |
| **Frontend** | Flutter, Riverpod (State Management), GoRouter, Dio (HTTP), Google Fonts |
| **Backend** | Java 17, Spring Boot 2.5.3, Spring Security, JPA/Hibernate, Maven |
| **Database** | MySQL |
| **Authentication** | JWT (JSON Web Token), OAuth2 (Google integration ready) |
| **API Documentation**| Swagger / Springfox |

---

## 📥 Installation and Setup

### 1. Backend (Spring Boot)
1. **Prerequisites**: Java 17+, MySQL 8.0+.
2. **Configuration**: Modify the `backend-springboot/src/main/resources/application.properties` file with your MySQL credentials.
   ```properties
   spring.datasource.url=jdbc:mysql://localhost:3306/buyflow?createDatabaseIfNotExist=true
   spring.datasource.username=YOUR_USERNAME
   spring.datasource.password=YOUR_PASSWORD
   ```
3. **Run**:
   ```bash
   cd backend-springboot
   ./mvnw spring-boot:run
   ```
   *The API will be accessible at: `http://localhost:9091`*

### 2. Frontend (Flutter)
1. **Prerequisites**: Flutter SDK (3.10+).
2. **Dependencies**:

   ```bash
   cd frontend-flutter
   flutter pub get
   ```
3. **Run**:

   ```bash
   flutter run
   ```

---

## 🔌 Useful APIs (Overview)

### Authentication (`/api/auth`)
- `POST /login`: Login and obtain JWT token.
- `POST /register`: Create an account.
- `POST /forgot-password`: Password reset request.

### Stock Management (`/stocks`)
- `GET /`: Full list of stocks.
- `GET /stats`: Global statistics (Total products, low stock alerts).
- `POST /`: Add a new stock location.

### Products (`/produits`)
- `GET /`: List of all products.
- `POST /`: Add a product.

> [!TIP]
> Access the interactive **Swagger** documentation once the server is running at: `http://localhost:9091/swagger-ui/`

---

## 📝 Author
Developed with passion to simplify purchase flows. 🚀


## Contributing

1. Fork repository
2. Create feature branch
3. Commit changes
4. Push and open a Pull Request

---

## License

Licensed under **CC0-1.0 (Public Domain)**.
