import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class TripDetailPage extends StatefulWidget {
  final String route;
  final String destination;
  final String days;
  final String startDate;
  final String status;
  const TripDetailPage({
    super.key,
    required this.route,
    required this.destination,
    required this.days,
    required this.startDate,
    required this.status,
  });

  @override
  State<TripDetailPage> createState() => _TripDetailPageState();
}

class _TripDetailPageState extends State<TripDetailPage> {
  int? _commentPlanIndex;
  String? _previewImage;
  int? _actionIndex; // 当前显示操作按钮的行程项索引
  final List<_PlanItem> _plans = [
    _PlanItem(time: '08:00', type: '交通', title: '', desc: ''),
    _PlanItem(time: '12:00', type: '游玩', title: '景点A', desc: '参观著名景点A'),
    _PlanItem(time: '18:00', type: '餐食', title: '特色晚餐', desc: '品尝当地美食'),
    _PlanItem(time: '20:00', type: '住宿', title: '酒店入住', desc: '休息，准备明天行程'),
  ];
  final List<List<_Comment>> _comments = [
    [
      _Comment(
        user: '小明',
        content: '出发顺利！',
        rating: 5,
        time: '08:30',
        images: [],
      ),
    ],
    [
      _Comment(
        user: '小芳',
        content: '景点很美，推荐！',
        rating: 4,
        time: '13:00',
        images: [],
      ),
    ],
    [],
    [],
  ];
  Position? _position;
  String _locationStatus = '定位中...';
  bool _locating = false;
  String? _address;
  int _currentPlanIndex = 0; // 当前执行的行程项索引

  @override
  void initState() {
    super.initState();
    _getLocation();
    _updateCurrentPlanIndex();
  }

  void _updateCurrentPlanIndex() {
    // 根据当前时间确定正在执行的行程项
    final now = DateTime.now();
    final currentTime =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    for (int i = 0; i < _plans.length; i++) {
      if (currentTime.compareTo(_plans[i].time) >= 0) {
        _currentPlanIndex = i;
      } else {
        break;
      }
    }
  }

  Future<void> _getLocation() async {
    debugPrint('TripDetailPage 调用 _getLocation');
    setState(() {
      _locating = true;
      _locationStatus = '定位中...';
      _address = null;
    });
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        debugPrint('TripDetailPage 定位权限被拒绝: $permission');
        setState(() {
          _locationStatus = '未授权，无法获取位置';
          _locating = false;
        });
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
      debugPrint('TripDetailPage 获取到位置: ${pos.latitude}, ${pos.longitude}');

      // 获取地址信息
      String? address;
      try {
        debugPrint('TripDetailPage 开始获取地址信息');
        List<Placemark> placemarks = await placemarkFromCoordinates(
          pos.latitude,
          pos.longitude,
        );
        debugPrint('TripDetailPage 获取到 ${placemarks.length} 个地址信息');

        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          debugPrint(
            'TripDetailPage 地址信息: locality=${p.locality}, administrativeArea=${p.administrativeArea}, country=${p.country}',
          );
          // 优先显示城市名，然后是省份，最后是国家
          address = p.locality ?? p.administrativeArea ?? p.country ?? '';
          // 去除可能的空格
          if (address.isNotEmpty) {
            address = address.trim();
          }
        }
      } catch (e) {
        debugPrint('TripDetailPage 获取地址信息失败: $e');
        address = null;
      }

