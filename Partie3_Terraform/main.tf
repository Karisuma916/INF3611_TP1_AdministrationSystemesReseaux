# =================================================================
# INF 3611 - TP 1: Configuration Terraform pour l'exécution du script
# =================================================================

# 1. Définition du Fournisseur (Provider) pour la connexion distante
# Le fournisseur 'null' est souvent utilisé pour des opérations locales ou des exécutions
# de scripts sans provisionner d'infrastructure cloud.
terraform {
  required_providers {
    null = {
      source = "hashicorp/null"
      version = "~> 3.0"
    }
    # Le 'tls' provider est utile pour créer une clé SSH temporaire si nécessaire
    # Mais ici, nous supposons que la clé existe déjà.
  }
  required_version = ">= 1.0"
}

# 2. Configuration de la Connexion SSH (Provider 'remote-exec' nécessite une connexion)
# Nous utilisons un bloc 'connection' qui peut être référencé par les ressources.
resource "null_resource" "script_executor" {
  # Pour forcer l'exécution du script à chaque application Terraform
  triggers = {
    always_run = timestamp()
  }

  # Définition du bloc de connexion SSH au serveur cible
  connection {
    type        = "ssh"
    user        = var.ssh_user
    host        = var.target_host
    private_key = file(var.private_key_path) # Lit le contenu de la clé privée
    timeout     = "5m" # Laisser 5 minutes pour l'exécution du script
  }
  
  # 3. Exécution des Commandes à Distance (remote-exec)
  # Ce bloc envoie les fichiers et exécute la commande sur le serveur distant.

  provisioner "file" {
    # Copier le script Bash et le fichier users.txt vers le répertoire temporaire du serveur
    source      = "${path.module}/../Partie1_Bash/create_users.sh"
    destination = "/tmp/create_users.sh"
  }

  provisioner "file" {
    source      = "${path.module}/../Partie1_Bash/users.txt"
    destination = "/tmp/users.txt"
  }
  
  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /tmp/create_users.sh", # Rendre le script exécutable
      "sudo mv /tmp/users.txt /tmp/Partie1_Bash/users.txt", # Si le script s'attend à un chemin spécifique
      # EXÉCUTION DU SCRIPT BASH AVEC LE PARAMÈTRE (Livrable 1)
      "sudo /tmp/create_users.sh ${var.group_name}" 
    ]
  }
}

# 4. Output (Sortie) pour confirmer l'exécution
output "execution_status" {
  description = "Statut de l'exécution du script sur le serveur cible."
  value       = "Le script de creation d'utilisateurs a ete execute avec le groupe : ${var.group_name} sur la machine : ${var.target_host}"
}
