# 🏗️ Architecture Globale

L'infrastructure est conçue pour être à la fois modulaire, sécurisée et optimisée en termes de coûts :

* **Réseau (VPC) :** Un réseau VPC dédié (`swordmanager-vpc`) isole les composants de l'application. Une règle de pare-feu stricte (`allow-postgres`) autorise uniquement le trafic entrant sur le port `5432` pour la base de données.
* **Frontend (`swordmanager-frontend`) :** Hébergé sur **Google Cloud Run**, conteneurisé avec Nginx pour servir l'application statique (HTML/CSS/JS). Il est associé aux domaines `swordmanager.cloud` (domaine nu) et `www.swordmanager.cloud`.
* **Backend (`swordmanager-backend`) :** API REST Node.js/Express utilisant l'ORM Sequelize, hébergée sur **Google Cloud Run** et associée au sous-domaine `api.swordmanager.cloud`.
* **Base de Données (`db-postgres-spot`) :** Une instance PostgreSQL hébergée sur une machine virtuelle **Compute Engine Spot** (choix économique), rattachée au VPC et stockant les blobs de données chiffrés.
* **Artifact Registry (`swordmanager-repo`) :** Registre Docker privé centralisant les images construites par les pipelines CI/CD GitHub Actions des dépôts applicatifs.

---

## 📁 Arborescence du Projet IaC

Le projet respecte l'une des meilleures pratiques de Terraform en séparant la définition des ressources (**modules**) de leur instanciation par environnement (**envs**) :

```text
projet-terraform-swordmanager/
└── SwordManager/
    ├── envs/
    │   └── dev/
    │       ├── main.tf                 # Point d'entrée, appel des modules pour l'env DEV
    │       ├── variables.tf            # Déclaration des variables propres à l'env DEV
    │       ├── outputs.tf              # Outputs spécifiques (IPs, URLs générées)
    │       └── terraform.tfvars        # Fichier de valeurs (Variables locales / secrètes)
    └── modules/
        ├── vpc/
        │   ├── main.tf                 # Création du réseau VPC et des règles de pare-feu
        │   ├── variables.tf
        │   └── outputs.tf
        ├── database/
        │   ├── main.tf                 # Provisioning de la VM Compute Engine PostgreSQL (Spot)
        │   ├── variables.tf
        │   └── outputs.tf
        ├── services/
        │   ├── main.tf                 # Déploiement de Cloud Run (Front + Back) et des Mappings DNS
        │   ├── variables.tf
        │   └── outputs.tf
        └── analytics/
            ├── main.tf                 # BigQuery pour la centralisation des logs analytiques
            └── variables.tf
```