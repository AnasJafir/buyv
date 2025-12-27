"""
Script pour consulter la base de données et vérifier les utilisateurs
"""
import sys
sys.path.insert(0, '.')

from app.database import SessionLocal
from app.models import User, Post
from sqlalchemy import func

def check_database():
    db = SessionLocal()
    
    print("\n" + "="*60)
    print("🔍 CONSULTATION BASE DE DONNÉES BUYV")
    print("="*60)
    
    # 1. Vérifier les utilisateurs
    print("\n👥 UTILISATEURS DANS LA BASE:")
    print("-"*60)
    users = db.query(User).all()
    
    if not users:
        print("❌ AUCUN UTILISATEUR TROUVÉ!")
        print("⚠️ Créez des utilisateurs via l'app ou API")
    else:
        print(f"✅ Total: {len(users)} utilisateurs\n")
        for i, user in enumerate(users, 1):
            print(f"{i}. UID: {user.uid}")
            print(f"   Username: {user.username}")
            print(f"   Email: {user.email}")
            print(f"   Display Name: {user.display_name}")
            print(f"   Profile Image: {user.profile_image_url or 'None'}")
            print()
    
    # 2. Vérifier les posts
    print("\n📝 POSTS DANS LA BASE:")
    print("-"*60)
    posts = db.query(Post).all()
    
    if not posts:
        print("❌ AUCUN POST TROUVÉ!")
    else:
        print(f"✅ Total: {len(posts)} posts\n")
        for i, post in enumerate(posts[:5], 1):  # Afficher 5 premiers
            print(f"{i}. UID: {post.uid}")
            print(f"   Type: {post.type}")
            print(f"   Caption: {post.caption[:50] if post.caption else 'None'}...")
            print(f"   User ID: {post.user_id}")
            print()
        
        if len(posts) > 5:
            print(f"... et {len(posts) - 5} autres posts")
    
    # 3. Test recherche utilisateurs
    print("\n🔍 TEST RECHERCHE UTILISATEURS:")
    print("-"*60)
    
    search_queries = ['a', 'e', 'test', 'user']
    
    for query in search_queries:
        search_pattern = f"%{query}%"
        results = db.query(User).filter(
            (User.username.ilike(search_pattern)) |
            (User.display_name.ilike(search_pattern))
        ).all()
        
        print(f"Recherche '{query}': {len(results)} résultats")
        if results:
            for user in results[:3]:
                print(f"  - {user.username} ({user.display_name})")
    
    # 4. Test recherche posts
    print("\n\n🔍 TEST RECHERCHE POSTS:")
    print("-"*60)
    
    for query in ['p', 'a', 'test']:
        search_pattern = f"%{query}%"
        results = db.query(Post).filter(
            Post.caption.ilike(search_pattern)
        ).all()
        
        print(f"Recherche '{query}': {len(results)} résultats")
        if results:
            for post in results[:3]:
                caption = post.caption[:40] if post.caption else "No caption"
                print(f"  - {caption}...")
    
    print("\n" + "="*60)
    print("✅ CONSULTATION TERMINÉE")
    print("="*60 + "\n")
    
    db.close()

if __name__ == "__main__":
    try:
        check_database()
    except Exception as e:
        print(f"\n❌ ERREUR: {e}")
        import traceback
        traceback.print_exc()
