# 🛒 Configuration du Proxy CJ Dropshipping

## ❌ Problème Résolu

**Erreur**: `CJAPIException: Failed to obtain valid token (Code: 401)`  
**Cause**: Le serveur proxy CORS pour CJ Dropshipping n'était pas démarré  
**Impact**: Les produits ne pouvaient pas être chargés dans la boutique

## ✅ Solution

Le serveur proxy Node.js doit être en cours d'exécution sur le port 3001 pour que l'application Flutter puisse communiquer avec l'API CJ Dropshipping.

### 📋 Étapes de Configuration

#### 1. Installation des Dépendances (Une Seule Fois)

```bash
cd buyv_flutter_app
npm install
```

**Dépendances installées**:
- express
- cors
- http-proxy-middleware
- https

#### 2. Démarrage du Serveur Proxy

**Option A: Utiliser le fichier batch (Recommandé)**
```bash
cd buyv_flutter_app
start_proxy.bat
```

**Option B: Commande manuelle**
```bash
cd buyv_flutter_app
node cors_proxy_server.js
```

#### 3. Vérification du Serveur

Le serveur affichera:
```
🚀 CJ Dropshipping CORS Proxy Server running on http://localhost:3001
📡 Proxying requests to: https://developers.cjdropshipping.com
🔗 Use this base URL in your Flutter app: http://localhost:3001/api/cj
💡 Health check: http://localhost:3001/health
```

**Vérifier le port**:
```powershell
netstat -ano | Select-String ":3001"
```

Devrait montrer: `LISTENING` sur le port 3001

## 🔧 Configuration Technique

### URLs Selon la Plateforme

**Configuration dans**: `lib/core/config/environment_config.dart`

- **Web**: `http://127.0.0.1:3001/api/cj`
- **Android (émulateur)**: `http://10.0.2.2:3001/api/cj`
- **Android (appareil physique)**: `http://192.168.11.109:3001/api/cj`
- **iOS Simulator**: `http://localhost:3001/api/cj`

### Architecture du Proxy

```
Flutter App → Proxy CORS (port 3001) → CJ Dropshipping API
            (localhost)                (developers.cjdropshipping.com)
```

Le proxy:
1. Élimine les erreurs CORS
2. Redirige `/api/cj` vers `/api2.0/v1` de CJ
3. Gère les headers d'authentification
4. Timeout: 30 secondes

## 📁 Fichiers Impliqués

### Serveur Proxy
- **cors_proxy_server.js**: Serveur Express avec proxy middleware
- **start_proxy.bat**: Script de démarrage Windows
- **package.json**: Dépendances Node.js

### Configuration Flutter
- **lib/core/config/environment_config.dart**: URLs selon plateforme
- **lib/constants/app_constants.dart**: Configuration CJ API
- **lib/services/cj_dropshipping_service.dart**: Service d'authentification et requêtes

## 🚨 Procédure Avant Chaque Test

### Checklist Avant de Lancer l'App

1. ✅ Backend FastAPI actif sur port 8000
   ```bash
   cd buyv_backend
   run_backend.bat
   ```

2. ✅ Proxy CJ actif sur port 3001
   ```bash
   cd buyv_flutter_app
   start_proxy.bat
   ```

3. ✅ Flutter app
   ```bash
   cd buyv_flutter_app
   flutter run
   ```

### Ordre de Démarrage Important

```
1. Backend FastAPI (port 8000)    ← Données utilisateurs, posts, etc.
2. Proxy CJ (port 3001)           ← Produits CJ Dropshipping
3. Flutter App                     ← Interface utilisateur
```

## 🐛 Dépannage

### Erreur: "Connection timed out (errno = 110)"

**Cause**: Le serveur proxy n'est pas démarré

**Solution**:
```bash
cd buyv_flutter_app
node cors_proxy_server.js
```

### Erreur: "Cannot find module 'express'"

