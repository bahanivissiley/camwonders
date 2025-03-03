import 'dart:async';
import 'dart:math';
import 'package:camwonders/firebase/supabase_logique.dart';
import 'package:camwonders/mainapp.dart';
import 'package:camwonders/services/camwonders.dart';
import 'package:camwonders/widgetGlobal.dart';
import 'package:flutter/material.dart';
import 'package:mesomb/mesomb.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';



class PaymentPage extends StatefulWidget {
  final int amount;
  const PaymentPage({super.key, required this.amount});
  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String selectedMethod = 'none';
  String selectedService = 'MTN'; // MTN ou ORANGE
  TextEditingController phoneController = TextEditingController();
  TextEditingController cardNumberController = TextEditingController();
  TextEditingController expiryDateController = TextEditingController();
  TextEditingController cvvController = TextEditingController();

  final _formKeyCard = GlobalKey<FormState>();
  final _formKeyMobile = GlobalKey<FormState>();

  void makeMobilePayment() async {
    if (!_formKeyMobile.currentState!.validate()) return;

    _showLoadingDialog("Traitement du paiement...");

    final payment = PaymentOperation(
      '4a50852563ef5a309594ff7e46d8b0b061d5deac',
      'bac83d7b-0b87-42af-84ba-6a64a1f20387',
      'd5df157c-97a9-427c-978e-d670c9b36935',
    );

    final response = await payment.makeCollect({
      'amount': widget.amount,
      'service': selectedService,
      'payer': phoneController.text,
      'nonce': Random().nextInt(999999).toString(),
    });

    Navigator.pop(context); // Ferme le modal de chargement
    if(response.isOperationSuccess()){
      print(response.transaction);
      await Camwonder.updatePremiumStatusByFieldId(AuthService().currentUser!.id, true);
      Provider.of<UserProvider>(context, listen: false).setPremium(true);
    }

    _showValidationDialog(
        response.isOperationSuccess() && response.isTransactionSuccess());

    final SupabaseClient supabase = Supabase.instance.client;

    await supabase.from('transactions').insert({
      'user_uid': AuthService().currentUser!.id,
      'amount': response.transaction.amount,
      'message': response.transaction.message,
      'status': response.status,
      'service': response.transaction.service
    });
  }

  void _showLoadingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Colors.green,),
              SizedBox(height: 15),
              Text(message, style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        );
      },
    );
  }

  void _showValidationDialog(bool success) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text(success ? "Paiement Réussi" : "Échec du Paiement"),
          content: Icon(
            success ? Icons.check_circle : Icons.error,
            color: success ? Colors.green : Colors.red,
            size: 50,
          ),
          actions: [
            TextButton(
              onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MainApp()),
                            (Route<dynamic> route) => false
                    );
              },
              child: Text("OK", style: TextStyle(color: Colors.green[700])),
            ),
          ],
        );
      },
    );

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Paiement"),
        backgroundColor: Colors.green[700],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Choisissez un mode de paiement",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _paymentOption("Carte Bancaire", Icons.credit_card, 'card'),
                _paymentOption("Mobile Money", Icons.phone_android, 'mobile'),
              ],
            ),
            SizedBox(height: 20),
            if (selectedMethod == 'card') _cardPaymentForm(),
            if (selectedMethod == 'mobile') _mobilePaymentForm(),
          ],
        ),
      ),
    );
  }

  Widget _paymentOption(String title, IconData icon, String method) {
    return GestureDetector(
      onTap: () => setState(() => selectedMethod = method),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.42,
        padding: EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selectedMethod == method ? Colors.green[700] : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.green),
        ),
        child: Column(
          children: [
            Icon(icon,
                size: 30,
                color: selectedMethod == method ? Colors.white : Colors.green),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color:
                    selectedMethod == method ? Colors.white : Colors.green[700],
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cardPaymentForm() {
    return Form(
      key: _formKeyCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: cardNumberController,
            keyboardType: TextInputType.number,
            maxLength: 16,
            decoration: InputDecoration(
                labelText: "Numéro de carte", border: OutlineInputBorder()),
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: expiryDateController,
                  keyboardType: TextInputType.datetime,
                  decoration: InputDecoration(
                      labelText: "Date d'expiration (MM/YY)",
                      border: OutlineInputBorder()),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: cvvController,
                  keyboardType: TextInputType.number,
                  maxLength: 3,
                  decoration: InputDecoration(
                      labelText: "CVV", border: OutlineInputBorder()),
                ),
              ),
            ],
          ),
          SizedBox(height: 15),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[700],
              padding: EdgeInsets.symmetric(vertical: 12),
            ),
            child: Center(
              child: Text("Payer par carte",
                  style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _mobilePaymentForm() {
    return Form(
      key: _formKeyMobile,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Paiement par Mobile Money",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: selectedService,
            items: ['MTN', 'ORANGE'].map((service) {
              return DropdownMenuItem(value: service, child: Text(service));
            }).toList(),
            onChanged: (value) => setState(() => selectedService = value!),
            decoration: InputDecoration(
                border: OutlineInputBorder(), labelText: "Opérateur"),
          ),
          SizedBox(height: 10),
          TextFormField(
            controller: phoneController,
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value!.isEmpty || !RegExp(r'^[6][0-9]{8}$').hasMatch(value)) {
                return "Numéro invalide";
              }
              return null;
            },
            decoration: InputDecoration(
                labelText: "Numéro de téléphone", border: OutlineInputBorder()),
          ),
          SizedBox(height: 15),
          ElevatedButton(
            onPressed: makeMobilePayment,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[700],
              padding: EdgeInsets.symmetric(vertical: 12),
            ),
            child: Center(
              child: Text("Payer par Mobile Money",
                  style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
