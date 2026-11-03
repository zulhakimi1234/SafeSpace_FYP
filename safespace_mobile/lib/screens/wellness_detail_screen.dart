import 'package:flutter/material.dart';

import '../models/wellness_model.dart';
import '../services/wellness_service.dart';

class WellnessDetailScreen extends StatefulWidget {
  final int resourceId;

  const WellnessDetailScreen({super.key, required this.resourceId});

  @override
  State<WellnessDetailScreen> createState() => _WellnessDetailScreenState();
}

class _WellnessDetailScreenState extends State<WellnessDetailScreen> {
  late Future<WellnessResource> _resourceFuture;

  @override
  void initState() {
    super.initState();

    _loadResource();
  }

  void _loadResource() {
    _resourceFuture = WellnessService.getResource(widget.resourceId);
  }

  void _retry() {
    setState(() {
      _loadResource();
    });
  }

  // ======================================
  // RESOURCE CONTENT
  // ======================================
  Widget _buildContent(WellnessResource resource) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 650),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category and type
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Chip(
                    backgroundColor: const Color(0xFFE8DFF5),
                    side: BorderSide.none,
                    label: Text(
                      resource.typeLabel,
                      style: const TextStyle(
                        color: Color(0xFF594780),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  Chip(label: Text(resource.categoryLabel)),
                ],
              ),

              const SizedBox(height: 22),

              // Resource title
              Text(
                resource.title,
                style: const TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF594780),
                  height: 1.3,
                ),
              ),

              const SizedBox(height: 14),

              Row(
                children: [
                  const Icon(
                    Icons.update_rounded,
                    size: 17,
                    color: Colors.grey,
                  ),

                  const SizedBox(width: 7),

                  Expanded(
                    child: Text(
                      'Last updated: ${resource.displayDate}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Full article or tip
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: SelectableText(
                  resource.content,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.75,
                    color: Color(0xFF444444),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Wellness reminder
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8DFF5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.favorite_outline_rounded,
                      color: Color(0xFF594780),
                    ),

                    SizedBox(width: 12),

                    Expanded(
                      child: Text(
                        'Remember to be kind to yourself. Progress takes time, and every small step matters.',
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.5,
                          color: Color(0xFF594780),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'This content provides general wellness information and is not a substitute for professional medical or mental health care.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey, height: 1.5),
              ),

              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: const Text('Back to Wellness Resources'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
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

  // ======================================
  // MAIN DETAIL SCREEN
  // ======================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6FC),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F6FC),
        title: const Text(
          'Wellness Reading',
          style: TextStyle(
            color: Color(0xFF594780),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SafeArea(
        child: FutureBuilder<WellnessResource>(
          future: _resourceFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(25),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        color: Colors.redAccent,
                        size: 45,
                      ),

                      const SizedBox(height: 15),

                      Text('${snapshot.error}', textAlign: TextAlign.center),

                      const SizedBox(height: 18),

                      FilledButton(
                        onPressed: _retry,
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (!snapshot.hasData) {
              return const Center(
                child: Text('Wellness resource unavailable.'),
              );
            }

            return _buildContent(snapshot.data!);
          },
        ),
      ),
    );
  }
}
