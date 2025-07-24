import 'package:flutter/material.dart';
import 'dart:async';
import 'trip_detail_page.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedTripIndex = 0;
  final List<_TripData> _trips = const [
    _TripData(
      route: '上海',
      destination: '日本',
      days: '3天2晚',
      participants: 156,
      rating: 4.8,
    ),
    _TripData(
      route: '北京',
      destination: '韩国',
      days: '2天1晚',
      participants: 89,
      rating: 4.6,
    ),
    _TripData(
      route: '上海',
      destination: '日本',
      days: '2天1晚',
      participants: 203,
      rating: 4.7,
    ),
    _TripData(
      route: '北京',
      destination: '韩国',
      days: '3天2晚',
      participants: 127,
      rating: 4.5,
    ),
    _TripData(
      route: '广州',
      destination: '泰国',
      days: '4天3晚',
      participants: 234,
      rating: 4.9,
    ),
  ];

  final List<String> _danmakuList = const [
    '小雨：小青蛙让我的日本之旅变得如此轻松愉快！',
    '小明：界面太可爱了，像在玩游戏一样！',
    '小芳：导航功能很强大，节省了很多时间！',
    '小刚：推荐新宿的拉面店，超级好吃！',
    '小美：行程安排很合理，点赞！',
    '小李：第一次出国，体验很棒，感谢小青蛙！',
    '小王：东京塔夜景太美了，强烈推荐！',
    '小陈：行程提醒很贴心，不会错过任何计划。',
    '小赵：和朋友一起出行，大家都很满意。',
    '小孙：美食推荐很实用，吃得很开心！',
  ];

  double _danmakuOffset = 0;
  double _danmakuContentWidth = 0;
  double _screenWidth = 0;
  late Timer _danmakuTimer;
  final GlobalKey _danmakuKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initDanmaku());
  }

  void _initDanmaku() {
    _screenWidth = MediaQuery.of(context).size.width;
    setState(() {});
    Future.delayed(const Duration(milliseconds: 100), () {
      _danmakuContentWidth = _danmakuKey.currentContext?.size?.width ?? 400;
      if (_danmakuContentWidth < _screenWidth) {
        _danmakuContentWidth = _screenWidth + 200;
      }
      _danmakuOffset = _screenWidth;
      _danmakuTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
        setState(() {
          _danmakuOffset -= 1.0;
          if (_danmakuOffset < -_danmakuContentWidth) {
            _danmakuOffset = _screenWidth;
          }
        });
      });
    });
  }

  @override
  void dispose() {
    _danmakuTimer.cancel();
    super.dispose();
  }

  void _onTripSelected(int index) {
    setState(() {
      _selectedTripIndex = index;
    });
  }

  void _onStartTrip() {
    final trip = _trips[_selectedTripIndex];
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TripDetailPage(
          route: trip.route,
          destination: trip.destination,
          days: trip.days,
          startDate: '2024-07-01',
          status: '进行中',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final danmakuRow = Row(
      key: _danmakuKey,
      children: [
        ..._danmakuList.map(
          (text) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 18),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.shade100,
                  blurRadius: 2,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.emoji_nature, color: Colors.green, size: 18),
                const SizedBox(width: 4),
                Text(text, style: const TextStyle(color: Colors.black87)),
              ],
            ),
          ),
        ),
        ..._danmakuList.map(
          (text) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 18),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.shade100,
                  blurRadius: 2,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.emoji_nature, color: Colors.green, size: 18),
                const SizedBox(width: 4),
                Text(text, style: const TextStyle(color: Colors.black87)),
              ],
            ),
          ),
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.eco, color: Colors.green),
            const SizedBox(width: 8),
            const Text('小青蛙的旅行日记'),
            const Spacer(),
            Row(
              children: [
                const Icon(
                  Icons.location_on,
                  color: Colors.redAccent,
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text('定位中...', style: TextStyle(fontSize: 14)),
              ],
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 欢迎横幅
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              color: Colors.green.shade50,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    '小青蛙的旅行日记',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // 一比一还原的四个小图标
                  Wrap(
                    spacing: 12,
                    children: [
                      _FeatureChipFa(
                        icon: FontAwesomeIcons.mapMarkedAlt,
                        label: '智能导航',
                      ),
                      _FeatureChipFa(
                        icon: FontAwesomeIcons.clock,
                        label: '时间管理',
                      ),
                      _FeatureChipFa(
                        icon: FontAwesomeIcons.comments,
                        label: '社区分享',
                      ),
                      _FeatureChipFa(
                        icon: FontAwesomeIcons.heart,
                        label: '治愈体验',
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '跟随小青蛙的脚步，探索世界的美好。每一次旅行都是一次心灵的治愈，让我们在旅途中发现生活的诗意与远方。',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, color: Colors.black87),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _StatItem(label: '旅行者', value: '1000+'),
                      _StatItem(label: '目的地', value: '50+'),
                      _StatItem(label: '满意度', value: '98%'),
                    ],
                  ),
                ],
              ),
            ),
            // 弹幕区
            Container(
              height: 38,
              color: Colors.white,
              margin: const EdgeInsets.only(bottom: 2),
              child: Stack(
                children: [
                  Positioned(
                    left: _danmakuOffset,
                    top: 0,
                    bottom: 0,
                    child: danmakuRow,
                  ),
                ],
              ),
            ),
            // 行程选择
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '🌿 选择您的旅行路线',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ...List.generate(
                    _trips.length,
                    (i) => _TripOption(
                      route: _trips[i].route,
                      destination: _trips[i].destination,
                      days: _trips[i].days,
                      participants: _trips[i].participants,
                      rating: _trips[i].rating,
                      selected: i == _selectedTripIndex,
                      onTap: () => _onTripSelected(i),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: ElevatedButton(
                      onPressed: _onStartTrip,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 48,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: const Text('开始旅行', style: TextStyle(fontSize: 18)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TripData {
  final String route;
  final String destination;
  final String days;
  final int participants;
  final double rating;
  const _TripData({
    required this.route,
    required this.destination,
    required this.days,
    required this.participants,
    required this.rating,
  });
}

class _FeatureChipFa extends StatelessWidget {
  final IconData icon;
  final String label;
  const _FeatureChipFa({required this.icon, required this.label});
  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: FaIcon(icon, color: Colors.green, size: 18),
      label: Text(label, style: const TextStyle(color: Colors.green)),
      backgroundColor: Colors.green.shade100,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  const _StatItem({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

class _TripOption extends StatelessWidget {
  final String route;
  final String destination;
  final String days;
  final int participants;
  final double rating;
  final bool selected;
  final VoidCallback? onTap;
  const _TripOption({
    required this.route,
    required this.destination,
    required this.days,
    required this.participants,
    required this.rating,
    this.selected = false,
    this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return Card(
      color: selected ? Colors.green.shade100 : Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: const Icon(Icons.flight_takeoff, color: Colors.green),
        title: Text('$route → $destination'),
        subtitle: Text(days),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.people, color: Colors.green.shade300, size: 18),
            Text(' $participants  ', style: const TextStyle(fontSize: 13)),
            Icon(Icons.star, color: Colors.orange, size: 18),
            Text(' $rating', style: const TextStyle(fontSize: 13)),
          ],
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: onTap,
      ),
    );
  }
}
