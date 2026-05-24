## SwordManager - Infrastructure GCP (Terraform)

Ce dépôt contient l’infrastructure Terraform pour un gestionnaire de mots de passe type Bitwarden, hébergé sur **Google Cloud Platform** avec :
- **Cloud Run** pour l’application conteneurisée
- **Cloud SQL (PostgreSQL)** pour la base de données
- **Global HTTP(S) Load Balancer** avec certificat SSL managé
- **Secret Manager** pour les secrets applicatifs
- **Artifact Registry** pour les images Docker

### Arborescence du projet

```text
.
├── cloudbuild.yaml                # Pipeline Cloud Build (build + déploiement dev)
├── terraform/
│   ├── modules/
│   │   ├── app/                   # Module Cloud Run + Artifact Registry
│   │   │   ├── main.tf
│   │   │   └── variables.tf
│   │   ├── database/              # Module Cloud SQL + Secret Manager
│   │   │   ├── main.tf
│   │   │   └── variables.tf
│   │   └── networking/            # Module Load Balancer global + cert HTTPS
│   │       ├── main.tf
│   │       └── variables.tf
│   └── environments/
│       ├── dev/
│       │   ├── main.tf            # Appel des modules + providers
│       │   ├── variables.tf
│       │   └── terraform.tfvars   # Valeurs pour l’environnement dev
│       ├── qualif/                # (à créer sur le même modèle que dev)
│       └── prod/                  # (à créer sur le même modèle que dev)
└── README.md
```

### Prérequis

- Terraform **>= 1.6**
- Un projet **GCP** avec la facturation activée
- Les APIs suivantes activées :
  - `run.googleapis.com`
  - `compute.googleapis.com`
  - `sqladmin.googleapis.com`
  - `secretmanager.googleapis.com`
  - `artifactregistry.googleapis.com`
  - `cloudbuild.googleapis.com`
- Un compte de service avec les rôles minimum suivants (pour Cloud Run) :
  - `roles/run.admin`
  - `roles/cloudsql.client`
  - `roles/secretmanager.secretAccessor`

### Initialisation de l’environnement dev

1. **Se placer dans le dossier dev :**

```bash
cd terraform/environments/dev
```

2. **Adapter les variables dans `terraform.tfvars` :**

- `project_id` : ID du projet GCP cible
- `app_image` : chemin de l’image dans Artifact Registry
- `app_service_account_email` : compte de service de Cloud Run
- `domains` / `primary_domain` : domaine(s) utilisé(s) pour le certificat HTTPS

3. **Initialiser Terraform :**

```bash
terraform init
```

4. **Voir le plan d’exécution :**

```bash
terraform plan \
  -var="project_id=<votre-projet-gcp>"
```

5. **Appliquer l’infrastructure :**

```bash
terraform apply \
  -var="project_id=<votre-projet-gcp>"
```

> Remarque : vous pouvez surcharger d’autres variables avec `-var` ou via un autre fichier `.tfvars`.

### Déploiement via Cloud Build (CI/CD)

Le fichier `cloudbuild.yaml` fournit un pipeline d’exemple pour :
- **builder** l’image Docker de l’application
- **pousser** l’image dans Artifact Registry
- **exécuter** `terraform init` puis `terraform apply` dans `terraform/environments/dev`

Pour déclencher le pipeline :
1. Pousser votre code sur une branche monitorée par Cloud Build (ou créer un trigger manuel).
2. Vérifier dans la console GCP (section **Cloud Build**) que les étapes se terminent correctement.

### Création des environnements qualif et prod

Pour **qualif** et **prod**, vous pouvez :
- Dupliquer le dossier `terraform/environments/dev` vers `qualif` et `prod`
- Adapter :
  - le backend Terraform (bucket GCS, préfixe)
  - `project_id`, `project_prefix`, `db_instance_tier`, `app_image`, `domains`, etc.

Chaque environnement utilisera les **mêmes modules** (`app`, `database`, `networking`), mais avec des valeurs différentes, ce qui garantit une cohérence d’architecture tout en permettant de changer de sizing / sécurité selon l’environnement.
# SwordManager
Gestionnaire de mots de passe
