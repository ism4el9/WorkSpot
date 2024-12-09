class PaymentCard {
  final int id; // Supabase ID
  final String provider;
  final String cardNumber;
  final String expiryDate;
  final String holderName;

  PaymentCard({
    required this.id,
    required this.provider,
    required this.cardNumber,
    required this.expiryDate,
    required this.holderName,
  });

  factory PaymentCard.fromMap(Map<String, dynamic> map) {
    return PaymentCard(
      id: map['id'],
      provider: map['provider'],
      cardNumber: map['card_number'],
      expiryDate: map['expiry_date'],
      holderName: map['holder_name'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'provider': provider,
      'card_number': cardNumber,
      'expiry_date': expiryDate,
      'holder_name': holderName,
    };
  }
}
