@echo off
echo ==========================================
echo   Lancement de BuyV Flutter App
echo ==========================================

echo.
echo [1/5] Vérification du dossier...
if not exist "pubspec.yaml" (
    echo ERREUR: Vous n'êtes pas dans le bon dossier !
    echo Naviguez vers buyv_flutter_app avant d'exécuter ce script.
    pause
    exit /b 1
)

echo.
echo [2/5] Nettoyage du projet...
call flutter clean
cd android
call gradlew.bat clean
cd ..

echo.
echo [3/5] Suppression des caches...
if exist "build" rmdir /s /q "build"
if exist "android\.gradle" rmdir /s /q "android\.gradle"

echo.
echo [4/5] Récupération des dépendances...
call flutter pub get

echo.
echo [5/5] Lancement de l'application...
call flutter run

pause