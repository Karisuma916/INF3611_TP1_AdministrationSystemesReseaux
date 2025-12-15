# Nom d'utilisateur SSH pour la connexion à la machine cible
variable "ssh_user" {
  description = "Nom d'utilisateur SSH de l'administrateur sur le serveur cible."
  type        = string
  default     = "votre_user_admin" # À remplacer
}

# Adresse IP ou Nom d'hôte de la machine cible (VPS ou machine locale)
variable "target_host" {
  description = "Adresse IP ou nom d'hôte du serveur où le script sera exécuté."
  type        = string
  default     = "votre_ip_serveur" # À remplacer
}

# Chemin vers la clé privée SSH pour l'authentification
variable "private_key_path" {
  description = "Chemin absolu vers la clé privée SSH pour l'authentification (ex: ~/.ssh/id_rsa)."
  type        = string
  default     = "~/.ssh/id_rsa" # À remplacer par le chemin de votre clé
}

# Nom du groupe à créer par le script Bash (students-inf-361)
variable "group_name" {
  description = "Nom du groupe à créer pour les nouveaux utilisateurs."
  type        = string
  default     = "students-inf-361"
}
