import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:athidhi/constants/app_colors.dart';
import 'package:athidhi/models/photo_model.dart';
import 'package:athidhi/providers/photo_provider.dart';
import 'package:athidhi/providers/language_provider.dart';

class MemoryWallScreen extends StatefulWidget {
  final String eventId;
  final bool isHost;

  const MemoryWallScreen({
    super.key,
    required this.eventId,
    this.isHost = false,
  });

  @override
  State<MemoryWallScreen> createState() => _MemoryWallScreenState();
}

class _MemoryWallScreenState extends State<MemoryWallScreen> {
  final _nameController = TextEditingController();
  final _captionController = TextEditingController();
  File? _selectedImage;
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PhotoProvider>().loadPhotos(widget.eventId);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final provider = context.watch<PhotoProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          lang.t('മെമ്മറി വാൾ', 'Memory Wall'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (widget.isHost && provider.pendingPhotos.isNotEmpty)
            GestureDetector(
              onTap: () => _showModerationPanel(context),
              child: Container(
                margin: const EdgeInsets.only(right: 12),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.rate_review_outlined,
                        size: 14, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(
                      '${provider.pendingPhotos.length}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      body: _buildBody(provider, lang),
      floatingActionButton: widget.isHost
          ? FloatingActionButton(
              heroTag: 'slideshow',
              backgroundColor: AppColors.primary,
              onPressed: () => _startSlideshow(context, provider),
              child: const Icon(Icons.slideshow, color: Colors.white),
            )
          : FloatingActionButton(
              heroTag: 'upload',
              backgroundColor: AppColors.primary,
              onPressed: () => _showUploadSheet(context, lang),
              child: const Icon(Icons.camera_alt, color: Colors.white),
            ),
    );
  }

  Widget _buildBody(PhotoProvider provider, LanguageProvider lang) {
    switch (provider.status) {
      case PhotoLoadStatus.loading:
        return const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        );
      case PhotoLoadStatus.error:
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off, size: 48, color: AppColors.textMuted),
              const SizedBox(height: 12),
              Text(
                lang.t('ഫോട്ടോകൾ ലോഡ് ചെയ്യാനായില്ല', 'Failed to load photos'),
                style: const TextStyle(color: AppColors.textMuted),
              ),
            ],
          ),
        );
      case PhotoLoadStatus.loaded:
        final photos =
            widget.isHost ? provider.photos : provider.approvedPhotos;
        if (photos.isEmpty) {
          return _buildEmptyState(lang);
        }
        return _buildPhotoGrid(photos, provider, lang);
      default:
        return const SizedBox();
    }
  }

  Widget _buildEmptyState(LanguageProvider lang) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.photo_library_outlined,
              size: 64, color: AppColors.border),
          const SizedBox(height: 16),
          Text(
            lang.t('ഇതുവരെ ഫോട്ടോകൾ ഒന്നുമില്ല', 'No photos yet'),
            style: const TextStyle(
                fontSize: 16,
                color: AppColors.textMuted,
                fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            lang.t(
                'ആദ്യത്തെ ഫോട്ടോ അപ്‌ലോഡ് ചെയ്യൂ! 📸',
                'Be the first to upload! 📸'),
            style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoGrid(
      List<MemoryPhoto> photos, PhotoProvider provider, LanguageProvider lang) {
    return RefreshIndicator(
      onRefresh: () => provider.loadPhotos(widget.eventId),
      child: GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 6,
          mainAxisSpacing: 6,
        ),
        itemCount: photos.length,
        itemBuilder: (_, i) {
          final photo = photos[i];
          return GestureDetector(
            onTap: () => _showPhotoDetail(context, photo, provider, lang),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    photo.imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (_, child, progress) {
                      if (progress == null) return child;
                      return Container(
                        color: AppColors.border.withValues(alpha: 0.3),
                        child: const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (_, __, ___) => Container(
                      color: AppColors.border.withValues(alpha: 0.3),
                      child: const Icon(Icons.broken_image,
                          color: AppColors.textMuted),
                    ),
                  ),
                  if (!photo.isApproved && widget.isHost)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: photo.isPending
                              ? Colors.orange
                              : Colors.redAccent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          photo.isPending ? 'Pending' : 'Rejected',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.6),
                          ],
                        ),
                      ),
                      child: Text(
                        photo.guestName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showPhotoDetail(BuildContext context, MemoryPhoto photo,
      PhotoProvider provider, LanguageProvider lang) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(photo.guestName,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                      if (photo.caption != null && photo.caption!.isNotEmpty)
                        Text(photo.caption!,
                            style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 13)),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close,
                        color: Colors.white, size: 28),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: InteractiveViewer(
                child: Image.network(
                  photo.imageUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (_, child, progress) {
                    if (progress == null) return child;
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    );
                  },
                  errorBuilder: (_, __, ___) => const Center(
                    child: Icon(Icons.broken_image,
                        color: Colors.white54, size: 48),
                  ),
                ),
              ),
            ),
            if (widget.isHost)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (!photo.isApproved)
                      _buildActionButton(
                        icon: Icons.check_circle,
                        label: lang.t('അംഗീകരിക്കുക', 'Approve'),
                        color: AppColors.green,
                        onTap: () {
                          provider.approvePhoto(photo.id);
                          Navigator.pop(context);
                        },
                      ),
                    if (photo.isPending)
                      _buildActionButton(
                        icon: Icons.cancel,
                        label: lang.t('നിരസിക്കുക', 'Reject'),
                        color: Colors.redAccent,
                        onTap: () {
                          provider.rejectPhoto(photo.id);
                          Navigator.pop(context);
                        },
                      ),
                    _buildActionButton(
                      icon: Icons.delete,
                      label: lang.t('ഇല്ലാതാക്കുക', 'Delete'),
                      color: Colors.red,
                      onTap: () {
                        provider.deletePhoto(photo.id, photo.imageUrl);
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  void _showUploadSheet(BuildContext context, LanguageProvider lang) {
    _nameController.clear();
    _captionController.clear();
    _selectedImage = null;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                lang.t('ഫോട്ടോ അപ്‌ലോഡ് ചെയ്യുക', 'Upload a Photo'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () async {
                  final picker = ImagePicker();
                  final picked =
                      await picker.pickImage(source: ImageSource.gallery);
                  if (picked != null) {
                    setSheetState(() => _selectedImage = File(picked.path));
                  }
                },
                child: Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: _selectedImage != null
                        ? Colors.transparent
                        : AppColors.background,
                    borderRadius: BorderRadius.circular(14),
                    border: _selectedImage != null
                        ? null
                        : Border.all(color: AppColors.border),
                    image: _selectedImage != null
                        ? DecorationImage(
                            image: FileImage(_selectedImage!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _selectedImage == null
                      ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate_outlined,
                                size: 40, color: AppColors.textMuted),
                            SizedBox(height: 8),
                            Text(
                              'Tap to select photo',
                              style: TextStyle(color: AppColors.textMuted),
                            ),
                          ],
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: lang.t('നിങ്ങളുടെ പേര്', 'Your name'),
                    hintStyle:
                        const TextStyle(color: AppColors.textMuted),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: TextField(
                  controller: _captionController,
                  decoration: InputDecoration(
                    hintText: lang.t(
                        'ഒരു കുറിപ്പ് (ഓപ്ഷണൽ)', 'Add a caption (optional)'),
                    hintStyle:
                        const TextStyle(color: AppColors.textMuted),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _uploading || _selectedImage == null ||
                          _nameController.text.isEmpty
                      ? null
                      : () async {
                          setSheetState(() => _uploading = true);
                          final success = await context
                              .read<PhotoProvider>()
                              .uploadPhoto(
                                eventId: widget.eventId,
                                guestName: _nameController.text.trim(),
                                imageFile: _selectedImage!,
                                caption: _captionController.text
                                        .trim()
                                        .isEmpty
                                    ? null
                                    : _captionController.text.trim(),
                              );
                          if (ctx.mounted) {
                            Navigator.pop(ctx);
                            if (success && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    lang.t(
                                      'ഫോട്ടോ അപ്‌ലോഡ് ചെയ്തു! ✅',
                                      'Photo uploaded! ✅',
                                    ),
                                  ),
                                  backgroundColor: AppColors.green,
                                ),
                              );
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: _uploading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          lang.t('അപ്‌ലോഡ് ചെയ്യുക', 'Upload'),
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _showModerationPanel(BuildContext context) {
    final provider = context.read<PhotoProvider>();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        builder: (_, scrollController) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Pending Moderation',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: provider.pendingPhotos.isEmpty
                    ? const Center(child: Text('No pending photos'))
                    : ListView.builder(
                        controller: scrollController,
                        itemCount: provider.pendingPhotos.length,
                        itemBuilder: (_, i) {
                          final photo = provider.pendingPhotos[i];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(14)),
                                  child: Image.network(
                                    photo.imageUrl,
                                    height: 200,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(photo.guestName,
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.w600)),
                                            if (photo.caption != null &&
                                                photo.caption!.isNotEmpty)
                                              Text(photo.caption!,
                                                  style: const TextStyle(
                                                      fontSize: 12,
                                                      color:
                                                          AppColors.textMuted)),
                                          ],
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          GestureDetector(
                                            onTap: () => provider
                                                .approvePhoto(photo.id),
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: AppColors.green
                                                    .withValues(alpha: 0.1),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: const Icon(Icons.check,
                                                  color: AppColors.green),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          GestureDetector(
                                            onTap: () => provider
                                                .rejectPhoto(photo.id),
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: Colors.redAccent
                                                    .withValues(alpha: 0.1),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: const Icon(Icons.close,
                                                  color: Colors.redAccent),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          GestureDetector(
                                            onTap: () => provider
                                                .deletePhoto(photo.id,
                                                    photo.imageUrl),
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: Colors.red
                                                    .withValues(alpha: 0.1),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: const Icon(
                                                  Icons.delete_outline,
                                                  color: Colors.red),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startSlideshow(BuildContext context, PhotoProvider provider) {
    final photos = provider.approvedPhotos;
    if (photos.isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _LiveSlideshowScreen(photos: photos),
      ),
    );
  }
}

class _LiveSlideshowScreen extends StatefulWidget {
  final List<MemoryPhoto> photos;
  const _LiveSlideshowScreen({required this.photos});

  @override
  State<_LiveSlideshowScreen> createState() => _LiveSlideshowScreenState();
}

class _LiveSlideshowScreenState extends State<_LiveSlideshowScreen>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animController;
  int _currentIndex = 0;
  bool _paused = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..addListener(() {
        if (_animController.isCompleted) {
          _nextSlide();
        }
      });
    _animController.forward();
  }

  void _nextSlide() {
    if (_currentIndex < widget.photos.length - 1) {
      _currentIndex++;
    } else {
      _currentIndex = 0;
    }
    _pageController.animateToPage(
      _currentIndex,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
    _animController.reset();
    if (!_paused) _animController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.photos.isEmpty) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text('No photos',
              style: TextStyle(color: Colors.white)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () => setState(() => _paused = !_paused),
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              onPageChanged: (i) {
                setState(() => _currentIndex = i);
                _animController.reset();
                if (!_paused) _animController.forward();
              },
              itemCount: widget.photos.length,
              itemBuilder: (_, i) {
                final photo = widget.photos[i];
                return InteractiveViewer(
                  child: Image.network(
                    photo.imageUrl,
                    fit: BoxFit.contain,
                    width: double.infinity,
                    height: double.infinity,
                    loadingBuilder: (_, child, progress) {
                      if (progress == null) return child;
                      return const Center(
                        child: CircularProgressIndicator(
                            color: Colors.white),
                      );
                    },
                  ),
                );
              },
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              right: 16,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.close,
                      color: Colors.white, size: 24),
                ),
              ),
            ),
            Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Text(
                    widget.photos[_currentIndex].guestName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (widget.photos[_currentIndex].caption != null)
                    Text(
                      widget.photos[_currentIndex].caption!,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 13,
                      ),
                    ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      widget.photos.length > 20 ? 20 : widget.photos.length,
                      (i) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: _currentIndex == i ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentIndex == i
                              ? AppColors.primary
                              : Colors.white.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Icon(
                    _paused ? Icons.play_arrow : Icons.pause,
                    color: Colors.white.withValues(alpha: 0.5),
                    size: 28,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_currentIndex + 1} / ${widget.photos.length}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 12,
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
