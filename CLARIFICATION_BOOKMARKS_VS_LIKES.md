# Clarification : Bookmarks vs Liked Posts

## 🔖 Bookmarks (Saved) vs ❤️ Liked Posts

### Tab "Saved" (Bookmarks) - Index 2

**Icon** : 🔖 Bookmark

**Fonction** : 
- Sauvegarder des posts/reels pour les retrouver plus tard
- Liste privée (seul l'utilisateur voit ses bookmarks)
- Comme les "favoris" ou "enregistrements" sur Instagram

**Utilisation** :
- Cliquer sur l'icône bookmark dans un post → ajouté à "Saved"
- Consulter les posts sauvegardés dans Profile → Tab "Saved"

**Backend** :
- Table `post_bookmarks` avec `user_id` et `post_id`
- Endpoints : `/posts/{post_uid}/bookmark`, `/posts/{post_uid}/unbookmark`
- Récupération : `/posts/user/{uid}/bookmarked` ou `/posts/by-ids`

---

### Tab "Liked" - Index 3

**Icon** : ❤️ Heart/Like

**Fonction** :
- Liker un post/reel pour montrer qu'on l'aime
- Liste privée ou publique selon settings
- Contribue au compteur de likes visible par tous
- Comme les "J'aime" sur Instagram

**Utilisation** :
- Cliquer sur l'icône cœur dans un post → ajouté à "Liked"
- Consulter les posts likés dans Profile → Tab "Liked"
- Le créateur du post voit le nombre de likes augmenter

**Backend** :
- Table `post_likes` avec `user_id` et `post_id`
- Endpoints : `/posts/{post_uid}/like`, `/posts/{post_uid}/unlike`
- Récupération : `/posts/user/{uid}/liked`

---

## 📊 Comparaison

| Feature | Bookmarks (Saved) | Liked Posts |
|---------|-------------------|-------------|
| **Icon** | 🔖 | ❤️ |
| **Action** | Sauvegarder | Aimer |
| **Visibilité** | Privée | Publique (compteur) |
| **Objectif** | Retrouver plus tard | Montrer son appréciation |
| **Compteur visible** | Non | Oui (`likes_count`) |
| **Table DB** | `post_bookmarks` | `post_likes` |
| **Endpoint GET** | `/posts/user/{uid}/bookmarked` | `/posts/user/{uid}/liked` |

---

## 🐛 Problème Signalé : "j'ai un posts liké qui ne s'affiche pas"

### Causes Possibles

1. **Post supprimé** :
   - Le like existe en DB mais le post a été supprimé
   - L'endpoint `/posts/user/{uid}/liked` charge les posts via JOIN
   - Si post supprimé → ne s'affiche pas

2. **Problème de synchronisation** :
   - Le like n'a pas été enregistré en backend
   - Vérifier les logs backend

3. **Cache/Timing** :
   - Le like vient d'être fait, tab "Liked" pas encore rafraîchi
   - Besoin d'actualiser la page

### Solution : LikeProvider (similaire à BookmarkProvider)

Pour avoir la même synchronisation en temps réel que les bookmarks, il faudrait :

1. **Créer `LikeProvider`** :
```dart
class LikeProvider extends ChangeNotifier {
  Set<String> _likedPostIds = {};
  
  Set<String> get likedPostIds => _likedPostIds;
  
  bool isLiked(String postId) => _likedPostIds.contains(postId);
  
  Future<void> loadLikes() async {
    final posts = await PostService().getUserLikedPosts('');
    _likedPostIds = posts.map((p) => p.id).toSet();
    notifyListeners();
  }
  
  Future<void> toggleLike(String postId) async {
    if (_likedPostIds.contains(postId)) {
      // Unliked
      _likedPostIds.remove(postId);
      notifyListeners();
      final success = await PostApiService.unlikePost(postId);
      if (!success) {
        _likedPostIds.add(postId);
        notifyListeners();
      }
    } else {
      // Like
      _likedPostIds.add(postId);
      notifyListeners();
      final success = await PostApiService.likePost(postId);
      if (!success) {
        _likedPostIds.remove(postId);
        notifyListeners();
      }
    }
  }
}
```

2. **Modifier `profile_screen.dart`** :
```dart
case 3: // Liked - ✅ UTILISE LikeProvider au lieu de l'API
  final likeProvider = Provider.of<LikeProvider>(context, listen: false);
  final likedIds = likeProvider.likedPostIds.toList();
  
  if (likedIds.isEmpty) {
    return [];
  }
  
  // Charge les posts complets pour les IDs likés
  return await _postService.getPostsByIds(likedIds);
```

3. **Ajouter listener similaire à bookmarks**

---

## ✅ Actions Recommandées

### Option 1 : Investiguer le Post Manquant
1. Vérifier en DB si le post existe :
   ```sql
   SELECT * FROM posts WHERE uid = 'POST_ID';
   ```

2. Vérifier si le like existe :
   ```sql
   SELECT * FROM post_likes WHERE user_id = USER_ID;
   ```

3. Regarder les logs backend lors de l'appel `/posts/user/{uid}/liked`

### Option 2 : Implémenter LikeProvider
Créer un `LikeProvider` sur le même modèle que `BookmarkProvider` pour avoir une synchronisation en temps réel.

### Option 3 : Force Refresh
Ajouter un bouton "Actualiser" sur le tab "Liked" pour forcer le rechargement depuis l'API.

---

## 📝 Clarification pour le Client

**Bookmarks (Saved)** = 🔖 Pour retrouver plus tard (privé)
- Utile pour sauvegarder des produits intéressants
- Permet de créer une collection personnelle

**Liked Posts** = ❤️ Pour montrer qu'on aime (public)
- Augmente la visibilité du post
- Montre au créateur qu'on apprécie son contenu
- Peut influencer l'algorithme de recommandation

Les deux sont complémentaires :
- Je **like** ❤️ un post que je trouve génial (le créateur voit +1 like)
- Je **bookmark** 🔖 un produit que je veux acheter plus tard (privé)

---

## 🎯 Conclusion

Pour avoir la même expérience fluide sur "Liked Posts" que sur "Bookmarks", il faut :
1. Créer un `LikeProvider` 
2. Modifier la page profile pour l'utiliser
3. Ajouter un listener sur les changements de likes

Sinon, le système actuel fonctionne mais nécessite une actualisation manuelle de la page profile après avoir liké des posts depuis la page reels.