      setState(() {
        _position = pos;
        _locationStatus = '已定位';
        _address = address;
        _locating = false;
      });
      debugPrint('TripDetailPage 定位完成，地址: $address');
    } catch (e) {
      debugPrint('TripDetailPage 定位失败异常: ' + e.toString());
      setState(() {
        _locationStatus = '定位失败';
        _locating = false;
      });
    }
  }

  void _showCommentModal(int planIndex) {
    setState(() {
      _commentPlanIndex = planIndex;
    });
    showDialog(
      context: context,
      builder: (context) => _CommentModal(
        plan: _plans[planIndex],
        comments: _comments[planIndex],
        onSubmit: (content, rating, images) {
          setState(() {
            _comments[planIndex].add(
              _Comment(
                user: '我',
                content: content,
                rating: rating,
                time: '现在',
                images: images,
              ),
            );
          });
          Navigator.of(context).pop();
        },
        onImageTap: (img) => setState(() => _previewImage = img),
      ),
    );
  }

  void _closePreview() {
    setState(() {
      _previewImage = null;
    });
  }

  void _showAction(int i) {
    setState(() {
      _actionIndex = _actionIndex == i ? null : i;
    });
  }

  void _hideAction() {
    setState(() {
      _actionIndex = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final plans = [
      _PlanItem(
        time: '08:00',
        type: '交通',
        title: '${widget.route} 出发',
        desc: '前往 ${widget.destination}',
      ),
      ..._plans.sublist(1),
    ];
    return GestureDetector(
      onTap: _hideAction,
      child: Stack(
        children: [
          Scaffold(
            appBar: AppBar(
              title: Text('${widget.route} → ${widget.destination}'),
              actions: [
                Container(
                  margin: const EdgeInsets.only(right: 16),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: widget.status == '进行中'
                        ? Colors.green.shade100
                        : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      widget.status,
                      style: TextStyle(
                        color: widget.status == '进行中'
                            ? Colors.green
                            : Colors.black54,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  color: Colors.green.shade50,
                  padding: const EdgeInsets.symmetric(
                    vertical: 18,
                    horizontal: 18,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        color: Colors.green.shade400,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '出发日期: ${widget.startDate}',
                        style: const TextStyle(fontSize: 15),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.schedule,
                        color: Colors.green.shade400,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(widget.days, style: const TextStyle(fontSize: 15)),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.separated(
                    itemCount: plans.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, i) => Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            _showAction(i);
                          },
                          child: _PlanCard(
                            plan: plans[i],
                            showActions: _actionIndex == i,
                            isCompleted: i < _currentPlanIndex,
                            isCurrent: i == _currentPlanIndex,
                            isLocating: _locating && i == _currentPlanIndex,
                            address: i == _currentPlanIndex ? _address : null,
                            locationStatus: i == _currentPlanIndex
                                ? _locationStatus
                                : null,
                            onNavigation: () =>
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('导航功能待实现')),
                                ),
                            onTaxi: () =>
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('打车功能待实现')),
                                ),
                            onComment: () => _showCommentModal(i),
                            onComplete: () =>
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('标记完成功能待实现')),
                                ),
                            onRefreshLocation: i == _currentPlanIndex
                                ? _getLocation
                                : null,
                          ),
                        ),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: _actionIndex == i
                              ? _PlanActions(
                                  onNavigation: () =>
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text('导航功能待实现'),
                                        ),
                                      ),
                                  onTaxi: () => ScaffoldMessenger.of(context)
                                      .showSnackBar(
                                        const SnackBar(
                                          content: Text('打车功能待实现'),
                                        ),
                                      ),
                                  onComment: () => _showCommentModal(i),
                                  onComplete: () =>
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text('标记完成功能待实现'),
                                        ),
                                      ),
                                )
                              : const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_previewImage != null)
            GestureDetector(
              onTap: _closePreview,
              child: Container(
                color: Colors.black.withOpacity(0.85),
                alignment: Alignment.center,
                child: Stack(
                  alignment: Alignment.topRight,
                  children: [
                    Center(
                      child: Image.file(
                        File(_previewImage!),
                        width: 320,
                        fit: BoxFit.contain,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 32,
                      ),
                      onPressed: _closePreview,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PlanItem {
  final String time;
  final String type;
  final String title;
  final String desc;
  const _PlanItem({
    required this.time,
    required this.type,
    required this.title,
    required this.desc,
  });
}

class _PlanCard extends StatelessWidget {
  final _PlanItem plan;
  final bool showActions;
  final bool isCompleted;
  final bool isCurrent;
  final bool isLocating;
  final String? address;
  final String? locationStatus;
  final VoidCallback? onNavigation;
  final VoidCallback? onTaxi;
  final VoidCallback? onComment;
  final VoidCallback? onComplete;
  final VoidCallback? onRefreshLocation;
  const _PlanCard({
    required this.plan,
    this.showActions = false,
    this.isCompleted = false,
    this.isCurrent = false,
    this.isLocating = false,
    this.address,
    this.locationStatus,
    this.onNavigation,
    this.onTaxi,
    this.onComment,
    this.onComplete,
    this.onRefreshLocation,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      color: isCompleted ? Colors.grey.shade50 : Colors.white,
      child: ListTile(
        leading: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              plan.time,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isCompleted ? Colors.grey : Colors.green,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              plan.type,
              style: TextStyle(
                fontSize: 12,
                color: isCompleted ? Colors.grey.shade400 : Colors.black54,
              ),
            ),
            if (isCompleted)
              const Icon(Icons.check_circle, color: Colors.green, size: 16),
          ],
        ),
        title: Text(
          plan.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isCompleted ? Colors.grey : Colors.black87,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              plan.desc,
              style: TextStyle(
                color: isCompleted ? Colors.grey.shade500 : Colors.black54,
              ),
            ),
            // 只在当前执行的行程项中显示定位信息
            if (isCurrent && !isCompleted) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    color: isLocating ? Colors.blue : Colors.green,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  if (isLocating)
                    const SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(strokeWidth: 1.5),
                    )
                  else if (address != null && address!.isNotEmpty)
                    Text(
                      address!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  else if (locationStatus != null)
                    Text(
                      locationStatus!,
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  const Spacer(),
                  if (!isLocating && onRefreshLocation != null)
                    IconButton(
                      icon: const Icon(
                        Icons.refresh,
                        color: Colors.green,
                        size: 14,
                      ),
                      tooltip: '刷新位置',
                      onPressed: onRefreshLocation,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PlanActions extends StatelessWidget {
  final VoidCallback? onNavigation;
  final VoidCallback? onTaxi;
  final VoidCallback? onComment;
  final VoidCallback? onComplete;
  const _PlanActions({
    this.onNavigation,
    this.onTaxi,
    this.onComment,
    this.onComplete,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 8, spreadRadius: 1),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: SvgPicture.asset(
              'assets/svg/navigation.svg',
              width: 28,
              height: 28,
            ),
            tooltip: '导航',
            onPressed: onNavigation,
          ),
          IconButton(
            icon: SvgPicture.asset('assets/svg/car.svg', width: 28, height: 28),
            tooltip: '打车',
            onPressed: onTaxi,
          ),
          IconButton(
            icon: SvgPicture.asset(
              'assets/svg/finish.svg',
              width: 28,
              height: 28,
            ),
            tooltip: '标记完成',
            onPressed: onComplete,
          ),
          IconButton(
            icon: const Icon(Icons.comment, color: Colors.green),
            tooltip: '评论',
            onPressed: onComment,
          ),
        ],
      ),
    );
  }
}

class _Comment {
  final String user;
  final String content;
  final int rating;
  final String time;
  final List<String> images;
  const _Comment({
    required this.user,
    required this.content,
    required this.rating,
    required this.time,
    required this.images,
  });
}

class _CommentModal extends StatefulWidget {
  final _PlanItem plan;
  final List<_Comment> comments;
  final void Function(String content, int rating, List<String> images) onSubmit;
  final void Function(String img)? onImageTap;
  const _CommentModal({
    required this.plan,
    required this.comments,
    required this.onSubmit,
    this.onImageTap,
  });
  @override
  State<_CommentModal> createState() => _CommentModalState();
}

class _CommentModalState extends State<_CommentModal> {
  final TextEditingController _controller = TextEditingController();
  int _rating = 0;
  List<String> _images = [];

  void _pickImage() async {
    setState(() {
      _images.add('/mock/path/to/comment_image_${_images.length + 1}.jpg');
    });
  }

  @override
  Widget build(BuildContext context) {
    final String title = (widget.plan.title.trim().isEmpty)
        ? '评论'
        : '评论 - ${widget.plan.title}';
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 60),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.black54),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // 评分
              Row(
                children: [
                  ...List.generate(
                    5,
                    (i) => IconButton(
                      icon: Icon(
                        Icons.star,
                        color: i < _rating
                            ? Colors.orange
                            : Colors.grey.shade300,
                      ),
                      iconSize: 28,
                      padding: EdgeInsets.zero,
                      onPressed: () => setState(() => _rating = i + 1),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _rating == 0 ? '未评分' : '$_rating 分',
                    style: const TextStyle(fontSize: 15, color: Colors.black87),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // 输入框
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: '写下你的体验...（最多200字）',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                  ),
                  minLines: 4,
                  maxLines: 6,
                  maxLength: 200,
                ),
              ),
              const SizedBox(height: 10),
              // 图片九宫格
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  ..._images.map(
                    (img) => Stack(
                      alignment: Alignment.topRight,
                      children: [
                        GestureDetector(
                          onTap: widget.onImageTap != null
                              ? () => widget.onImageTap!(img)
                              : null,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(img),
                              width: 72,
                              height: 72,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => setState(() => _images.remove(img)),
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_images.length < 9)
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.add_a_photo,
                          color: Colors.green,
                          size: 28,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 18),
              // 历史评论
              if (widget.comments.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Divider(),
                      const Text(
                        '大家的评论',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 6),
                      ...widget.comments.map(
                        (c) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    '${c.user}: ',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  ...List.generate(
                                    5,
                                    (i) => Icon(
                                      Icons.star,
                                      size: 14,
                                      color: i < c.rating
                                          ? Colors.orange
                                          : Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '  ${c.time}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 32,
                                  top: 2,
                                ),
                                child: Text(c.content),
                              ),
                              if (c.images.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 32,
                                    top: 4,
                                  ),
                                  child: Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: c.images
                                        .map(
                                          (img) => GestureDetector(
                                            onTap: widget.onImageTap != null
                                                ? () => widget.onImageTap!(img)
                                                : null,
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: Image.file(
                                                File(img),
                                                width: 48,
                                                height: 48,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (_controller.text.trim().isEmpty || _rating == 0)
                          return;
                        widget.onSubmit(
                          _controller.text.trim(),
                          _rating,
                          List.from(_images),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      child: const Text('发布'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
