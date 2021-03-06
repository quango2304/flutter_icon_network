import 'dart:convert';

Balance balanceFromJson(String str) => Balance.fromJson(json.decode(str));

String balanceToJson(Balance data) => json.encode(data.toJson());

class Balance {
  Balance({
    this.balance,
  });

  final String balance;

  double get icxBalance {
    return BigInt.tryParse(balance)/BigInt.from(1000000000000000000);
  }

  Balance copyWith({
    String balance,
  }) =>
      Balance(
        balance: balance ?? this.balance,
      );

  factory Balance.fromJson(Map<String, dynamic> json) => Balance(
    balance: json["balance"],
  );

  Map<String, dynamic> toJson() => {
    "balance": balance,
  };
}
