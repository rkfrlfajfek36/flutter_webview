import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../utils/webview_cache_manager.dart';
import '../utils/webview_performance_monitor.dart';
import '../utils/webview_preloader.dart';

/// 성능 최적화가 적용된 웹뷰 화면
/// 캐싱, 프리로딩, 성능 모니터링이 모두 포함되어 있습니다.
class WebViewScreenWithPerformance extends StatefulWidget {
  final String webViewUrl;
  final bool enablePerformanceMonitoring;
  final bool enablePreloading;

  const WebViewScreenWithPerformance({
    super.key,
    required this.webViewUrl,
    this.enablePerformanceMonitoring = true,
    this.enablePreloading = false,
  });

  @override
  State<WebViewScreenWithPerformance> createState() =>
      _WebViewScreenWithPerformanceState();
}

class _WebViewScreenWithPerformanceState
    extends State<WebViewScreenWithPerformance> {
  final GlobalKey webViewKey = GlobalKey();
  InAppWebViewController? webViewController;
  double progress = 0;
  bool hasError = false;
  String errorMessage = '';
  bool isLoading = true;

  late WebViewPerformanceMonitor? performanceMonitor;
  final cacheManager = WebViewCacheManager();

  @override
  void initState() {
    super.initState();

    // 성능 모니터링 초기화
    if (widget.enablePerformanceMonitoring) {
      performanceMonitor =
          GlobalPerformanceMonitor().createMonitor(widget.webViewUrl);
    }

    // 프리로딩 확인
    if (widget.enablePreloading) {
      _checkPreloading();
    }
  }

  void _checkPreloading() {
    final isPreloaded = WebViewPreloader().isPreloaded(widget.webViewUrl);
    if (isPreloaded) {
      print('✅ 프리로딩된 페이지 사용: ${widget.webViewUrl}');
    } else {
      print('ℹ️ 프리로딩 안됨, 일반 로딩: ${widget.webViewUrl}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('웹뷰 (성능 최적화)'),
        actions: [
          // 성능 통계 보기
          if (widget.enablePerformanceMonitoring)
            IconButton(
              icon: const Icon(Icons.analytics_outlined),
              onPressed: _showPerformanceStats,
              tooltip: '성능 통계',
            ),
          // 새로고침
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              webViewController?.reload();
            },
            tooltip: '새로고침',
          ),
          // 캐시 삭제
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'clear_cache') {
                await cacheManager.clearAllCache();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('캐시가 삭제되었습니다.')),
                );
                webViewController?.reload();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'clear_cache',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline),
                    SizedBox(width: 8),
                    Text('캐시 삭제'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            InAppWebView(
              key: webViewKey,
              initialUrlRequest: URLRequest(
                url: WebUri(widget.webViewUrl),
                headers: {
                  'Accept-Encoding': 'gzip, deflate, br',
                },
              ),
              initialSettings: cacheManager.getSettingsForProduction(),
              onWebViewCreated: (controller) {
                webViewController = controller;
                print('WebView Created');

                // JavaScript 최적화 인젝션
                _injectOptimizationScript(controller);

                // Web Vitals 측정
                if (widget.enablePerformanceMonitoring) {
                  controller.evaluateJavascript(
                    source: WebViewPerformanceMonitor.getWebVitalsScript(),
                  );
                }
              },
              onLoadStart: (controller, url) {
                print('Load Started: $url');
                setState(() {
                  progress = 0;
                  hasError = false;
                  isLoading = true;
                });

                // 성능 모니터링 시작
                if (widget.enablePerformanceMonitoring) {
                  performanceMonitor?.startMonitoring();
                }
              },
              onProgressChanged: (controller, progress) {
                setState(() {
                  this.progress = progress / 100;
                });
              },
              onLoadStop: (controller, url) async {
                print('Load Stopped: $url');
                setState(() {
                  progress = 1.0;
                  isLoading = false;
                });

                // 성능 모니터링 종료
                if (widget.enablePerformanceMonitoring) {
                  performanceMonitor?.stopMonitoring();
                  performanceMonitor?.printReport();
                }

                // 로딩 완료 후 추가 최적화
                _optimizeAfterLoad(controller);
              },
              onLoadError: (controller, url, code, message) {
                print('Load Error: $message (Code: $code)');
                setState(() {
                  hasError = true;
                  errorMessage = 'Error $code: $message';
                  isLoading = false;
                });
              },
              onReceivedError: (controller, request, error) {
                print('Received Error: ${error.description}');
              },
              onConsoleMessage: (controller, consoleMessage) {
                // Web Vitals 로그 필터링
                final message = consoleMessage.message;
                if (message.contains('Web Vital') ||
                    message.contains('Performance Metrics') ||
                    message.contains('Navigation Timing')) {
                  print('📊 $message');
                }
              },
            ),

            // 로딩 인디케이터
            if (progress < 1.0 && !hasError)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey[200],
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.deepPurple,
                      ),
                    ),
                    // 로딩 퍼센트 표시
                    Container(
                      color: Colors.deepPurple.withOpacity(0.1),
                      padding: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 12,
                      ),
                      child: Row(
                        children: [
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '로딩 중... ${(progress * 100).toInt()}%',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            // 에러 화면
            if (hasError)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 60, color: Colors.red),
                      const SizedBox(height: 20),
                      Text(
                        '페이지 로드 실패',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        errorMessage,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            hasError = false;
                          });
                          webViewController?.reload();
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('다시 시도'),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _injectOptimizationScript(InAppWebViewController controller) {
    controller.evaluateJavascript(source: '''
      // 이미지 Lazy Loading
      if ('loading' in HTMLImageElement.prototype) {
        const images = document.querySelectorAll('img:not([loading])');
        images.forEach(img => {
          img.loading = 'lazy';
        });
      }
      
      // DNS Prefetch & Preconnect
      (function() {
        const origins = new Set();
        document.querySelectorAll('a, img, script, link').forEach(el => {
          const url = el.href || el.src;
          if (url) {
            try {
              const origin = new URL(url).origin;
              if (origin !== location.origin) {
                origins.add(origin);
              }
            } catch(e) {}
          }
        });
        
        origins.forEach(origin => {
          const dns = document.createElement('link');
          dns.rel = 'dns-prefetch';
          dns.href = origin;
          document.head.appendChild(dns);
          
          const preconnect = document.createElement('link');
          preconnect.rel = 'preconnect';
          preconnect.href = origin;
          document.head.appendChild(preconnect);
        });
      })();
    ''');
  }

  void _optimizeAfterLoad(InAppWebViewController controller) {
    controller.evaluateJavascript(source: '''
      // Passive Event Listeners
      document.addEventListener('touchstart', function() {}, { passive: true });
      document.addEventListener('touchmove', function() {}, { passive: true });
      
      // IntersectionObserver로 이미지 지연 로드
      if ('IntersectionObserver' in window) {
        const imageObserver = new IntersectionObserver((entries) => {
          entries.forEach(entry => {
            if (entry.isIntersecting) {
              const img = entry.target;
              if (img.dataset.src) {
                img.src = img.dataset.src;
                img.removeAttribute('data-src');
                imageObserver.unobserve(img);
              }
            }
          });
        });
        
        document.querySelectorAll('img[data-src]').forEach(img => {
          imageObserver.observe(img);
        });
      }
    ''');
  }

  void _showPerformanceStats() {
    if (performanceMonitor == null) return;

    final stats = performanceMonitor!.getPerformanceData();
    final globalStats = GlobalPerformanceMonitor().getAllStats();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.analytics, color: Colors.deepPurple),
            SizedBox(width: 8),
            Text('성능 통계'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('📊 현재 페이지',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _buildStatRow('URL', stats['url'] ?? 'N/A'),
              _buildStatRow(
                '로딩 시간',
                stats['total_load_time_ms'] != null
                    ? '${stats['total_load_time_ms']}ms'
                    : 'N/A',
              ),
              _buildStatRow('평가', stats['rating'] ?? 'N/A'),
              const Divider(height: 24),
              const Text('📈 전체 통계',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _buildStatRow('측정 횟수', '${globalStats['total_measurements'] ?? 0}'),
              _buildStatRow(
                '평균 로딩',
                globalStats['average_load_time_ms'] != null
                    ? '${globalStats['average_load_time_ms']}ms'
                    : 'N/A',
              ),
              _buildStatRow(
                '최단 시간',
                globalStats['fastest_load_time_ms'] != null
                    ? '${globalStats['fastest_load_time_ms']}ms'
                    : 'N/A',
              ),
              _buildStatRow(
                '최장 시간',
                globalStats['slowest_load_time_ms'] != null
                    ? '${globalStats['slowest_load_time_ms']}ms'
                    : 'N/A',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              GlobalPerformanceMonitor().printAllStats();
              Navigator.pop(context);
            },
            child: const Text('콘솔 출력'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    webViewController = null;
    super.dispose();
  }
}

