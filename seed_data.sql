-- ==========================================================
-- SCRIPT DE PEUPLEMENT DE LA BASE DE DONNÉES BUYFLOW
-- Cible : MySQL
-- Logique : Données réalistes pour tests et démonstrations
-- ==========================================================

-- Désactivation temporaire des contraintes pour le nettoyage si nécessaire (optionnel)
-- SET FOREIGN_KEY_CHECKS = 0;

-- 1. SECTEUR D'ACTIVITÉ (Table de référence)
INSERT INTO secteur_activite (id_secteur_activite, code_secteur_activite, libelle_secteur_activite) VALUES
(1, 'TECH', 'Technologies et Informatique'),
(2, 'AGRI', 'Agriculture et Agroalimentaire'),
(3, 'MED', 'Santé et Médical'),
(4, 'CONS', 'Construction et BTP');

-- 2. STOCK (Table de référence pour les produits)
INSERT INTO stock (id_stock, libelle_stock, qte_min) VALUES
(1, 'Stock Central Tunis', 50),
(2, 'Entrepôt Sousse', 20),
(3, 'Dépôt Sfax', 10),
(4, 'Stock Réserve Tech', 5);

-- 3. CATÉGORIE PRODUIT
INSERT INTO categorie_produit (id_categorie_produit, code_categorie, libelle_categorie) VALUES
(1, 'CAT-HW', 'Hardware et Matériel'),
(2, 'CAT-SW', 'Logiciels et Licences'),
(3, 'CAT-OFF', 'Fournitures de bureau'),
(4, 'CAT-PER', 'Périphériques');

-- 4. DÉTAIL FOURNISSEUR (Dépendant de Fournisseur, mais inséré en premier pour le OneToOne)
INSERT INTO detail_fournisseur (id_detail_fournisseur, adresse, date_debut_collaboration, email, matricule) VALUES
(1, '123 Rue de la Technologie, Tunis', '2023-01-15', 'contact@techsupplier.tn', 'MAT-2023-001'),
(2, 'Zone Industrielle, Sousse', '2022-06-10', 'info@agriplus.com', 'MAT-2022-045'),
(3, 'Avenue Habib Bourguiba, Tunis', '2024-01-01', 'sales@medtech.com', 'MAT-2024-012'),
(4, 'Route de Gabès, Sfax', '2021-11-20', 'support@buildit.tn', 'MAT-2021-088');

-- 5. UTILISATEUR (_user)
-- Note: Les mots de passe sont des exemples (en production, ils devraient être hashés via BCrypt)
-- Le mot de passe ici correspond à "password" hashé
INSERT INTO _user (id, first_name, last_name, email, password, role, enabled, deleted, provider, created_at, updated_at) VALUES
(55, 'Admin', 'System', 'admin2@buyflow.com', '$2a$10$8.UnVuG9HHgffUDAlk8q6OuVGkqnRAdyzpEqfSCm9k9u.T6p7B6ea', 'ADMIN', 1, 0, 'LOCAL', NOW(), NOW()),
(2, 'Ahmed', 'Ben Salah', 'ahmed@gmail.com', '$2a$10$8.UnVuG9HHgffUDAlk8q6OuVGkqnRAdyzpEqfSCm9k9u.T6p7B6ea', 'USER', 1, 0, 'LOCAL', NOW(), NOW()),
(3, 'Livreur', 'Express', 'livreur@buyflow.tn', '$2a$10$8.UnVuG9HHgffUDAlk8q6OuVGkqnRAdyzpEqfSCm9k9u.T6p7B6ea', 'LIVREUR', 1, 0, 'LOCAL', NOW(), NOW());

-- 6. OPÉRATEUR
INSERT INTO operateur (id_operateur, nom, prenom, password) VALUES
(1, 'Trabelsi', 'Mohamed', 'pass123'),
(2, 'Guesmi', 'Faten', 'pass456'),
(3, 'Jlassi', 'Sami', 'pass789');

