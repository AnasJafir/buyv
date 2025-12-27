@echo off
REM Script de test Deep Linking pour BuyV
REM Date: 27 Dec 2024

echo ========================================
echo  TEST DEEP LINKING - BuyV
echo ========================================
echo.

:menu
echo Choisissez un test:
echo.
echo 1. Test Post/Reel (ID: 762136ed-468b-4315-ba58-16b1d41a1bdb)
echo 2. Test User Profile (ID: 359b21e7-03d4-41de-984a-b693ef6c03f7)
echo 3. Test Product avec parametres
echo 4. Test Home
echo 5. Test Shop
echo 6. Test Reels
echo 7. Test Search
echo 8. Test Custom Post ID
echo 9. Quitter
echo.

set /p choice="Entrez votre choix (1-9): "

if "%choice%"=="1" goto test_post
if "%choice%"=="2" goto test_user
if "%choice%"=="3" goto test_product
if "%choice%"=="4" goto test_home
if "%choice%"=="5" goto test_shop
if "%choice%"=="6" goto test_reels
if "%choice%"=="7" goto test_search
if "%choice%"=="8" goto test_custom
if "%choice%"=="9" goto end
goto menu

:test_post
echo.
echo [TEST 1] Ouverture Post/Reel...
echo Deep Link: buyv://post/762136ed-468b-4315-ba58-16b1d41a1bdb
echo.
adb shell am start -W -a android.intent.action.VIEW -d "buyv://post/762136ed-468b-4315-ba58-16b1d41a1bdb" com.buyv.flutter_app
echo.
echo Resultat attendu: Navigation vers le reel specifique
echo.
pause
goto menu

:test_user
echo.
echo [TEST 2] Ouverture User Profile...
echo Deep Link: buyv://user/359b21e7-03d4-41de-984a-b693ef6c03f7
echo.
adb shell am start -W -a android.intent.action.VIEW -d "buyv://user/359b21e7-03d4-41de-984a-b693ef6c03f7" com.buyv.flutter_app
echo.
echo Resultat attendu: Navigation vers le profil utilisateur
echo.
pause
goto menu

:test_product
echo.
echo [TEST 3] Ouverture Product avec parametres...
echo Deep Link: buyv://product/12345?name=T-Shirt&price=29.99&category=Clothing
echo.
adb shell am start -W -a android.intent.action.VIEW -d "buyv://product/12345?name=T-Shirt&price=29.99&category=Clothing" com.buyv.flutter_app
echo.
echo Resultat attendu: Navigation vers le detail produit
echo.
pause
goto menu

:test_home
echo.
echo [TEST 4] Ouverture Home...
echo Deep Link: buyv://home
echo.
adb shell am start -W -a android.intent.action.VIEW -d "buyv://home" com.buyv.flutter_app
echo.
echo Resultat attendu: Navigation vers l'accueil
echo.
pause
goto menu

:test_shop
echo.
echo [TEST 5] Ouverture Shop...
echo Deep Link: buyv://shop
echo.
adb shell am start -W -a android.intent.action.VIEW -d "buyv://shop" com.buyv.flutter_app
echo.
echo Resultat attendu: Navigation vers le shop
echo.
pause
goto menu

:test_reels
echo.
echo [TEST 6] Ouverture Reels...
echo Deep Link: buyv://reels
echo.
adb shell am start -W -a android.intent.action.VIEW -d "buyv://reels" com.buyv.flutter_app
echo.
echo Resultat attendu: Navigation vers les reels
echo.
pause
goto menu

:test_search
echo.
echo [TEST 7] Ouverture Search...
echo Deep Link: buyv://search
echo.
adb shell am start -W -a android.intent.action.VIEW -d "buyv://search" com.buyv.flutter_app
echo.
echo Resultat attendu: Navigation vers la recherche
echo.
pause
goto menu

:test_custom
echo.
echo [TEST 8] Test avec ID custom...
echo.
set /p postid="Entrez l'ID du post: "
echo.
echo Deep Link: buyv://post/%postid%
echo.
adb shell am start -W -a android.intent.action.VIEW -d "buyv://post/%postid%" com.buyv.flutter_app
echo.
echo Resultat attendu: Navigation vers le post specifique
echo.
pause
goto menu

:end
echo.
echo Au revoir!
exit /b 0
