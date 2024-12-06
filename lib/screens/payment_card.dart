class PaymentCard {
  final String provider; // Ej: Visa, MasterCard
  final String cardNumber;
  final String expiryDate;
  final String holderName;

  PaymentCard({
    required this.provider,
    required this.cardNumber,
    required this.expiryDate,
    required this.holderName,
  });
}
