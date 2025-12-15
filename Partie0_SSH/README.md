# 🔒 Partie 0: Procédure de modification du serveur SSH

## [cite_start]1. Décrire la procédure correcte pour modifier la configuration du service SSH. [cite: 12, 13]

[cite_start]La procédure sécurisée pour modifier la configuration du service SSH (`sshd`) [cite: 13] implique :

1.  **Sauvegarde :** Créer une copie de secours du fichier de configuration (`/etc/ssh/sshd_config`) avant toute modification.
2.  **Modification :** Éditer le fichier de configuration.
3.  **Vérification :** Tester la syntaxe du nouveau fichier avec la commande `sshd -t`.
4.  **Application :** Recharger le service SSH (`systemctl reload sshd` ou `systemctl restart sshd`).
5.  **Test :** Ouvrir une nouvelle session de terminal pour vérifier la connexion avec les nouveaux paramètres avant de fermer l'ancienne.

## [cite_start]2. Expliquer le principal risque encouru si cette procédure n'est pas respectée. [cite: 14]

[cite_start]Le principal risque est le **"lockout"** (l'auto-exclusion)[cite: 14]. Si la configuration contient une erreur de syntaxe ou si un paramètre critique (comme le port ou l'authentification) est mal réglé, le service SSH peut échouer à démarrer ou rejeter toute connexion. Sans accès physique ou console distante, l'administrateur perd le contrôle du serveur.

## [cite_start]3. Citer et justifier au moins cinq paramètres de sécurité du serveur SSH à modifier. [cite: 15]

| Paramètre SSH | Valeur à définir | Justification |
| :--- | :--- | :--- |
| `Port` | `2222` (ou autre) | Évite les scans automatisés et les attaques ciblées sur le port standard 22. |
| `PermitRootLogin` | `no` | Empêche la connexion directe de l'utilisateur `root`, forçant l'usage d'un compte utilisateur standard suivi de `sudo` (principe du moindre privilège). |
| `PasswordAuthentication` | `no` | Désactive la connexion par mot de passe au profit des clés SSH, qui sont bien plus résistantes à la force brute. |
| `MaxAuthTries` | `3` | Limite le nombre d'essais de connexion par session, réduisant l'efficacité des attaques par force brute. |
| `AllowUsers` | `user1 user2` | Liste explicitement les utilisateurs autorisés, bloquant toutes les autres tentatives d'accès SSH au niveau du service. |
