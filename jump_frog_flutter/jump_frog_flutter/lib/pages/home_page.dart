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

  // AI聊天相关状态
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _chatScrollController = ScrollController();
  final List<_ChatMessage> _chatMessages = [];
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _getLocation();
    // 添加欢迎消息
    _chatMessages.add(
      _ChatMessage(
        text: '你好！我是馒馒，我可以帮你规划完美的旅行行程。请告诉我你想去哪里旅行？',
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
  }

  @override
  void dispose() {
    _chatController.dispose();
    _chatScrollController.dispose();
    super.dispose();
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

  // AI聊天相关方法
  void _sendMessage() {
    final text = _chatController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _chatMessages.add(
        _ChatMessage(text: text, isUser: true, timestamp: DateTime.now()),
      );
      _isTyping = true;
    });

    _chatController.clear();
    _scrollToBottom(); // 滚动到最新消息

    // 模拟AI回复
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isTyping = false;
          _chatMessages.add(
            _ChatMessage(
              text: _generateAIResponse(text),
              isUser: false,
              timestamp: DateTime.now(),
            ),
          );
        });
        _scrollToBottom(); // AI回复后也滚动到最新消息
      }
    });
  }

  // 滚动到聊天列表底部
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_chatScrollController.hasClients) {
        _chatScrollController.animateTo(
          _chatScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _generateAIResponse(String userMessage) {
    // 简单的AI回复逻辑
    if (userMessage.contains('日本') || userMessage.contains('东京')) {
      return '日本是个很棒的选择！我推荐你3天2晚的行程：\n\n第1天：浅草寺 → 东京塔 → 新宿\n第2天：迪士尼乐园\n第3天：秋叶原 → 银座购物\n\n需要我为你详细规划具体路线吗？';
    } else if (userMessage.contains('韩国') || userMessage.contains('首尔')) {
      return '首尔是个充满活力的城市！建议2天1晚行程：\n\n第1天：明洞 → 景福宫 → 南山塔\n第2天：弘大 → 东大门\n\n需要我为你推荐美食和住宿吗？';
    } else if (userMessage.contains('泰国') || userMessage.contains('曼谷')) {
      return '曼谷是个美食天堂！推荐4天3晚：\n\n第1天：大皇宫 → 卧佛寺\n第2天：水上市场 → 美功铁道市场\n第3天：暹罗广场购物\n第4天：四面佛祈福\n\n需要我为你规划具体路线吗？';
    } else {
      return '听起来很有趣！请告诉我更多细节，比如：\n• 你想去哪个国家或城市？\n• 计划旅行几天？\n• 有什么特别想体验的活动吗？\n\n我会根据你的需求为你定制完美的行程！';
    }
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
      resizeToAvoidBottomInset: false, // 防止键盘弹出时页面被压缩
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.eco, color: Colors.green),
            const SizedBox(width: 8),
            const Text('小青蛙的旅行日记'),
            const Spacer(),
            Row(
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
                  Flexible(
                    child: Text(
                      _address!,
                      style: const TextStyle(fontSize: 13, color: Colors.green),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  )
                else if (_position != null)
                  Flexible(
                    child: Text(
                      '${_position!.latitude.toStringAsFixed(4)}, ${_position!.longitude.toStringAsFixed(4)}',
                      style: const TextStyle(fontSize: 12, color: Colors.green),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  )
                else
                  Flexible(
                    child: Text(
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
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
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
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 第一部分：AI聊天框
            Container(
              height: _chatMessages.length <= 2
                  ? 280 // 聊天记录少时，使用较小高度
                  : (_chatMessages.length <= 5
                        ? 400 // 中等数量聊天记录
                        : MediaQuery.of(context).size.height *
                              0.45), // 聊天记录多时，使用较大高度
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // 聊天框标题
                  GestureDetector(
                    onTap: () {
                      // 点击标题区域时收起键盘
                      FocusScope.of(context).unfocus();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.chat_bubble, color: Colors.green),
                          const SizedBox(width: 8),
                          const Text(
                            '馒馒',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              '在线',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // 聊天消息区域
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        // 点击聊天区域时收起键盘
                        FocusScope.of(context).unfocus();
                      },
                      child: ListView.builder(
                        controller: _chatScrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: _chatMessages.length + (_isTyping ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == _chatMessages.length && _isTyping) {
                            return _buildTypingIndicator();
                          }
                          return _buildChatMessage(_chatMessages[index]);
                        },
                      ),
                    ),
                  ),
                  // 输入框
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _chatController,
                            maxLines: 3, // 支持多行输入
                            minLines: 2, // 最少2行
                            decoration: InputDecoration(
                              hintText: '告诉我想去哪里旅行？\n比如：我想去日本东京，计划3天2晚...',
                              hintStyle: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 14,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: Colors.green.shade200,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: Colors.green.shade200,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: Colors.green,
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            onSubmitted: (_) => _sendMessage(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.green.withOpacity(0.3),
                                spreadRadius: 1,
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.send,
                              color: Colors.white,
                              size: 24,
                            ),
                            onPressed: _sendMessage,
                            padding: const EdgeInsets.all(12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // 第二部分：热门旅游路线
            GestureDetector(
              onTap: () {
                // 点击热门路线区域时收起键盘
                FocusScope.of(context).unfocus();
              },
              child: Container(
                color: Colors.grey.shade50,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 热门路线标题
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: const Row(
                        children: [
                          Icon(Icons.trending_up, color: Colors.green),
                          SizedBox(width: 8),
                          Text(
                            '🔥 热门旅游路线',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // 路线列表
                    ListView.builder(
                      shrinkWrap: true, // 重要：让ListView适应内容高度
                      physics:
                          const NeverScrollableScrollPhysics(), // 禁用滚动，让外层ScrollView处理
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _trips.length,
                      itemBuilder: (context, index) => _TripOption(
                        route: _trips[index].route,
                        destination: _trips[index].destination,
                        days: _trips[index].days,
                        participants: _trips[index].participants,
                        rating: _trips[index].rating,
                        selected: index == _selectedTripIndex,
                        onTap: () => _onTripSelected(index),
                      ),
                    ),
                    // 开始旅行按钮
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: Center(
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
                          child: const Text(
                            '开始旅行',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
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

  Widget _buildChatMessage(_ChatMessage message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: message.isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.smart_toy, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: message.isUser ? Colors.green : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: message.isUser ? Colors.white : Colors.black87,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 20),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.smart_toy, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
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

// 聊天消息数据类
class _ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  _ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}
