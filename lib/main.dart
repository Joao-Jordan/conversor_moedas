import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const request =
    'https://api.hgbrasil.com/finance?format=json-cors&key=b6f67fe7';

void main() async {
  runApp(
    MaterialApp(
      title: 'Conversor',
      debugShowCheckedModeBanner: false,
      home: const Home(),
      theme: ThemeData(
        hintColor: Colors.amber,
        primaryColor: Colors.black,
      ),
    ),
  );
}

//Função para capturar os dados da API
Future<Map> getData() async {
  http.Response response = await http.get(Uri.parse(request));
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  //TELA INICIAL DO APP CRIADA USANDO O STFULL
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  late double dolar;
  late double euro;
  late double real;

  void _realChanged(String text) {
    double real = double.parse(text);
    dolarController.text = (real / dolar).toStringAsFixed(2);
    euroController.text = (real / euro).toStringAsFixed(2);
  }

  void _dolarChanged(String text) {
    double dolar = double.parse(text);
    realController.text = (dolar * this.dolar).toStringAsFixed(2);
    euroController.text = (dolar * this.dolar / euro).toStringAsFixed(2);
  }

  void _euroChanged(String text) {
    double euro = double.parse(text);
    realController.text = (euro * this.euro).toStringAsFixed(2);
    dolarController.text = (euro * this.euro / dolar).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 25,
          fontWeight: FontWeight.bold,
        ),
        title: const Text('CONVERSOR DE MOEDAS'),
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),
      body: FutureBuilder<Map>(
        future: getData(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.watch_later_outlined,
                      size: 140,
                      color: Colors.amber,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'POR FAVOR, AGUARDE',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.amber,
                          fontSize: 30,
                          fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              );
            default:
              if (snapshot.hasError) {
                return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.wifi_off_outlined,
                          size: 150,
                          color: Colors.amber,
                        ),
                        Text(
                          'ERRO DE CONEXÃO',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.amber,
                              fontSize: 30,
                              fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                );
              } else {
                dolar = snapshot.data!['results']['currencies']['USD']['buy'];
                euro = snapshot.data!['results']['currencies']['EUR']['buy'];

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(
                        Icons.monetization_on,
                        size: 150,
                        color: Colors.amber,
                      ),
                      buildTextField(
                          'Reais', 'R\$', realController, _realChanged),
                      const Divider(),
                      buildTextField(
                          'Dólares', 'US\$', dolarController, _dolarChanged),
                      const Divider(),
                      buildTextField(
                          'Euros', '€\$', euroController, _euroChanged),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 60, vertical: 20),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            primary: Colors.amber,
                            shadowColor: Colors.black,
                            textStyle: const TextStyle(
                                fontSize: 20,
                                fontFamily: 'Arial Hebrew',
                                fontWeight: FontWeight.bold),
                          ),
                          child: const Text(
                            'REDEFINIR',
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                          onPressed: () {
                            realController.text = "";
                            dolarController.text = "";
                            euroController.text = "";
                          },
                        ),
                      ),
                    ],
                  ),
                );
              }
          }
        },
      ),
    );
  }
}

Widget buildTextField(String label,
    String prefix,
    TextEditingController moeda,
    Function(String) refreshValue,) {
  return TextField(
    controller: moeda,
    cursorColor: Colors.amber,
    cursorHeight: 30,
    keyboardType: TextInputType.number,
    textAlign: TextAlign.left,
    style: const TextStyle(color: Colors.amber, fontSize: 25),
    decoration: InputDecoration(
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.amber),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white),
      ),
      prefixText: prefix,
      border: const OutlineInputBorder(),
      labelText: label,
      labelStyle: const TextStyle(
        color: Colors.amber,
        fontSize: 20,
      ),
    ),
    onChanged: refreshValue,
  );
}
