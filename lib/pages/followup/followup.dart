import 'package:flutter/material.dart';
import 'package:nhapp/pages/followup/models/followup_list_item.dart';
import 'package:nhapp/pages/followup/pages/followup_detail_page.dart';
import 'package:nhapp/pages/followup/widgets/followup_infinite_list.dart';

class FollowupListPage extends StatelessWidget {
  const FollowupListPage({super.key});

  void handleTap(BuildContext context, FollowupListItem followup) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => FollowupDetailPage(followup: followup)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Followups List')),
      body: FollowupInfiniteList(
        onTap: (followup) => handleTap(context, followup),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.pushNamed(context, '/followup/create');
        },
      ),
    );
  }
}
