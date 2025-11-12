import 'package:flutter/material.dart';
import '../screens/webview_screen_with_performance.dart';
import '../utils/webview_preloader.dart';

/// 성능 최적화 예제 및 데모
class PerformanceOptimizationExample extends StatefulWidget {
  const PerformanceOptimizationExample({super.key});

  @override
  State<PerformanceOptimizationExample> createState() =>
      _PerformanceOptimizationExampleState();
}

class _PerformanceOptimizationExampleState
    extends State<PerformanceOptimizationExample> {
  final List<String> demoUrls = [
    'https://flutter.dev',
    'https://dart.dev',
    'https://pub.dev',
    'https://github.com',
  ];

  final preloader = WebViewPreloader();
  Map<String, bool> preloadStatus = {};

  @override
  void initState() {
    super.initState();
    _updatePreloadStatus();
  }

  void _updatePreloadStatus() {
    setState(() {
      for (var url in demoUrls) {
        preloadStatus[url] = preloader.isPreloaded(url);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('웹뷰 성능 최적화 예제'),
        backgroundColor: Colors.deepPurple,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 헤더
          _buildHeader(),
          const SizedBox(height: 24),

          // 성능 최적화 기능 카드
          _buildFeatureCard(
            icon: Icons.speed,
            title: '캐싱',
            description: '리소스를 캐시하여 재방문 시 50-80% 빠른 로딩',
            color: Colors.blue,
            onTap: () => _showInfoDialog(
              '캐싱',
              '웹 리소스(HTML, CSS, JS, 이미지 등)를 로컬에 저장하여\n'
                  '재방문 시 네트워크 요청 없이 빠르게 로드합니다.\n\n'
                  '✅ 기본 설정으로 활성화되어 있습니다.',
            ),
          ),
          const SizedBox(height: 12),

          _buildFeatureCard(
            icon: Icons.rocket_launch,
            title: '프리로딩',
            description: '자주 방문하는 페이지를 미리 백그라운드에서 로드',
            color: Colors.orange,
            onTap: () => _showPreloadingDemo(),
          ),
          const SizedBox(height: 12),

          _buildFeatureCard(
            icon: Icons.compress,
            title: 'Gzip/Brotli 압축',
            description: '전송 데이터 크기를 줄여 로딩 속도 향상',
            color: Colors.green,
            onTap: () => _showInfoDialog(
              'HTTP 압축',
              'HTTP 헤더에 Accept-Encoding을 설정하여\n'
                  '서버에서 압축된 데이터를 받습니다.\n\n'
                  '✅ 자동으로 적용됩니다.\n'
                  '압축률: 약 60-70% 크기 감소',
            ),
          ),
          const SizedBox(height: 12),

          _buildFeatureCard(
            icon: Icons.hardware,
            title: '하드웨어 가속',
            description: 'GPU를 활용한 렌더링 성능 향상',
            color: Colors.purple,
            onTap: () => _showInfoDialog(
              '하드웨어 가속',
              'GPU를 활용하여 웹페이지 렌더링을 가속화합니다.\n\n'
                  '✅ 기본 설정으로 활성화\n'
                  '효과: 스크롤, 애니메이션 부드러움',
            ),
          ),
          const SizedBox(height: 12),

          _buildFeatureCard(
            icon: Icons.analytics,
            title: '성능 모니터링',
            description: 'Web Vitals 및 로딩 시간 측정',
            color: Colors.teal,
            onTap: () => _showInfoDialog(
              '성능 모니터링',
              '웹페이지 로딩 성능을 실시간으로 측정합니다.\n\n'
                  '측정 지표:\n'
                  '• LCP (Largest Contentful Paint)\n'
                  '• FID (First Input Delay)\n'
                  '• CLS (Cumulative Layout Shift)\n'
                  '• 로딩 시간, 리소스 통계',
            ),
          ),
          const SizedBox(height: 24),

          // 데모 URL 목록
          const Text(
            '🌐 테스트 URL',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          ...demoUrls.map((url) => _buildUrlCard(url)),

          const SizedBox(height: 24),

          // 프리로딩 컨트롤
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '🚀 프리로딩 제어',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _preloadAllUrls,
                          icon: const Icon(Icons.download),
                          label: const Text('모두 프리로드'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _clearAllPreloads,
                          icon: const Icon(Icons.delete_outline),
                          label: const Text('모두 삭제'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '프리로드 상태: ${preloadStatus.values.where((v) => v).length}/${demoUrls.length}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Card(
      color: Colors.deepPurple.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.deepPurple.shade700),
                const SizedBox(width: 8),
                Text(
                  '성능 최적화 적용됨',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              '모든 웹뷰에 캐싱, 압축, 하드웨어 가속이 자동으로 적용됩니다.\n'
              '각 카드를 탭하여 자세한 정보를 확인하세요.',
              style: TextStyle(fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUrlCard(String url) {
    final isPreloaded = preloadStatus[url] ?? false;

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isPreloaded ? Colors.green : Colors.grey,
          child: Icon(
            isPreloaded ? Icons.check : Icons.language,
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          url.replaceAll('https://', ''),
          style: const TextStyle(fontSize: 14),
        ),
        subtitle: Text(
          isPreloaded ? '✅ 프리로드 완료' : '⚪ 미로드',
          style: TextStyle(
            fontSize: 12,
            color: isPreloaded ? Colors.green : Colors.grey,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isPreloaded)
              IconButton(
                icon: const Icon(Icons.download, size: 20),
                onPressed: () => _preloadUrl(url),
                tooltip: '프리로드',
              ),
            IconButton(
              icon: const Icon(Icons.open_in_browser, size: 20),
              onPressed: () => _openUrl(url),
              tooltip: '열기',
            ),
          ],
        ),
      ),
    );
  }

  void _showInfoDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _showPreloadingDemo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('프리로딩 데모'),
        content: const Text(
          '프리로딩은 페이지를 백그라운드에서 미리 로드하여\n'
          '사용자가 방문할 때 즉시 표시할 수 있게 합니다.\n\n'
          '사용 시나리오:\n'
          '• 앱 시작 시 메인 페이지 프리로드\n'
          '• 사용자가 클릭할 가능성이 높은 페이지\n'
          '• 탭 전환 전 다음 탭 프리로드\n\n'
          '아래 URL 카드에서 다운로드 버튼을 눌러\n'
          '프리로딩을 테스트해보세요!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  Future<void> _preloadUrl(String url) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('프리로딩 시작: ${url.replaceAll('https://', '')}')),
    );

    await preloader.preloadUrl(url);
    _updatePreloadStatus();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ 완료: ${url.replaceAll('https://', '')}')),
      );
    }
  }

  Future<void> _preloadAllUrls() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('모든 URL 프리로딩 시작...')),
    );

    await preloader.preloadMultipleUrls(demoUrls);
    _updatePreloadStatus();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ 모든 프리로딩 완료!')),
      );
    }
  }

  Future<void> _clearAllPreloads() async {
    await preloader.disposeAll();
    _updatePreloadStatus();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('모든 프리로드 삭제됨')),
      );
    }
  }

  void _openUrl(String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WebViewScreenWithPerformance(
          webViewUrl: url,
          enablePerformanceMonitoring: true,
          enablePreloading: true,
        ),
      ),
    );
  }

  @override
  void dispose() {
    // 필요시 프리로드 정리
    // preloader.disposeAll();
    super.dispose();
  }
}

