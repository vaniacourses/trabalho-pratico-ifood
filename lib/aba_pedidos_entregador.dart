import 'package:flutter/material.dart';
import 'package:projetofinal/BD.dart'; //Banco de dados

// Modelo de dados para um Pedido
class Pedido {
  final int id; // ID agora é um inteiro, como no banco de dados
  final String nomeCliente;
  final String endereco;
  final String status;

  Pedido({required this.id, required this.nomeCliente, required this.endereco, required this.status});
}

// ignore: must_be_immutable
class AbaPedidosEntregador extends StatefulWidget {
  AbaPedidosEntregador({super.key});

  static const String routeName = "/AbaPedidosEntregador";

  @override
  State<StatefulWidget> createState() => _AbaPedidosEntregadorState();
}

class _AbaPedidosEntregadorState extends State<AbaPedidosEntregador> {
  // Futuro que conterá a lista de pedidos vinda do banco de dados
  late Future<List<Pedido>> _pedidosFuture;

  @override
  void initState() {
    super.initState();
    // Inicia a busca pelos pedidos assim que a tela é carregada
    _pedidosFuture = _fetchPedidos();
  }

  // Função para buscar e converter os pedidos do banco de dados
  Future<List<Pedido>> _fetchPedidos() async {
    final dbHelper = DBADMN();
    final List<Map<String, dynamic>> maps = await dbHelper.getAllPedidos();

    // Converte a lista de Mapas em uma lista de Pedidos
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
        title: Text(
          "Pedidos",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      // Usa FutureBuilder para lidar com os dados assíncronos
      body: FutureBuilder<List<Pedido>>(
        future: _pedidosFuture,
        builder: (context, snapshot) {
          // Enquanto os dados estão carregando, mostra um indicador de progresso
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } 
          // Se ocorrer um erro na busca
          else if (snapshot.hasError) {
            return Center(child: Text("Erro ao carregar pedidos: ${snapshot.error}", style: TextStyle(color: Colors.white)));
          } 
          // Se os dados foram carregados com sucesso, mas a lista está vazia
          else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("Nenhum pedido encontrado", style: TextStyle(color: Colors.white)));
          } 
          // Se os dados foram carregados com sucesso
          else {
            final pedidos = snapshot.data!;
            return ListView.builder(
              itemCount: pedidos.length,
              itemBuilder: (context, index) {
                final pedido = pedidos[index];
                return Card(
                  color: Colors.grey[900],
                  margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: ListTile(
                    title: Text(
                      "Cliente: ${pedido.nomeCliente}",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
                          style: TextStyle(
                            color: _getStatusColor(pedido.status),
                            fontWeight: FontWeight.bold,
                          ),
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

  // Função auxiliar para definir a cor do status
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pendente':
        return Colors.orange;
      case 'Em trânsito':
        return Colors.blue;
      case 'Entregue':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
