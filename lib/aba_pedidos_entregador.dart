import 'package:flutter/material.dart';
import 'package:projetofinal/BD.dart';

/// Modelo de dados
class Pedido {
  final int id;
  final String nomeCliente;
  final String endereco;
  final String status;

  Pedido({
    required this.id,
    required this.nomeCliente,
    required this.endereco,
    required this.status,
  });
}

/// Interface Strategy
abstract class StatusStyleStrategy {
  Color getColor();
}

class PendenteStrategy implements StatusStyleStrategy {
  @override
  Color getColor() => Colors.orange;
}

class EmTransitoStrategy implements StatusStyleStrategy {
  @override
  Color getColor() => Colors.blue;
}

class EntregueStrategy implements StatusStyleStrategy {
  @override
  Color getColor() => Colors.green;
}

class DesconhecidoStrategy implements StatusStyleStrategy {
  @override
  Color getColor() => Colors.grey;
}

class StatusStyleContext {
  late StatusStyleStrategy _strategy;

  StatusStyleContext(String status) {
    _strategy = _selectStrategy(status);
  }

  StatusStyleStrategy _selectStrategy(String status) {
    switch (status) {
      case 'Pendente':
        return PendenteStrategy();
      case 'Em trânsito':
        return EmTransitoStrategy();
      case 'Entregue':
        return EntregueStrategy();
      default:
        return DesconhecidoStrategy();
    }
  }

  Color getColor() => _strategy.getColor();
}

/// Widget principal
class AbaPedidosEntregador extends StatefulWidget {
  AbaPedidosEntregador({super.key});
  static const String routeName = "/AbaPedidosEntregador";

  @override
  State<StatefulWidget> createState() => _AbaPedidosEntregadorState();
}

class _AbaPedidosEntregadorState extends State<AbaPedidosEntregador> {
  late Future<List<Pedido>> _pedidosFuture;

  @override
  void initState() {
    super.initState();
    _pedidosFuture = _fetchPedidos();
  }

  Future<List<Pedido>> _fetchPedidos() async {
    final dbHelper = DBADMN();
    final List<Map<String, dynamic>> maps = await dbHelper.getAllPedidos();

    return List.generate(maps.length, (i) {
      return Pedido(
        id: maps[i]['id'],
        nomeCliente: maps[i]['nomeCliente'],
        endereco: maps[i]['endereco'],
        status: maps[i]['status'],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.black,
        title: Text("Pedidos", style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<List<Pedido>>(
        future: _pedidosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text("Erro ao carregar pedidos: ${snapshot.error}",
                  style: TextStyle(color: Colors.white)),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child:
                  Text("Nenhum pedido encontrado", style: TextStyle(color: Colors.white)),
            );
          } else {
            final pedidos = snapshot.data!;
            return ListView.builder(
              itemCount: pedidos.length,
              itemBuilder: (context, index) {
                final pedido = pedidos[index];
                final color = StatusStyleContext(pedido.status).getColor();

                return Card(
                  color: Colors.grey[900],
                  margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: ListTile(
                    title: Text(
                      "Cliente: ${pedido.nomeCliente}",
                      style:
                          TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 4.0),
                        Text(
                          "Endereço: ${pedido.endereco}",
                          style: TextStyle(color: Colors.white70),
                        ),
                        SizedBox(height: 4.0),
                        Text(
                          "Status: ${pedido.status}",
                          style: TextStyle(color: color, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    trailing: Icon(Icons.arrow_forward_ios, color: Colors.white),
                    onTap: () {
                      print("Pedido ID ${pedido.id} clicado.");
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