-- 7. FOURNISSEUR
INSERT INTO fournisseur (id_fournisseur, code, libelle, categorie_fournisseur, detail_fournisseur_id_detail_fournisseur) VALUES
(1, 'F-TECH-01', 'Tech Solution Tunisia', 'CONVENTIONNE', 1),
(2, 'F-AGRI-02', 'Agri Distribution', 'ORDINAIRE', 2),
(3, 'F-MED-03', 'Medical Support S.A', 'CONVENTIONNE', 3),
(4, 'F-BUILD-04', 'BuildIt Hardware', 'ORDINAIRE', 4);

-- 8. RELATION FOURNISSEUR <-> SECTEUR ACTIVITÉ (Table de jointure)
INSERT INTO fournisseur_secteur_activites (fournisseurs_id_fournisseur, secteur_activites_id_secteur_activite) VALUES
(1, 1), -- Tech Solution -> Tech
(2, 2), -- Agri Distr -> Agri
(3, 3), -- Medical Support -> Santé
(4, 4); -- BuildIt -> Construction

-- 9. PRODUIT
INSERT INTO produit (id_produit, code_produit, libelle_produit, prix, qte_min, date_creation, date_derniere_modification, image_url, id_categorie_produit, stock_id_stock) VALUES
(1, 'LAP-X1', 'Laptop Dell XPS 15', 3500.5, 5, '2024-01-10', '2024-01-10', 'https://example.com/dell-xps.jpg', 1, 1),
(2, 'MS-300', 'Souris Logitech MX Master', 280.0, 10, '2024-01-11', '2024-01-11', 'https://example.com/mx-master.jpg', 4, 1),
(3, 'OFF-P1', 'Papier A4 Premium (Pack 5)', 65.0, 20, '2024-01-12', '2024-01-12', NULL, 3, 2),
(4, 'WIN-H1', 'Licence Windows 11 Home', 450.0, 0, '2024-01-13', '2024-01-13', NULL, 2, 4);

-- 10. FACTURE
INSERT INTO facture (id_facture, montant_facture, montant_remise, date_creation_facture, date_derniere_modification_facture, archivee, fournisseur_id_fournisseur) VALUES
(1, 7001.0, 100.0, '2024-01-20', '2024-01-20', 0, 1), -- Achat de 2 Laptops
(2, 280.0, 0, '2024-01-21', '2024-01-21', 0, 1),    -- Achat de 1 Souris
(3, 1300.0, 50.0, '2024-01-22', '2024-01-22', 0, 2);   -- Achat divers

-- 11. DÉTAIL FACTURE
INSERT INTO detail_facture (id_detail_facture, qte_commandee, prix_total_detail, montant_remise, pourcentage_remise, produit_id_produit, facture_id_facture) VALUES
(1, 2, 7001.0, 0, 0, 1, 1), -- 2 Laptops dans facture 1
(2, 1, 280.0, 0, 0, 2, 2),  -- 1 Souris dans facture 2
(3, 20, 1300.0, 0, 0, 3, 3); -- 20 Packs papier dans facture 3

-- 12. RÈGLEMENT
INSERT INTO reglement (id_reglement, date_reglement, montant_paye, montant_restant, payee, facture_id_facture) VALUES
(1, '2024-01-21', 5000.0, 2001.0, 0, 1),
(2, '2024-01-22', 280.0, 0.0, 1, 2);

-- 13. MOUVEMENT STOCK
-- ENTREE: Achat initial
-- SORTIE: Vente ou transfert
INSERT INTO mouvement_stock (id, date_mouvement, quantite, type, produit_id_produit) VALUES
(1, '2024-01-20 10:00:00', 10, 'ENTREE', 1), -- 10 Laptops entrés en stock
(2, '2024-01-21 09:30:00', 50, 'ENTREE', 2), -- 50 Souris entrées
(3, '2024-01-22 14:00:00', 2, 'SORTIE', 1),  -- 2 Laptops sortis (vente)
(4, '2024-01-23 11:00:00', 5, 'SORTIE', 2);  -- 5 Souris sorties

-- 14. RELATION OPÉRATEUR <-> FACTURE (Table de jointure operateur_factures)
INSERT INTO operateur_factures (operateur_id_operateur, factures_id_facture) VALUES
(1, 1),
(1, 2),
(2, 3);

-- Réactivation des contraintes
-- SET FOREIGN_KEY_CHECKS = 1;

-- ==========================================================
-- FIN DU SCRIPT
-- ==========================================================
