import 'package:flutter/material.dart';
import 'package:nhapp/pages/followup/models/followup_list_item.dart';
import 'package:nhapp/pages/followup/pages/followup_detail_page.dart';
import 'package:nhapp/pages/followup/widgets/followup_infinite_list.dart';

class FollowupListPage extends StatelessWidget {
  FollowupListPage({super.key});

  final GlobalKey<FollowupInfiniteListState> _listKey = GlobalKey();

  void handleTap(BuildContext context, FollowupListItem followup) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => FollowupDetailPage(followup: followup)),
    );
  }

  void _openCreateFollowup(BuildContext context) async {
    final result = await Navigator.pushNamed(context, '/followup/create');
    if (result == true) {
      _listKey.currentState?.refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Followups List')),
      body: FollowupInfiniteList(
        key: _listKey,
        onTap: (followup) => handleTap(context, followup),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          _openCreateFollowup(context);
        },
      ),
    );
  }
}
