import 'package:flutter/material.dart';
import 'dart:async';
import 'trip_detail_page.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:app_settings/app_settings.dart';
import 'package:flutter_svg/flutter_svg.dart';

class _DanmakuWidget extends StatefulWidget {
  final List<String> danmakuList;

  const _DanmakuWidget({required this.danmakuList});

  @override
  State<_DanmakuWidget> createState() => _DanmakuWidgetState();
}

class _DanmakuWidgetState extends State<_DanmakuWidget> {
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
    Future.delayed(const Duration(milliseconds: 100), () {
      _danmakuContentWidth = _danmakuKey.currentContext?.size?.width ?? 400;
      if (_danmakuContentWidth < _screenWidth) {
        _danmakuContentWidth = _screenWidth + 200;
      }
      _danmakuOffset = _screenWidth;
      _danmakuTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
        if (mounted) {
          setState(() {
            _danmakuOffset -= 2.0;
            if (_danmakuOffset < -_danmakuContentWidth) {
              _danmakuOffset = _screenWidth;
            }
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _danmakuTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final danmakuRow = Row(
      key: _danmakuKey,
      children: [
        ...widget.danmakuList.map(
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
        ...widget.danmakuList.map(
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

    return Container(
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
    );
  }
}

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

  Position? _position;
  String _locationStatus = '定位中...';
  bool _locating = false;
  String? _address;

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  Future<void> _showLocationServiceDisabledDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('定位服务未启用'),
        content: const Text('请在系统设置中开启定位服务，否则无法获取当前位置。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('知道了'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              AppSettings.openAppSettings();
            },
            child: const Text('去设置'),
          ),
        ],
      ),
    );
  }

  Future<void> _showLocationDeniedDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('定位权限未开启'),
        content: const Text('请在系统设置中为小青蛙的旅行日记开启定位权限，否则无法获取当前位置。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('知道了'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              AppSettings.openAppSettings();
            },
            child: const Text('去设置'),
          ),
        ],
      ),
    );
  }

  Future<void> _getLocation() async {
    debugPrint('调用 _getLocation');
    setState(() {
      _locating = true;
      _locationStatus = '定位中...';
      _address = null;
    });

    try {
      // 检查定位服务是否启用
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('定位服务未启用');
        setState(() {
          _locationStatus = '定位服务未启用';
          _locating = false;
        });
        _showLocationServiceDisabledDialog();
        return;
      }

      // 检查权限
      LocationPermission permission = await Geolocator.checkPermission();
      debugPrint('当前权限状态: $permission');

      if (permission == LocationPermission.denied) {
        debugPrint('请求定位权限');
        permission = await Geolocator.requestPermission();
        debugPrint('请求权限后状态: $permission');
      }

      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        debugPrint('定位权限被拒绝: $permission');
        setState(() {
          _locationStatus = '未授权，无法获取定位权限';
          _locating = false;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          debugPrint('准备弹出定位权限弹窗');
          _showLocationDeniedDialog();
        });
        return;
      }

      // 获取位置
      debugPrint('开始获取位置信息');
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
      debugPrint('获取到位置: ${pos.latitude}, ${pos.longitude}');

      // 获取地址信息
      String? address;
      try {
        debugPrint('开始获取地址信息');
        List<Placemark> placemarks = await placemarkFromCoordinates(
          pos.latitude,
          pos.longitude,
        );
        debugPrint('获取到 ${placemarks.length} 个地址信息');

        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          debugPrint(
            '地址信息: locality=${p.locality}, administrativeArea=${p.administrativeArea}, country=${p.country}',
          );
          // 优先显示城市名，然后是省份，最后是国家
          address = p.locality ?? p.administrativeArea ?? p.country ?? '';
          // 去除可能的空格
          if (address.isNotEmpty) {
            address = address.trim();
          }
        }
      } catch (e) {
        debugPrint('获取地址信息失败: $e');
        address = null;
      }

      setState(() {
        _position = pos;
        _locationStatus = '已定位';
        _address = address;
        _locating = false;
      });
      debugPrint('定位完成，地址: $address');
      debugPrint('地址长度: ${address?.length}');
      debugPrint('地址是否为空: ${address?.isEmpty}');
      debugPrint(
        '状态更新: _locating=$_locating, _address=$_address, _position=${_position != null}',
      );
    } catch (e) {
      debugPrint('定位失败异常: $e');
      setState(() {
        _locationStatus = '定位失败: ${e.toString().split(':').last.trim()}';
        _locating = false;
      });
    }
  }

  @override
  void dispose() {
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
    // 调试信息
    debugPrint(
      'Build - _locating: $_locating, _address: "$_address", _position: ${_position != null}',
    );
    debugPrint(
      'Build - _address is null: ${_address == null}, _address isEmpty: ${_address?.isEmpty}',
    );

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.eco, color: Colors.green),
            const SizedBox(width: 8),
            const Text('小青蛙的旅行日记'),
            const Spacer(),
            Flexible(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 定位状态图标
                  Icon(
                    Icons.location_on,
                    color: _locating
                        ? Colors.blue
                        : (_position != null ||
                              (_address != null && _address!.isNotEmpty))
                        ? Colors.green
                        : (_locationStatus.contains('失败') ||
                              _locationStatus.contains('未授权') ||
                              _locationStatus.contains('未启用'))
                        ? Colors.red
                        : Colors.grey,
                    size: 20,
                  ),
                  const SizedBox(width: 4),

                  // 定位状态显示
                  if (_locating)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else if (_address != null && _address!.isNotEmpty)
                    Text(
                      _address!,
                      style: const TextStyle(fontSize: 13, color: Colors.green),
                    )
                  else if (_position != null)
                    Text(
                      '${_position!.latitude.toStringAsFixed(4)}, ${_position!.longitude.toStringAsFixed(4)}',
                      style: const TextStyle(fontSize: 12, color: Colors.green),
                    )
                  else
                    Text(
                      _locationStatus,
                      style: TextStyle(
                        fontSize: 12,
                        color:
                            (_locationStatus.contains('失败') ||
                                _locationStatus.contains('未授权') ||
                                _locationStatus.contains('未启用'))
                            ? Colors.red
                            : Colors.grey,
                      ),
                    ),

                  // 刷新按钮
                  IconButton(
                    icon: const Icon(
                      Icons.refresh,
                      size: 18,
                      color: Colors.green,
                    ),
                    tooltip: '刷新定位',
                    onPressed: _getLocation,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
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
            _DanmakuWidget(danmakuList: _danmakuList),
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
