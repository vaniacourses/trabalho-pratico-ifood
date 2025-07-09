import 'package:flutter/material.dart';
import 'package:projetofinal/aba_pedidos_entregador.dart';
import 'package:projetofinal/BD.dart';

// ignore: must_be_immutable
class Cardapio extends StatelessWidget {
  
  static const String routeName = "/Cardapio";

  Future<List<Map<String, dynamic>>> _fetchCardapio() async {
    var db = DBADMN();
    return await db.getCardapioItems();
  }

  bool _isValidUrl(String url) {
    final Uri? uri = Uri.tryParse(url);
    return uri != null && uri.isAbsolute && (uri.scheme == 'http' || uri.scheme == 'https');
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cardápio', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Color.fromARGB(255, 0, 0, 0),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchCardapio(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: Colors.white));
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar cardápio', style: TextStyle(color: Colors.white)));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Cardápio vazio', style: TextStyle(color: Colors.white)));
          } else {
            final itens = snapshot.data!;
            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1, // Definindo duas colunas
                crossAxisSpacing: 10, // Espaçamento entre as colunas
                mainAxisSpacing: 10, // Espaçamento entre as linhas
                childAspectRatio: 3, // Proporção entre largura e altura dos itens
              ),
              itemCount: itens.length,
              itemBuilder: (context, index) {
                final item = itens[index];
                
                return Container(
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 30, 30, 30),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      if (_isValidUrl(item['thumbnail']))
                        Container(
                          height: 120, // Definindo uma altura fixa para a imagem
                          width: 120, // Imagem ocupará toda a largura do container
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            image: DecorationImage(
                              image: NetworkImage(item['thumbnail']),
                              fit: BoxFit.cover, // Garantindo que a imagem cubra o container sem distorcer
                            ),
                          ),
                        ),

                        SizedBox(width: 8),

                      Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['nome'],
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                        overflow: TextOverflow.ellipsis, // Para evitar que o título ultrapasse
                      ),
                      SizedBox(height: 8),
                      Text(
                        item['descricao'],
                        style: TextStyle(fontSize: 14, color: Colors.white70),
                        overflow: TextOverflow.ellipsis, // Para evitar textos longos
                      ),
                      SizedBox(height: 8),
                      
                      Text(
                        'Preço: \$${item['preco'].toString()}',
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                      
                    ],
                  ),

                    ]),
                  
                  
                );
              },
            );
          }
        },
      ),
    );
  }
}