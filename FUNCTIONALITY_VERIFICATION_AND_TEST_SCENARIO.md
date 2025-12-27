# Vérification des Fonctionnalités et Scénario de Test

## 📋 État des Fonctionnalités

### ✅ Backend - APIs

#### 1. API de Commentaires (`/comments`)
- **Status**: ✅ **IMPLÉMENTÉ**
- **Endpoints**:
  - `POST /comments/{post_uid}` - Ajouter un commentaire
  - `GET /comments/{post_uid}` - Récupérer les commentaires d'un post (avec pagination)
- **Fichier**: `buyv_backend/app/comments.py`
- **Intégration**: ✅ Inclus dans `main.py`

#### 2. API de Recherche
- **Status**: ✅ **IMPLÉMENTÉ**
- **Endpoints**:
  - `GET /users/search?q={query}` - Recherche d'utilisateurs (par username ou display_name)
  - `GET /posts/search?q={query}&type={type}` - Recherche de posts (par caption, avec filtre optionnel par type)
- **Fichiers**: 
  - `buyv_backend/app/users.py` (ligne 41)
  - `buyv_backend/app/posts.py` (ligne 212)
- **Intégration**: ✅ Inclus dans `main.py`

#### 3. API d'Historique des Commandes (`/orders`)
- **Status**: ✅ **IMPLÉMENTÉ**
- **Endpoints**:
  - `GET /orders/me` - Liste toutes les commandes de l'utilisateur connecté
  - `GET /orders/{order_id}` - Détails d'une commande spécifique
  - `GET /orders/me/by_status?status={status}` - Commandes filtrées par statut
- **Fichier**: `buyv_backend/app/orders.py`
- **Intégration**: ✅ Inclus dans `main.py`

### ✅ Frontend - Flutter

#### 1. Commentaires
- **Status**: ✅ **CONNECTÉ**
- **Service**: `lib/services/api/comment_api_service.dart`
- **Méthodes**:
  - `addComment(postUid, content)` - Ajouter un commentaire
  - `getComments(postUid, limit, offset)` - Récupérer les commentaires
- **Modèle**: `lib/domain/models/comment_model.dart`
- **Utilisation**: Utilisé dans les widgets de posts/reels

#### 2. Historique des Commandes
- **Status**: ✅ **CONNECTÉ**
- **Écran**: `lib/presentation/screens/orders/orders_history_screen.dart`
- **Service**: Utilise `OrderService` pour récupérer les commandes
- **Fonctionnalités**:
  - Affichage de toutes les commandes
  - Filtrage par statut (All, Delivered, Processing, Shipped, Cancelled)
  - Détails de chaque commande
  - Navigation vers le suivi de commande

#### 3. Recherche
- **Status**: ⚠️ **PARTIELLEMENT IMPLÉMENTÉ**
- **Écran**: `lib/presentation/screens/search/search_screen.dart`
- **Problème**: Utilise actuellement des données mockées
- **Action requise**: Connecter à l'API `/posts/search` et `/users/search`

#### 4. Deep Linking
- **Status**: ⚠️ **CONFIGURÉ MAIS NON IMPLÉMENTÉ**
- **Configuration Android**: ✅ Configuré dans `AndroidManifest.xml` (ligne 28-35)
- **Configuration iOS**: ✅ Configuré dans `Info.plist` (ligne 48-61)
- **Schéma**: `buyv://product/{id}`
- **Problème**: Aucun code Flutter pour gérer les deep links
- **Action requise**: Implémenter le handler de deep linking dans `main.dart`

---

## 🧪 Scénario de Test Complet

### Prérequis
1. Backend FastAPI en cours d'exécution sur `http://192.168.11.109:8000`
2. Application Flutter installée et fonctionnelle sur votre tablette
3. Utilisateur test créé et connecté dans l'application

---

### Test 1: API de Commentaires (Backend)

login : 

#### 🔑 Connexion (Login) via API

```bash
curl -X POST "http://192.168.11.109:8000/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"email": "anasjafir@gmail.com", "password": "Anasjafir95"}'
```

**Résultat attendu :**
- Status 200
- Retourne un token JWT dans la réponse sous la clé `"access_token"`

> Note : Remplacez `<votre_nom_utilisateur>` et `<votre_mot_de_passe>` par vos identifiants de test.


