class Token {
  final String address;
  final String? name;
  final String symbol;
  final int decimal;

  Token(
    this.address,
    this.symbol,
    this.decimal, {
    this.name,
  });

  @override
  String toString() {
    return '$symbol at $address';
  }
}
