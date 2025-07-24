import 'package:flutter/material.dart';
import 'package:characters/characters.dart';
import 'dart:io';

class CirclePage extends StatefulWidget {
  const CirclePage({super.key});
  @override
  State<CirclePage> createState() => _CirclePageState();
}

class _CirclePageState extends State<CirclePage> {
  final List<_MomentData> _moments = [
    _MomentData(
      username: '小青蛙',
      avatarUrl: null,
      content: '今天在东京塔看到了超美的夜景！',
      time: '刚刚',
      likes: 12,
      comments: 3,
      isLiked: false,
      isFollowed: false,
      images: [],
    ),
    _MomentData(
      username: '小明',
      avatarUrl: null,
      content: '推荐新宿的拉面店，超级好吃！',
      time: '1小时前',
      likes: 8,
      comments: 1,
      isLiked: true,
      isFollowed: true,
      images: [],
    ),
  ];

  void _onLike(int i) {
    setState(() {
      _moments[i] = _moments[i].copyWith(
        isLiked: !_moments[i].isLiked,
        likes: _moments[i].isLiked
            ? _moments[i].likes - 1
            : _moments[i].likes + 1,
      );
    });
  }

  void _onFollow(int i) {
    setState(() {
      _moments[i] = _moments[i].copyWith(isFollowed: !_moments[i].isFollowed);
    });
  }

  void _onComment(int i) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('评论功能待实现')));
  }

  void _onPostMoment() async {
    final result = await showDialog<_MomentData>(
      context: context,
      builder: (context) => _PostMomentModal(),
    );
    if (result != null) {
      setState(() {
        _moments.insert(0, result);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('蛙友圈'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Colors.green),
            tooltip: '发布动态',
            onPressed: _onPostMoment,
          ),
        ],
      ),
      body: _moments.isEmpty
          ? const Center(child: Text('暂无动态'))
          : ListView.builder(
              itemCount: _moments.length,
              itemBuilder: (context, i) => _MomentCard(
                data: _moments[i],
                onLike: () => _onLike(i),
                onComment: () => _onComment(i),
                onFollow: () => _onFollow(i),
              ),
            ),
    );
  }
}

class _MomentData {
  final String username;
  final String? avatarUrl;
  final String content;
  final String time;
  final int likes;
  final int comments;
  final bool isLiked;
  final bool isFollowed;
  final List<String> images;
  const _MomentData({
    required this.username,
    required this.avatarUrl,
    required this.content,
    required this.time,
    required this.likes,
    required this.comments,
    required this.isLiked,
    required this.isFollowed,
    required this.images,
  });
  _MomentData copyWith({
    String? username,
    String? avatarUrl,
    String? content,
    String? time,
    int? likes,
    int? comments,
    bool? isLiked,
    bool? isFollowed,
    List<String>? images,
  }) {
    return _MomentData(
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      content: content ?? this.content,
      time: time ?? this.time,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      isLiked: isLiked ?? this.isLiked,
      isFollowed: isFollowed ?? this.isFollowed,
      images: images ?? this.images,
    );
  }
}

class _MomentCard extends StatelessWidget {
  final _MomentData data;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onFollow;
  const _MomentCard({
    required this.data,
    required this.onLike,
    required this.onComment,
    required this.onFollow,
  });
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.green.shade100,
                  child: Text(data.username.characters.first),
                ),
                const SizedBox(width: 10),
                Text(
                  data.username,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  data.time,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: onFollow,
                  style: TextButton.styleFrom(
                    foregroundColor: data.isFollowed
                        ? Colors.grey
                        : Colors.green,
                  ),
                  child: Text(data.isFollowed ? '已关注' : '关注'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(data.content),
            if (data.images.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: data.images
                      .map(
                        (img) => ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(img),
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    data.isLiked ? Icons.favorite : Icons.favorite_border,
                    color: Colors.red,
                  ),
                  onPressed: onLike,
                ),
                Text('${data.likes}'),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.comment, color: Colors.blueGrey),
                  onPressed: onComment,
                ),
                Text('${data.comments}'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PostMomentModal extends StatefulWidget {
  @override
  State<_PostMomentModal> createState() => _PostMomentModalState();
}

class _PostMomentModalState extends State<_PostMomentModal> {
  final TextEditingController _controller = TextEditingController();
  List<String> _images = [];

  void _pickImage() async {
    // mock: 选择图片后添加本地文件路径（实际项目可用 image_picker）
    setState(() {
      _images.add('/mock/path/to/image_${_images.length + 1}.jpg');
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('发布动态'),
      content: SizedBox(
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(hintText: '分享你的旅行心情...'),
              minLines: 3,
              maxLines: 6,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.add_a_photo),
                  label: const Text('添加图片'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '已选${_images.length}张',
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
            if (_images.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _images
                      .map(
                        (img) => Stack(
                          alignment: Alignment.topRight,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                File(img),
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
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
                      )
                      .toList(),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_controller.text.trim().isEmpty) return;
            Navigator.of(context).pop(
              _MomentData(
                username: '我',
                avatarUrl: null,
                content: _controller.text.trim(),
                time: '刚刚',
                likes: 0,
                comments: 0,
                isLiked: false,
                isFollowed: false,
                images: List.from(_images),
              ),
            );
          },
          child: const Text('发布'),
        ),
      ],
    );
  }
}
