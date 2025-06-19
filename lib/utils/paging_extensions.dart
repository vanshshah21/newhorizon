import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

extension PagingStateExtension<PageKeyType, ItemType>
    on PagingState<PageKeyType, ItemType> {
  List<ItemType>? get items =>
      pages != null ? List.unmodifiable(pages!.expand((e) => e)) : null;

  bool get lastPageIsEmpty => pages?.lastOrNull?.isEmpty ?? false;
}

extension IntPagingStateExtension<ItemType> on PagingState<int, ItemType> {
  int get nextIntPageKey => (keys?.lastOrNull ?? 0) + 1;
}
