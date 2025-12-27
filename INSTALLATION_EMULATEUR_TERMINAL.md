# 📦 Installation Émulateur Android (Terminal uniquement)

## 🎯 Objectif
Installer et configurer l'émulateur Android **sans Android Studio**, uniquement via le terminal.

---



## 🔧 Méthode 2: Installation Manuelle (Plus de contrôle)

### Étape 1: Télécharger le SDK Android Command Line Tools

1. **Aller sur:** https://developer.android.com/studio#command-tools
2. **Télécharger:** "Command line tools only"
   - Windows: `commandlinetools-win-XXXXXX_latest.zip`
   - Linux: `commandlinetools-linux-XXXXXX_latest.zip`
   - Mac: `commandlinetools-mac-XXXXXX_latest.zip`

3. **Extraire** dans un dossier:
   - Windows: `C:\Android\Sdk\cmdline-tools\latest`
   - Linux/Mac: `~/Android/Sdk/cmdline-tools/latest`

### Étape 2: Configurer les variables d'environnement

**Windows (PowerShell):**
```powershell
# Ajouter au PATH (temporaire pour cette session)
$env:PATH += ";C:\Android\Sdk\platform-tools;C:\Android\Sdk\emulator;C:\Android\Sdk\cmdline-tools\latest\bin"

# Pour rendre permanent, ajouter dans Variables d'environnement système:
# - ANDROID_HOME = C:\Android\Sdk
# - Ajouter au PATH:
#   - %ANDROID_HOME%\platform-tools
#   - %ANDROID_HOME%\emulator
#   - %ANDROID_HOME%\cmdline-tools\latest\bin
```

**Linux/Mac:**
```bash
# Ajouter à ~/.bashrc ou ~/.zshrc
export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/platform-tools
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin
```

### Étape 3: Installer les composants nécessaires

```bash
# Accepter les licences
yes | sdkmanager --licenses

# Installer les outils de base
sdkmanager "platform-tools" "platforms;android-33" "build-tools;33.0.0"

# Installer l'émulateur
sdkmanager "emulator"

# Installer une image système Android
sdkmanager "system-images;android-33;google_apis;x86_64"
# OU pour ARM (si votre CPU le supporte):
# sdkmanager "system-images;android-33;google_apis;arm64-v8a"
```

### Étape 4: Créer un AVD (Android Virtual Device)

```bash
# Lister les cibles disponibles
avdmanager list targets

# Créer un AVD
avdmanager create avd \
  -n Pixel_5_API_33 \
  -k "system-images;android-33;google_apis;x86_64" \
  -d "pixel_5"

# Paramètres:
# -n: Nom de l'AVD
# -k: Clé du système d'image (format: system-images;android-VERSION;TYPE;ARCH)
# -d: Device profile (pixel_5, pixel_6, etc.)
```

### Étape 5: Vérifier l'installation

```bash
# Vérifier que l'AVD est créé
avdmanager list avd

# Vérifier les outils
adb version
emulator -version
```

---

## 🚀 Démarrer l'émulateur

### Méthode simple
```bash
# Lister les AVD disponibles
emulator -list-avds

# Démarrer
emulator -avd Pixel_5_API_33
```

### Options utiles
```bash
# Démarrer en arrière-plan
emulator -avd Pixel_5_API_33 &

# Démarrer sans snapshot (plus lent mais plus stable)
emulator -avd Pixel_5_API_33 -no-snapshot-load

# Démarrer avec données effacées
emulator -avd Pixel_5_API_33 -wipe-data

# Démarrer avec RAM personnalisée
emulator -avd Pixel_5_API_33 -memory 4096
```

---

## ✅ Vérification

### Vérifier que l'émulateur fonctionne
```bash
# Attendre que l'émulateur démarre (30-60 secondes)
# Puis vérifier:
adb devices

# Devrait afficher:
# List of devices attached
# emulator-5554   device
```

### Vérifier que l'émulateur est prêt
```bash
# Attendre que l'émulateur soit complètement démarré
adb wait-for-device

# Vérifier que le système est prêt
adb shell getprop sys.boot_completed
# Devrait retourner: 1
```

---

## 🐛 Résolution de Problèmes

### Problème: "emulator: command not found"
**Solution:**
```bash
# Vérifier que l'émulateur est dans le PATH
which emulator  # Linux/Mac
where emulator  # Windows

# Si non trouvé, ajouter au PATH (voir Étape 2)
```

### Problème: "sdkmanager: command not found"
**Solution:**
```bash
# Vérifier que cmdline-tools est dans le PATH
# Le chemin devrait être: .../cmdline-tools/latest/bin
```

### Problème: "HAXM is not installed" (Windows)
**Solution:**
```bash
# Installer HAXM depuis:
# https://github.com/intel/haxm/releases
# OU utiliser l'accélération Hyper-V (Windows 10/11)
```

### Problème: L'émulateur est très lent
**Solutions:**
1. **Augmenter la RAM:**
   ```bash
   emulator -avd Pixel_5_API_33 -memory 4096
   ```

2. **Utiliser l'accélération matérielle:**
   - Vérifier que HAXM ou Hyper-V est activé
   - `flutter doctor` devrait le confirmer

3. **Réduire la résolution:**
   - Créer un AVD avec résolution plus faible

### Problème: "x86_64 images require hardware acceleration"
**Solution:**
```bash
# Utiliser une image ARM à la place
sdkmanager "system-images;android-33;google_apis;arm64-v8a"
avdmanager create avd -n Pixel_5_API_33_ARM -k "system-images;android-33;google_apis;arm64-v8a"
```

---

## 📊 Comparaison des méthodes

| Méthode | Avantages | Inconvénients |
|---------|-----------|---------------|
| **Via Flutter** | ✅ Simple et rapide<br>✅ Géré automatiquement<br>✅ Pas besoin de configurer PATH | ❌ Moins de contrôle<br>❌ Dépend de Flutter |
| **Manuelle** | ✅ Contrôle total<br>✅ Personnalisable<br>✅ Indépendant de Flutter | ❌ Plus complexe<br>❌ Nécessite configuration PATH |

**Recommandation:** Utilisez la méthode Flutter si vous êtes pressé, la méthode manuelle si vous voulez plus de contrôle.

---

## 🎯 Prochaines étapes

Une fois l'émulateur installé et démarré:

1. **Vérifier la connexion:**
   ```bash
   adb devices
   ```

2. **Lancer l'app Flutter:**
   ```bash
   cd buyv_flutter_app
   flutter run
   ```

3. **Consulter les guides:**
   - `DEMARRAGE_RAPIDE.md` - Pour démarrer rapidement
   - `GUIDE_TEST_EMULATEUR.md` - Guide complet de test

---

**💡 Astuce:** Gardez l'émulateur démarré en arrière-plan pour éviter de le redémarrer à chaque fois.