#### 1.1 Ajouter un commentaire
```bash
# Remplacer {token} par votre token JWT et {post_uid} par un UID de post valide
curl -X POST "http://192.168.11.109:8000/comments/14590799-432f-49ce-bfd6-d643ce2eae48" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzNTliMjFlNy0wM2Q0LTQxZGUtOTg0YS1iNjkzZWY2YzAzZjciLCJleHAiOjE3NjY3NzYxOTd9.ktFxbFCGQgQtTfiR1Q14U1LASgznAsmH7E4M9tqF8NQ" \
  -H "Content-Type: application/json" \
  -d '{"content": "Ceci est un commentaire de test"}'
```

**Résultat attendu**: 
- Status 200
- Retourne un objet CommentOut avec id, userId, username, content, etc.

#### 1.2 Récupérer les commentaires
```bash
curl -X GET "http://192.168.11.109:8000/comments/14590799-432f-49ce-bfd6-d643ce2eae48?limit=20&offset=0"
```

**Résultat attendu**: 
- Status 200
- Retourne une liste de commentaires (peut être vide)

**✅ Vérification Backend**: Les endpoints répondent correctement

---

### Test 2: API de Recherche (Backend)

#### 2.1 Recherche d'utilisateurs
```bash
curl -X GET "http://192.168.11.109:8000/users/search?q=test&limit=20&offset=0"
```

**Résultat attendu**: 
- Status 200
- Retourne une liste d'utilisateurs dont le username ou display_name contient "test"

#### 2.2 Recherche de posts
```bash
# Recherche générale
curl -X GET "http://192.168.11.109:8000/posts/search?q=test&limit=20&offset=0"

# Recherche filtrée par type
curl -X GET "http://192.168.11.109:8000/posts/search?q=test&type=reel&limit=20&offset=0"
```

**Résultat attendu**: 
- Status 200
- Retourne une liste de posts dont le caption contient "test"
- Si type est spécifié, filtre par type (reel, product, photo)

**✅ Vérification Backend**: Les endpoints répondent correctement

---

### Test 3: API d'Historique des Commandes (Backend)

#### 3.1 Liste des commandes
```bash
curl -X GET "http://192.168.11.109:8000/orders/me" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzNTliMjFlNy0wM2Q0LTQxZGUtOTg0YS1iNjkzZWY2YzAzZjciLCJleHAiOjE3NjY3NzYxOTd9.ktFxbFCGQgQtTfiR1Q14U1LASgznAsmH7E4M9tqF8NQ"
```

**Résultat attendu**: 
- Status 200
- Retourne une liste de toutes les commandes de l'utilisateur connecté
- Triées par date (plus récentes en premier)

#### 3.2 Détails d'une commande
```bash
curl -X GET "http://192.168.11.109:8000/orders/{order_id}" \
  -H "Authorization: Bearer {token}"
```

**Résultat attendu**: 
- Status 200
- Retourne les détails complets d'une commande (items, total, statut, etc.)

**✅ Vérification Backend**: Les endpoints répondent correctement

---

### Test 4: Commentaires dans l'Application Flutter

