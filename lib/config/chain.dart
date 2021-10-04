import '../models/chain.dart';
import '../utils.dart';

const Map<int, Chain> chainConfig = {
  56: Chain(
    name: 'Binance Smart Chain',
    logoAsset: 'assets/binance.svg',
    blockExplorerUrl: 'https://bscscan.com/',
  ),
  96: Chain(
    name: 'Bitkub Chain',
    logoAsset: 'assets/bitkub.svg',
    blockExplorerUrl: 'https://bkcscan.com',
  ),
  97: Chain(
    name: 'Binance Testnet',
    logoAsset: 'assets/binance.svg',
    blockExplorerUrl: 'https://testnet.bscscan.com',
    fixedSwapContractAddress: '0xc0eDD0ba53c2C49a800fFdDDB9e87837C44B8b21',
    nativeTokenLP: NativeTokenLP(
      address: '0x575Cb459b6E6B8187d3Ef9a25105D64011874820',
      decimals: 18,
      isToken0Native: true,
    ),
    fixedSwapCurrency: [
      CurrencyToken(
        symbol: 'BNB',
        address: zeroAddress,
        logoAsset: 'assets/binance.svg',
        decimal: 18,
      ),
      CurrencyToken(
        symbol: 'BUSD',
        address: '0xed24fc36d5ee211ea25a80239fb8c4cfd80f12ee',
        logoAsset: 'assets/busd.svg',
        decimal: 18,
      ),
      CurrencyToken(
        symbol: 'USDT',
        address: '0x7ef95a0fee0dd31b22626fa2e10ee6a223f8a684',
        logoAsset: 'assets/usdt.svg',
        decimal: 18,
      ),
    ],
  ),
  25925: Chain(
    name: 'Bitkub Testnet',
    logoAsset: 'assets/bitkub.svg',
    blockExplorerUrl: 'https://testnet.bkcscan.com',
  )
};
