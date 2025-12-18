import 'package:flutter/material.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import 'package:photo_manager/photo_manager.dart';
import '../helpers/media_permission.dart';
import '../videopage/video_player_page.dart';
import '../audiopage/audio_player_page.dart';

enum LocalMediaType { video, audio }

class LocalMedia {
  final LocalMediaType type;
  final AssetEntity asset;

  LocalMedia({required this.type, required this.asset});
}

class SearchLocalPage extends StatefulWidget {
  const SearchLocalPage({super.key});

  @override
  State<SearchLocalPage> createState() => _SearchLocalPageState();
}

class _SearchLocalPageState extends State<SearchLocalPage> {
  final TextEditingController _searchController = TextEditingController();

  List<LocalMedia> _allMedia = [];
  List<LocalMedia> _filteredMedia = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    loadLocalMedia();
    _searchController.addListener(_filter);
  }

  Future<void> loadLocalMedia() async {
    final granted = await requestMediaPermission();
    if (!granted) return;

    final videoAlbums = await PhotoManager.getAssetPathList(
      type: RequestType.video,
    );
    final audioAlbums = await PhotoManager.getAssetPathList(
      type: RequestType.audio,
    );

    final List<LocalMedia> results = [];

    if (videoAlbums.isNotEmpty) {
      final videos = await videoAlbums.first.getAssetListPaged(
        page: 0,
        size: 300,
      );
      results.addAll(
        videos.map((v) => LocalMedia(type: LocalMediaType.video, asset: v)),
      );
    }

    if (audioAlbums.isNotEmpty) {
      final audios = await audioAlbums.first.getAssetListPaged(
        page: 0,
        size: 300,
      );
      results.addAll(
        audios.map((a) => LocalMedia(type: LocalMediaType.audio, asset: a)),
      );
    }

    if (mounted) {
      setState(() {
        _allMedia = results;
        _filteredMedia = results;
        _isLoading = false;
      });
    }
  }

  void _filter() {
    final q = _searchController.text.toLowerCase();

    setState(() {
      _filteredMedia = _allMedia.where((m) {
        final title = m.asset.title?.toLowerCase() ?? '';
        return title.contains(q);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromARGB(255, 54, 45, 94),
      child: Column(
        children: [
          // SEARCH BOX
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Cari video atau audio lokal...',
                hintStyle: const TextStyle(color: Colors.white54),
                prefixIcon: const Icon(Icons.search, color: Colors.white54),
                filled: true,
                fillColor: const Color.fromARGB(255, 89, 85, 155),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // LIST
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredMedia.isEmpty
                    ? const Center(
                        child: Text(
                          'Tidak ada media',
                          style: TextStyle(color: Colors.white54),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _filteredMedia.length,
                        itemBuilder: (context, index) {
                          final item = _filteredMedia[index];

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                              leading: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: item.type == LocalMediaType.video
                                        ? AssetEntityImage(
                                            item.asset,
                                            width: 80,
                                            height: 80,
                                            fit: BoxFit.cover,
                                            isOriginal: false,
                                            thumbnailSize: const ThumbnailSize(200, 200),
                                            errorBuilder: (_, __, ___) => _fallbackCover(item),
                                          )
                                        : _fallbackCover(item),
                                  ),
                                  Positioned(
                                    bottom: 4,
                                    right: 4,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.black54,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        item.type == LocalMediaType.video
                                            ? Icons.videocam
                                            : Icons.audiotrack,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              title: Text(
                                item.asset.title ?? 'Unknown',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              onTap: () {
                                // --- FIX: Menyesuaikan parameter List dan Index ---
                                if (item.type == LocalMediaType.video) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => VideoPlayerPage(
                                        videoList: [item.asset], // Diubah ke List
                                        initialIndex: 0,         // Ditambahkan Index
                                      ),
                                    ),
                                  );
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => AudioPlayerPage(
                                        audioList: [item.asset], // Diubah ke List
                                        initialIndex: 0,         // Ditambahkan Index
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _fallbackCover(LocalMedia item) {
    final title = item.asset.title ?? 'M';

    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: const LinearGradient(
          colors: [Color(0xFF6A5AE0), Color(0xFF9F8CFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          title.isNotEmpty ? title[0].toUpperCase() : 'M',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}