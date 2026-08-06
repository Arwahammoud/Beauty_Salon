// Turns an ISO-8601 timestamp from the backend into a short "2 min ago"
// style label for display.
String relativeTime(String isoDate) {
  final date = DateTime.tryParse(isoDate);
  if (date == null) return '';
  final diff = DateTime.now().difference(date);
  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
  if (diff.inHours < 24) return '${diff.inHours} hr ago';
  if (diff.inDays == 1) return 'Yesterday';
  return '${diff.inDays} days ago';
}
