"""Quick DB check"""
import sys
sys.path.insert(0, '..')
from app.database import SessionLocal
from app.models import Post

db = SessionLocal()
try:
    posts = db.query(Post).filter(Post.type.in_(['reel', 'video'])).all()
    print(f'\n📊 Total video posts: {len(posts)}\n')
    
    if posts:
        for i, p in enumerate(posts[:10], 1):
            print(f'{i}. Post {p.uid}')
            print(f'   URL: {p.media_url or "(EMPTY)"}')
            print(f'   Type: {p.type}\n')
    else:
        print('No video posts found')
finally:
    db.close()
