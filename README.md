# flutter_web3_auction

A token auction website made by Flutter thats interacts with Ethereum web3 through [flutter_web3](https://github.com/y-pakorn/flutter_web3) package.

This flutter web package is **demonstration/example** for [flutter_web3](https://github.com/y-pakorn/flutter_web3) package usage **ONLY**.

Live preview at https://auction.yoisha.dev/

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

This example website covers

- Ethereum interaction
- Wallet interaction
- Provider interaction
- Contract call (Both read and write)
- Flutter web basics
- A lot of rubbish and crude code ??
