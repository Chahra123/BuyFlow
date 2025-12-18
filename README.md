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
* [API Endpoints](#api-endpoints)
* [Usage](#usage)
* [Contributing](#contributing)
* [License](#license)

---

## About

BuyFlow simplifies purchase management on mobile devices, combining a Spring Boot backend with a Flutter mobile frontend.

---

## Features

* User authentication
* Manage purchases, products, stocks, invoices, and suppliers
* CRUD operations via REST API
* Cross-platform mobile support (Android / iOS)

---

## Technologies

| Layer                            | Technology                                 |
| -------------------------------- | ------------------------------------------ |
| Backend                          | Spring Boot (Java)                         |
| Frontend                         | Flutter (Dart)                             |
| Dependency Management (Backend)  | Maven / Gradle                             |
| Dependency Management (Frontend) | Dart / Pub                                 |
| Database                         | MySQL                                      |

---

## Project Structure

```
BuyFlow/
│── backend-springboot/    # Spring Boot API
│── frontend-flutter/      # Flutter mobile application
│── README.md
│── LICENSE
```

---

## Installation

### Prerequisites

* Git
* Java JDK 17+
* Flutter SDK
* IDE (IntelliJ, Android Studio, VS Code)
* Android Emulator or device

### Clone the Repository

```bash
git clone https://github.com/Chahra123/BuyFlow.git
cd BuyFlow
```

---

## Running the Project

### Backend (Spring Boot)

```bash
cd backend-springboot
./mvnw spring-boot:run
# or ./gradlew bootRun
```

API available at `http://localhost:9091`.

### Frontend (Flutter)

```bash
cd frontend-flutter
flutter pub get
flutter run
```

---

## API Endpoints

### CategorieProduit

* GET `/categories` - Retrieve all categories
* GET `/categories/{id}` - Retrieve a single category
* POST `/categories` - Add a new category
* PUT `/categorie-produit` - Update a category
* DELETE `/categorieproduit/{id}` - Delete a category

### Facture

* GET `/factures` - Retrieve all invoices
* GET `/{facture-id}` - Retrieve a single invoice
* POST `/factures` - Add a new invoice
* PUT `/cancel/{facture-id}` - Cancel an invoice
* GET `/byfournisseur/{fournisseur-id}` - Invoices by supplier
* PUT `/assign-to-operateur/{idOperateur}/{idFacture}` - Assign operator to invoice
* GET `/pourcentage-recouvrement/{startDate}/{endDate}` - Recovery percentage

### Fournisseur

* GET `/fournisseurs` - Retrieve all suppliers
* GET `/{fournisseur-id}` - Retrieve a single supplier
* POST `/fournisseurs` - Add supplier
* PUT `/fournisseurs` - Update supplier
* DELETE `/fournisseur/{id}` - Delete supplier
* PUT `/assignSecteurActiviteToFournisseur/{idSecteurActivite}/{idFournisseur}` - Assign sector to supplier

### MouvementStock

* POST `/mouvements` - Create a stock movement

### Operateur

* GET `/operateurs` - Retrieve all operators
* GET `/{operateur-id}` - Retrieve a single operator
* POST `/operateurs` - Add operator
* PUT `/operateurs` - Update operator
* DELETE `/operateur/{id}` - Delete operator

### Produit

* GET `/produits` - Retrieve all products
* GET `/produits/{id}` - Retrieve a product
* GET `/produits/getProduitByStock/{idStock}` - Products by stock
* GET `/produits/{id}/quantite` - Product quantity
* GET `/produits/{id}/mouvements` - Product stock movements
* POST `/produits` - Add product
* PUT `/produits` - Update product
* PUT `/produits/assignProduitToStock/{idProduit}/{idStock}` - Assign product to stock
* PUT `/produits/removeProduitFromStock/{idProduit}` - Remove product from stock
* DELETE `/produits/{id}` - Delete product

### Reglement

* GET `/getChiffreAffaireEntreDeuxDate/{startDate}/{endDate}` - Revenue between dates
* GET `/retrieveReglementByFacture/{facture-id}` - Payments for an invoice
* GET `/retrieve-reglement/{reglement-id}` - Retrieve payment
* GET `/retrieve-all-reglements` - All payments
* POST `/add-reglement` - Add payment

### SecteurActivite

* GET `/secteurs` - Retrieve all sectors
* GET `/{secteurActivite-id}` - Retrieve a sector
* POST `/secteurs` - Add sector
* PUT `/secteur-activite` - Update sector
* DELETE `/secteuractivite/{id}` - Delete sector

### Stock

* GET `/stocks` - Retrieve all stocks
* GET `/stocks/{id}` - Retrieve a stock
* GET `/stocks/{id}/qteTotale` - Total quantity in stock
* POST `/stocks` - Add stock
* PUT `/stocks` - Update stock
* DELETE `/stocks/{id}` - Delete stock
* You can see a short demonstration of the stock management feature below:
<img src="utils/demo_stock.gif?raw=true" alt="Demo GIF" width="300"/> 

---

## Usage

Use the mobile app to authenticate, view, and manage purchases, products, stocks, invoices, and suppliers. CRUD operations are performed via the API.

---

## Contributing

1. Fork repository
2. Create feature branch
3. Commit changes
4. Push and open a Pull Request

---

## License

Licensed under **CC0-1.0 (Public Domain)**.
