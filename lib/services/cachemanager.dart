import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class CustomCacheManager extends CacheManager {
  static const key = "customCache";

  static final CustomCacheManager _instance = CustomCacheManager._();

  factory CustomCacheManager() {
    return _instance;
  }

  CustomCacheManager._()
      : super(
          Config(
            key,
            stalePeriod: const Duration(minutes: 15), // Durée de vie des fichiers dans le cache
            maxNrOfCacheObjects: 100, // Nombre maximum d'objets dans le cache
          ),
        );
}



class CustomCacheManagerLong extends CacheManager {
  static const key = "customCacheLong";

  static final CustomCacheManagerLong _instance = CustomCacheManagerLong._();

  factory CustomCacheManagerLong() {
    return _instance;
  }

  CustomCacheManagerLong._()
      : super(
          Config(
            key,
            stalePeriod: const Duration(days: 365),
          ),
        );
}