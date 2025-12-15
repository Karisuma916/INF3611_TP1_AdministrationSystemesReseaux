# 🧱 Partie 3: Exécution avec Terraform
Ce répertoire contient la configuration Terraform pour exécuter le script Bash `create_users.sh` sur un serveur cible.

## Fichiers
* `main.tf` : Définit la connexion SSH et l'exécution à distance du script.
* `variables.tf` : Contient les variables pour le nom d'utilisateur, l'hôte cible et le chemin de la clé SSH.

## Utilisation
1. Initialisation : `terraform init`
2. Planification : `terraform plan`
3. Application (Exécution) : `terraform apply`
