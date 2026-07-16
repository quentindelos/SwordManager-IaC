# 🏗️ Architecture Globale

L'infrastructure est conçue pour être à la fois modulaire, sécurisée et optimisée en termes de coûts :

* **Réseau (VPC) :** Un réseau VPC dédié isole les composants de l'application. Un Cloud Router + Cloud NAT permet aux ressources privées de sortir sur internet, et une règle de pare-feu (`allow-postgres-internal`) autorise uniquement le trafic entrant sur le port `5432`, restreint au CIDR du sous-réseau.
* **Frontend (`<project_id>-frontend`) :** Hébergé sur **Google Cloud Run**, associé aux domaines `<domain_name>` et `www.<domain_name>`. L'image applicative est déployée par la CI/CD (Terraform ignore les changements d'image après le premier déploiement).
* **Backend (`<project_id>-backend`) :** API hébergée sur **Google Cloud Run**, associée au sous-domaine `api.<domain_name>`, connectée au VPC via un accès VPC direct (egress `PRIVATE_RANGES_ONLY`). Les secrets (mot de passe DB, JWT) sont injectés depuis Secret Manager.
* **Base de Données (`db-postgres-<project_id>`) :** Une instance PostgreSQL (conteneur Docker `postgres:16`) hébergée sur une VM **Compute Engine standard** (`e2-micro`, non préemptible), rattachée au VPC en IP privée. Le disque est sauvegardé par une politique de snapshot quotidienne (rétention 7 jours). La VM est protégée contre la suppression (`deletion_protection`, `prevent_destroy`).
* **Artifact Registry (`<project_id>-repo`) :** Registre Docker privé centralisant les images construites par les pipelines CI/CD des dépôts applicatifs.
* **Analytics :** Un dataset BigQuery (`swordmanager_logs_analytics`) centralise les logs.
* **State Terraform :** Chaque environnement dispose de son propre bucket GCS versionné (`envs/<env>/state_bucket.tf`) et de son propre backend GCS (`prefix = "SwordManager/envs/<env>"`).

---

## 📁 Arborescence du Projet IaC

Le projet respecte l'une des meilleures pratiques de Terraform en séparant la définition des ressources (**modules**) de leur instanciation par environnement (**envs**) :

```text
SwordManager-IaC/
├── versions.tf                     # Contraintes de version Terraform / provider Google
├── envs/
│   ├── dev/
│   │   ├── main.tf                 # Point d'entrée, appel des modules pour l'env DEV
│   │   ├── variables.tf            # Déclaration des variables propres à l'env DEV
│   │   ├── provider.tf             # Configuration du provider Google
│   │   ├── backend.tf              # Backend GCS (state distant)
│   │   ├── state_bucket.tf         # Bucket GCS versionné pour le state
│   │   └── terraform.tfvars        # Fichier de valeurs (non versionné, cf .gitignore)
│   │
│   ├── qualif/
│   │   └── ...                     # Même structure que DEV
│   │
│   └── prod/
│       └── ...                     # Même structure que DEV
│
└── modules/
    ├── vpc/
    │   ├── main.tf                 # VPC, Cloud Router, Cloud NAT, règle de pare-feu Postgres
    │   ├── variables.tf
    │   └── outputs.tf
    │
    ├── database/
    │   ├── main.tf                 # VM Compute Engine (Postgres en Docker), service account, snapshot policy
    │   ├── variables.tf
    │   └── outputs.tf
    │
    ├── services/
    │   ├── main.tf                 # Artifact Registry, Cloud Run (Front + Back), IAM secrets, Domain Mappings
    │   └── variables.tf
    │
    └── analytics/
        ├── main.tf                 # Dataset BigQuery pour la centralisation des logs
        └── variables.tf
```

> **Note :** les fichiers `terraform.tfvars`, `.terraform/` et les fichiers de state (`*.tfstate`) sont exclus du dépôt (voir `.gitignore`) car ils contiennent des valeurs spécifiques à l'environnement ou de l'état sensible.
