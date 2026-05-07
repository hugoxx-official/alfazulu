import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../providers/app_provider.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;
  bool _showUnreadOnly = false;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    try {
      final provider = context.read<AppProvider>();
      final userId = provider.currentUser?.id;
      if (userId == null) return;

      final response = await http.get(
        Uri.parse('${AppProvider.apiUrl}/notifications?user_id=$userId${_showUnreadOnly ? '&unread_only=true' : ''}'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _notifications = (data['notifications'] as List)
              .map((n) => Map<String, dynamic>.from(n))
              .toList();
        });
      }
    } catch (e) {
      print('Error loading notifications: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _markAsRead(String id) async {
    try {
      await http.put(
        Uri.parse('${AppProvider.apiUrl}/notifications/$id/read'),
      );
      setState(() {
        final index = _notifications.indexWhere((n) => n['id'] == id);
        if (index != -1) {
          _notifications[index]['is_read'] = true;
        }
      });
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      final provider = context.read<AppProvider>();
      final userId = provider.currentUser?.id;
      if (userId == null) return;

      await http.put(
        Uri.parse('${AppProvider.apiUrl}/notifications/read-all'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_id': userId}),
      );

      setState(() {
        for (var n in _notifications) {
          n['is_read'] = true;
        }
      });
    } catch (e) {
      print('Error marking all as read: $e');
    }
  }

  Future<void> _deleteNotification(String id) async {
    try {
      await http.delete(
        Uri.parse('${AppProvider.apiUrl}/notifications/$id'),
      );
      setState(() {
        _notifications.removeWhere((n) => n['id'] == id);
      });
    } catch (e) {
      print('Error deleting notification: $e');
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'premium':
        return Colors.amber;
      case 'upload':
        return Colors.green;
      case 'admin':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'premium':
        return Icons.workspace_premium;
      case 'upload':
        return Icons.upload_file;
      case 'admin':
        return Icons.admin_panel_settings;
      default:
        return Icons.notifications;
    }
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _notifications.where((n) => !(n['is_read'] ?? true)).length;

    return Scaffold(
      appBar: AppBar(
        title: Text('NOTIFICACIONES', style: GoogleFonts.orbitron(letterSpacing: 2, color: Colors.red)),
        backgroundColor: Colors.black,
        actions: [
          if (unreadCount > 0)
            IconButton(
              icon: const Icon(Icons.done_all, color: Colors.red),
              onPressed: _markAllAsRead,
              tooltip: 'Marcar todas como leídas',
            ),
          IconButton(
            icon: Icon(
              _showUnreadOnly ? Icons.filter_alt_off : Icons.filter_alt,
              color: _showUnreadOnly ? Colors.amber : Colors.grey,
            ),
            onPressed: () {
              setState(() => _showUnreadOnly = !_showUnreadOnly);
              _loadNotifications();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.red))
          : _notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_none,
                        size: 80,
                        color: Colors.grey[700],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _showUnreadOnly
                            ? 'NO HAY NOTIFICACIONES SIN LEER'
                            : 'SIN NOTIFICACIONES',
                        style: GoogleFonts.orbitron(
                          fontSize: 14,
                          color: Colors.grey[600],
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadNotifications,
                  color: Colors.red,
                  backgroundColor: const Color(0xFF0A0A0A),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _notifications.length,
                    itemBuilder: (_, i) {
                      final notification = _notifications[i];
                      final isRead = notification['is_read'] ?? false;
                      final type = notification['type'] ?? 'info';
                      final createdAt = DateTime.tryParse(notification['created_at']);

                      return Dismissible(
                        key: Key(notification['id']),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 16),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.delete, color: Colors.red),
                        ),
                        onDismissed: (_) => _deleteNotification(notification['id']),
                        child: Card(
                          color: const Color(0xFF0A0A0A),
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: isRead
                                  ? const Color(0xFF222222)
                                  : _getTypeColor(type).withOpacity(0.5),
                              width: isRead ? 1 : 2,
                            ),
                          ),
                          child: InkWell(
                            onTap: () => _markAsRead(notification['id']),
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: _getTypeColor(type).withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: _getTypeColor(type).withOpacity(0.5),
                                      ),
                                    ),
                                    child: Icon(
                                      _getTypeIcon(type),
                                      color: _getTypeColor(type),
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                notification['title'] ?? 'Notificación',
                                                style: GoogleFonts.orbitron(
                                                  fontSize: 14,
                                                  fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                                                  color: isRead ? Colors.grey[500] : Colors.white,
                                                  letterSpacing: 1,
                                                ),
                                              ),
                                            ),
                                            if (!isRead)
                                              Container(
                                                width: 8,
                                                height: 8,
                                                decoration: BoxDecoration(
                                                  color: _getTypeColor(type),
                                                  shape: BoxShape.circle,
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: _getTypeColor(type).withOpacity(0.5),
                                                      blurRadius: 4,
                                                      spreadRadius: 1,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          notification['message'] ?? '',
                                          style: TextStyle(
                                            color: Colors.grey[400],
                                            fontSize: 12,
                                          ),
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        if (createdAt != null) ...[
                                          const SizedBox(height: 8),
                                          Text(
                                            _formatDate(createdAt),
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 10,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'Ahora';
    if (diff.inMinutes < 60) return 'hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'hace ${diff.inHours} h';
    if (diff.inDays < 7) return 'hace ${diff.inDays} días';

    final months = ['ENE', 'FEB', 'MAR', 'ABR', 'MAY', 'JUN', 'JUL', 'AGO', 'SEP', 'OCT', 'NOV', 'DIC'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