**Cause**: Dépendances non installées

**Solution**:
```bash
cd buyv_flutter_app
npm install
```

### Serveur Proxy se Ferme Immédiatement

**Cause**: Erreur dans le code ou port déjà utilisé

**Solution**:
1. Vérifier les logs du serveur
2. Tuer le processus sur le port 3001:
   ```powershell
   # Trouver le PID
   netstat -ano | Select-String ":3001"
   
   # Tuer le processus (remplacer PID)
   taskkill /PID <PID> /F
   ```

### Produits Ne Se Chargent Pas

**Vérifications**:
1. Proxy actif: `netstat -ano | Select-String ":3001"`
2. Health check: Ouvrir `http://localhost:3001/health` dans un navigateur
3. Credentials CJ valides dans `app_constants.dart`

## 📱 Configuration Appareil Physique

Si vous testez sur un **appareil physique Android**:

1. Appareil et PC sur le **même réseau WiFi**
2. Trouver l'IP de votre PC:
   ```bash
   ipconfig
   ```
3. Mettre à jour `_localNetworkIp` dans `environment_config.dart`:
   ```dart
   static const String _localNetworkIp = '192.168.11.109'; // Votre IP
   ```
4. Redémarrer l'app Flutter

## 🔐 Sécurité

### Credentials CJ Dropshipping

Définis dans `lib/constants/app_constants.dart`:
```dart
static const String cjEmail = 'votre_email@example.com';
static const String cjApiKey = 'votre_cle_api';
```

⚠️ **Ne jamais commiter ces valeurs en production**

### Tokens

- **Access Token**: Valide 30 jours
- **Stockage**: Sécurisé via `CJTokenManager`
- **Refresh**: Automatique si expiré

## 📊 Logs Utiles

### Vérifier l'Authentification CJ

Dans les logs Flutter:
```
🔐 CJ Authentication attempt with proxy URL: http://192.168.11.109:3001/api/cj
✅ CJ Authentication successful
🛍️ Access Token obtained and stored securely
```

### Logs du Proxy

Dans le terminal du proxy:
```
Proxying POST /api/cj/authentication/getAccessToken to CJ API
Response from CJ API: 200
```

## ✅ Test de Validation

### 1. Test du Proxy
```bash
curl http://localhost:3001/health
```

Réponse attendue:
```json
{
  "status": "ok",
  "timestamp": "2024-01-15T10:30:00.000Z",
  "proxy": {
    "target": "https://developers.cjdropshipping.com",
    "health": "operational"
  }
}
```

### 2. Test de l'App

1. Ouvrir la section **Shop** dans l'app
2. Les produits doivent se charger
3. Pas d'erreur CJAPIException dans les logs

## 📝 Notes

- Le proxy doit rester **actif pendant toute la session** de test
- **Ne pas fermer** le terminal du proxy
- Si le proxy se ferme, redémarrer avec `start_proxy.bat`
- Pour production, considérer un proxy hébergé (Heroku, Railway, etc.)

## 🔄 Modifications Appliquées

### Fichiers Modifiés

1. **search_screen.dart** (Simplifié)
   - ✅ Onglet "Posts" supprimé
   - ✅ Recherche limitée aux utilisateurs uniquement
   - ✅ Interface simplifiée sans TabBar

2. **Proxy CJ** (Activé)
   - ✅ Dépendances Node.js installées
   - ✅ Serveur proxy actif sur port 3001
   - ✅ Configuration validée

## 🎯 État Actuel

- ✅ Backend FastAPI: OPÉRATIONNEL (port 8000)
- ✅ Proxy CJ: OPÉRATIONNEL (port 3001)
- ✅ Search Screen: SIMPLIFIÉ (users-only)
- ⏳ Flutter App: PRÊTE À TESTER

---

**Dernière mise à jour**: ${DateTime.now()}  
**Proxy Status**: ✅ ACTIF sur port 3001
