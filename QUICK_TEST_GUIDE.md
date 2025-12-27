# 🧪 Guide de Test Rapide - BuyV

## Tests à effectuer avant la démo client

### 1. Test Système de Commentaires

#### Backend
```bash
# Démarrer le backend
cd buyv_backend
python -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload

# Tester l'endpoint (remplacer TOKEN et POST_UID)
curl -X GET "http://localhost:8000/comments/POST_UID?limit=20&offset=0" \
  -H "Authorization: Bearer TOKEN"

curl -X POST "http://localhost:8000/comments/POST_UID" \
  -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"content": "Test comment"}'
```

#### Frontend
1. Ouvrir l'app
2. Aller dans l'onglet "Reels"
3. Cliquer sur l'icône commentaire d'un reel
4. Vérifier que les commentaires existants s'affichent
5. Ajouter un nouveau commentaire
6. Vérifier qu'il apparaît immédiatement avec format "time-ago"

**✅ Critères de succès:**
- Les commentaires se chargent sans erreur
- Le nouveau commentaire apparaît en haut de la liste
- Le format "time-ago" s'affiche correctement (ex: "2m", "1h", "3d")

---

### 2. Test Paiements Stripe

#### Prérequis
- Vérifier que `STRIPE_SECRET_KEY` est dans `buyv_backend/.env`
- Utiliser les clés de test Stripe

#### Test
1. Ajouter des produits au panier
2. Aller au checkout
3. Cliquer sur "Pay Now"
4. Vérifier que le Payment Sheet Stripe s'ouvre
5. Utiliser la carte de test: `4242 4242 4242 4242`
   - Date: n'importe quelle date future
   - CVC: n'importe quel 3 chiffres
   - Code postal: n'importe quel code postal
6. Confirmer le paiement
7. Vérifier que la commande est créée

**✅ Critères de succès:**
- Le Payment Sheet s'ouvre sans erreur
- Le paiement avec carte test fonctionne
- La commande est créée dans la base de données

---

### 3. Test Historique des Commandes

#### Test
1. Se connecter avec un compte qui a des commandes
2. Aller dans Profile → Orders History
3. Vérifier que les commandes s'affichent
4. Tester les filtres (All, Delivered, Processing, Shipped, Cancelled)
5. Vérifier les couleurs des statuts:
   - Delivered: Vert
   - Processing: Orange
   - Shipped: Bleu
   - Cancelled: Rouge

**✅ Critères de succès:**
- Les commandes se chargent depuis le serveur (pas de mock data)
- Les filtres fonctionnent correctement
- Les couleurs correspondent aux statuts

---

### 4. Test Cache Vidéo

#### Test
1. Ouvrir l'app et aller dans Reels
2. Faire défiler quelques vidéos (les laisser charger)
3. Fermer complètement l'app
4. Rouvrir l'app et retourner dans Reels
5. Faire défiler vers les mêmes vidéos
6. Vérifier qu'elles se chargent plus rapidement (cache)

**✅ Critères de succès:**
- Les vidéos se chargent instantanément après le premier chargement
- Pas de re-téléchargement si la vidéo est en cache

---

### 5. Test Deep Linking

#### Android
```bash
# Tester depuis un terminal ADB
adb shell am start -a android.intent.action.VIEW -d "buyv://product/123"
```

#### iOS
```bash
# Tester depuis un terminal
xcrun simctl openurl booted "buyv://product/123"
```

#### Test manuel
1. Créer un lien `buyv://product/123` dans un navigateur ou autre app
2. Cliquer sur le lien
3. Vérifier que l'app s'ouvre et navigue vers le produit

**✅ Critères de succès:**
- L'app s'ouvre depuis le lien
- La navigation vers le produit fonctionne
- L'ID du produit est correctement passé

---

## 🐛 Résolution des Problèmes Courants

### Problème: Backend ne démarre pas
```bash
# Vérifier les dépendances
cd buyv_backend
pip install -r requirements.txt

# Vérifier le fichier .env
cat .env  # Vérifier que DATABASE_URL est présent

# Vérifier la base de données
python -c "from app.database import engine; engine.connect()"
```

### Problème: App ne se connecte pas au backend
1. Vérifier que le backend tourne: `http://localhost:8000/health`
2. Vérifier l'URL dans `EnvironmentConfig.fastApiBaseUrl`
3. Pour Android Emulator, utiliser `10.0.2.2:8000` au lieu de `localhost:8000`

### Problème: Erreur de build cached_video_player
```bash
# Option 1: Mettre à jour Flutter
flutter upgrade

# Option 2: Nettoyer et reconstruire
cd buyv_flutter_app
flutter clean
flutter pub get
flutter build apk --debug
```

### Problème: Stripe Payment Sheet ne s'ouvre pas
1. Vérifier que `STRIPE_SECRET_KEY` est dans `.env` backend
2. Vérifier les logs backend pour erreurs Stripe
3. Utiliser les clés de test Stripe (commencent par `sk_test_`)

### Problème: Commentaires ne s'affichent pas
1. Vérifier que l'utilisateur est connecté (JWT token valide)
2. Vérifier les logs backend: `curl http://localhost:8000/comments/POST_UID`
3. Vérifier que le `post_uid` existe dans la base de données

---

## 📊 Checklist Finale

Avant la démo, vérifier:

- [ ] Backend démarre sans erreur
- [ ] Base de données accessible
- [ ] App compile sans erreur
- [ ] Authentification fonctionne
- [ ] Commentaires: Ajout et affichage OK
- [ ] Paiements Stripe: Payment Sheet s'ouvre
- [ ] Historique commandes: Affichage avec statuts colorés
- [ ] Cache vidéo: Chargement rapide après premier load
- [ ] Deep linking: Navigation depuis lien externe
- [ ] Pas d'erreurs dans les logs (backend et Flutter)

---

## 🎯 Scénario de Démo Recommandé

1. **Introduction** (2 min)
   - Présenter l'app et ses fonctionnalités principales

2. **Système de Commentaires** (3 min)
   - Montrer un reel avec commentaires existants
   - Ajouter un nouveau commentaire en direct
   - Montrer le format "time-ago"
   - **Message clé**: "Les commentaires sont maintenant en temps réel, connectés au serveur"

3. **Paiements Stripe** (3 min)
   - Ajouter un produit au panier
   - Aller au checkout
   - Ouvrir le Payment Sheet Stripe
   - **Message clé**: "Intégration complète avec Stripe, prête pour les paiements réels"

4. **Historique des Commandes** (2 min)
   - Montrer l'historique avec différents statuts
   - Tester les filtres
   - **Message clé**: "Données réelles depuis le serveur, plus de mock data"

5. **Performance Vidéo** (2 min)
   - Montrer le chargement rapide des vidéos après cache
   - **Message clé**: "Optimisation avec cache vidéo pour une meilleure expérience"

6. **Deep Linking** (1 min)
   - Tester un lien `buyv://product/123`
   - **Message clé**: "L'app peut être ouverte depuis des liens externes"

**Total: ~13 minutes**

---

**Bonne chance pour la démo! 🚀**

