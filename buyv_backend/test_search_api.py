"""
Script de test rapide pour vérifier les APIs de recherche et d'édition de profil
"""
import requests
import json

BASE_URL = "http://127.0.0.1:8000"

def test_posts_search():
    """Test de l'API de recherche de posts"""
    print("\n🔍 TEST: Recherche de posts")
    print("-" * 50)
    
    url = f"{BASE_URL}/posts/search"
    params = {
        "q": "p",
        "limit": 20,
        "offset": 0
    }
    
    try:
        response = requests.get(url, params=params, timeout=5)
        print(f"Status Code: {response.status_code}")
        print(f"URL appelée: {response.url}")
        
        if response.status_code == 200:
            data = response.json()
            print(f"✅ Succès! {len(data)} posts trouvés")
            if data:
                print(f"Premier post: {data[0].get('id', 'N/A')}")
        else:
            print(f"❌ Erreur: {response.text}")
            
    except Exception as e:
        print(f"❌ Exception: {e}")

def test_users_search():
    """Test de l'API de recherche d'utilisateurs"""
    print("\n👥 TEST: Recherche d'utilisateurs")
    print("-" * 50)
    
    url = f"{BASE_URL}/users/search"
    params = {
        "q": "a",
        "limit": 20,
        "offset": 0
    }
    
    try:
        response = requests.get(url, params=params, timeout=5)
        print(f"Status Code: {response.status_code}")
        print(f"URL appelée: {response.url}")
        
        if response.status_code == 200:
            data = response.json()
            print(f"✅ Succès! {len(data)} utilisateurs trouvés")
            if data:
                print(f"Premier user: {data[0].get('username', 'N/A')}")
        else:
            print(f"❌ Erreur: {response.text}")
            
    except Exception as e:
        print(f"❌ Exception: {e}")

def test_update_user():
    """Test de l'API d'édition de profil (nécessite un token)"""
    print("\n✏️ TEST: Édition de profil")
    print("-" * 50)
    print("⚠️ Ce test nécessite un token d'authentification valide")
    print("Vérifiez manuellement dans l'app Flutter")

def test_server_health():
    """Test si le serveur répond"""
    print("\n🏥 TEST: Santé du serveur")
    print("-" * 50)
    
    try:
        response = requests.get(f"{BASE_URL}/docs", timeout=5)
        if response.status_code == 200:
            print("✅ Serveur actif et répond sur /docs")
        else:
            print(f"⚠️ Serveur répond avec code: {response.status_code}")
    except Exception as e:
        print(f"❌ Serveur inaccessible: {e}")

if __name__ == "__main__":
    print("=" * 50)
    print("🧪 TESTS DES APIs BUYV BACKEND")
    print("=" * 50)
    
    test_server_health()
    test_posts_search()
    test_users_search()
    test_update_user()
    
    print("\n" + "=" * 50)
    print("✅ Tests terminés")
    print("=" * 50)
