import 'dart:async';
import 'dart:html';

import 'package:decimal/decimal.dart';
import 'package:flutter_web3/flutter_web3.dart';
import 'package:get/get.dart';

import '../config/chain.dart';
import '../models/chain.dart';
import '../models/token.dart';
import '../utils.dart';

class Web3Controller extends GetxController {
  static Web3Controller get to => Get.find();

  bool get isEnabled => ethereum != null;

  bool get isConnected =>
      (ethereum?.isConnected() ?? false) && selectedAddress.isNotEmpty;

  bool get isInSupportedChain => currentChain?.supported ?? false;

  Chain? get currentChain => chainConfig[getChainId()];

  bool get isConnectedAndInSupportedChain => isConnected && isInSupportedChain;

  bool get isConnectedAndInKnownChain => isConnected && currentChain != null;

  bool get isConnectedButInUnknownChain => isConnected && currentChain == null;

  // Should not be used, use ethereum event subscription instead.
  Stream<bool> connectionChangedToConnected() {
    bool lastValue = isConnectedAndInSupportedChain;
    return Stream.periodic(kAccountPollingRate, (tick) {
      final bool val = (lastValue != isConnectedAndInSupportedChain &&
          isConnectedAndInSupportedChain);
      lastValue = isConnectedAndInSupportedChain;
      return val;
    });
  }

  String get selectedAddress => ethereum?.selectedAddress ?? '';

  int getChainId() {
    return int.tryParse(ethereum?.chainId as String) ?? -1;
  }

  Future<BigInt> getNativeTokenBalance() async =>
      getNativeTokenBalanceOf(selectedAddress);

  Future<BigInt> getNativeTokenBalanceOf(String address) async {
    try {
      if (ethereum != null) return await provider!.getBalance(address);

      return BigInt.zero;
    } catch (error) {
      return BigInt.zero;
    }
  }

  Future<List<String>> connectToLocalProvider() async {
    try {
      if (ethereum != null) {
        return await ethereum!.requestAccount();
      }
      return [];
    } finally {
      update();
    }
  }

  Future<bool> addTokenToWatchList(Token token) => ethereum!.walletWatchAssets(
        address: token.address,
        symbol: token.symbol,
        decimals: token.decimal,
      );

  allowInteropWrapper(dynamic arg) {
    return connectToLocalProvider();
  }

  Future<Decimal> fetchNativeTokenPriceThisChain() async =>
      fetchNativeTokenPrice(currentChain?.nativeTokenLP);

  Future<Decimal> fetchNativeTokenPrice(NativeTokenLP? nativeTokenLP) async {
    if (nativeTokenLP != null) {
      List<BigInt> result = (await Contract(
        nativeTokenLP.address,
        ['function getReserves() view returns (uint,uint,uint)'],
        provider!,
      ).call<List>('getReserves'))
          .map((e) => (e as BigNumber).toBigInt)
          .toList();

      final reserve0 = toDecimal(result[0]);
      final reserve1 = toDecimal(result[1]);

      return nativeTokenLP.isToken0Native
          ? reserve0 / reserve1
          : reserve1 / reserve0;
    }
    return Decimal.one;
  }

  @override
  void onInit() {
    if (ethereum != null) {
      ethereum!.onAccountsChanged((accounts) {
        connectToLocalProvider();
      });

      ethereum!.onChainChanged((chainId) {
        window.location.reload();
      });

      ethereum!.onDisconnect((error) {
        update();
      });
    }
    super.onInit();
  }
}
