import 'package:get/get.dart';

import '../../models/pool.dart';
import '../../widgets/paginate_controller.dart';
import '../web3controller.dart';
import 'contract_controller.dart';

class FixedSwapHomeController extends GetxController {
  final ContractController contract = ContractController();

  bool isLoadingItem = true;
  bool isYourPool = false;

  final PaginateController pageController = PaginateController();

  List<Pool> currentPoolList = [];

  Future<void> changePage(int index) async {
    if (index > 0 && index <= pageController.lastPage) {
      pageController.changePage(index);
      currentPoolList.clear();
      toggleLoading(true);

      if (index == pageController.currentPage) await 1.seconds.delay();
      await updateTotalLength();
      await fetchPoolInThisPage();

      toggleLoading(false);
    }
  }

  void togggleYourPool(bool value) async {
    try {
      if (value != isYourPool) {
        toggleLoading(true);
        isYourPool = value;
        if (!value) pageController.clearCustomIndexList();

        await updateTotalLength(true);
        await fetchPoolInThisPage();
      }
    } finally {
      toggleLoading(false);
    }
  }

  Future<void> updateTotalLength([bool reset = false]) async {
    if (isYourPool) {
      final indexList = await contract.getPoolOwnerIndexList();
      pageController.changeCustomIndexList(indexList, reset);
    } else {
      final newLength = await contract.getPoolLength();
      pageController.updateTotalLength(newLength, reset);
    }
  }

  Future<void> fetchPoolInThisPage() async {
    try {
      //await updateTotalLength();
      final list =
          await Future.wait<Pool>(pageController.indexListInThisPage.map(
        (e) => contract.getPoolByIndex(e),
      ));
      currentPoolList = isYourPool ? list : list.reversed.toList();
    } catch (error) {}
  }

  @override
  void onClose() {
    //print('home dispose');
    super.onClose();
  }

  @override
  void onInit() async {
    //print('home init');

    if (Web3Controller.to.isConnectedAndInSupportedChain) trigger(true);
    Web3Controller.to.connectionChangedToConnected().listen(trigger);

    contract.getPoolOwnerIndexList();

    super.onInit();

    update();
  }

  void toggleLoading(bool val) {
    isLoadingItem = val;
    update();
  }

  trigger(bool val) async {
    if (val == true) {
      toggleLoading(true);
      await updateTotalLength();
      await fetchPoolInThisPage();
      toggleLoading(false);
    }
  }
}
