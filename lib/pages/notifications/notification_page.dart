// import 'package:flutter/material.dart';
// import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
// import 'package:nhapp/pages/notifications/models/notification_item.dart';
// import 'package:nhapp/pages/notifications/services/notification_service.dart';
// import 'package:nhapp/pages/notifications/widgets/notification_card.dart';

// class NotificationListPage extends StatefulWidget {
//   const NotificationListPage({Key? key}) : super(key: key);

//   @override
//   State<NotificationListPage> createState() => _NotificationListPageState();
// }

// class _NotificationListPageState extends State<NotificationListPage>
//     with AutomaticKeepAliveClientMixin<NotificationListPage> {
//   static const _pageSize = 10;
//   late final PagingController<int, NotificationItem> _pagingController;
//   final NotificationService _service = NotificationService();

//   @override
//   void initState() {
//     super.initState();
//     _pagingController = PagingController<int, NotificationItem>(
//       getNextPageKey: (state) => (state.keys?.last ?? 0) + 1,
//       fetchPage: (pageKey) async {
//         try {
//           final newItems = await _service.fetchNotificationsPaged(
//             page: pageKey,
//             pageSize: _pageSize,
//           );
//           if (!mounted) return [];
//           return newItems;
//         } catch (error) {
//           if (!mounted) return [];
//           rethrow;
//         }
//       },
//     );
//   }

//   @override
//   void dispose() {
//     _pagingController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     super.build(context); // for AutomaticKeepAliveClientMixin
//     return Scaffold(
//       appBar: AppBar(title: const Text('Notifications')),
//       body: PagingListener<int, NotificationItem>(
//         controller: _pagingController,
//         builder:
//             (context, state, fetchNextPage) =>
//                 PagedListView<int, NotificationItem>(
//                   state: state,
//                   fetchNextPage: fetchNextPage,
//                   builderDelegate: PagedChildBuilderDelegate<NotificationItem>(
//                     itemBuilder:
//                         (context, notification, index) =>
//                             NotificationCard(notification: notification),
//                     noItemsFoundIndicatorBuilder:
//                         (context) => const Center(
//                           child: Text('No notifications found.'),
//                         ),
//                     firstPageErrorIndicatorBuilder:
//                         (context) => const Center(
//                           child: Text('Error loading notifications.'),
//                         ),
//                   ),
//                 ),
//       ),
//     );
//   }

//   @override
//   bool get wantKeepAlive => true;
// }

//--------------------------------------------------------------------------------------------------------

// import 'package:flutter/material.dart';
// import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
// import 'package:nhapp/pages/notifications/models/notification_item.dart';
// import 'package:nhapp/pages/notifications/services/notification_service.dart';
// import 'package:nhapp/pages/notifications/widgets/notification_card.dart';

// class NotificationListPage extends StatefulWidget {
//   const NotificationListPage({super.key});

//   @override
//   State<NotificationListPage> createState() => _NotificationListPageState();
// }

// class _NotificationListPageState extends State<NotificationListPage>
//     with AutomaticKeepAliveClientMixin<NotificationListPage> {
//   static const _pageSize = 20;
//   late final PagingController<int, NotificationItem> _pagingController;
//   final NotificationService _service = NotificationService();
//   final TextEditingController _searchController = TextEditingController();
//   String? _currentSearchValue;

//   @override
//   void initState() {
//     super.initState();
//     _pagingController = PagingController<int, NotificationItem>(
//       getNextPageKey: (state) => (state.keys?.last ?? 0) + 1,
//       fetchPage: (pageKey) async {
//         try {
//           final newItems = await _service.fetchNotificationsPaged(
//             page: pageKey,
//             pageSize: _pageSize,
//             searchValue: _currentSearchValue,
//           );
//           if (!mounted) return [];
//           return newItems;
//         } catch (error) {
//           if (!mounted) return [];
//           rethrow;
//         }
//       },
//     );
//   }

//   void _onSearch() {
//     setState(() {
//       _currentSearchValue =
//           _searchController.text.trim().isEmpty
//               ? null
//               : _searchController.text.trim();
//       _pagingController.refresh();
//     });
//   }

//   @override
//   void dispose() {
//     _pagingController.dispose();
//     _searchController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     super.build(context); // for AutomaticKeepAliveClientMixin
//     return Scaffold(
//       appBar: AppBar(title: const Text('Notifications')),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _searchController,
//                     decoration: const InputDecoration(
//                       labelText: 'Search',
//                       border: OutlineInputBorder(),
//                     ),
//                     onTapOutside: (event) {
//                       FocusScope.of(context).unfocus();
//                     },
//                     onSubmitted: (_) => _onSearch(),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 IconButton.filled(
//                   onPressed: () {
//                     FocusScope.of(context).unfocus();
//                     _onSearch();
//                   },
//                   icon: const Icon(Icons.search),
//                 ),
//               ],
//             ),
//           ),
//           Expanded(
//             child: PagingListener<int, NotificationItem>(
//               controller: _pagingController,
//               builder:
//                   (context, state, fetchNextPage) =>
//                       PagedListView<int, NotificationItem>(
//                         state: state,
//                         fetchNextPage: fetchNextPage,
//                         builderDelegate:
//                             PagedChildBuilderDelegate<NotificationItem>(
//                               itemBuilder:
//                                   (context, notification, index) =>
//                                       NotificationCard(
//                                         notification: notification,
//                                       ),
//                               noItemsFoundIndicatorBuilder:
//                                   (context) => const Center(
//                                     child: Text('No notifications found.'),
//                                   ),
//                               firstPageErrorIndicatorBuilder:
//                                   (context) => const Center(
//                                     child: Text('Error loading notifications.'),
//                                   ),
//                             ),
//                       ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   bool get wantKeepAlive => true;
// }

