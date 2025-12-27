"""
API endpoint pour nettoyer les posts invalides
"""
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from .database import get_db
from .models import Post

router = APIRouter(prefix="/cleanup", tags=["cleanup"])

@router.get("/check-invalid-posts")
async def check_invalid_posts(db: Session = Depends(get_db)):
    """Vérifie les posts avec URLs invalides"""
    all_posts = db.query(Post).filter(Post.type.in_(['reel', 'video'])).all()
    invalid_posts = []
    
    for post in all_posts:
        reason = None
        if not post.media_url or post.media_url.strip() == "":
            reason = "URL vide"
        elif "example.com" in post.media_url:
            reason = "URL mock (example.com)"
        elif not post.media_url.startswith("https://"):
            reason = "URL non HTTPS"
        
        if reason:
            invalid_posts.append({
                "id": str(post.uid),
                "reason": reason,
                "url": post.media_url or "(vide)",
                "type": post.type,
                "created_at": str(post.created_at)
            })
    
    return {
        "total_video_posts": len(all_posts),
        "invalid_posts": invalid_posts,
        "invalid_count": len(invalid_posts)
    }

@router.delete("/delete-invalid-posts")
async def delete_invalid_posts(db: Session = Depends(get_db)):
    """Supprime les posts avec URLs invalides"""
    all_posts = db.query(Post).filter(Post.type.in_(['reel', 'video'])).all()
    deleted_count = 0
    
    for post in all_posts:
        is_invalid = False
        if not post.media_url or post.media_url.strip() == "":
            is_invalid = True
        elif "example.com" in post.media_url:
            is_invalid = True
        elif not post.media_url.startswith("https://"):
            is_invalid = True
        
        if is_invalid:
            db.delete(post)
            deleted_count += 1
    
    db.commit()
    
    remaining = db.query(Post).filter(Post.type.in_(['reel', 'video'])).count()
    
    return {
        "deleted_count": deleted_count,
        "remaining_posts": remaining,
        "message": f"✅ {deleted_count} post(s) invalide(s) supprimé(s)!"
    }
