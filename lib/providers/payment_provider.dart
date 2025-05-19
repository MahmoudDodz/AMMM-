import 'package:flutter/material.dart';

class PaymentProvider with ChangeNotifier {
  String? cardHolderName;
  String? cardNumber;
  String? expiryDate;
  String? cvv;

  void setCard({
    required String holderName,
    required String number,
    required String expiry,
    required String cvvCode,
  }) {
    cardHolderName = holderName;
    cardNumber = number;
    expiryDate = expiry;
    cvv = cvvCode;
    notifyListeners();
  }

  void clearCard() {
    cardHolderName = null;
    cardNumber = null;
    expiryDate = null;
    cvv = null;
    notifyListeners();
  }

  bool get hasCardSelected => cardNumber != null;
}
