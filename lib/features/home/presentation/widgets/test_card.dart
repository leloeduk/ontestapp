import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../test/domain/entities/test_app.dart';

/// Carte d'une application à tester.
class TestCard extends StatelessWidget {
  const TestCard({super.key, required this.test, required this.onTap});

  final TestApp test;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: test.iconUrl,
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    width: 56,
                    height: 56,
                    color: Colors.grey.shade200,
                  ),
                  errorWidget: (_, __, ___) => Container(
                    width: 56,
                    height: 56,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.apps),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      test.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    if (test.category.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          test.category,
                          style: TextStyle(
                            color: colors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    Text(
                      test.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '+${test.points}',
                  style: TextStyle(
                    color: colors.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
