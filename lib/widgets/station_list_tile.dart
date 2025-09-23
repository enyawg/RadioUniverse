import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/station.dart';

class StationListTile extends StatelessWidget {
  final Station station;
  final VoidCallback onTap;
  final Widget? trailing;

  const StationListTile({
    super.key,
    required this.station,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 56,
          height: 56,
          child: station.logoUrl != null
              ? CachedNetworkImage(
                  imageUrl: station.logoUrl!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                  errorWidget: (context, url, error) => _buildDefaultImage(context),
                )
              : _buildDefaultImage(context),
        ),
      ),
      title: Text(
        station.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                switch (station.contentType) {
                  ContentType.radio => Icons.radio,
                  ContentType.podcast => Icons.mic,
                  ContentType.stream => Icons.stream,
                },
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 4),
              Text(
                station.contentType.name.toUpperCase(),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              if (station.genre != null || station.country != null) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    [station.genre, station.country]
                        .where((e) => e != null)
                        .join(' • '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ],
          ),
          if (station.host != null)
            Text(
              'Host: ${station.host}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }

  Widget _buildDefaultImage(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Icon(
        Icons.radio,
        size: 24,
        color: Theme.of(context).colorScheme.onPrimaryContainer,
      ),
    );
  }
}