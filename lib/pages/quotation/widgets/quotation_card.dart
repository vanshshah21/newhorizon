// import 'package:flutter/material.dart';
// import '../models/quotation_list_item.dart';

// class QuotationCard extends StatelessWidget {
//   final QuotationListItem quotation;
//   final VoidCallback onPdfTap;

//   const QuotationCard({
//     required this.quotation,
//     required this.onPdfTap,
//     super.key,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       child: ListTile(
//         onTap: onPdfTap,
//         title: Text(
//           'Quotation#: ${quotation.qtnNumber} | Customer: ${quotation.customerFullName}',
//           style: const TextStyle(fontWeight: FontWeight.bold),
//         ),
//         subtitle: Text(
//           'Date: ${quotation.date.split('T').first}\n'
//           'Status: ${quotation.quotationStatus ?? "-"}',
//         ),
//         trailing: Text(quotation.qtnYear),
//       ),
//     );
//   }
// }

//-----------------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/svg.dart';
import 'package:nhapp/pages/quotation/pages/quotation_detail.dart';
import 'package:nhapp/utils/format_utils.dart';
import '../models/quotation_list_item.dart';

class QuotationCard extends StatelessWidget {
  final QuotationListItem quotation;
  final VoidCallback onPdfTap;
  final VoidCallback? onEditTap;
  final VoidCallback? onDeleteTap;

  const QuotationCard({
    required this.quotation,
    required this.onPdfTap,
    this.onEditTap,
    this.onDeleteTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final actions = <Widget>[
      CustomSlidableAction(
        onPressed: (_) => onPdfTap(),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        child: SvgPicture.asset(
          'assets/icons/pdf.svg',
          width: 30,
          height: 30,
          colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
        ),
      ),
      if (quotation.isEdit)
        CustomSlidableAction(
          onPressed: (_) => onEditTap!(),
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          child: const Icon(Icons.edit),
        ),
    ];

    return Slidable(
      key: ValueKey(quotation.qtnID),
      endActionPane: ActionPane(
        extentRatio: 0.3,
        motion: const DrawerMotion(),
        children: actions,
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: ListTile(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => QuotationDetailPage(quotation: quotation),
              ),
            );
          },
          title: Text(
            'Quotation No.: ${quotation.qtnNumber}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            'Customer: ${quotation.customerFullName}\n'
            'Date: ${FormatUtils.formatDateForUser(DateTime.parse(quotation.date))}',
          ),
          trailing: Text(quotation.qtnYear),
        ),
      ),
    );
  }
}
