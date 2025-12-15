# ⚙️ Partie 2: Playbook Ansible
Ce répertoire contient le Playbook Ansible `create_users.yml` et le fichier d'inventaire `inventory.ini`.

## Prérequis
* Ansible doit être installé sur la machine de contrôle.
* Le service SMTP doit être configuré (ou utiliser un relai comme SendGrid ou Mailgun) pour l'envoi d'e-mails dans le Playbook.

## Exécution
`ansible-playbook -i inventory.ini create_users.yml`
