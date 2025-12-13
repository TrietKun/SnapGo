import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_service.dart';

class FirestoreService {
  final _db = FirebaseService.instance.firestore;

  CollectionReference<Map<String, dynamic>> collection(String path) {
    return _db.collection(path);
  }
}
