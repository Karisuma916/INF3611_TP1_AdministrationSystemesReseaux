# INF 3611 - TP 1: Automatisation de la création d'utilisateurs
=======
# INF3611_TP1_AdministrationSystemesReseaux
#  INF 3611 - TP 1: Automatisation de la création d'utilisateurs sous Linux

##  Étudiant

* **Nom/Prénom :** [NJOYA NJOYA YASSIN ARAFAT]
* **Matricule :** [23U2867]

---

## Objectif du TP

Ce dépôt contient les livrables pour le Travail Pratique 1 du cours INF 3611, axé sur l'automatisation de l'administration système via des scripts Bash, des Playbooks Ansible et de l'Infrastructure-as-Code (Terraform).

---

##  Structure et Contenu du Dépôt

| Répertoire | Description | Livrables Principaux |
| :--- | :--- | :--- |
| **Partie0_SSH/** | Réponses théoriques sur la sécurisation du service SSH (sshd_config). | Documentation |
| **Partie1_Bash/** | Script Bash (`create_users.sh`) complet, implémentant toutes les contraintes de création d'utilisateurs, de restrictions et de logs. | 1, 4, Log, Restrictions |
| **Partie2_Ansible/** | Playbook Ansible (`create_users.yml`) et Inventaire (`inventory.ini`), reproduisant la logique du Bash et gérant l'envoi d'e-mails. | 2, 3, Email |
| **Partie3_Terraform/** | Configuration Terraform (`main.tf`, `variables.tf`) pour orchestrer l'exécution du script Bash sur un hôte distant. | 5, Orchestration |

---

## Exécution des Outils

### Bash

Exécuter le script Bash sur le serveur :
```bash
sudo ./Partie1_Bash/create_users.sh students-inf-361

