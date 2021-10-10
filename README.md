# flutter_web3_auction

A token auction website made by Flutter thats interacts with Ethereum web3 through [flutter_web3](https://github.com/y-pakorn/flutter_web3) package.

This flutter web package is **demonstration/example** for [flutter_web3](https://github.com/y-pakorn/flutter_web3) package usage **ONLY**.

Live preview at https://auction.yoisha.dev/

---

Currently operating chain are (is)

- Binance Testnet (97)

---

![auction web](https://i.imgur.com/AJdZ0Fy.png)


![auction mobile](https://i.imgur.com/bhgxbQH.png)

## Disclaimer

I've built this a while ago and decided to take this to open-source, so don't hope for anything magnificient and/or bug-free. Any contributions are welcomed and appreciated.

### DO NOT USE THIS IN PRODUCTION

- Inefficient large list query method **Current method will break/subject for rate limit for large list**
	- Current: Get total list length and recursively query each item (1 item per 1 https call) although paginated
	- Fix: Use off-chain indexers like TheGraph or your own querying tools or use Multicall
- Inefficient constant property monitor
	- Current: Use Timers and constantly invoke https call per interval
	- Fix: Use event subscription or off-chain indexers
- Insufficient user account checks/monitors
	- Fix: Use event subscription and if-clause checks
- No error catching for invalid transaction/canceled transaction
- Etc.

For best case scenario, you should use **Multicall**/**Logs querying**/**Event subscription** whenever available to reduce the number of https call made to the node. 

## Content

This example website usage is to auction/sell off ERC20 token using others ERC20 token or native token as a payment (selectable). The seller can put certain amount of token for sale and decide the price from start, then the total time that the token will be put on sale. The seller also can put a limit per account on.

For buyer can navigate to the desired pool page by accessing from the front page or by dedicated link. And then the buyer can buy the token by putting how much they want to spend, that less than the limit set by the buyer.

So, this website cover

- Ethereum interaction
- Wallet interaction
- Provider interaction
- Contract call (Both read and write)
- Cutomizable multichain contract access
- Dynamic URL for each token pool
- Flutter web basics
- A lot of rubbish and crude code

## Usage

First, in the package directory.

```bash
flutter pub get
```

To run the web-server, use

```bash
flutter run -d web-server
```

And navigates to the URL shown after the command was used.

## Directory

Edit `/config/chain.dart` to configure available chain and contract information.

All contract interaction is located in `/controllers/*/contract_controller.dart`

```
.
├── config
│   └── chain.dart
├── constants.dart
├── controllers
│   ├── fixed_swap
│   │   ├── contract_controller.dart
│   │   ├── create_controller.dart
│   │   ├── home_controller.dart
│   │   └── pool_controller.dart
│   └── web3controller.dart
├── extensions.dart
├── generated_plugin_registrant.dart
├── main.dart
├── models
│   ├── chain.dart
│   ├── controller_bundle.dart
│   ├── currency.dart
│   ├── pool.dart
│   ├── pool_create_request.dart
│   ├── pool_swap_request.dart
│   └── token.dart
├── pages
│   ├── fixed_swap
│   │   ├── create.dart
│   │   ├── home.dart
│   │   ├── pool.dart
│   │   ├── widgets
│   │   │   ├── claim_pool.dart
│   │   │   ├── create_listing.dart
│   │   │   ├── create_pool_dialog.dart
│   │   │   ├── fixed_pool_mini.dart
│   │   │   ├── join_pool.dart
│   │   │   ├── paginate.dart
│   │   │   ├── pool_dialog_action.dart
│   │   │   ├── pool_header.dart
│   │   │   ├── pool_information.dart
│   │   │   ├── pool_settings.dart
│   │   │   ├── swap_dialog.dart
│   │   │   └── token_contract_form.dart
│   │   └── your_pool.dart
│   └── redirect.dart
├── routes.dart
├── utils.dart
└── widgets
    ├── account_large.dart
    ├── layout.dart
    ├── logo_large.dart
    ├── navigation_bar.dart
    └── paginate_controller.dart
```
