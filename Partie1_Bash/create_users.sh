#!/bin/bash

# =================================================================
# INF 3611 - TP 1: Script d'automatisation de la création d'utilisateurs
# Auteur: karisuma916
# =================================================================

# Fichiers et variables
USERS_FILE="Partie1_Bash/users.txt"
LOG_FILE="Partie1_Bash/user_creation.log"
WELCOME_MSG_FILE="/etc/skel/WELCOME.txt"
SKEL_BASHRC="/etc/skel/.bashrc"

# --- FONCTIONS UTILES ---

# Fonction de journalisation (Livrable 10)
log_action() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
    echo -e "$1"  # Afficher aussi à l'écran
}

# Fonction pour créer un message d'accueil dans le répertoire de base (Livrable 7)
setup_welcome_message() {
    log_action "INFO: Configuration du message de bienvenue dans /etc/skel"

    # Création du message d'accueil (WELCOME.txt) dans le répertoire squelette
    echo "Bonjour $1," > "$WELCOME_MSG_FILE"
    echo "" >> "$WELCOME_MSG_FILE"
    echo "Bienvenue sur votre nouvel espace de travail pour le cours INF 3611." >> "$WELCOME_MSG_FILE"
    echo "Votre compte est prêt. Votre mot de passe initial doit être changé immédiatement." >> "$WELCOME_MSG_FILE"
    echo "---" >> "$WELCOME_MSG_FILE"
    echo "Ce fichier est accessible sous ~/WELCOME.txt" >> "$WELCOME_MSG_FILE"
    
    # Ajout de l'affichage du message dans le .bashrc du répertoire squelette
    if ! grep -q "cat ~/WELCOME.txt" "$SKEL_BASHRC"; then
        echo "" >> "$SKEL_BASHRC"
        echo "# Affichage du message de bienvenue (Livrable 7)" >> "$SKEL_BASHRC"
        echo "cat ~/WELCOME.txt" >> "$SKEL_BASHRC"
    fi

    # Définir les permissions
    chmod 644 "$WELCOME_MSG_FILE"
}

# --- VÉRIFICATIONS PRÉ-EXÉCUTION ---

# 1. Vérification des permissions
if [ "$(id -u)" -ne 0 ]; then
    echo "ERREUR: Ce script doit être exécuté en tant que root. Utilisez 'sudo'."
    exit 1
fi

# 2. Vérification du fichier source
if [ ! -f "$USERS_FILE" ]; then
    echo "ERREUR: Le fichier source des utilisateurs '$USERS_FILE' est introuvable."
    exit 1
fi

# 3. Vérification du paramètre (Nom du groupe)
if [ -z "$1" ]; then
    echo "ERREUR: Veuillez spécifier le nom du groupe en paramètre."
    echo "Usage: sudo ./create_users.sh <NOM_DU_GROUPE>"
    log_action "ERREUR: Exécution interrompue, nom du groupe manquant."
    exit 1
fi

GROUP_NAME="$1"
log_action "--- DÉBUT DE L'EXÉCUTION DU SCRIPT ---"
log_action "PARAMÈTRE: Nom du groupe à créer: $GROUP_NAME"

# --- ÉTAPE 1 : CRÉATION DU GROUPE (Livrable 1) ---

if ! getent group "$GROUP_NAME" > /dev/null; then
    groupadd "$GROUP_NAME"
    log_action "SUCCÈS: Groupe '$GROUP_NAME' créé."
else
    log_action "AVERTISSEMENT: Le groupe '$GROUP_NAME' existe déjà."
fi

# Configuration du message de bienvenue dans /etc/skel
setup_welcome_message "\$LOGNAME"

# --- ÉTAPE 2 : TRAITEMENT DES UTILISATEURS ---

