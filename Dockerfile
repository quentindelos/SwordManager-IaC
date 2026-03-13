# Utiliser l'image officielle Google Cloud SDK basée sur Alpine
FROM google/cloud-sdk:462.0.0-alpine

# Définir la version de Terraform
ENV TF_VERSION=1.5.7

# Définir le répertoire de travail
WORKDIR /

# Installer Terraform
RUN apk add --no-cache wget unzip bash \
    && mkdir -p /usr/lib/terraform/${TF_VERSION} \
    && cd /usr/lib/terraform/${TF_VERSION} \
    && wget https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_amd64.zip \
    && unzip terraform_${TF_VERSION}_linux_amd64.zip \
    && chmod 755 /usr/lib/terraform/${TF_VERSION}/terraform \
    && ln -s /usr/lib/terraform/${TF_VERSION}/terraform /usr/bin/terraform \
    && rm terraform_${TF_VERSION}_linux_amd64.zip \
    && apk del wget unzip

# Définir le répertoire de travail par défaut
WORKDIR /app

# Vérification des versions (utile pour vérifier pendant la construction)
RUN terraform version && gcloud version

# Commande par défaut
CMD ["/bin/bash"]
