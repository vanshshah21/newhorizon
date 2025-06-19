// import 'package:flutter/material.dart';
// import '../models/notification_notification.dart';

// class NotificationCard extends StatelessWidget {
//   final Notificationnotification notification;

//   const NotificationCard({required this.notification, Key? key})
//     : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       color: notification.markasread ? Colors.grey[200] : Colors.white,
//       margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       child: ListTile(
//         leading: Icon(
//           notification.markasread
//               ? Icons.notifications_none
//               : Icons.notifications,
//           color: notification.markasread ? Colors.grey : Colors.blue,
//         ),
//         title: Text(
//           notification.xntmsgdesC1,
//           style: const TextStyle(fontWeight: FontWeight.bold),
//         ),
//         subtitle: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(notification.xntmsgdesC2),
//             if (notification.xntmsgdesC3.isNotEmpty)
//               Text(notification.xntmsgdesC3),
//             const SizedBox(height: 4),
//             Text(
//               '${notification.fullDate} • ${notification.time}',
//               style: const TextStyle(fontSize: 12, color: Colors.grey),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import '../models/notification_item.dart';

// class NotificationCard extends StatelessWidget {
//   final NotificationItem notification;

//   const NotificationCard({super.key, required this.notification});

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 1,
//       margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
//       child: InkWell(
//         onTap: () {},
//         borderRadius: BorderRadius.circular(12.0),
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Leading Icon (choose an icon that fits your context)
//               Icon(
//                 Icons.notifications, // Default icon
//                 size: 28.0,
//               ),
//               const SizedBox(width: 16.0),
//               // Main content column
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Title
//                     Text(
//                       notification.xntmsgdesC1,
//                       style: const TextStyle(fontWeight: FontWeight.bold),
//                     ),
//                     const SizedBox(height: 4.0),
//                     // Message
//                     Text(
//                       notification.xntmsgdesC2,
//                       maxLines: 3,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     const SizedBox(height: 10.0),
//                     // Bottom Row: Sender & Timestamp
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         // Sender
//                         Text(notification.xntdoccrusrcd),
//                         // Timestamp
//                         Text(notification.fullDate),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(width: 8.0),
//               // Trailing Unread Indicator Dot
//               if (!notification.markasread)
//                 Padding(
//                   padding: const EdgeInsets.only(top: 4.0),
//                   child: CircleAvatar(radius: 5),
//                 )
//               else
//                 const SizedBox(width: 10),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

//---------------------------------------------------------------------------------------------
import 'package:flutter/material.dart';
import '../models/notification_item.dart';

class NotificationCard extends StatelessWidget {
  final NotificationItem notification;
  final VoidCallback? onMarkAsRead;
  final VoidCallback? onDelete;

  const NotificationCard({
    super.key,
    required this.notification,
    this.onMarkAsRead,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isUnread = !notification.markasread;
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      color: isUnread ? Colors.blue.shade50 : null,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              isUnread ? Icons.notifications_active : Icons.notifications_none,
              size: 28.0,
              color: isUnread ? Colors.blue : Colors.grey,
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.xntmsgdesC1,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isUnread ? Colors.black : Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    notification.xntmsgdesC2,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(notification.xntdoccrusrcd),
                      Text(notification.fullDate),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8.0),
            // Mark as Read Button
            if (isUnread)
              IconButton(
                icon: const Icon(Icons.mark_email_read_outlined),
                tooltip: 'Mark as Read',
                onPressed: onMarkAsRead,
              ),
            // Delete Button
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Delete',
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