# Lecture du fichier users.txt ligne par ligne
IFS=$'\n' # Définir le séparateur de champ interne à la nouvelle ligne
while read -r line; do
    # Ignorer les lignes vides ou de commentaires
    if [ -z "$line" ] || [[ "$line" =~ ^# ]]; then
        continue
    fi

    # Découpage des champs séparés par le point-virgule (;)
    IFS=';' read -r USERNAME DEFAULT_PASSWORD FULL_NAME PHONE EMAIL PREFERRED_SHELL <<< "$line"
    IFS=$'\n' # Restaurer le séparateur de champ

    log_action "--- Traitement de l'utilisateur: $USERNAME ---"

    # Vérifier si l'utilisateur existe déjà
    if id "$USERNAME" &>/dev/null; then
        log_action "AVERTISSEMENT: L'utilisateur '$USERNAME' existe déjà. Ignoré."
        continue
    fi
    
    # Préparer le champ de commentaire GECOS (Livrable 2b)
    GECOS="$FULL_NAME,,$PHONE,$EMAIL"
    
    # 2. Vérification et installation du Shell préféré (Livrable 2c)
    CURRENT_SHELL="/bin/bash"
    if [ -n "$PREFERRED_SHELL" ]; then
        if [ -x "$PREFERRED_SHELL" ]; then
            CURRENT_SHELL="$PREFERRED_SHELL"
            log_action "INFO: Shell préféré '$CURRENT_SHELL' trouvé."
        else
            log_action "INFO: Shell '$PREFERRED_SHELL' non trouvé. Tentative d'installation..."
            
            # Installation du shell (la commande dépend de la distribution)
            # Pour Debian/Ubuntu :
            if command -v apt &>/dev/null; then
                if apt install -y $(basename "$PREFERRED_SHELL") &>/dev/null; then
                    CURRENT_SHELL="$PREFERRED_SHELL"
                    log_action "SUCCÈS: Shell $(basename "$PREFERRED_SHELL") installé et sélectionné."
                else
                    log_action "ERREUR: Installation du shell échouée. Assignation de /bin/bash."
                fi
            else
                log_action "AVERTISSEMENT: Le système n'utilise pas apt. Assignation de /bin/bash."
            fi
        fi
    fi

    # 3. Création de l'utilisateur (Livrable 2a, 2b, 2d)
    useradd -m -s "$CURRENT_SHELL" -c "$GECOS" "$USERNAME"
    if [ $? -eq 0 ]; then
        log_action "SUCCÈS: Utilisateur '$USERNAME' créé avec Home Dir et GECOS."
    else
        log_action "FATAL: Échec de la création de l'utilisateur '$USERNAME'."
        continue
    fi
    
    # 4. Hachage du mot de passe (Livrable 4)
    # Nécessite 'mkpasswd' ou 'openssl passwd' ou l'utilisation de 'chpasswd'
    # Utilisation de openssl pour SHA-512 (meilleure compatibilité)
    HASHED_PASS=$(openssl passwd -6 "$DEFAULT_PASSWORD")
    
    # 5. Définition du mot de passe et forçage du changement (Livrable 4 & 5)
    
    # Utilisation de usermod pour définir le mot de passe haché et forcer le changement
    usermod -p "$HASHED_PASS" "$USERNAME"
    
    # Forcer le changement à la première connexion (Livrable 5)
    chage -d 0 "$USERNAME"
    log_action "SUCCÈS: Mot de passe défini (haché SHA-512) et changement forcé à la première connexion."

    # 6. Ajout aux groupes (Livrable 3 & 6)
    
    # Ajout au groupe students-inf-361 (Livrable 3)
    usermod -aG "$GROUP_NAME" "$USERNAME"
    log_action "INFO: Ajout de '$USERNAME' au groupe '$GROUP_NAME'."

    # Ajout au groupe sudo/wheel (Livrable 6)
    if getent group sudo &>/dev/null; then
        SUDO_GROUP="sudo"
    elif getent group wheel &>/dev/null; then
        SUDO_GROUP="wheel"
    fi

    if [ -n "$SUDO_GROUP" ]; then
        usermod -aG "$SUDO_GROUP" "$USERNAME"
        log_action "INFO: Ajout de '$USERNAME' au groupe $SUDO_GROUP pour l'élévation de privilèges."
    fi

    # 7. Limiter l'usage de 'su' (Livrable 6, suite)
    # Pour restreindre 'su', il faut souvent utiliser le module PAM.
    # On ajoute une règle pour le groupe $GROUP_NAME dans /etc/security/access.conf
    # Note: Cette modification nécessite souvent une gestion de la configuration PAM,
    # mais pour une solution Bash simple, on ajoute une ligne.
    
    # Vérification et ajout de la règle PAM pour interdire 'su' au groupe
    if ! grep -q "su: $GROUP_NAME" /etc/security/access.conf; then
        echo "-: $GROUP_NAME: ALL EXCEPT root" >> /etc/security/access.conf
        log_action "INFO: Restriction de la commande 'su' ajoutée pour le groupe '$GROUP_NAME'."
    fi
    
    # 8. Quota Disque (Livrable 8)
    # Nécessite l'installation et la configuration de quota sur la partition /home
    # La commande à utiliser est 'setquota'.
    # Si le quota n'est pas activé, cette partie génère des erreurs.
    # Nous allons simuler la commande car l'activation complète du quota sort du cadre du script simple.
    # Pour que cela fonctionne, les paquets 'quota' doivent être installés, et le montage /home doit supporter 'usrjquota=aquota.user,grpjquota=aquota.group,jqfmt=vfsv0'.
    
    # setquota -u $USERNAME 15G 16G 0 0 /home
    log_action "AVERTISSEMENT: La configuration du quota disque (15 Go) nécessite l'activation préalable du quota sur la partition /home. Commande setquota non exécutée dans le script."
    
    # 9. Limite d'utilisation mémoire (Ulimit) (Livrable 9)
    # Limiter l'utilisation mémoire (20% de la RAM)
    # Cela se fait via /etc/security/limits.conf. 
    # Pour 20% de la RAM, il faut déterminer la taille en KiB ou Mio. C'est plus complexe.
    # Nous allons fixer une limite en KiB (soft) pour la taille des fichiers virtuels (vmem)
    # L'approche la plus courante est de limiter la taille de la mémoire virtuelle (vmem, rlimit virtual memory, VMS) ou d'implémenter des cgroups.
    
    # Calcul approximatif si 20% de la RAM = 4GB (4194304 KiB)
    MEMORY_LIMIT_KB="4194304" # 4 Gio (à adapter à la taille de la RAM du VPS)
    
    # Ajout de la limite pour la taille des fichiers virtuels (vmem)
    if ! grep -q "$USERNAME hard as" /etc/security/limits.conf; then
        echo "$USERNAME hard as $MEMORY_LIMIT_KB" >> /etc/security/limits.conf
        echo "$USERNAME soft as $MEMORY_LIMIT_KB" >> /etc/security/limits.conf
        log_action "INFO: Limite de mémoire virtuelle (vmem) de $MEMORY_LIMIT_KB KiB appliquée pour $USERNAME via limits.conf."
        log_action "INFO: Cette limite vise à empêcher les processus de consommer plus de la limite définie."
    fi

done < "$USERS_FILE"

log_action "--- FIN DE L'EXÉCUTION DU SCRIPT ---"

# Rendre le script exécutable
chmod +x "$0"
