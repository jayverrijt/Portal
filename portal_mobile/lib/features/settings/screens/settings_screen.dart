import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/nord_theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../../budget/providers/budget_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _fullNameController = TextEditingController();
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isUploading = false;
  String? _email;
  String? _profilePictureUrl;
  String? _message;
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.dio.get('/UserSettings');

      if (!mounted) return;

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        setState(() {
          _email = data['email'] ?? '';
          _fullNameController.text = data['fullName'] ?? '';
          _profilePictureUrl = data['profilePictureUrl'];
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _message = 'Kon profielgegevens niet laden.';
        _isSuccess = false;
      });
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);

    if (pickedFile == null || !mounted) return;

    setState(() {
      _isUploading = true;
      _message = null;
    });

    try {
      final apiClient = ref.read(apiClientProvider);
      String fileName = pickedFile.path.split('/').last;
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(pickedFile.path, filename: fileName),
      });

      final response = await apiClient.dio.post('/UserSettings/upload-picture', data: formData);

      if (!mounted) return;

      if (response.statusCode == 200 && response.data != null) {
        setState(() {
          _profilePictureUrl = response.data['profilePictureUrl'] ?? response.data['url'];
          _message = 'Profielfoto succesvol geüpload!';
          _isSuccess = true;
        });

        if (response.data['token'] != null) {
          await ref.read(authNotifierProvider.notifier).updateToken(response.data['token']);
        }
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _message = 'Fout bij uploaden van foto: $e';
        _isSuccess = false;
      });
    } finally {
      if (!mounted) return;
      setState(() => _isUploading = false);
    }
  }

  Future<void> _saveSettings() async {
    setState(() {
      _isSaving = true;
      _message = null;
    });

    try {
      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.dio.put('/UserSettings', data: {
        'fullName': _fullNameController.text.trim(),
        'profilePictureUrl': _profilePictureUrl,
      });

      if (!mounted) return;

      if (response.statusCode == 200) {
        setState(() {
          _message = 'Instellingen succesvol opgeslagen!';
          _isSuccess = true;
        });

        if (response.data != null && response.data['token'] != null) {
          await ref.read(authNotifierProvider.notifier).updateToken(response.data['token']);
        }
      } else {
        setState(() {
          _message = 'Opslaan mislukt.';
          _isSuccess = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _message = 'Fout bij opslaan: $e';
        _isSuccess = false;
      });
    } finally {
      if (!mounted) return;
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final apiClient = ref.read(apiClientProvider);

    return Scaffold(
      backgroundColor: NordColors.nord0,
      appBar: AppBar(
        backgroundColor: NordColors.nord1,
        elevation: 0,
        title: const Text(
          'Instellingen',
          style: TextStyle(color: NordColors.nord6, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: NordColors.nord6),
      ),
      drawer: Drawer(
        backgroundColor: NordColors.nord1,
        child: FutureBuilder<Response>(
          future: apiClient.dio.get('/UserSettings'),
          builder: (context, snapshot) {
            String displayName = 'Portal Gebruiker';
            String? profilePictureUrl;

            if (snapshot.hasData && snapshot.data?.data != null) {
              final data = snapshot.data!.data;
              displayName = data['fullName'] ?? 'Portal Gebruiker';
              if (displayName.trim().isEmpty) displayName = 'Portal Gebruiker';
              profilePictureUrl = data['profilePictureUrl'];
            }

            return Column(
              children: [
                DrawerHeader(
                  decoration: const BoxDecoration(
                    color: NordColors.nord0,
                    border: Border(bottom: BorderSide(color: NordColors.nord2)),
                  ),
                  child: Container(
                    alignment: Alignment.bottomLeft,
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: NordColors.nord8, width: 1.5),
                            color: NordColors.nord1,
                          ),
                          child: ClipOval(
                            child: profilePictureUrl != null && profilePictureUrl.isNotEmpty
                                ? Image.network(
                              profilePictureUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Icon(
                                Icons.person,
                                size: 24,
                                color: NordColors.nord4,
                              ),
                            )
                                : const Icon(
                              Icons.person,
                              size: 24,
                              color: NordColors.nord4,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            displayName,
                            style: const TextStyle(
                              color: NordColors.nord6,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.home_outlined, color: NordColors.nord4),
                  title: const Text('Dashboard', style: TextStyle(color: NordColors.nord4)),
                  onTap: () {
                    Navigator.of(context).pop();
                    context.go('/home');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.folder_outlined, color: NordColors.nord4),
                  title: const Text('Projecten', style: TextStyle(color: NordColors.nord4)),
                  onTap: () {
                    Navigator.of(context).pop();
                    context.go('/projects');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.view_kanban_outlined, color: NordColors.nord4),
                  title: const Text('FlowBoards', style: TextStyle(color: NordColors.nord4)),
                  onTap: () {
                    Navigator.of(context).pop();
                    context.go('/flowboards');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.note_alt_outlined, color: NordColors.nord4),
                  title: const Text('Notities', style: TextStyle(color: NordColors.nord4)),
                  onTap: () {
                    Navigator.of(context).pop();
                    context.go('/notes');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.account_balance_wallet_outlined, color: NordColors.nord4),
                  title: const Text('Financiën', style: TextStyle(color: NordColors.nord4)),
                  onTap: () {
                    Navigator.of(context).pop();
                    context.go('/budget');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.widgets_outlined, color: NordColors.nord4),
                  title: const Text('Utils', style: TextStyle(color: NordColors.nord4)),
                  onTap: () {
                    Navigator.of(context).pop();
                    context.go('/tools');
                  },
                ),
                const Spacer(),
                const Divider(color: NordColors.nord2),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: ListTile(
                    leading: const Icon(Icons.settings_outlined, color: NordColors.nord8),
                    title: const Text('Instellingen', style: TextStyle(color: NordColors.nord6, fontWeight: FontWeight.w600)),
                    selected: true,
                    selectedTileColor: NordColors.nord2.withValues(alpha: 0.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: ListTile(
                    leading: const Icon(Icons.logout, color: NordColors.nord11),
                    title: const Text('Uitloggen', style: TextStyle(color: NordColors.nord11)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    onTap: () {
                      Navigator.of(context).pop();
                      ref.read(authNotifierProvider.notifier).logout();
                    },
                  ),
                ),
                const SizedBox(height: 12),
              ],
            );
          },
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: NordColors.nord8))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: NordColors.nord1,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: NordColors.nord2),
              ),
              child: Column(
                children: [
                  const Text(
                    'Profielgegevens',
                    style: TextStyle(color: NordColors.nord8, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: _isUploading ? null : _pickAndUploadImage,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: NordColors.nord8, width: 2),
                            color: NordColors.nord0,
                          ),
                          child: ClipOval(
                            child: _profilePictureUrl != null && _profilePictureUrl!.isNotEmpty
                                ? Image.network(
                              _profilePictureUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Icon(
                                Icons.person,
                                size: 45,
                                color: NordColors.nord4,
                              ),
                            )
                                : const Icon(
                              Icons.person,
                              size: 45,
                              color: NordColors.nord4,
                            ),
                          ),
                        ),
                        if (_isUploading)
                          const CircularProgressIndicator(color: NordColors.nord8)
                        else
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: NordColors.nord8,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                size: 16,
                                color: NordColors.nord0,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tik om foto te wijzigen',
                    style: TextStyle(color: NordColors.nord3, fontSize: 12),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    enabled: false,
                    controller: TextEditingController(text: _email ?? ''),
                    style: const TextStyle(color: NordColors.nord3),
                    decoration: InputDecoration(
                      labelText: 'E-mailadres',
                      labelStyle: const TextStyle(color: NordColors.nord4),
                      filled: true,
                      fillColor: NordColors.nord0,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _fullNameController,
                    style: const TextStyle(color: NordColors.nord6),
                    decoration: InputDecoration(
                      labelText: 'Volledige Naam',
                      labelStyle: const TextStyle(color: NordColors.nord4),
                      filled: true,
                      fillColor: NordColors.nord0,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (_message != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _isSuccess
                      ? NordColors.nord14.withValues(alpha: 0.15)
                      : NordColors.nord11.withValues(alpha: 0.15),
                  border: Border.all(color: _isSuccess ? NordColors.nord14 : NordColors.nord11),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _message!,
                  style: TextStyle(
                    color: _isSuccess ? NordColors.nord14 : NordColors.nord11,
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
            ],
            ElevatedButton(
              onPressed: _isSaving ? null : _saveSettings,
              style: ElevatedButton.styleFrom(
                backgroundColor: NordColors.nord8,
                foregroundColor: NordColors.nord0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 4,
              ),
              child: _isSaving
                  ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: NordColors.nord0,
                ),
              )
                  : const Text(
                'Wijzigingen Opslaan',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}