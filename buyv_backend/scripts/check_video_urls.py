"""
Script de diagnostic pour vérifier les URLs vidéo dans la base de données
"""
import sys
import os

# Add parent directory to path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from app.database import SessionLocal
from app.models import Post, User

def check_video_urls():
    """Vérifie toutes les URLs vidéo dans la base de données"""
    db = SessionLocal()
    try:
        print("=" * 80)
        print("🔍 DIAGNOSTIC: Vérification des URLs vidéo dans la base de données")
        print("=" * 80)
        print()
        
        # Get all posts of type 'reel' or 'video'
        posts = db.query(Post).filter(Post.type.in_(['reel', 'video'])).all()
        
        print(f"📊 Total posts vidéo trouvés: {len(posts)}")
        print()
        
        if not posts:
            print("⚠️  Aucun post vidéo trouvé dans la base de données!")
            print("   Créez un reel depuis l'application pour tester.")
            return
        
        # Statistics
        empty_urls = 0
        cloudinary_urls = 0
        http_urls = 0
        https_urls = 0
        invalid_urls = 0
        
        print("-" * 80)
        print("DÉTAILS DES POSTS:")
        print("-" * 80)
        
        for i, post in enumerate(posts, 1):
            user = db.query(User).filter(User.id == post.user_id).first()
            username = user.username if user else "Unknown"
            
            print(f"\n{i}. Post ID: {post.uid}")
            print(f"   👤 User: {username} (ID: {post.user_id})")
            print(f"   📝 Type: {post.type}")
            print(f"   📅 Created: {post.created_at}")
            print(f"   📹 Media URL: {post.media_url or '(EMPTY)'}")
            
            if post.caption:
                print(f"   💬 Caption: {post.caption[:50]}...")
            
            # Analyze URL
            if not post.media_url or post.media_url.strip() == "":
                print(f"   ❌ STATUS: URL VIDE - C'est le problème!")
                empty_urls += 1
            elif post.media_url.startswith('https://'):
                print(f"   ✅ STATUS: URL HTTPS valide")
                https_urls += 1
                if 'cloudinary.com' in post.media_url:
                    cloudinary_urls += 1
                    print(f"   ☁️  TYPE: Cloudinary")
            elif post.media_url.startswith('http://'):
                print(f"   ⚠️  STATUS: URL HTTP (non sécurisé)")
                http_urls += 1
            else:
                print(f"   ❌ STATUS: URL INVALIDE (pas http/https)")
                invalid_urls += 1
            
            print(f"   👍 Likes: {post.likes_count}")
            print(f"   💬 Comments: {post.comments_count}")
        
        # Summary
        print()
        print("=" * 80)
        print("📊 RÉSUMÉ:")
        print("=" * 80)
        print(f"Total posts vidéo: {len(posts)}")
        print(f"✅ URLs HTTPS valides: {https_urls}")
        print(f"☁️  URLs Cloudinary: {cloudinary_urls}")
        print(f"⚠️  URLs HTTP (non sécurisé): {http_urls}")
        print(f"❌ URLs VIDES: {empty_urls} {'← PROBLÈME CRITIQUE!' if empty_urls > 0 else ''}")
        print(f"❌ URLs invalides: {invalid_urls}")
        print()
        
        if empty_urls > 0:
            print("🔥 PROBLÈME DÉTECTÉ:")
            print(f"   {empty_urls} post(s) ont des URLs vidéo vides!")
            print("   Cela explique les points d'exclamation rouges dans l'app.")
            print()
            print("💡 SOLUTIONS POSSIBLES:")
            print("   1. Vérifier que l'upload Cloudinary fonctionne correctement")
            print("   2. Vérifier les credentials Cloudinary dans .env")
            print("   3. Vérifier les logs de l'app Flutter lors de la création d'un post")
            print("   4. Tester l'upload manuellement depuis add_post_screen.dart")
        else:
            print("✅ Toutes les URLs vidéo semblent correctes!")
            print("   Si le problème persiste, vérifiez:")
            print("   - Les permissions CORS de Cloudinary")
            print("   - L'accès réseau de l'application")
            print("   - Les logs du VideoPlayerWidget dans l'app")
        
        print()
        print("=" * 80)
        
    finally:
        db.close()

if __name__ == "__main__":
    check_video_urls()
