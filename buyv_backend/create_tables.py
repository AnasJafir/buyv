"""
Script pour créer toutes les tables de la base de données
Utiliser après déploiement Railway ou lors du premier setup
"""

from app.database import engine
from app.models import Base
import sys

def create_tables():
    """Créer toutes les tables définies dans les modèles SQLAlchemy"""
    try:
        print("🔧 Création des tables de la base de données...")
        print(f"📊 Connexion à: {engine.url}")
        
        # Créer toutes les tables
        Base.metadata.create_all(bind=engine)
        
        print("✅ Tables créées avec succès!")
        print("\n📋 Tables créées:")
        for table in Base.metadata.sorted_tables:
            print(f"  - {table.name}")
        
        return True
        
    except Exception as e:
        print(f"❌ Erreur lors de la création des tables: {e}")
        import traceback
        traceback.print_exc()
        return False

if __name__ == "__main__":
    success = create_tables()
    sys.exit(0 if success else 1)
