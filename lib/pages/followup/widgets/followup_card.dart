// import 'package:flutter/material.dart';
// import 'package:flutter_slidable/flutter_slidable.dart';
// import 'package:nhapp/utils/format_utils.dart';
// import '../models/followup_list_item.dart';

// class FollowupCard extends StatelessWidget {
//   final FollowupListItem followup;
//   final VoidCallback onTap;

//   const FollowupCard({required this.followup, required this.onTap, super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Slidable(
//       key: ValueKey(followup.autoId),
//       endActionPane: const ActionPane(motion: DrawerMotion(), children: []),
//       child: Card(
//         margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//         child: ListTile(
//           onTap: onTap,
//           title: Text(
//             'No: ${followup.number} | ',
//             style: const TextStyle(fontWeight: FontWeight.bold),
//           ),
//           subtitle: Text(
//             'Customer: ${followup.customerFullName}\n'
//             'Date: ${FormatUtils.formatDateForUser(DateTime.parse(followup.date))}',
//           ),
//           trailing: Chip(label: Text(followup.baseOn)),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:nhapp/utils/format_utils.dart';
import '../models/followup_list_item.dart';

class FollowupCard extends StatelessWidget {
  final FollowupListItem followup;
  final VoidCallback onTap;

  const FollowupCard({required this.followup, required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      // elevation: 2,
      // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Followup #${followup.number}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Theme.of(context).primaryColor.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      followup.baseOnDesc.split(' ')[0],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.person_outline, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      followup.customerFullName,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    FormatUtils.formatDateForUser(
                      DateTime.parse(followup.date),
                    ),
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
