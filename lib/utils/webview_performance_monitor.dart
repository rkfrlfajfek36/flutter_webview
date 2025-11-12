import 'package:flutter_inappwebview/flutter_inappwebview.dart';

/// 웹뷰 성능 모니터링 클래스
/// 로딩 시간, 리소스 사용량 등을 추적합니다.
class WebViewPerformanceMonitor {
  final String url;
  DateTime? _startTime;
  DateTime? _endTime;
  
  Map<String, dynamic> performanceData = {};

  WebViewPerformanceMonitor(this.url);

  /// 로딩 시작 시간 기록
  void startMonitoring() {
    _startTime = DateTime.now();
    print('📊 성능 모니터링 시작: $url');
  }

  /// 로딩 완료 시간 기록
  void stopMonitoring() {
    _endTime = DateTime.now();
    if (_startTime != null) {
      final loadTime = _endTime!.difference(_startTime!).inMilliseconds;
      performanceData['total_load_time_ms'] = loadTime;
      print('📊 페이지 로딩 완료: ${loadTime}ms');
      
      _evaluatePerformance(loadTime);
    }
  }

  /// 성능 평가
  void _evaluatePerformance(int loadTimeMs) {
    String rating;
    String emoji;
    
    if (loadTimeMs < 1000) {
      rating = '매우 빠름';
      emoji = '🚀';
    } else if (loadTimeMs < 2000) {
      rating = '빠름';
      emoji = '⚡';
    } else if (loadTimeMs < 3000) {
      rating = '보통';
      emoji = '👍';
    } else if (loadTimeMs < 5000) {
      rating = '느림';
      emoji = '🐢';
    } else {
      rating = '매우 느림';
      emoji = '🐌';
    }
    
    performanceData['rating'] = rating;
    print('$emoji 성능 평가: $rating (${loadTimeMs}ms)');
  }

  /// Web Vitals 수집 (JavaScript에서)
  static String getWebVitalsScript() {
    return '''
      (function() {
        // Core Web Vitals 측정
        const reportWebVital = (metric) => {
          console.log('Web Vital: ' + metric.name + ' = ' + metric.value);
        };
        
        // LCP (Largest Contentful Paint)
        if ('PerformanceObserver' in window) {
          try {
            const lcpObserver = new PerformanceObserver((list) => {
              const entries = list.getEntries();
              const lastEntry = entries[entries.length - 1];
              reportWebVital({
                name: 'LCP',
                value: lastEntry.renderTime || lastEntry.loadTime,
                rating: lastEntry.renderTime < 2500 ? 'good' : lastEntry.renderTime < 4000 ? 'needs-improvement' : 'poor'
              });
            });
            lcpObserver.observe({ entryTypes: ['largest-contentful-paint'] });
          } catch (e) {
            console.log('LCP measurement not supported');
          }
          
          // FID (First Input Delay)
          try {
            const fidObserver = new PerformanceObserver((list) => {
              list.getEntries().forEach((entry) => {
                reportWebVital({
                  name: 'FID',
                  value: entry.processingStart - entry.startTime,
                  rating: entry.processingStart - entry.startTime < 100 ? 'good' : entry.processingStart - entry.startTime < 300 ? 'needs-improvement' : 'poor'
                });
              });
            });
            fidObserver.observe({ entryTypes: ['first-input'] });
          } catch (e) {
            console.log('FID measurement not supported');
          }
          
          // CLS (Cumulative Layout Shift)
          try {
            let clsValue = 0;
            const clsObserver = new PerformanceObserver((list) => {
              list.getEntries().forEach((entry) => {
                if (!entry.hadRecentInput) {
                  clsValue += entry.value;
                  reportWebVital({
                    name: 'CLS',
                    value: clsValue,
                    rating: clsValue < 0.1 ? 'good' : clsValue < 0.25 ? 'needs-improvement' : 'poor'
                  });
                }
              });
            });
            clsObserver.observe({ entryTypes: ['layout-shift'] });
          } catch (e) {
            console.log('CLS measurement not supported');
          }
        }
        
        // Navigation Timing
        window.addEventListener('load', () => {
          setTimeout(() => {
            if (window.performance && window.performance.timing) {
              const timing = window.performance.timing;
              const metrics = {
                'DNS Lookup': timing.domainLookupEnd - timing.domainLookupStart,
                'TCP Connection': timing.connectEnd - timing.connectStart,
                'Request Time': timing.responseStart - timing.requestStart,
                'Response Time': timing.responseEnd - timing.responseStart,
                'DOM Processing': timing.domComplete - timing.domLoading,
                'Load Event': timing.loadEventEnd - timing.loadEventStart,
                'Total Load': timing.loadEventEnd - timing.navigationStart
              };
              
              console.log('=== Navigation Timing Metrics ===');
              Object.keys(metrics).forEach(key => {
                console.log(key + ': ' + metrics[key] + 'ms');
              });
            }
            
            // Resource Timing
            if (window.performance && window.performance.getEntriesByType) {
              const resources = window.performance.getEntriesByType('resource');
              const resourceStats = {
                total: resources.length,
                images: resources.filter(r => r.initiatorType === 'img').length,
                scripts: resources.filter(r => r.initiatorType === 'script').length,
                stylesheets: resources.filter(r => r.initiatorType === 'link' || r.initiatorType === 'css').length,
                totalSize: resources.reduce((sum, r) => sum + (r.transferSize || 0), 0)
              };
              
              console.log('=== Resource Stats ===');
              console.log('Total Resources: ' + resourceStats.total);
              console.log('Images: ' + resourceStats.images);
              console.log('Scripts: ' + resourceStats.scripts);
              console.log('Stylesheets: ' + resourceStats.stylesheets);
              console.log('Total Size: ' + (resourceStats.totalSize / 1024).toFixed(2) + ' KB');
            }
          }, 0);
        });
      })();
    ''';
  }

