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

// import 'package:flutter/material.dart';
// import '../models/notification_item.dart';

// class NotificationCard extends StatelessWidget {
//   final NotificationItem notification;
//   final VoidCallback? onMarkAsRead;
//   final VoidCallback? onDelete;

//   const NotificationCard({
//     super.key,
//     required this.notification,
//     this.onMarkAsRead,
//     this.onDelete,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final isUnread = !notification.markasread;
//     return Card(
//       margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//       shape:
//           isUnread
//               ? RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12.0),
//               )
//               : null,
//       color: isUnread ? Colors.blue.shade50 : null,
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Icon(
//               isUnread ? Icons.notifications_active : Icons.notifications_none,
//               size: 28.0,
//               color: isUnread ? Colors.blue : Colors.grey,
//             ),
//             const SizedBox(width: 16.0),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     notification.xntmsgdesC1,
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       color: isUnread ? Colors.black : Colors.grey[700],
//                     ),
//                   ),
//                   const SizedBox(height: 4.0),
//                   Text(
//                     notification.xntmsgdesC2,
//                     maxLines: 3,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                   const SizedBox(height: 10.0),
//                   Column(
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text("From: ${notification.xntdoccrusrcd}"),
//                       Text("Date: ${notification.fullDate}"),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(width: 8.0),
//             // Mark as Read Button
//             if (isUnread)
//               IconButton(
//                 icon: const Icon(Icons.mark_email_read_outlined),
//                 tooltip: 'Mark as Read',
//                 onPressed: onMarkAsRead,
//               ),
//             // Delete Button
//             IconButton(
//               icon: const Icon(Icons.delete_outline),
//               tooltip: 'Delete',
//               onPressed: onDelete,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

//----------------------------------------------------------------------------------------

// import 'package:flutter/material.dart';
// import 'package:nhapp/pages/notifications/models/notification_item.dart';

// class NotificationCard extends StatelessWidget {
//   final NotificationItem notification;
//   final VoidCallback? onMarkAsRead;
//   final VoidCallback? onDelete;
//   //final VoidCallback? onTap; // Added an onTap callback for the whole card

//   const NotificationCard({
//     super.key,
//     required this.notification,
//     this.onMarkAsRead,
//     this.onDelete,
//     //this.onTap, // Initialize onTap
//   });

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final bool isUnread = !notification.markasread;

//     // Determine colors and text styles based on read status and theme
//     final Color cardBackgroundColor =
//         isUnread
//             ? theme.brightness == Brightness.light
//                 ? Colors
//                     .blue
//                     .shade50 // Light blue for unread in light mode
//                 : theme
//                     .colorScheme
//                     .surface // Use theme surface for unread in dark mode
//             : theme.cardColor; // Use theme's card color for read notifications

//     final Color primaryTextColor =
//         isUnread
//             ? theme
//                 .colorScheme
//                 .onSurface // Use theme's onSurface for unread
//             : theme.textTheme.bodyMedium?.color ??
//                 Colors.grey.shade700; // Default or greyed out for read

//     final Color secondaryTextColor =
//         isUnread
//             ? theme.textTheme.bodySmall?.color ?? Colors.grey.shade600
//             : theme.textTheme.bodySmall?.color ?? Colors.grey.shade500;

//     final Color iconColor = isUnread ? theme.colorScheme.primary : Colors.grey;

//     return Card(
//       margin: const EdgeInsets.symmetric(
//         horizontal: 16,
//         vertical: 8,
//       ), // Slightly larger margins
//       color: cardBackgroundColor,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12.0), // Consistent border radius
//         side: BorderSide(
//           color:
//               isUnread
//                   ? theme.colorScheme.primary.withOpacity(0.5)
//                   : theme.dividerColor,
//           width: isUnread ? 1.5 : 1.0, // Thicker border for unread
//         ),
//       ),
//       elevation: isUnread ? 4 : 1, // Higher elevation for unread
//       shadowColor:
//           isUnread
//               ? theme.shadowColor.withOpacity(0.2)
//               : theme.shadowColor.withOpacity(
//                 0.05,
//               ), // More prominent shadow for unread
//       child: InkWell(
//         // Use InkWell for tap animation
//         borderRadius: BorderRadius.circular(12.0),
//         //onTap: onTap,
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Icon(
//                     isUnread
//                         ? Icons.mark_email_unread_rounded
//                         : Icons.mail_outline_rounded,
//                     size: 28.0,
//                     color: iconColor,
//                   ),
//                   const SizedBox(width: 16.0),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           notification.xntmsgdesC1,
//                           style: theme.textTheme.titleMedium?.copyWith(
//                             fontWeight: FontWeight.bold,
//                             color: primaryTextColor,
//                           ),
//                         ),
//                         const SizedBox(height: 4.0),
//                         Text(
//                           notification.xntmsgdesC2,
//                           maxLines: 3,
//                           overflow: TextOverflow.ellipsis,
//                           style: theme.textTheme.bodyMedium?.copyWith(
//                             color: primaryTextColor,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 12.0),
//               // Separator
//               Divider(
//                 color: theme.dividerColor.withOpacity(0.5),
//                 height: 1,
//                 thickness: 0.8,
//               ),
//               const SizedBox(height: 12.0),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           "From: ${notification.xntdoccrusrcd}",
//                           style: theme.textTheme.bodySmall?.copyWith(
//                             color: secondaryTextColor,
//                           ),
//                         ),
//                         const SizedBox(height: 4.0),
//                         Text(
//                           "Date: ${notification.fullDate}",
//                           style: theme.textTheme.bodySmall?.copyWith(
//                             color: secondaryTextColor,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   Row(
//                     children: [
//                       if (isUnread && onMarkAsRead != null)
//                         IconButton(
//                           icon: const Icon(Icons.check_circle_outline_rounded),
//                           tooltip: 'Mark as Read',
//                           onPressed: onMarkAsRead,
//                           color:
//                               theme
//                                   .colorScheme
//                                   .primary, // Use theme primary for action
//                         ),
//                       if (onDelete != null)
//                         IconButton(
//                           icon: const Icon(Icons.delete_outline_rounded),
//                           tooltip: 'Delete',
//                           onPressed: onDelete,
//                           color:
//                               theme
//                                   .colorScheme
//                                   .error, // Use theme error for delete
//                         ),
//                     ],
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:nhapp/pages/notifications/models/notification_item.dart';

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
    final theme = Theme.of(context);
    final bool isUnread = !notification.markasread;
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color:
          isUnread
              ? colorScheme.primaryContainer.withOpacity(0.15)
              : colorScheme.surface,
      elevation: isUnread ? 3 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color:
              isUnread
                  ? colorScheme.primary.withOpacity(0.4)
                  : colorScheme.outline.withOpacity(0.1),
          width: isUnread ? 1.5 : 1.0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row: Icon, Title, Actions
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  isUnread
                      ? Icons.mark_email_unread_rounded
                      : Icons.mail_outline_rounded,
                  size: 32,
                  color:
                      isUnread
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    notification.xntmsgdesC1,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color:
                          isUnread
                              ? colorScheme.onSurface
                              : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Actions
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isUnread == true)
                      IconButton(
                        icon: const Icon(Icons.check_circle_outline_rounded),
                        tooltip: 'Mark as Read',
                        onPressed: onMarkAsRead,
                        color: colorScheme.primary,
                      ),
                    if (onDelete != null)
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded),
                        tooltip: 'Delete',
                        onPressed: onDelete,
                        color: colorScheme.error,
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Message Body (no truncation)
            Text(
              notification.xntmsgdesC2,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            if (notification.xntmsgdesC3.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                notification.xntmsgdesC3,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: 16),
            // Divider
            Divider(
              color: colorScheme.outline.withOpacity(0.15),
              height: 1,
              thickness: 1,
            ),
            const SizedBox(height: 12),
            // Extra Details: From and Date
            Row(
              children: [
                Icon(
                  Icons.person_outline,
                  size: 18,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    notification.xntdoccrusrcd,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(width: 18),
                Icon(
                  Icons.calendar_today_outlined,
                  size: 18,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    notification.fullDate,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
