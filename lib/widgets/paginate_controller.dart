class PaginateController {
  final int firstPage = 1;

  int _currentPage = 1;

  int _totalLength;

  int _maxItemPerPage;

  List<int> _customIndexList = [];

  PaginateController({
    int maxItemPerPage = 10,
    totalLength = 0,
  })  : _totalLength = totalLength,
        _maxItemPerPage = maxItemPerPage;

  int get currentPage => _currentPage;

  int get maxItemPerPage => _maxItemPerPage;

  List<int> get indexListInThisPage {
    if (_customIndexList.isEmpty)
      return [
        if (isLastPage)
          for (var i = 0; i < itemInThisPage; i++) i
        else
          for (var i = 0; i < itemInThisPage; i++)
            i + itemInLastPage + (lastPage - currentPage - 1) * _maxItemPerPage
      ];
    else
      return _customIndexList.sublist(
        (currentPage - 1) * _maxItemPerPage,
        isLastPage
            ? null
            : (currentPage - 1) * _maxItemPerPage + _maxItemPerPage,
      );
  }

  bool get isFirstPage => currentPage == firstPage;

  bool get isLastPage => currentPage == lastPage;

  int get itemInLastPage => _maxItemPerPage > _totalLength
      ? totalLength
      : totalLength == _maxItemPerPage
          ? _maxItemPerPage
          : totalLength % _maxItemPerPage;

  int get itemInThisPage => totalLength == 0
      ? 0
      : _currentPage == lastPage
          ? itemInLastPage
          : _maxItemPerPage;

  int get lastPage =>
      totalLength == 0 ? 1 : (totalLength / _maxItemPerPage).ceil();

  int get totalLength =>
      _customIndexList.isEmpty ? _totalLength : _customIndexList.length;

  ///List must be ascending; low to high.
  void changeCustomIndexList(List<int> list, [bool reset = false]) {
    _customIndexList = list;
    if (reset) _currentPage = 1;
  }

  void changePage(int page) => _currentPage = page;

  void clearCustomIndexList() {
    _customIndexList = [];
    _currentPage = 1;
  }

  void changeMaxItemPerPage(int maxItemPerPage) {
    _maxItemPerPage = maxItemPerPage;
    _currentPage = 1;
  }

  void updateTotalLength(int newLength, [bool reset = false]) {
    _totalLength = newLength;
    if (reset) _currentPage = 1;
  }
}
