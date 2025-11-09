import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/app_providers.dart';
import '../../core/config.dart';

class SearchPage extends ConsumerStatefulWidget {
  final String? initialQuery;
  const SearchPage({Key? key, this.initialQuery}) : super(key: key);

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _searchQuery = '';
  bool _isMapView = false;
  List<String> _recentSearches = [];
  double _scrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
    _scrollController.addListener(_onScroll);
    // Apply initial query if provided
    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      _searchController.text = widget.initialQuery!;
      _performSearch(widget.initialQuery!);
    }
  }

  void _onScroll() {
    if (!mounted) return;
    final offset = _scrollController.offset;
    if ((offset - _scrollOffset).abs() > 1) {
      setState(() {
        _scrollOffset = offset;
      });
    }
  }

  Future<void> _loadRecentSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final searches = prefs.getStringList('recent_searches') ?? [];
      setState(() {
        _recentSearches = searches;
      });
    } catch (e) {
      // Silently handle error
    }
  }

  Future<void> _saveRecentSearch(String query) async {
    if (query.isEmpty) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final searches = List<String>.from(_recentSearches);

      searches.remove(query);
      searches.insert(0, query);
      if (searches.length > 10) {
        searches.removeRange(10, searches.length);
      }

      await prefs.setStringList('recent_searches', searches);
      setState(() {
        _recentSearches = searches;
      });
    } catch (e) {
      // Silently handle error
    }
  }

  void _performSearch(String query) {
    if (query.isNotEmpty) {
      _saveRecentSearch(query);
    }
    setState(() {
      _searchQuery = query;
    });
  }

  Widget _buildMedicineCard(dynamic medicine) {
    final isWide = MediaQuery.of(context).size.width > 600;
    final name = medicine.name_en ?? medicine.name_te ?? 'Unknown';

    return Card(
      margin: EdgeInsets.symmetric(
        horizontal: isWide ? 24.0 : 16.0,
        vertical: 6.0,
      ),
      elevation: 6,
      shadowColor: Colors.black.withValues(alpha: 0.25),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, const Color(0xFFF8F9FA)],
          ),
        ),
        child: InkWell(
          onTap: () => _showMedicineDetails(medicine),
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF007BFF).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.medication,
                    color: Color(0xFF007BFF),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              letterSpacing: 0.2,
                            ),
                      ),
                      const SizedBox(height: 2),
                      if (medicine.description != null)
                        Text(
                          medicine.description!,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                                fontSize: 14,
                              ),
                        ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: Color(0xFF9CA3AF),
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showMedicineDetails(dynamic medicine) {
    final name = medicine.name_en ?? medicine.name_te ?? 'Unknown';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: EdgeInsets.all(
            MediaQuery.of(context).size.width > 600 ? 24.0 : 16.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(name, style: Theme.of(context).textTheme.titleLarge),
              if (medicine.description != null) ...[
                const SizedBox(height: 8),
                Text(
                  medicine.description!,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/map');
                  },
                  icon: const Icon(Icons.store),
                  label: Text(
                    'Find Nearby Stores',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 6,
      shadowColor: color.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, color.withValues(alpha: 0.05)],
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [color, color.withValues(alpha: 0.8)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 28),
                ),
                const SizedBox(height: 12),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1F2937),
                    height: 1.3,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchView() {
    final isWide = MediaQuery.of(context).size.width > 600;

    return Column(
      children: [
        // Environment banner (backend + AI) for clarity in non-release or when overridden.
        _EnvironmentBanner(),
        Container(
          margin: EdgeInsets.all(isWide ? 24.0 : 16.0),
          child: SearchBar(
            controller: _searchController,
            hintText: 'Search medicines...',
            hintStyle: WidgetStateProperty.all(
              Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            textStyle: WidgetStateProperty.all(
              Theme.of(context).textTheme.bodyMedium,
            ),
            leading: Icon(
              Icons.search,
              color: const Color(0xFF007BFF),
              size: 24,
            ),
            trailing: [
              if (_searchController.text.isNotEmpty)
                IconButton(
                  onPressed: () {
                    _searchController.clear();
                    _performSearch('');
                  },
                  icon: const Icon(Icons.clear),
                  tooltip: 'Clear',
                )
              else
                IconButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Voice search feature coming soon!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  icon: const Icon(Icons.mic),
                  tooltip: 'Voice Search',
                  color: const Color(0xFF007BFF),
                ),
            ],
            onChanged: _performSearch,
            padding: WidgetStateProperty.all(
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),

        if (_searchController.text.isEmpty) ...[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isWide ? 24.0 : 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quick Actions',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildQuickActionCard(
                        icon: Icons.store,
                        label: 'Nearest\nStores',
                        color: const Color(0xFF007BFF),
                        onTap: () {
                          Navigator.pushNamed(context, '/map');
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildQuickActionCard(
                        icon: Icons.check_circle,
                        label: 'Available\nNow',
                        color: const Color(0xFF4CAF50),
                        onTap: () {
                          setState(() {
                            _isMapView = true;
                          });
                          Navigator.pushNamed(context, '/map');
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildQuickActionCard(
                        icon: Icons.auto_awesome,
                        label: 'AI\nSearch',
                        color: const Color(0xFF8B5CF6),
                        onTap: () {
                          Navigator.pushNamed(context, '/ai-search');
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],

        Expanded(
          child: Consumer(
            builder: (context, ref, _) {
              final medicinesAsync = ref.watch(
                medicineSearchProvider(_searchQuery),
              );

              return medicinesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stackTrace) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: isWide ? 80 : 64,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading medicines',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: Theme.of(context).colorScheme.error,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        error.toString(),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                data: (medicines) {
                  if (medicines.isEmpty && _searchController.text.isNotEmpty) {
                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.25,
                        ),
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: isWide ? 80 : 64,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No medicines found',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Try searching with different keywords',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(medicineSearchProvider(_searchQuery));
                    },
                    color: const Color(0xFF007BFF),
                    child: ListView.builder(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: medicines.length,
                      itemBuilder: (context, index) {
                        return _buildMedicineCard(medicines[index]);
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isMapView ? 'Nearby Pharmacies' : 'Find Medicines',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        leading: _isMapView
            ? IconButton(
                onPressed: () {
                  setState(() {
                    _isMapView = false;
                  });
                },
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              )
            : null,
        actions: [
          if (!_isMapView) ...[
            IconButton(
              onPressed: () {
                Navigator.pushNamed(context, '/map');
              },
              icon: const Icon(Icons.map, color: Colors.white),
              tooltip: 'Map View',
            ),
          ],
        ],
        backgroundColor: const Color(0xFF007BFF),
        elevation: 2,
      ),
      body: Column(children: [Expanded(child: _buildSearchView())]),
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

/// Small pinned banner showing which backend & AI service the app is talking to.
/// Helps during debugging and when switching between local, LAN, and hosted services.
class _EnvironmentBanner extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final backend = ApiConfig.baseUrl;
    final ai = ApiConfig.aiBaseUrl;
    final isRelease = bool.fromEnvironment('dart.vm.product');

    // Hide banner in pure release mode unless user provided explicit overrides.
    final hasOverride =
        const String.fromEnvironment('BACKEND_BASE_URL').isNotEmpty ||
        const String.fromEnvironment('AI_BASE_URL').isNotEmpty;
    if (isRelease && !hasOverride) return const SizedBox.shrink();

    Color pickColor(String url) {
      if (url.contains('hf.space'))
        return const Color(0xFF2563EB); // Production (blue)
      if (url.contains('10.0.2.2') || url.contains('localhost'))
        return const Color(0xFF6B7280); // Local (gray)
      return const Color(0xFFF59E0B); // LAN / custom (amber)
    }

    Widget pill(String label, String url, {Widget? trailing}) {
      final color = pickColor(url);
      return Container(
        margin: const EdgeInsets.only(right: 8, bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              label == 'Backend' ? Icons.cloud_outlined : Icons.auto_awesome,
              size: 14,
              color: color,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                url.replaceAll(RegExp(r'^https?://'), ''),
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  color: color.withValues(alpha: 0.85),
                ),
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 6),
              trailing,
            ],
          ],
        ),
      );
    }

    // AI Health indicator LED
    final aiHealth = ref.watch(aiHealthProvider);
    final aiIndicator = aiHealth.when(
      data: (ok) => _LedDot(
        color: ok ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
        tooltip: ok ? 'AI: Healthy' : 'AI: Unreachable',
      ),
      loading: () => const _LedDot(color: Color(0xFFF59E0B), tooltip: 'AI: Checking...'),
      error: (e, _) => const _LedDot(color: Color(0xFFDC2626), tooltip: 'AI: Error'),
    );

    return Material(
      color: Colors.transparent,
      child: Align(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: const EdgeInsets.only(left: 12, right: 12, top: 8),
          child: Wrap(
            runSpacing: 4,
            children: [
              pill('Backend', backend),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => ref.invalidate(aiHealthProvider),
                child: pill('AI', ai, trailing: aiIndicator),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LedDot extends StatelessWidget {
  final Color color;
  final String tooltip;
  const _LedDot({required this.color, required this.tooltip});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.45),
              blurRadius: 6,
              spreadRadius: 0.5,
            ),
          ],
        ),
      ),
    );
  }
}
