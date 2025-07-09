import 'package:flutter/material.dart';
import 'package:projetofinal/aba_pedidos_entregador.dart'; // Importa a nova tela

// ignore: must_be_immutable
class Abaentregador extends StatefulWidget {
  Abaentregador({super.key});

  State<StatefulWidget> createState() => EntregadorState();

  static const String routeName = "/AbaEntregador";

  String nome = "";

  Abaentregador.name(this.nome);
}

class EntregadorState extends State<Abaentregador> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // Cor de fundo ajustada para preto para consistência
        backgroundColor: Colors.black,
        appBar: AppBar(
            centerTitle: true,
            backgroundColor: Colors.black,
            title: Text(
                "Entregador", 
                style: 
                TextStyle(color: Colors.white // Texto branco na AppBar
                    ),
                ),
            // Adiciona ícone de voltar branco
            iconTheme: IconThemeData(color: Colors.white),
        ),
        body: Center(
            child: Container(
                padding: EdgeInsets.all(20.0), // Adiciona um padding
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center, // Centraliza os itens
                    crossAxisAlignment: CrossAxisAlignment.stretch, // Estica os botões
                    children: [
                        Text(
                          "Bem-vindo, ${widget.nome}",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 50), // Espaçamento
                        
                        // Botão para ver os veículos
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(255, 255, 0, 0),
                                padding: EdgeInsets.symmetric(vertical: 16.0),
                                textStyle: TextStyle(fontSize: 16)),
                            onPressed: () {
                              // Lógica para ver veículos (Placeholder)
                              print("Botão 'Veículos' pressionado.");
                            },
                            child: Text("Veículos",
                            style: TextStyle(color: Colors.white),
                            )
                        ),
                        SizedBox(height: 20), // Espaçamento

                        // Botão para ver as entregas
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(255, 255, 0, 0),
                                padding: EdgeInsets.symmetric(vertical: 16.0),
                                textStyle: TextStyle(fontSize: 16)),
                            // Ação atualizada para navegar para a tela de pedidos
                            onPressed: () {
                              Navigator.pushNamed(context, AbaPedidosEntregador.routeName);
                            },
                            child: Text("Minhas Entregas", 
                                style: TextStyle(color: Colors.white),)
                        ),
                        SizedBox(height: 40), // Espaçamento

                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[800], // Cor diferente para o botão de voltar
                                padding: EdgeInsets.symmetric(vertical: 16.0),
                                textStyle: TextStyle(fontSize: 16)),
                            // Ação atualizada para voltar para a tela anterior
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text("Voltar", 
                                style: TextStyle(color: Colors.white),
                                )
                            )
                    ],
                ),
            ),
        ),
    );
  }
}