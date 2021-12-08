import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:stripe_app/bloc/pagar/pagar_bloc.dart';
import 'package:stripe_app/helpers/helpers.dart';

import 'package:stripe_app/bloc/services/stripe_service.dart';
import 'package:stripe_payment/stripe_payment.dart';

import 'package:google_fonts/google_fonts.dart';

class TotalPayBtn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final pagarBloc = context.read<PagarBloc>().state;

    return Container(
        width: width,
        height: 80,
        padding: EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
            border: Border.all(width: 5, color: Colors.white),
            color: Colors.blueGrey,
            borderRadius: BorderRadius.all(Radius.circular(30))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Total',
                  style: GoogleFonts.nanumGothic(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '${pagarBloc.montoPagar} ${pagarBloc.moneda}',
                  style: GoogleFonts.nanumGothic(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            BlocBuilder<PagarBloc, PagarState>(
              builder: (context, state) {
                return _BtnPay(state);
              },
            ),
          ],
        ));
  }
}

class _BtnPay extends StatelessWidget {
  final PagarState state;
  const _BtnPay(this.state);

  @override
  Widget build(BuildContext context) {
    return state.tarjetaActiva //icono de tarjeta en pagar
        ? buildBtnTarjeta(context)
        : buildAppleAndGooglePay(context);
  }

  Widget buildBtnTarjeta(BuildContext context) {
    return MaterialButton(
        height: 45,
        minWidth: 150,
        shape: StadiumBorder(),
        elevation: 0,
        color: Colors.white,
        child: Row(
          children: [
            Icon(
              FontAwesomeIcons.solidCreditCard,
              color: Colors.black,
              size: 22,
            ),
            Text(
              '    Pagar',
              style: GoogleFonts.nanumGothic(
                fontSize: 22,
                color: Colors.blueGrey,
              ),
            ),
          ],
        ),
        onPressed: () async {
          mostrarLoading(context);
          final stripeService = new StripeService();
          final state = context.read<PagarBloc>().state;
          final tarjeta = state.tarjeta;
          final mesAnio = tarjeta!.expiracyDate.split('/');

          final resp = await stripeService.pagarConTarjetaExistente(
              amount: state.montoPagarString,
              currency: state.moneda,
              card: CreditCard(
                number: tarjeta.cardNumber,
                expMonth: int.parse(mesAnio[0]),
                expYear: int.parse(mesAnio[1]),
              ));

          Navigator.pop(context);
          if (resp.ok! == true) {
            await Navigator.pushReplacementNamed(context, 'pago_completo');
          } else {
            await mostrarAlerta(context, 'Algo salío mal ', resp.msg);
          }
          // print(tarjeta!.cardNumber);
        });
  }
}

Widget buildAppleAndGooglePay(BuildContext context) {
  return MaterialButton(
      height: 45,
      minWidth: 150,
      shape: StadiumBorder(),
      elevation: 0,
      color: Colors.white,
      child: Row(
        children: [
          Icon(
            Platform.isAndroid
                ? FontAwesomeIcons.google
                : FontAwesomeIcons.apple,
            color: Colors.black,
            size: 22,
          ),
          Text(
            '    Pay',
            style: GoogleFonts.nanumGothic(
              fontSize: 22,
              color: Colors.blueGrey,
            ),
          ),
        ],
      ),
      onPressed: () async {
        final stripeService = new StripeService();
        final state = context.read<PagarBloc>().state;

        final resp = await stripeService.pagarApplePayGooglePay(
            amount: state.montoPagarString, currency: state.moneda);
      });
}
