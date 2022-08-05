---
marp: true
theme: gaia
title: Brief 3 Groupe 1
paginate: true
---
 
# <!--fit--> **Brief 3 : Déploiement scripté d’une application**
### Groupe 1
(Célia, Gabriel, Stéphane)

---

## Topologie

[![](https://mermaid.ink/img/pako:eNptUlFqAjEQvUrIV4WuB5BWqFhKQcFq249u-hGT0Q1kkzBJuljxQJ7Di3V2W6uVhhDeZN6bzDyy5cpr4AO-sr5RlcTEJnPhGK2Yl2uUoWLyE8u7t5f5PVuhdAqYApdQ2vdv3h8uxjWGEiFGn5Goa_Q5wBlzGZMrRzIm493ZtQkBt9vHGZuh-TjsYbf7p_jrdG0SyPJ1yh5acKbvEqdQYSoVDQMMD_sIMp9RwelTMB61zQDTtL1z9LIQbrpZPE3-U_yC35Z0sLVLpUdtnEyQsat02AfrDdTk0_uFIDQYK2vL4BsgBPZoY1RoQiqKofzMCMqaiyc7cMzd3g47p4XrBr8h2XhEaV0bV_SfJ4t-0Rpd9GOs-sXwxzjhyJebgi5au1tR0zRXV3T0ehQVwxyxzBGQWuLXvAaspdH0ObZtC4KnikYSfEBQw0pmmwQXbkfUHDRNf69N8sgHK2kjXHOZk19snOKDhBmOpLGR5ET9w9p9AZWY1xg)](https://mermaid.live/edit#pako:eNptUlFqAjEQvUrIV4WuB5BWqFhKQcFq249u-hGT0Q1kkzBJuljxQJ7Di3V2W6uVhhDeZN6bzDyy5cpr4AO-sr5RlcTEJnPhGK2Yl2uUoWLyE8u7t5f5PVuhdAqYApdQ2vdv3h8uxjWGEiFGn5Goa_Q5wBlzGZMrRzIm493ZtQkBt9vHGZuh-TjsYbf7p_jrdG0SyPJ1yh5acKbvEqdQYSoVDQMMD_sIMp9RwelTMB61zQDTtL1z9LIQbrpZPE3-U_yC35Z0sLVLpUdtnEyQsat02AfrDdTk0_uFIDQYK2vL4BsgBPZoY1RoQiqKofzMCMqaiyc7cMzd3g47p4XrBr8h2XhEaV0bV_SfJ4t-0Rpd9GOs-sXwxzjhyJebgi5au1tR0zRXV3T0ehQVwxyxzBGQWuLXvAaspdH0ObZtC4KnikYSfEBQw0pmmwQXbkfUHDRNf69N8sgHK2kjXHOZk19snOKDhBmOpLGR5ET9w9p9AZWY1xg)

---

## Ressources Azure

- [x] un groupe de ressource
- [x] un réseau avec deux sous réseaux
- [x] une VM A series medium, 1 CPU avec 2 coeurs, 3,5 GiO de RAM, deux disques et Ubuntu 18 pour OS 
- [x] un service Bastion
- [x] un serveur MySQL et une base de données MySQL
- [x] deux IP publiques
- [ ] app insight
---

## Préparation avant l'écriture du script

- Choix du language : **Powershell**
- Script de nettoyage en cas d'erreur
- Installation d'Azure cli et az extension ssh (bastion)
- Choix de l'interface web : **Gitea** (pour l'hébergement d'un serveur git)
- Choix du moyen de configuration initiale de la VM : **cloud-init**

---

## Organisation du script

- Variables déclarées pour :
    - la mise en forme des logs (date, heure) 
    - l'incrémentation des logs
    - le chemin des logs
- Variables déclarées pour l'infrastructure :
    - à quelle étape débuter le script pendant les tests = "variable de développement"
    - noms des variables utilisées (certaines modifiables)

---

## Gestion d'erreurs et try-catch

- Try-catch : on s'en sert pour arrêter le script quand il y a une erreur
- Récupération et ajout dans une variable des sorties standard et erreurs regroupées et affichage de la réussite ou de l'échec de chaque étape

---

## Problèmes rencontrés

- Comment faire du rollback => try-catch => ne fonctionnait pas
- Oubli / mauvaise écriture de certains arguments
- Oubli de l'installation de la database et du firewall
- Création de la database après gitea
- Oubli du tunnel bastion
- Commande qui récupère les logs d'erreur vérifie la (mauvaise) commande précédente
- Lecture des documentations gitea et cloud-init compliquées

---

## Problèmes rencontrés
- Oubli de l'activation de SSL
- Incompatibilité de "geo-redundant-backup Enabled" et de la règle de firewall
- Mauvais encodage pour gitea : prérequis à l'installation
- Priorité des ports différentes
- Montage des disques : trouver un moyen d'identifier le disque de manière certaine
- Gitea est installé mais renvoie à la page de configuration : commande de démarrage ne fonctionnait pas

---

## Manque de temps

- Les modifications des variables par les utilisateurs ne sont pas possibles car les variables sont en dur dans *cloud-init*
- Certbot n'a pas été utilisé pour déployer le certificat TLS
- La rétention des logs pendant un an n'a pas été configurée
- Un moyen de surveillance de la disponibilité de l'application n'a pas été mis en place (*app insight*)

---

## Difficultés rencontrées

### Groupe

Pas de problème, ça s'est très bien passé.

### Travail

Parfois difficultés de compréhension, mais explications par un membre du groupe.
Petit inconfort d'utilisation de yamL
Problème de planning

---

## Ce que j'ai appris

- Utilisation de Powershell et Azure CLI
- Script de déploiement, au moins pour les ressources azures. Plus compliqué pour l'application Gitea.
- Utilisation de Git
- Lire la documentation
- Faire des recherches pour se débloquer