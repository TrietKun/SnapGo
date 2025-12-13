import 'package:snapgo/models/spot_entity.dart';
import 'package:snapgo/services/spot/spot_service.dart';

class SpotRepository {
  final SpotService _service;

  SpotRepository(this._service);

  Future<List<SpotEntity>> getSpots(
    String tab, {
    required int page,
    required int pageSize,
  }) async {
    final snapshot = tab == 'trending'
        ? await _service.getTrending(page: page, limit: pageSize)
        : await _service.getAll(page: page, limit: pageSize);

    final spots = snapshot.docs.map((doc) {
      final data = doc.data();
      return SpotEntity.fromJson({
        'id': doc.id,
        ...data,
      });
    }).toList();

    return spots;
  }

  Future<List<SpotEntity>> refresh(
    String tab, {
    required int page,
    required int pageSize,
  }) async {
    return getSpots(tab, page: page, pageSize: pageSize);
  }
}
