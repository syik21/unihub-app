import './asset_service.dart';
import './asset_model.dart';

class AssetRepository {
  final AssetService _assetService;

  AssetRepository(this._assetService);

  Future<Asset> addNewAsset({
    required String userId,
    required String roomId,
    required String name,
    required String category,
    required String condition,
    String? image,
    required DateTime purchasedDate,
    required DateTime lastMaintenance,
    required String type,
  }) async {
    return await _assetService.addAsset(
      userId: userId,
      roomId: roomId,
      name: name,
      category: category,
      condition: condition,
      image: image,
      purchasedDate: purchasedDate,
      lastMaintenance: lastMaintenance,
      type: type,
    );
  }

  Future<Asset?> scanAndFindAsset(String barcode) async {
    return await _assetService.findAssetByBarcode(barcode);
  }

  Future<List<Asset>> getAllAssets() async {
    return await _assetService.getAllAssets();
  }
}