#### 4.1 Ajouter un commentaire
1. Ouvrir l'application sur votre tablette
2. Naviguer vers un post/reel (dans l'écran Reels ou Feed)
3. Cliquer sur l'icône de commentaires
4. Taper un commentaire de test (ex: "Super post!")
5. Cliquer sur "Envoyer" ou "Poster"

**Résultat attendu**: 
- Le commentaire apparaît immédiatement dans la liste
- Le compteur de commentaires du post s'incrémente
- Pas d'erreur affichée

#### 4.2 Voir les commentaires
1. Sur un post qui a des commentaires
2. Cliquer sur l'icône de commentaires
3. Vérifier que la liste des commentaires s'affiche

**Résultat attendu**: 
- Liste des commentaires affichée
- Informations utilisateur (nom, photo) visibles
- Date/heure du commentaire affichée

**✅ Vérification Frontend**: Les commentaires fonctionnent dans l'UI

---

### Test 5: Historique des Commandes dans l'Application Flutter

#### 5.1 Accéder à l'historique
1. Ouvrir l'application
2. Aller dans le profil (icône profil en bas)
3. Cliquer sur "Orders History" ou "Historique des commandes"
4. Ou naviguer directement via `/orders-history`

**Résultat attendu**: 
- Écran d'historique s'affiche
- Liste des commandes chargée (ou message "No orders found" si vide)
- Pas d'erreur de chargement

#### 5.2 Filtrer les commandes
1. Dans l'écran d'historique
2. Cliquer sur un filtre (ex: "Delivered", "Processing")
3. Vérifier que la liste se filtre correctement

**Résultat attendu**: 
- Seules les commandes avec le statut sélectionné s'affichent
- Le filtre sélectionné est mis en évidence

#### 5.3 Voir les détails d'une commande
1. Dans l'historique
2. Cliquer sur "View Details" d'une commande
3. Vérifier les informations affichées

**Résultat attendu**: 
- Modal ou écran avec détails complets
- Numéro de commande, date, statut, items, total affichés
- Bouton pour fermer/retourner

**✅ Vérification Frontend**: L'historique des commandes fonctionne

---

### Test 6: Recherche dans l'Application Flutter

#### 6.1 Recherche d'utilisateurs (si implémentée)
1. Aller dans l'écran de recherche (`/search`)
2. Taper un nom d'utilisateur
3. Vérifier les résultats

**Résultat attendu**: 
- Liste d'utilisateurs correspondants
- Possibilité de cliquer pour voir le profil

#### 6.2 Recherche de posts (à implémenter)
1. Aller dans l'écran de recherche
2. Taper un mot-clé (ex: "test")
3. Vérifier les résultats

**Résultat attendu**: 
- Liste de posts correspondants
- Possibilité de filtrer par type (reel, product, photo)

**⚠️ Note**: Actuellement, l'écran de recherche utilise des données mockées. Il faut connecter à l'API.

---

### Test 7: Deep Linking

#### 7.1 Test depuis un navigateur (Android)
1. Sur votre tablette Android
2. Ouvrir un navigateur (Chrome)
3. Taper dans la barre d'adresse: `buyv://product/123`
4. Appuyer sur Entrée

**Résultat attendu**: 
- L'application BuyV s'ouvre automatiquement
- Navigation vers la page de détail du produit avec ID 123
- Ou message d'erreur si le produit n'existe pas

#### 7.2 Test depuis ADB (Android)
```bash
adb shell am start -W -a android.intent.action.VIEW -d "buyv://product/123" com.buyv.flutter_app
```

**Résultat attendu**: 
- L'application s'ouvre
- Navigation vers le produit

#### 7.3 Test depuis un lien partagé
1. Créer un lien: `buyv://product/{product_id}`
2. Partager ce lien (email, message, etc.)
3. Cliquer sur le lien depuis la tablette

**Résultat attendu**: 
- L'application s'ouvre
- Navigation vers le produit spécifié

**⚠️ Note**: Le deep linking est configuré mais pas encore implémenté dans le code Flutter. Il faut ajouter le handler.

---

## 📝 Checklist de Vérification

### Backend
- [x] API Commentaires - POST /comments/{post_uid}
- [x] API Commentaires - GET /comments/{post_uid}
- [x] API Recherche Utilisateurs - GET /users/search
- [x] API Recherche Posts - GET /posts/search
- [x] API Historique Commandes - GET /orders/me
- [x] API Détails Commande - GET /orders/{order_id}

### Frontend
- [x] Service Commentaires (CommentApiService)
- [x] Écran Historique Commandes (OrdersHistoryScreen)
- [ ] Écran Recherche connecté aux APIs (actuellement mocké)
- [ ] Handler Deep Linking dans main.dart

### Configuration
- [x] Deep Linking Android (AndroidManifest.xml)
- [x] Deep Linking iOS (Info.plist)
- [ ] Handler Deep Linking Flutter

---

## 🔧 Actions Requises

### 1. Connecter la Recherche au Backend
- Modifier `lib/presentation/screens/search/search_screen.dart`
- Appeler `/posts/search` et `/users/search`
- Afficher les résultats réels

### 2. Implémenter le Deep Linking
- Ajouter un package (ex: `uni_links` ou `app_links`)
- Gérer les URLs `buyv://product/{id}` dans `main.dart`
- Naviguer vers `ProductDetailScreen` avec l'ID du produit

---

## 📊 Résumé

| Fonctionnalité | Backend | Frontend | Testable |
|----------------|---------|----------|----------|
| Commentaires | ✅ | ✅ | ✅ |
| Recherche | ✅ | ⚠️ | ⚠️ |
| Historique Commandes | ✅ | ✅ | ✅ |
| Deep Linking | N/A | ⚠️ | ⚠️ |

**Légende**:
- ✅ Complètement implémenté et testable
- ⚠️ Partiellement implémenté ou nécessite des ajustements
- ❌ Non implémenté

---

## 🎯 Prochaines Étapes

1. **Tester les fonctionnalités existantes** selon le scénario ci-dessus
2. **Implémenter le deep linking** dans Flutter
3. **Connecter la recherche** au backend
4. **Documenter les bugs** trouvés pendant les tests
5. **Corriger les problèmes** identifiés

