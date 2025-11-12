import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

/// 웹뷰 프리로딩 매니저
/// 자주 사용하는 URL을 미리 로드하여 성능을 향상시킵니다.
class WebViewPreloader {
  static final WebViewPreloader _instance = WebViewPreloader._internal();
  factory WebViewPreloader() => _instance;
  WebViewPreloader._internal();

  final Map<String, HeadlessInAppWebView> _preloadedWebViews = {};
  final Set<String> _preloadingUrls = {};

  /// URL을 미리 로드 (백그라운드에서 로딩)
  Future<void> preloadUrl(String url) async {
    if (_preloadedWebViews.containsKey(url) || _preloadingUrls.contains(url)) {
      print('⚠️ 이미 프리로드 중이거나 완료된 URL: $url');
      return;
    }

    _preloadingUrls.add(url);
    
    try {
      print('🚀 프리로딩 시작: $url');
      
      final headlessWebView = HeadlessInAppWebView(
        initialUrlRequest: URLRequest(
          url: WebUri(url),
          headers: {
            'Accept-Encoding': 'gzip, deflate, br',
          },
        ),
        initialSettings: InAppWebViewSettings(
          cacheEnabled: true,
          javaScriptEnabled: true,
          domStorageEnabled: true,
          hardwareAcceleration: true,
          loadsImagesAutomatically: true,
        ),
        onLoadStop: (controller, url) {
          print('✅ 프리로딩 완료: $url');
        },
      );

      await headlessWebView.run();
      _preloadedWebViews[url] = headlessWebView;
      _preloadingUrls.remove(url);
      
    } catch (e) {
      print('❌ 프리로딩 실패: $url, 에러: $e');
      _preloadingUrls.remove(url);
    }
  }

  /// 여러 URL을 동시에 프리로드
  Future<void> preloadMultipleUrls(List<String> urls) async {
    await Future.wait(
      urls.map((url) => preloadUrl(url)),
    );
  }

  /// 프리로드된 웹뷰 확인
  bool isPreloaded(String url) {
    return _preloadedWebViews.containsKey(url);
  }

  /// 특정 URL의 프리로드된 웹뷰 가져오기
  HeadlessInAppWebView? getPreloadedWebView(String url) {
    return _preloadedWebViews[url];
  }

  /// 특정 URL의 프리로드 해제
  Future<void> disposePreloadedUrl(String url) async {
    if (_preloadedWebViews.containsKey(url)) {
      await _preloadedWebViews[url]?.dispose();
      _preloadedWebViews.remove(url);
      print('🗑️ 프리로드 해제: $url');
    }
  }

  /// 모든 프리로드된 웹뷰 해제
  Future<void> disposeAll() async {
    for (var webView in _preloadedWebViews.values) {
      await webView.dispose();
    }
    _preloadedWebViews.clear();
    _preloadingUrls.clear();
    print('🗑️ 모든 프리로드 해제 완료');
  }

  /// 프리로드 상태 정보
  Map<String, dynamic> getPreloadStatus() {
    return {
      'preloaded_count': _preloadedWebViews.length,
      'preloading_count': _preloadingUrls.length,
      'preloaded_urls': _preloadedWebViews.keys.toList(),
      'preloading_urls': _preloadingUrls.toList(),
    };
  }

  /// 오래된 프리로드 정리 (메모리 관리)
  Future<void> cleanupOldPreloads({int keepCount = 3}) async {
    if (_preloadedWebViews.length <= keepCount) {
      return;
    }

    final urlsToRemove = _preloadedWebViews.keys.take(
      _preloadedWebViews.length - keepCount,
    ).toList();

    for (var url in urlsToRemove) {
      await disposePreloadedUrl(url);
    }
  }
}

/// 프리로딩 위젯 래퍼
/// 특정 URL을 프리로드하는 위젯
class PreloadWebView extends StatefulWidget {
  final String url;
  final VoidCallback? onPreloadComplete;

  const PreloadWebView({
    super.key,
    required this.url,
    this.onPreloadComplete,
  });

  @override
  State<PreloadWebView> createState() => _PreloadWebViewState();
}

class _PreloadWebViewState extends State<PreloadWebView> {
  @override
  void initState() {
    super.initState();
    _preload();
  }

  Future<void> _preload() async {
    await WebViewPreloader().preloadUrl(widget.url);
    widget.onPreloadComplete?.call();
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink(); // 보이지 않는 위젯
  }

  @override
  void dispose() {
    // 필요에 따라 프리로드 해제
    // WebViewPreloader().disposePreloadedUrl(widget.url);
    super.dispose();
  }
}

