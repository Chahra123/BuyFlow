# 📦 Module Gestion des Stocks & Mouvements

Ce module est le cœur logistique de l'application **BuyFlow**. Il gère en temps réel la disponibilité des produits, la traçabilité des flux et l'intégrité des données d'inventaire.

## 🚀 Architecture Technique

Le module repose sur un modèle d'**audit complet** :
- **Source de Vérité** : La quantité d'un produit n'est pas un champ statique en base de données. Elle est recalculée dynamiquement via la somme pondérée de ses `MouvementsStock` (Entrées vs Sorties).
- **Immuabilité** : Un mouvement enregistré ne peut être ni modifié ni supprimé, garantissant une traçabilité totale (Audit Trail).

## 📋 Cas d'Utilisation (Use Cases)

### Gestion des Référentiels
- **Création/Édition de Stocks** : Définition des emplacements logiques avec seuils d'alerte (`qteMin`).
- **Assignation de Produits** : Liaison entre le catalogue produit et les unités de stockage.

### Flux de Stock (Mouvements)
- **Entrées Manuelles** : Réapprovisionnement, retours clients, ajustements d'inventaire.
- **Sorties Manuelles** : Casse, perte, retraits exceptionnels.
- **Sorties Automatiques** : Déclenchées par la confirmation d'une commande client.
- **Réapprovisionnement Auto (Restock)** : Déclenché par l'annulation d'une commande.

### Analyse & Monitoring
- **Dashboard Analytics** : Visualisation des KPIs (Total stocks, produits, alertes critiques).
- **Historique de Traçabilité** : Consultation des flux avec détails (Qui, Quand, Pourquoi).
- **Status Santé Stock** : Indicateurs visuels (Vert/Orange/Rouge) basés sur les seuils configurés.

## 🛠️ Règles Métier (Business Rules)

1.  **🚫 Stock Négatif Interdit** : Toute sortie est bloquée si la quantité disponible recalculée est insuffisante.
2.  **🔒 Sécurité de Suppression** :
    *   Impossible de supprimer un stock contenant des produits.
    *   Impossible de supprimer un produit ayant un stock résiduel > 0.
3.  **⏱️ Cohérence Temporelle** : Les mouvements sont automatiquement horodatés au niveau du serveur (`PrePersist`).

## 📊 Tableau de Présentation (Soutenance)

| Fonctionnalité | Impact Stock | Déclencheur | État |
| :--- | :--- | :--- | :--- |
| **Vente** | 📉 Sortie | Commande confirmée | OK |
| **Achat** | 📈 Entrée | Facture / Manuel | OK |
| **Annulation** | 📈 Entrée | Commande annulée | OK |
| **Ajustement** | ↕️ Variable | Action Admin | OK |

---
*Ce document fait partie de la documentation technique de BuyFlow.*
