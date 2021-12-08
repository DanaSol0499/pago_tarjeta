import 'package:flutter/material.dart';
import 'package:flutter_credit_card/credit_card_widget.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:stripe_app/bloc/pagar/pagar_bloc.dart';

import 'package:stripe_app/bloc/services/stripe_service.dart';

import 'package:stripe_app/data/tarjetas.dart';
import 'package:stripe_app/helpers/helpers.dart';
import 'package:stripe_app/pages/tarjeta.dart';
import 'package:stripe_app/widgets/total_pay_btn.dart';

import 'package:google_fonts/google_fonts.dart';

import 'package:meta/meta.dart';

class HomePage extends StatelessWidget {
  final stripeService = new StripeService();
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final pagarBloc = context.read<PagarBloc>();
    // final pagarBloc = RepositoryProvider.of<PagarBloc>(context);
    return Center(
      child: Scaffold(
          appBar: AppBar(
            title: Text(
              'Pagar',
              style: GoogleFonts.nanumGothic(
                fontSize: 22,
                color: Colors.white,
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () async {
                  mostrarLoading(context);

                  final amount = pagarBloc.state.montoPagarString;
                  final currency = pagarBloc.state.moneda;

                  final resp = await this
                      .stripeService
                      .pagarConNuevaTarjeta(amount: amount, currency: currency);

                  Navigator.pop(context);
                  if (resp!.ok) {
                    mostrarAlerta(context, 'Tarjeta OK', 'Todo correcto');
                    Navigator.pushReplacementNamed(context, 'pago_completo');
                  } else {
                    mostrarAlerta(context, 'Algo salío mal ', resp.msg);
                  }
                },
              )
            ],
          ),
          body: Stack(
            children: [
              Positioned(
                width: size.width,
                height: size.height,
                top: 200,
                child: PageView.builder(
                    controller: PageController(viewportFraction: 0.9),
                    physics: BouncingScrollPhysics(),
                    itemCount: tarjetas.length,
                    itemBuilder: (_, i) {
                      final tarjeta = tarjetas[i];

                      return GestureDetector(
                        onTap: () {
                          context
                              .read<PagarBloc>()
                              .add(OnSeleccionarTarjeta(tarjeta));
                          Navigator.push(
                              context, navegarFadeIn(context, TarjetaPage()));
                        },
                        child: Hero(
                          tag: tarjeta.cardNumber,
                          child: CreditCardWidget(
                              cardNumber: tarjeta.cardNumberHidden,
                              expiryDate: tarjeta.expiracyDate,
                              cardHolderName: tarjeta.cardHolderName,
                              cvvCode: tarjeta.cvv,
                              showBackView: false,
                            
                              onCreditCardWidgetChange: (CreditCardBrand) {}),
                        ),
                      );
                    }),
              ),
              Positioned(bottom: 0, child: TotalPayBtn())
            ],
          )),
    );
  }
}

class StripeCustomResponse {
  final bool ok;
  final String msg;

  StripeCustomResponse({required this.ok, required this.msg});
}
