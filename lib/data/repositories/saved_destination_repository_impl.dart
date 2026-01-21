import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:travel_app/domain/repositories/i_saved_destination_repository.dart';
import 'package:travel_app/features/explore/models/explore_destination.dart';

class SavedDestinationRepositoryImpl implements ISavedDestinationRepository {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  // Tạo unique ID từ destination
  String _getDestinationId(ExploreDestination d) {
    return '${d.name}_${d.latitude}_${d.longitude}'.replaceAll(' ', '_');
  }

  // Lấy reference đến collection saved của user
  CollectionReference? _getSavedCollection() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return null;
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('saved_destinations');
  }

  @override
  Future<void> saveDestination(ExploreDestination destination) async {
    final collection = _getSavedCollection();
    if (collection == null) return;

    await collection.doc(_getDestinationId(destination)).set({
      'name': destination.name,
      'city': destination.city,
      'latitude': destination.latitude,
      'longitude': destination.longitude,
      'imageUrl': destination.imageUrl,
      'savedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> unsaveDestination(ExploreDestination destination) async {
    final collection = _getSavedCollection();
    if (collection == null) return;

    await collection.doc(_getDestinationId(destination)).delete();
  }

  @override
  Future<Set<String>> getSavedIds() async {
    final collection = _getSavedCollection();
    if (collection == null) return {};

    final snapshot = await collection.get();
    return snapshot.docs.map((doc) => doc.id).toSet();
  }
}
