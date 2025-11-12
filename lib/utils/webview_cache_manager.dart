import 'package:flutter_inappwebview/flutter_inappwebview.dart';

/// 웹뷰 캐시 관리 클래스
/// 성능 향상을 위한 캐시 전략을 제공합니다.
class WebViewCacheManager {
  static final WebViewCacheManager _instance = WebViewCacheManager._internal();
  factory WebViewCacheManager() => _instance;
  WebViewCacheManager._internal();

  // 캐시 설정 옵션
  static const Duration cacheExpiration = Duration(hours: 24);
  
  /// 전체 캐시 초기화
  Future<void> clearAllCache() async {
    await InAppWebViewController.clearAllCache();
    print('✅ WebView 전체 캐시가 삭제되었습니다.');
  }

  /// 특정 URL의 캐시 정책 설정
  CacheMode getCacheModeForUrl(String url) {
    // URL 패턴에 따라 캐시 전략을 다르게 설정
    if (url.contains('static') || 
        url.contains('assets') || 
        url.endsWith('.css') || 
        url.endsWith('.js') ||
        url.endsWith('.png') ||
        url.endsWith('.jpg') ||
        url.endsWith('.jpeg') ||
        url.endsWith('.gif') ||
        url.endsWith('.webp')) {
      // 정적 리소스는 캐시 우선 사용
      return CacheMode.LOAD_CACHE_ELSE_NETWORK;
    } else if (url.contains('api') || url.contains('dynamic')) {
      // API나 동적 콘텐츠는 네트워크 우선
      return CacheMode.LOAD_DEFAULT;
    } else {
      // 기본: 캐시를 먼저 확인하되, 만료되면 네트워크에서 가져오기
      return CacheMode.LOAD_DEFAULT;
    }
  }

  /// 캐시 크기 제한 설정 (예상치)
  Future<void> setCacheSize(int sizeInMB) async {
    // 참고: flutter_inappwebview에서는 직접적인 캐시 크기 제어가 제한적입니다.
    // 플랫폼별 네이티브 설정이 필요할 수 있습니다.
    print('캐시 크기 제한: ${sizeInMB}MB로 설정 (플랫폼별 구현 필요)');
  }

  /// 오래된 캐시 삭제 (특정 기간 이상)
  Future<void> clearExpiredCache() async {
    // 브라우저 캐시 정책을 따르지만, 필요시 수동 삭제
    print('만료된 캐시 정리 중...');
    // 실제 구현은 플랫폼별로 다를 수 있습니다.
  }

  /// 개발 모드에서 캐시 비활성화
  InAppWebViewSettings getSettingsForDebug() {
    return InAppWebViewSettings(
      cacheEnabled: false,
      clearCache: true,
    );
  }

  /// 프로덕션 모드 최적화 설정
  InAppWebViewSettings getSettingsForProduction() {
    return InAppWebViewSettings(
      cacheEnabled: true,
      clearCache: false,
      cacheMode: CacheMode.LOAD_DEFAULT,
      databaseEnabled: true,
      domStorageEnabled: true,
      hardwareAcceleration: true,
    );
  }
}

/// 캐시 모드 확장 헬퍼
extension CacheModeExtension on CacheMode {
  String get description {
    switch (this) {
      case CacheMode.LOAD_DEFAULT:
        return '기본: 캐시 확인 후 네트워크';
      case CacheMode.LOAD_CACHE_ELSE_NETWORK:
        return '캐시 우선, 없으면 네트워크';
      case CacheMode.LOAD_NO_CACHE:
        return '캐시 사용 안함, 항상 네트워크';
      case CacheMode.LOAD_CACHE_ONLY:
        return '캐시만 사용';
      default:
        return '알 수 없음';
    }
  }
}