  /// 성능 데이터 가져오기
  Map<String, dynamic> getPerformanceData() {
    return {
      'url': url,
      'start_time': _startTime?.toIso8601String(),
      'end_time': _endTime?.toIso8601String(),
      ...performanceData,
    };
  }

  /// 성능 리포트 출력
  void printReport() {
    print('\n📊 ===== 성능 리포트 =====');
    print('URL: $url');
    print('시작: ${_startTime?.toString() ?? 'N/A'}');
    print('완료: ${_endTime?.toString() ?? 'N/A'}');
    performanceData.forEach((key, value) {
      print('$key: $value');
    });
    print('========================\n');
  }
}

/// 전역 성능 모니터 매니저
class GlobalPerformanceMonitor {
  static final GlobalPerformanceMonitor _instance = GlobalPerformanceMonitor._internal();
  factory GlobalPerformanceMonitor() => _instance;
  GlobalPerformanceMonitor._internal();

  final List<WebViewPerformanceMonitor> _monitors = [];

  /// 새 모니터 추가
  WebViewPerformanceMonitor createMonitor(String url) {
    final monitor = WebViewPerformanceMonitor(url);
    _monitors.add(monitor);
    return monitor;
  }

  /// 모든 모니터의 통계
  Map<String, dynamic> getAllStats() {
    if (_monitors.isEmpty) {
      return {'message': '측정된 데이터가 없습니다.'};
    }

    final loadTimes = _monitors
        .where((m) => m.performanceData['total_load_time_ms'] != null)
        .map((m) => m.performanceData['total_load_time_ms'] as int)
        .toList();

    if (loadTimes.isEmpty) {
      return {'message': '완료된 측정이 없습니다.'};
    }

    loadTimes.sort();
    final avg = loadTimes.reduce((a, b) => a + b) / loadTimes.length;
    final median = loadTimes[loadTimes.length ~/ 2];

    return {
      'total_measurements': _monitors.length,
      'completed_measurements': loadTimes.length,
      'average_load_time_ms': avg.round(),
      'median_load_time_ms': median,
      'fastest_load_time_ms': loadTimes.first,
      'slowest_load_time_ms': loadTimes.last,
    };
  }

  /// 통계 출력
  void printAllStats() {
    final stats = getAllStats();
    print('\n📈 ===== 전체 성능 통계 =====');
    stats.forEach((key, value) {
      print('$key: $value');
    });
    print('============================\n');
  }

  /// 모든 모니터 초기화
  void clearAll() {
    _monitors.clear();
  }
}

