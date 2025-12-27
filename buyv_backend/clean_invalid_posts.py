"""
Script pour nettoyer les posts avec URLs invalides ou mock
"""
import sys
sys.path.insert(0, '..')
from app.database import SessionLocal
from app.models import Post

db = SessionLocal()
try:
    print("\n🔍 Recherche de posts avec URLs invalides...")
    
    # Find posts with invalid URLs
    all_posts = db.query(Post).filter(Post.type.in_(['reel', 'video'])).all()
    invalid_posts = []
    
    for post in all_posts:
        if not post.media_url or post.media_url.strip() == "":
            invalid_posts.append((post, "URL vide"))
        elif "example.com" in post.media_url:
            invalid_posts.append((post, "URL mock (example.com)"))
        elif not post.media_url.startswith("https://"):
            invalid_posts.append((post, "URL non HTTPS"))
    
    if not invalid_posts:
        print("✅ Aucun post invalide trouvé!")
        print(f"   Total posts vidéo: {len(all_posts)}")
        print("   Toutes les URLs sont valides!")
    else:
        print(f"\n⚠️  {len(invalid_posts)} post(s) invalide(s) trouvé(s):\n")
        
        for i, (post, reason) in enumerate(invalid_posts, 1):
            print(f"{i}. Post {post.uid}")
            print(f"   Raison: {reason}")
            print(f"   URL: {post.media_url or '(vide)'}")
            print(f"   Type: {post.type}")
            print(f"   Créé: {post.created_at}\n")
        
        response = input("Voulez-vous supprimer ces posts invalides? (y/n): ")
        
        if response.lower() == 'y':
            for post, _ in invalid_posts:
                db.delete(post)
            db.commit()
            print(f"\n✅ {len(invalid_posts)} post(s) supprimé(s)!")
        else:
            print("\n❌ Opération annulée.")
    
    print(f"\n📊 Résumé final:")
    remaining_posts = db.query(Post).filter(Post.type.in_(['reel', 'video'])).all()
    print(f"   Total posts vidéo restants: {len(remaining_posts)}")
    
finally:
    db.close()
