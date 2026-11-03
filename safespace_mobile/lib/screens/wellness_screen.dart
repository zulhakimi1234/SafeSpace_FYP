import 'package:flutter/material.dart';

import '../models/wellness_model.dart';
import '../services/wellness_service.dart';
import 'wellness_detail_screen.dart';

class WellnessScreen extends StatefulWidget {
  const WellnessScreen({super.key});

  @override
  State<WellnessScreen> createState() => _WellnessScreenState();
}

class _WellnessScreenState extends State<WellnessScreen> {
  final _searchController = TextEditingController();

  List<WellnessResource> _resources = [];

  String _selectedType = 'all';
  String _searchTerm = '';
  String? _error;

  int _page = 0;
  int _total = 0;
  int _requestGeneration = 0;

  bool _hasMore = false;
  bool _isLoading = true;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _loadResources();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ======================================
  // LOAD RESOURCES FROM LARAVEL
  // ======================================
  Future<void> _loadResources({bool refresh = true}) async {
    if (!refresh && (_isLoading || _isLoadingMore || !_hasMore)) {
      return;
    }

    final generation = refresh ? ++_requestGeneration : _requestGeneration;

    final nextPage = refresh ? 1 : _page + 1;

    final type = _selectedType;
    final search = _searchTerm;

    setState(() {
      if (refresh) {
        _isLoading = true;
      } else {
        _isLoadingMore = true;
      }

      _error = null;
    });

    try {
      final result = await WellnessService.getResources(
        page: nextPage,
        type: type,
        search: search,
      );

      if (!mounted || generation != _requestGeneration) {
        return;
      }

      setState(() {
        if (refresh) {
          _resources = result.resources;
        } else {
          _resources.addAll(result.resources);
        }

        _page = result.currentPage;
        _hasMore = result.hasMore;
        _total = result.total;
      });
    } catch (e) {
      if (!mounted || generation != _requestGeneration) {
        return;
      }

      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted && generation == _requestGeneration) {
        setState(() {
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    }
  }

  // ======================================
  // SEARCH RESOURCES
  // ======================================
  void _applySearch() {
    FocusScope.of(context).unfocus();

    setState(() {
      _searchTerm = _searchController.text.trim();
    });

    _loadResources();
  }

  // ======================================
  // FILTER TYPE
  // ======================================
  void _changeType(String type) {
    if (_selectedType == type) return;

    setState(() {
      _selectedType = type;
    });

    _loadResources();
  }

  // ======================================
  // OPEN RESOURCE DETAILS
  // ======================================
  void _openResource(WellnessResource resource) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WellnessDetailScreen(resourceId: resource.id),
      ),
    );
  }

  // ======================================
  // RESOURCE CARD
  // ======================================
  Widget _buildResourceCard(WellnessResource resource) {
    final icon = resource.isArticle
        ? Icons.menu_book_outlined
        : Icons.lightbulb_outline_rounded;

    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _openResource(resource),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEE7F6),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, color: const Color(0xFF8E7AB5), size: 28),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          resource.title,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                            color: Color(0xFF333333),
                          ),
                        ),

                        const SizedBox(height: 5),

                        Text(
                          resource.categoryLabel,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFF8E7AB5),
                  ),
                ],
              ),

              if (resource.preview.isNotEmpty) ...[
                const SizedBox(height: 15),

                Text(
                  resource.preview,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF555555),
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],

              const SizedBox(height: 16),

              const Divider(height: 1, color: Color(0xFFF0EDF4)),

              const SizedBox(height: 13),

              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12,
                runSpacing: 8,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8DFF5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      resource.typeLabel,
                      style: const TextStyle(
                        color: Color(0xFF594780),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.access_time_rounded,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        resource.displayDate,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ======================================
  // FILTER BUTTON
  // ======================================
  Widget _filterChip(String label, String type) {
    return ChoiceChip(
      label: Text(label),
      selected: _selectedType == type,
      selectedColor: const Color(0xFFE8DFF5),
      onSelected: (_) {
        _changeType(type);
      },
    );
  }

  // ======================================
  // EMPTY STATE
  // ======================================
  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Column(
        children: [
          Icon(Icons.auto_stories_outlined, color: Color(0xFF8E7AB5), size: 50),

          SizedBox(height: 15),

          Text(
            'No wellness resources found.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),

          SizedBox(height: 8),

          Text(
            'Try another search or filter. Published resources will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ],
      ),
    );
  }

  // ======================================
  // MAIN WELLNESS SCREEN
  // ======================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6FC),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F6FC),
        title: const Text(
          'Wellness Resources',
          style: TextStyle(
            color: Color(0xFF594780),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh Resources',
            onPressed: () => _loadResources(),
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF594780)),
          ),
        ],
      ),

      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => _loadResources(),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(18),
            children: [
              // Welcome Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8E7AB5), Color(0xFFA992CF)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.favorite_border_rounded,
                      color: Colors.white,
                      size: 35,
                    ),

                    SizedBox(height: 12),

                    Text(
                      'A little care goes a long way 💜',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),

                    SizedBox(height: 9),

                    Text(
                      'Explore helpful articles and everyday wellness tips.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Search
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      maxLength: 100,
                      onSubmitted: (_) => _applySearch(),
                      decoration: InputDecoration(
                        hintText: 'Search resources...',
                        counterText: '',
                        prefixIcon: const Icon(Icons.search_rounded),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  IconButton.filled(
                    tooltip: 'Search',
                    onPressed: _applySearch,
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFF8E7AB5),
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.search_rounded),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              // Filter
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  _filterChip('All', 'all'),
                  _filterChip('Articles', 'article'),
                  _filterChip('Tips', 'tip'),
                ],
              ),

              const SizedBox(height: 20),

              if (!_isLoading && _error == null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 13),
                  child: Text(
                    '$_total resources found',
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ),

              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.all(35),
                  child: Center(child: CircularProgressIndicator()),
                ),

              if (_error != null) ...[
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                ),

                Center(
                  child: TextButton(
                    onPressed: () => _loadResources(),
                    child: const Text('Try Again'),
                  ),
                ),

                const SizedBox(height: 15),
              ],

              if (!_isLoading && _error == null) ...[
                if (_resources.isEmpty) _buildEmptyState(),

                ..._resources.map(_buildResourceCard),

                if (_hasMore)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: OutlinedButton(
                        onPressed: _isLoadingMore
                            ? null
                            : () => _loadResources(refresh: false),
                        child: _isLoadingMore
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Load More Resources'),
                      ),
                    ),
                  ),
              ],

              const SizedBox(height: 25),

              const Text(
                'Wellness resources are for general information and do not replace professional medical advice.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey, height: 1.5),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
