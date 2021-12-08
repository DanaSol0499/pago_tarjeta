import 'package:dio/dio.dart';
import 'package:meta/meta.dart';
import 'package:stripe_app/models/payment_intent_response.dart';
import 'package:stripe_app/models/stripe_custom_response.dart';
import 'package:stripe_payment/stripe_payment.dart';

class StripeService {
  //Singleton
  StripeService._privateConstructos();
  static final StripeService _intance = StripeService._privateConstructos();
  factory StripeService() => _intance;

  String _paymentApiUrl = 'https://api.stripe.com/v1/payment_intents';
  static String _secretKey =
      'sk_test_51K2N4VDQkRwoe1Qa4VAZS6GUpjBxxRfoyJu7ggCqDRPgegwjPfKUwG7zcaIvqv5O284mwcBYulcUFUwH9GVrrnJe00knaC6R5r';
  String _apikey =
      'pk_test_51K2N4VDQkRwoe1QaTbQNptcZFZfrhgMg0WMZSIPUgEhuMXFFjSBMGk7QhashG2TUbIhJkMBTRDdIG25h7I399gMO00tk8G0v7J';

  final headerOptioms = new Options(
      contentType: Headers.formUrlEncodedContentType,
      headers: {'Authorization': 'Bearer ${StripeService._secretKey}'});

  void init() {
    StripePayment.setOptions(StripeOptions(
        publishableKey: this._apikey,
        androidPayMode: 'test',
        merchantId: 'test'));
  }

  Future pagarConTarjetaExistente({
    required String amount,
    required String currency,
    required CreditCard card,
  }) async {
    try {
      final paymentMethod = await StripePayment.createPaymentMethod(
          PaymentMethodRequest(card: card));

      final resp = await this._realizarPago(
          amount: amount, currency: currency, paymentMethod: paymentMethod);

      return resp;
    } catch (e) {
      return StripeCustomResponse(ok: false, msg: e.toString());
    }
  }

  Future<StripeCustomResponse?> pagarConNuevaTarjeta({
    required String amount,
    required String currency,
  }) async {
    try {
      final paymentMethod = await StripePayment.paymentRequestWithCardForm(
          CardFormPaymentRequest());

      final resp = await this._realizarPago(
          amount: amount, currency: currency, paymentMethod: paymentMethod);

      await StripePayment.completeNativePayRequest();

      return resp;
    } catch (e) {
      return StripeCustomResponse(ok: false, msg: e.toString());

      //crear el intent

    }
  }

  Future pagarApplePayGooglePay({
    required String amount,
    required String currency,
  }) async {
    try {
      final newAmount = double.parse(amount) / 100;

      final token = await StripePayment.paymentRequestWithNativePay(
          androidPayOptions: AndroidPayPaymentRequest(
              currencyCode: currency, totalPrice: amount),
          applePayOptions: ApplePayPaymentOptions(
              countryCode: 'US',
              currencyCode: currency,
              items: [
                ApplePayItem(label: 'Total a pagar', amount: '$newAmount')
              ]));

      final paymentMethod = await StripePayment.createPaymentMethod(
          PaymentMethodRequest(card: CreditCard(token: token.tokenId)));

      final resp = await this._realizarPago(
          amount: amount, currency: currency, paymentMethod: paymentMethod);
    } catch (e) {
      print('Error en intento: ${e.toString()}');
      return StripeCustomResponse(ok: false, msg: e.toString());
    }
  }

  Future _crearPaymentIntent({
    required String amount,
    required String currency,
  }) async {
    try {
      final dio = new Dio();
      final data = {'amount': amount, 'currency': currency};

      final resp =
          await dio.post(_paymentApiUrl, data: data, options: headerOptioms);

      return PaymentIntentResponse.fromJson(resp.data);
    } catch (e) {
      print('Error en intento: ${e.toString()}');
      return PaymentIntentResponse(status: '400');
    }
  }

  Future<StripeCustomResponse?> _realizarPago(
      {required String amount,
      required String currency,
      required PaymentMethod paymentMethod}) async {
    try {
      final paymentIntent =
          await this._crearPaymentIntent(amount: amount, currency: currency);

      final paymentResult = await StripePayment.confirmPaymentIntent(
          PaymentIntent(
              clientSecret: paymentIntent.clientSecret,
              paymentMethodId: paymentMethod.id));

      if (paymentResult.status == 'succeeded') {
        return StripeCustomResponse(ok: true, msg: '');
      } else {
        return StripeCustomResponse(
            ok: false, msg: 'FALLÓ: ${paymentResult.status}');
      }
    } catch (e) {
      print(e.toString());
      return StripeCustomResponse(ok: false, msg: e.toString());
    }
  }
}
