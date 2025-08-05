import 'package:flutter/material.dart';
import 'package:characters/characters.dart';
import 'dart:io';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String avatarUrl = '';
  String nickname = '小青蛙';
  String bio = '热爱旅行的小青蛙 🐸';
  int tripCount = 12;
  int countryCount = 8;
  int momentCount = 156;

  void _onEditProfile() async {
    final result = await showDialog<_ProfileEditResult>(
      context: context,
      builder: (context) =>
          _EditProfileModal(avatarUrl: avatarUrl, nickname: nickname, bio: bio),
    );
    if (result != null) {
      setState(() {
        avatarUrl = result.avatarUrl;
        nickname = result.nickname;
        bio = result.bio;
      });
    }
  }

  void _onMenuTap(String menu) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$menu 功能待实现')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('我的')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(width: 24),
                GestureDetector(
                  onTap: _onEditProfile,
                  child: CircleAvatar(
                    radius: 38,
                    backgroundColor: Colors.green.shade100,
                    backgroundImage: avatarUrl.isNotEmpty
                        ? FileImage(File(avatarUrl))
                        : null,
                    child: avatarUrl.isEmpty
                        ? Text(
                            nickname.characters.first,
                            style: const TextStyle(
                              fontSize: 32,
                              color: Colors.green,
                            ),
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nickname,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        bio,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.green),
                  tooltip: '编辑资料',
                  onPressed: _onEditProfile,
                ),
                const SizedBox(width: 16),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _StatBlock(label: '旅行次数', value: '$tripCount'),
                _StatBlock(label: '国家', value: '$countryCount'),
                _StatBlock(label: '动态', value: '$momentCount'),
              ],
            ),
            const SizedBox(height: 24),
            _ProfileMenuItem(
              icon: Icons.login,
              label: '登录/注册',
              onTap: () => Navigator.of(context).pushNamed('/auth'),
            ),
            _ProfileMenuItem(
              icon: Icons.settings,
              label: '设置',
              onTap: () => _onMenuTap('设置'),
            ),
            _ProfileMenuItem(
              icon: Icons.help_outline,
              label: '帮助与反馈',
              onTap: () => _onMenuTap('帮助与反馈'),
            ),
            _ProfileMenuItem(
              icon: Icons.info_outline,
              label: '关于我们',
              onTap: () => _onMenuTap('关于我们'),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _StatBlock extends StatelessWidget {
  final String label;
  final String value;
  const _StatBlock({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.black54),
        ),
      ],
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ProfileMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.green),
      title: Text(label),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

class _ProfileEditResult {
  final String avatarUrl;
  final String nickname;
  final String bio;
  const _ProfileEditResult({
    required this.avatarUrl,
    required this.nickname,
    required this.bio,
  });
}

class _EditProfileModal extends StatefulWidget {
  final String avatarUrl;
  final String nickname;
  final String bio;
  const _EditProfileModal({
    required this.avatarUrl,
    required this.nickname,
    required this.bio,
  });
  @override
  State<_EditProfileModal> createState() => _EditProfileModalState();
}

class _EditProfileModalState extends State<_EditProfileModal> {
  late TextEditingController _nicknameController;
  late TextEditingController _bioController;
  String _avatarUrl = '';

  @override
  void initState() {
    super.initState();
    _nicknameController = TextEditingController(text: widget.nickname);
    _bioController = TextEditingController(text: widget.bio);
    _avatarUrl = widget.avatarUrl;
  }

  void _pickAvatar() async {
    // mock: 选择头像图片（实际项目可用 image_picker）
    setState(() {
      _avatarUrl =
          '/mock/path/to/avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('编辑资料'),
      content: SizedBox(
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: _pickAvatar,
                  child: CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.green.shade100,
                    backgroundImage: _avatarUrl.isNotEmpty
                        ? FileImage(File(_avatarUrl))
                        : null,
                    child: _avatarUrl.isEmpty
                        ? const Icon(
                            Icons.camera_alt,
                            color: Colors.green,
                            size: 28,
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 16),
                const Text(
                  '点击更换头像',
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nicknameController,
              decoration: const InputDecoration(labelText: '昵称'),
              maxLength: 12,
            ),
            TextField(
              controller: _bioController,
              decoration: const InputDecoration(labelText: '签名'),
              maxLength: 30,
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
            if (_nicknameController.text.trim().isEmpty) return;
            Navigator.of(context).pop(
              _ProfileEditResult(
                avatarUrl: _avatarUrl,
                nickname: _nicknameController.text.trim(),
                bio: _bioController.text.trim(),
              ),
            );
          },
          child: const Text('保存'),
        ),
      ],
    );
  }
}
