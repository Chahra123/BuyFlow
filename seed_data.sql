-- =============================================================================
-- SCRIPT DE PEUPLEMENT DE LA BASE DE DONNÉES (SEED DATA)
-- Application : BuyFlow
-- SGBD : MySQL
-- Description : Données réalistes pour tests et démonstration
-- =============================================================================

-- Désactivation temporaire des contraintes de clé étrangère pour faciliter le nettoyage si nécessaire
SET FOREIGN_KEY_CHECKS = 0;

-- Nettoyage des tables pour éviter les doublons lors des exécutions successives
TRUNCATE TABLE mouvement_stock;
TRUNCATE TABLE reglement;
TRUNCATE TABLE detail_facture;
TRUNCATE TABLE facture;
TRUNCATE TABLE produit;
TRUNCATE TABLE stock;
TRUNCATE TABLE categorie_produit;
TRUNCATE TABLE fournisseur_secteur_activites;
TRUNCATE TABLE fournisseur;
TRUNCATE TABLE detail_fournisseur;
TRUNCATE TABLE secteur_activite;
TRUNCATE TABLE _user;

SET FOREIGN_KEY_CHECKS = 1;

-- =============================================================================
-- 1. TABLES DE RÉFÉRENCE (Reference Tables)
-- =============================================================================

-- Secteurs d'activité
-- idSecteurActivite est AUTO_INCREMENT
INSERT INTO secteur_activite (code_secteur_activite, libelle_secteur_activite) VALUES
('TECH', 'Technologies de l''information'),
('AGRI', 'Agro-alimentaire'),
('CONS', 'Construction et BTP'),
('MED', 'Santé et Médical'),
('LOG', 'Logistique et Transport');

-- Catégories de produits
-- idCategorieProduit est AUTO_INCREMENT
INSERT INTO categorie_produit (code_categorie, libelle_categorie) VALUES
('CAT-INF', 'Informatique'),
('CAT-BUR', 'Fournitures de bureau'),
('CAT-ELC', 'Électronique'),
('CAT-MOB', 'Mobilier'),
('CAT-OUT', 'Outillage');

-- Stocks (Emplacements/Entrepôts)
-- idStock est AUTO_INCREMENT
INSERT INTO stock (libelle_stock, qte_min) VALUES
('Entrepôt Central - Ariana', 100),
('Dépôt Régional - Sousse', 50),
('Stock Boutique - Tunis', 20),
('Entrepôt Logistique - Radès', 200);

-- =============================================================================
-- 2. TABLES PRINCIPALES (Main Entities)
-- =============================================================================

