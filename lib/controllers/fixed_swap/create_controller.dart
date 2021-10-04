import 'package:decimal/decimal.dart';
import 'package:get/get.dart';

import '../../models/chain.dart';
import '../../models/controller_bundle.dart';
import '../../models/pool_create_request.dart';
import '../../models/token.dart';
import '../../pages/fixed_swap/pool.dart';
import '../../pages/fixed_swap/widgets/create_pool_dialog.dart';
import '../../utils.dart';
import '../web3controller.dart';
import 'contract_controller.dart';

class FixedSwapCreateController extends GetxController {
  final ContractController contract = ContractController();

  bool isLoading = false;

  final List<Duration> availableDuration = [
    30.minutes,
    1.hours,
    2.hours,
    4.hours,
    6.hours,
    12.hours,
    1.days,
    2.days,
    3.days,
    4.days,
    7.days
  ];

  bool isNoLimitPerWallet = true;

  Duration selectedDuration = 1.hours;

  CurrencyToken? selectedCurrency =
      Web3Controller.to.currentChain?.fixedSwapCurrency?.first;

  List<Token> _currentToken = [];

  BigInt _currentTokenBalance = BigInt.zero;

  ControllerBundle tokenController =
      ControllerBundle(validator: defaultTokenValidator);

  ControllerBundle? amountController;

  ControllerBundle poolNameController = ControllerBundle(validator: (val) {
    if (val == null || val.isEmpty) return 'empty string';
    if (val.length > 15) return 'length must no more than 15';
    return null;
  });

  ControllerBundle ratioController =
      ControllerBundle(validator: defaultDecimalValidator);
  ControllerBundle maxPerWalletController =
      ControllerBundle(validator: defaultDecimalValidator);

  List<CurrencyToken> get availableCurrency =>
      Web3Controller.to.currentChain?.fixedSwapCurrency ?? [];
  List<Token> get currentToken => _currentToken;

  BigInt get currentTokenBalance => _currentTokenBalance;

  bool get isTokenEmpty => currentToken.isEmpty;

  Decimal get totalCurrencyAmountByRatio {
    //final amountRes = amountController!.tokenValidator(amountController!.text);
    //final ratioRes = ratioController.tokenValidator(ratioController.text);
    if (!isTokenEmpty &&
        !amountController!.tokenIsError &&
        !ratioController.tokenIsError &&
        amountController!.text.isNotEmpty &&
        ratioController.text.isNotEmpty) {
      return Decimal.parse(amountController!.text) /
          Decimal.parse(ratioController.text);
    }
    return Decimal.zero;
  }

  void changeCurrency(CurrencyToken val) {
    if (!isTokenEmpty && (selectedCurrency != val)) {
      selectedCurrency = val;
      update();
    }
  }

  void changeDuration(Duration duration) {
    if (!isTokenEmpty && duration != selectedDuration) {
      selectedDuration = duration;
      update();
    }
  }

  void clearToken() {
    currentToken.clear();
    tokenController.clear();
    amountController?.clear();
    poolNameController.clear();
    ratioController.clear();
    update();
  }

  Future<void> createPool() async {
    if (!isTokenEmpty && validatePoolInformation()) {
      final createRequest = PoolCreateRequest(
        name: poolNameController.text,
        token0Address: currentToken.first.address,
        token1Address: selectedCurrency!.address,
        amountTotalToken0: toBase(
            Decimal.parse(amountController!.text), currentToken.first.decimal),
        amountTotalToken1: toBase(totalCurrencyAmountByRatio),
        claimDelayInSec: 0.seconds,
        maxPerWallet: isNoLimitPerWallet
            ? BigInt.zero
            : toBase(Decimal.parse(maxPerWalletController.text)),
        duration: selectedDuration,
      );

      final poolIndex = await Get.dialog<int>(
        CreatePoolDialog(createRequest),
        barrierDismissible: false,
      );

      if (poolIndex != null && poolIndex >= 0) {
        await 0.5.seconds.delay();
        changePagePop(FixedSwapPoolPage.routeNameFromIndex(poolIndex));
      }
    }
  }

  Future<void> fetchToken() async {
    try {
      if (tokenController.validate()) {
        toggleLoading(true);

        final res = await Future.wait([
          contract.getToken(tokenController.text),
          contract.getBalanceOf(
            tokenController.text,
            Web3Controller.to.selectedAddress,
          )
        ]);

        _currentToken = [res[0] as Token];
        _currentTokenBalance = res[1] as BigInt;
      }
    } finally {
      toggleLoading(false);
    }
  }

  @override
  void onClose() {
    //print('create controller close');
    super.onClose();
  }

  @override
  void onInit() {
    //print('create controller init');

    amountController = ControllerBundle(validator: (val) {
      if (val == null || val.isEmpty) return 'empty amount';
      if (Decimal.tryParse(val) == null || Decimal.parse(val).isNegative)
        return 'wrong value';
      if (Decimal.parse(val) == Decimal.zero) return 'zero amount';
      if (toBase(Decimal.parse(val)) > currentTokenBalance)
        return 'exceed current balance';
      if (!totalCurrencyAmountByRatio.hasFinitePrecision)
        return 'infinite decimal';
      return null;
    });

    super.onInit();
  }

  void toggleLoading(bool val) {
    isLoading = val;
    update();
  }

  void toggleWalletUnlimited(bool val) {
    if (val != isNoLimitPerWallet) {
      if (val == false) maxPerWalletController.clear();
      isNoLimitPerWallet = val;
      update();
    }
  }

  bool validatePoolInformation() {
    final resAmount = amountController!.validate();
    final resPoolName = poolNameController.validate();
    final resRatio = ratioController.validate();
    final resMax =
        isNoLimitPerWallet ? true : maxPerWalletController.validate();
    return resAmount && resPoolName && resRatio && resMax;
  }
}