//--------------------------------------------------------------------------------------------------
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:nhapp/pages/notifications/models/notification_item.dart';
import 'package:nhapp/pages/notifications/services/notification_service.dart';
import 'package:nhapp/pages/notifications/widgets/notification_card.dart';

class NotificationListPage extends StatefulWidget {
  const NotificationListPage({super.key});

  @override
  State<NotificationListPage> createState() => _NotificationListPageState();
}

class _NotificationListPageState extends State<NotificationListPage>
    with AutomaticKeepAliveClientMixin<NotificationListPage> {
  static const _pageSize = 20;
  late final PagingController<int, NotificationItem> _pagingController;
  final NotificationService _service = NotificationService();
  final TextEditingController _searchController = TextEditingController();
  String? _currentSearchValue;

  @override
  void initState() {
    super.initState();
    _pagingController = PagingController<int, NotificationItem>(
      getNextPageKey: (state) => (state.keys?.last ?? 0) + 1,
      fetchPage: (pageKey) async {
        try {
          final newItems = await _service.fetchNotificationsPaged(
            page: pageKey,
            pageSize: _pageSize,
            searchValue: _currentSearchValue,
          );
          if (!mounted) return [];
          return newItems;
        } catch (error) {
          if (!mounted) return [];
          rethrow;
        }
      },
    );
  }

  void _onSearch() {
    setState(() {
      _currentSearchValue =
          _searchController.text.trim().isEmpty
              ? null
              : _searchController.text.trim();
      _pagingController.refresh();
    });
  }

  Future<void> _markAsRead(NotificationItem notification) async {
    final index = _pagingController.items?.indexWhere(
      (item) => item.xntautoid == notification.xntautoid,
    );
    if (index == null || index == -1) return;

    // Optimistically update UI
    setState(() {
      _pagingController.items![index] = NotificationItem(
        markasread: true,
        xntautoid: notification.xntautoid,
        xnummenuname: notification.xnummenuname,
        xntmsgdesC1: notification.xntmsgdesC1,
        xntmsgdesC2: notification.xntmsgdesC2,
        xntmsgdesC3: notification.xntmsgdesC3,
        userId: notification.userId,
        xntdoccrusrcd: notification.xntdoccrusrcd,
        xntdoccrusrdt: notification.xntdoccrusrdt,
        xnumformid: notification.xnumformid,
        xntdocid: notification.xntdocid,
        totalRows: notification.totalRows,
        fullDate: notification.fullDate,
        time: notification.time,
        docno: notification.docno,
      );
    });

    try {
      final success = await _service.markAsRead(
        notificationId: notification.xntautoid,
      );
      if (!success) {
        // Revert if failed
        setState(() {
          _pagingController.items![index] = notification;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to mark as read')));
      }
    } catch (e) {
      // Revert if error
      setState(() {
        _pagingController.items![index] = notification;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Error marking as read')));
    }
  }

  Future<void> _deleteNotification(NotificationItem notification) async {
    final index = _pagingController.items?.indexWhere(
      (item) => item.xntautoid == notification.xntautoid,
    );
    if (index == null || index == -1) return;

    // Optimistically remove from UI
    final removed = _pagingController.items!.removeAt(index);
    setState(() {});

    try {
      final success = await _service.deleteNotification(
        notificationId: notification.xntautoid,
      );
      if (!success) {
        // Revert if failed
        _pagingController.items!.insert(index, removed);
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete notification')),
        );
      }
    } catch (e) {
      // Revert if error
      _pagingController.items!.insert(index, removed);
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error deleting notification')),
      );
    }
  }

  @override
  void dispose() {
    _pagingController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // for AutomaticKeepAliveClientMixin
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Search',
                      border: OutlineInputBorder(),
                    ),
                    onTapOutside: (event) {
                      FocusScope.of(context).unfocus();
                    },
                    onSubmitted: (_) => _onSearch(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    _onSearch();
                  },
                  icon: const Icon(Icons.search),
                ),
              ],
            ),
          ),
          Expanded(
            child: PagingListener<int, NotificationItem>(
              controller: _pagingController,
              builder:
                  (context, state, fetchNextPage) =>
                      PagedListView<int, NotificationItem>(
                        state: state,
                        fetchNextPage: fetchNextPage,
                        builderDelegate:
                            PagedChildBuilderDelegate<NotificationItem>(
                              itemBuilder:
                                  (
                                    context,
                                    notification,
                                    index,
                                  ) => NotificationCard(
                                    notification: notification,
                                    onMarkAsRead:
                                        notification.markasread
                                            ? null
                                            : () => _markAsRead(notification),
                                    onDelete:
                                        () => _deleteNotification(notification),
                                  ),
                              noItemsFoundIndicatorBuilder:
                                  (context) => const Center(
                                    child: Text('No notifications found.'),
                                  ),
                              firstPageErrorIndicatorBuilder:
                                  (context) => const Center(
                                    child: Text('Error loading notifications.'),
                                  ),
                            ),
                      ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