-- Utilisateurs (Système d'authentification)
-- id est AUTO_INCREMENT
-- Note : Les mots de passe sont des hashs fictifs pour l'exemple (compatibles Spring Security)
INSERT INTO _user (first_name, last_name, email, password, role, enabled, deleted, created_at, provider) VALUES
('Admin', 'System', 'admin2@buyflow.tn', '$2a$10$8.UnVuG9HHgffUDAlk8q6OuVGkqnRAdyzBq6vAtC0.vW9gWv6tA2.', 'ADMIN', 1, 0, NOW(), 'LOCAL'),
('Houcine', 'Ben Ali', 'houcine@buyflow.tn', '$2a$10$8.UnVuG9HHgffUDAlk8q6OuVGkqnRAdyzBq6vAtC0.vW9gWv6tA2.', 'USER', 1, 0, NOW(), 'LOCAL'),
('Ahmed', 'Livreur', 'ahmed@buyflow.tn', '$2a$10$8.UnVuG9HHgffUDAlk8q6OuVGkqnRAdyzBq6vAtC0.vW9gWv6tA2.', 'LIVREUR', 1, 0, NOW(), 'LOCAL'),
('Sami', 'Acheteur', 'sami@buyflow.tn', '$2a$10$8.UnVuG9HHgffUDAlk8q6OuVGkqnRAdyzBq6vAtC0.vW9gWv6tA2.', 'USER', 1, 0, NOW(), 'LOCAL');

-- Détails Fournisseurs
-- idDetailFournisseur est AUTO_INCREMENT
INSERT INTO detail_fournisseur (email, date_debut_collaboration, adresse, matricule) VALUES
('contact@tech-solutions.com', '2023-01-15', 'Zone Industrielle, Tunis', 'MF-123456-X'),
('sales@agro-plus.tn', '2022-06-10', 'Route de Bizerte, Km 12', 'MF-987654-Y'),
('info@build-pro.tn', '2024-02-01', 'Avenue Habib Bourguiba, Sousse', 'MF-456123-Z'),
('support@med-equip.tn', '2023-11-20', 'Centre Urbain Nord, Tunis', 'MF-789321-A');

-- Fournisseurs
-- idFournisseur est AUTO_INCREMENT
INSERT INTO fournisseur (code, libelle, categorie_fournisseur, detail_fournisseur_id_detail_fournisseur) VALUES
('F-001', 'Tech Solutions International', 'CONVENTIONNE', 1),
('F-002', 'AgroPlus SA', 'ORDINAIRE', 2),
('F-003', 'BuildPro Tunisia', 'CONVENTIONNE', 3),
('F-004', 'MedEquip Dist', 'ORDINAIRE', 4);

-- Association Fournisseurs <-> Secteurs d'activité (Table de jointure automatique JPA)
-- Assurez-vous que le nom de la table de jointure correspond à votre config (ici par défaut Hibernate)
INSERT INTO fournisseur_secteur_activites (fournisseurs_id_fournisseur, secteur_activites_id_secteur_activite) VALUES
(1, 1), -- Tech Solutions -> Tech
(1, 5), -- Tech Solutions -> Logistique
(2, 2), -- AgroPlus -> Agro
(3, 3), -- BuildPro -> Construction
(4, 4); -- MedEquip -> Santé

-- Produits
-- idProduit est AUTO_INCREMENT
INSERT INTO produit (code_produit, libelle_produit, prix, qte_min, date_creation, date_derniere_modification, stock_id_stock, categorie_produit_id_categorie_produit) VALUES
('P-LAP-01', 'Laptop Dell XPS 15', 3500.50, 5, CURDATE(), CURDATE(), 1, 1),
('P-MON-02', 'Ecran LG 27 UHD', 850.00, 10, CURDATE(), CURDATE(), 1, 1),
('P-PAP-03', 'Ramette Papier A4 80g', 12.500, 50, CURDATE(), CURDATE(), 3, 2),
('P-SRI-04', 'Souris Logi MX Master 3', 250.75, 15, CURDATE(), CURDATE(), 1, 3),
('P-CHE-05', 'Chaise de bureau Ergonomique', 450.00, 8, CURDATE(), CURDATE(), 3, 4),
('P-SOU-06', 'Perceuse Bosch Professional', 380.00, 12, CURDATE(), CURDATE(), 4, 5);

-- =============================================================================
-- 3. TABLES TRANSACTIONNELLES (Transactional Data)
-- =============================================================================

-- Factures (Achats auprès des fournisseurs)
-- idFacture est AUTO_INCREMENT
INSERT INTO facture (montant_remise, montant_facture, date_creation_facture, date_derniere_modification_facture, archivee, fournisseur_id_fournisseur) VALUES
(50.00, 15000.00, '2024-01-10', '2024-01-10', 0, 1),
(0.00, 2450.50, '2024-01-15', '2024-01-15', 0, 2),
(120.00, 5600.00, '2024-02-01', '2024-02-01', 0, 3),
(25.50, 1200.75, CURDATE(), CURDATE(), 0, 1);

-- Détails des Factures
-- idDetailFacture est AUTO_INCREMENT
INSERT INTO detail_facture (qte_commandee, prix_total_detail, pourcentage_remise, montant_remise, produit_id_produit, facture_id_facture) VALUES
(4, 14002.00, 0, 0, 1, 1), -- 4 Laptops Dell
(10, 8500.00, 5, 425.00, 2, 1), -- 10 Ecrans LG avec remise
(100, 1250.00, 0, 0, 3, 2), -- 100 Ramettes Papier
(10, 2507.50, 2, 50.15, 4, 4); -- 10 Souris Logi

-- Règlements (Paiments des factures)
-- idReglement est AUTO_INCREMENT
INSERT INTO reglement (montant_paye, montant_restant, payee, date_reglement, facture_id_facture) VALUES
(10000.00, 5000.00, 0, '2024-01-12', 1), -- Paiement partiel
(5000.00, 0, 1, '2024-01-20', 1), -- Solde de la facture 1
(2450.50, 0, 1, '2024-01-16', 2), -- Paiement complet facture 2
(1000.00, 4600.00, 0, CURDATE(), 3); -- Acompte facture 3

-- Mouvements de Stock
-- id est AUTO_INCREMENT
-- Reflète l'état actuel : Achats (ENTREE) et Ajustements/Ventes (SORTIE)
INSERT INTO mouvement_stock (quantite, type, date_mouvement, raison, utilisateur, produit_id_produit) VALUES
(20, 'ENTREE', '2024-01-11', 'Réception commande Dell', 'Admin', 1),
(50, 'ENTREE', '2024-01-11', 'Réception commande LG', 'Admin', 2),
(5, 'SORTIE', '2024-01-14', 'Vente Client #101', 'Houcine', 1),
(2, 'SORTIE', '2024-01-20', 'Retrait article défectueux', 'Admin', 2),
(100, 'ENTREE', '2024-01-16', 'Stockage Papier A4', 'Sami', 3),
(10, 'ENTREE', '2024-01-22', 'Réception Souris Logi', 'Admin', 4);

-- =============================================================================
-- FIN DU SCRIPT
-- =============================================================================
