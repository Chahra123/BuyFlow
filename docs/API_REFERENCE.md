# API Reference

## Base URL
The API is available at `http://localhost:9091`.

## Endpoints

### CategorieProduit
* `GET /categories`: Retrieve all categories
* `GET /categories/{id}`: Retrieve a single category
* `POST /categories`: Add a new category
* `PUT /categorie-produit`: Update a category
* `DELETE /categorieproduit/{id}`: Delete a category

### Facture
* `GET /factures`: Retrieve all invoices
* `GET /factures/{facture-id}`: Retrieve a single invoice
* `POST /factures`: Add a new invoice
* `PUT /factures/cancel/{facture-id}`: Cancel an invoice
* `GET /factures/byfournisseur/{fournisseur-id}`: Invoices by supplier
* `PUT /factures/assign-to-operateur/{idOperateur}/{idFacture}`: Assign operator to invoice
* `GET /factures/pourcentage-recouvrement/{startDate}/{endDate}`: Recovery percentage

### Fournisseur
* `GET /fournisseurs`: Retrieve all suppliers
* `GET /fournisseurs/{fournisseur-id}`: Retrieve a single supplier
* `POST /fournisseurs`: Add supplier
* `PUT /fournisseurs`: Update supplier
* `DELETE /fournisseur/{id}`: Delete supplier
* `PUT /fournisseurs/assignSecteurActiviteToFournisseur/{idSecteurActivite}/{idFournisseur}`: Assign sector to supplier

### MouvementStock
* `POST /mouvements`: Create a stock movement

### Operateur
* `GET /operateurs`: Retrieve all operators
* `GET /operateurs/{operateur-id}`: Retrieve a single operator
* `POST /operateurs`: Add operator
* `PUT /operateurs`: Update operator
* `DELETE /operateur/{id}`: Delete operator

### Produit
* `GET /produits`: Retrieve all products
* `GET /produits/{id}`: Retrieve a product
* `GET /produits/getProduitByStock/{idStock}`: Products by stock
* `GET /produits/{id}/quantite`: Product quantity
* `GET /produits/{id}/mouvements`: Product stock movements
* `POST /produits`: Add product
* `PUT /produits`: Update product
* `PUT /produits/assignProduitToStock/{idProduit}/{idStock}`: Assign product to stock
* `PUT /produits/removeProduitFromStock/{idProduit}`: Remove product from stock
* `DELETE /produits/{id}`: Delete product

### Reglement
* `GET /reglements/getChiffreAffaireEntreDeuxDate/{startDate}/{endDate}`: Revenue between dates
* `GET /reglements/retrieveReglementByFacture/{facture-id}`: Payments for an invoice
* `GET /reglements/retrieve-reglement/{reglement-id}`: Retrieve payment
* `GET /reglements/retrieve-all-reglements`: All payments
* `POST /reglements/add-reglement`: Add payment

### SecteurActivite
* `GET /secteurs`: Retrieve all sectors
* `GET /secteurs/{secteurActivite-id}`: Retrieve a sector
* `POST /secteurs`: Add sector
* `PUT /secteur-activite`: Update sector
* `DELETE /secteuractivite/{id}`: Delete sector

### Stock
* `GET /stocks`: Retrieve all stocks
* `GET /stocks/{id}`: Retrieve a stock
* `GET /stocks/{id}/qteTotale`: Total quantity in stock
* `POST /stocks`: Add stock
* `PUT /stocks`: Update stock
* `DELETE /stocks/{id}`: Delete stock

---
*Refer to the application code for request body schemas and specific usage details.*
