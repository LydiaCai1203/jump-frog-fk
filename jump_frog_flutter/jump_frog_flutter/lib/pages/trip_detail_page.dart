import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_svg/flutter_svg.dart';

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
    return Stack(
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
                  itemBuilder: (context, i) => _PlanCard(
                    plan: plans[i],
                    onNavigation: () => ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(const SnackBar(content: Text('导航功能待实现'))),
                    onTaxi: () => ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(const SnackBar(content: Text('打车功能待实现'))),
                    onComment: () => _showCommentModal(i),
                    onComplete: () => ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(const SnackBar(content: Text('标记完成功能待实现'))),
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
  final VoidCallback? onNavigation;
  final VoidCallback? onTaxi;
  final VoidCallback? onComment;
  final VoidCallback? onComplete;
  const _PlanCard({
    required this.plan,
    this.onNavigation,
    this.onTaxi,
    this.onComment,
    this.onComplete,
  });
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            plan.time,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            plan.type,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
      title: Text(
        plan.title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(plan.desc),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
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
            tooltip: '完成',
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
