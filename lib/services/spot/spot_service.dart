import 'package:cloud_firestore/cloud_firestore.dart';

class SpotService {
  final FirebaseFirestore _firestore;

  // Lưu lastDocument của mỗi query để pagination
  DocumentSnapshot? _lastTrendingDoc;
  DocumentSnapshot? _lastAllDoc;

  SpotService(this._firestore);

  Future<QuerySnapshot<Map<String, dynamic>>> getTrending({
    required int page,
    required int limit,
  }) async {
    Query<Map<String, dynamic>> query = _firestore
        .collection('spots')
        // .where('isTrending', isEqualTo: true)
        .orderBy('createdAt', descending: true);

    // Nếu page > 1, dùng startAfter để skip
    if (page > 1 && _lastTrendingDoc != null) {
      query = query.startAfterDocument(_lastTrendingDoc!);
    }

    final snapshot = await query.limit(limit).get();

    // Lưu document cuối để dùng cho lần sau
    if (snapshot.docs.isNotEmpty) {
      _lastTrendingDoc = snapshot.docs.last;
    }

    return snapshot;
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getAll({
    required int page,
    required int limit,
  }) async {
    Query<Map<String, dynamic>> query = _firestore.collection('spots').orderBy(
          'createdAt',
          descending: false,
        );

    // Nếu page > 1, dùng startAfter để skip
    if (page > 1 && _lastAllDoc != null) {
      query = query.startAfterDocument(_lastAllDoc!);
    }

    final snapshot = await query.limit(limit).get();

    // Lưu document cuối để dùng cho lần sau
    if (snapshot.docs.isNotEmpty) {
      _lastAllDoc = snapshot.docs.last;
    }

    return snapshot;
  }

  // Reset pagination khi refresh
  void resetPagination() {
    _lastTrendingDoc = null;
    _lastAllDoc = null;
  }
}
