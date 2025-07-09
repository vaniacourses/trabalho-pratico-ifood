import 'package:flutter/material.dart';
import 'package:projetofinal/BD.dart';
import 'package:projetofinal/uson.dart';
import 'package:image_picker/image_picker.dart';
// A LINHA 'import 'dart:io';' FOI REMOVIDA DAQUI


import 'package:projetofinal/aba_pedidos_entregador.dart';

import 'package:projetofinal/abaEntregador.dart';

import 'package:projetofinal/cardapio.dart';


  class del extends StatelessWidget {
  void _showDeleteConfirmationDialog(BuildContext context, int propertyId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900], // Fundo escuro do diálogo
          title: Text('Excluir propriedade ?', style: TextStyle(color: Colors.white)),
          content: Text('', style: TextStyle(color: Colors.white70)),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar', style: TextStyle(color: Colors.grey[400])),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Excluir', style: TextStyle(color: const Color.fromARGB(255, 255, 0, 0))),
              onPressed: () {
                _deleteProperty(context, propertyId);
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteProperty(BuildContext context, int propertyId) async {
    var db = DBADMN();
    await db.deleteProperty(propertyId);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Propriedade excluída com sucesso')),
    );
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => del()),
    );
  }

  bool _isValidUrl(String url) {
    final Uri? uri = Uri.tryParse(url);
    return uri != null && uri.isAbsolute && (uri.scheme == 'http' || uri.scheme == 'https');
  }

  Future<List<Map<String, dynamic>>> _fetchProperties() async {
    var db = DBADMN();
    return await db.getUserProperties();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Remoção de Propriedades', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black, // Fundo escuro da tela
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchProperties(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: Colors.white));
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar propriedades', style: TextStyle(color: Colors.white)));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Nenhuma propriedade encontrada', style: TextStyle(color: Colors.white)));
          } else {
            final properties = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(10.0),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Define o número de colunas
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.8, // Ajusta a altura proporcionalmente à largura
                ),
                itemCount: properties.length,
                itemBuilder: (context, index) {
                  final property = properties[index];
                  return GestureDetector(
                    onTap: () {
                      _showDeleteConfirmationDialog(context, property['id']);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[850],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_isValidUrl(property['thumbnail']))
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                property['thumbnail'],
                                width: double.infinity,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                          SizedBox(height: 8),
                          Text(
                            property['title'],
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                          ),
                          SizedBox(height: 4),
                          Text(
                            property['description'],
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 14, color: Colors.white70),
                          ),
                          Spacer(),
                          Text(
                            'Máx. hóspedes: ${property['max_guest'].toString()}',
                            style: TextStyle(color: Colors.grey[400], fontSize: 12),
                          ),
                          Text(
                            'Preço: \$${property['price'].toString()}',
                            style: TextStyle(color: Colors.grey[400], fontSize: 12),
                          ),
                          Text(
                            'Número: ${property['number'].toString()}',
                            style: TextStyle(color: Colors.grey[400], fontSize: 12),
                          ),
                          Text(
                            'Complemento: ${property['complement'] ?? 'Não possui'}',
                            style: TextStyle(color: Colors.grey[400], fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }
}

// usuário gerenciar propriedades
class UG extends StatefulWidget {
  @override
  _UGState createState() => _UGState();
}

class _UGState extends State<UG> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Property'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                // Add your create property logic here
                Navigator.pushNamed(context, '/create_prop');
              },
              child: Text('Adicionar nova'),
            ),
            SizedBox(height: 20), // Espaçamento adicionado
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/list_prop');
              },
              child: Text('Listar'),
            ),
            SizedBox(height: 20), // Espaçamento adicionado
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/delete_prop');
              },
              child: Text('Remover '),
            ),
            SizedBox(height: 20), // Espaçamento adicionado
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/edit_prop');
              },
              child: Text('Editar '),
            ),
          ],
        ),
      ),
    );
  }
}


// Alugar Propriedade
class AL extends StatefulWidget {
  @override
  _ALState createState() => _ALState();
}

class _ALState extends State<AL> {
  List<dynamic> _properties = [];
  List<dynamic> _filteredProperties = [];
  final TextEditingController _ufController = TextEditingController();
  final TextEditingController _bairroController = TextEditingController();
  final TextEditingController _cidadeController = TextEditingController();
  final TextEditingController _maxGuestController = TextEditingController();

  bool _showFilters = false;
  bool _filterUF = false;
  bool _filterBairro = false;
  bool _filterCidade = false;
  bool _filterMaxGuests = false;

  @override
  void initState() {
    super.initState();
    _loadProperties();
  }

  Future<void> _loadProperties() async {
    var db = DBADMN();
    try {
      List<dynamic> properties = await db.getAllProperties();
      setState(() {
        _properties = properties;
        _filteredProperties = properties;
      });
    } catch (e) {
      print("Erro ao carregar propriedades: $e");
    }
  }

  bool _isValidUrl(String url) {
    final Uri? uri = Uri.tryParse(url);
    return uri != null && uri.isAbsolute && (uri.scheme == 'http' || uri.scheme == 'https');
  }

  void _filterProperties() {
    String uf = _ufController.text.trim().toLowerCase();
    String bairro = _bairroController.text.trim().toLowerCase();
    String cidade = _cidadeController.text.trim().toLowerCase();
    int? maxGuests = int.tryParse(_maxGuestController.text.trim());

    setState(() {
      _filteredProperties = _properties.where((property) {
        return _matchesFilter(property, uf, bairro, cidade, maxGuests);
      }).toList();
    });
  }

  bool _matchesFilter(dynamic property, String uf, String bairro, String cidade, int? maxGuests) {
    return (!_filterUF || uf.isEmpty || property['uf'].toString().toLowerCase().contains(uf)) &&
           (!_filterBairro || bairro.isEmpty || property['bairro'].toString().toLowerCase().contains(bairro)) &&
           (!_filterCidade || cidade.isEmpty || property['localidade'].toString().toLowerCase().contains(cidade)) &&
           (!_filterMaxGuests || maxGuests == null || property['max_guest'] >= maxGuests);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Buscar Propriedade',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 0, 0, 0), // Dark app bar background
        elevation: 4, // Adding shadow to the app bar for depth
      ),
      body: Column(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: PopupMenuButton<String>(
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(value: 'logout', child: Text('Deslogar')),
                const PopupMenuItem<String>(value: 'reservas', child: Text('Minhas reservas')),
              ],
              onSelected: (String result) {
                if (result == 'logout') {
                  ONU().logout();
                  Navigator.pushNamedAndRemoveUntil(context, '/', (Route<dynamic> route) => false);
                }
              },
            ),
          ),

          // Botão para exibir/ocultar filtros
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _showFilters = !_showFilters;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[800], // Dark background color for the button
                padding: EdgeInsets.symmetric(vertical: 14.0, horizontal: 20.0), // Bigger button size
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // Rounded corners
              ),
              child: Text(
                _showFilters ? 'Ocultar Filtros' : 'Buscar por',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),

          // Campos de filtro (exibidos apenas se ativados)
          if (_showFilters) _buildFilterFields(),

          // Usando GridView para exibir as propriedades lado a lado
          Expanded(
            child: _filteredProperties.isEmpty
                ? Center(child: Text('Nenhuma propriedade encontrada', style: TextStyle(color: Colors.white, fontSize: 18)))
                : GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // Número de colunas
                      crossAxisSpacing: 10, // Espaço horizontal entre as colunas
                      mainAxisSpacing: 10, // Espaço vertical entre as linhas
                      childAspectRatio: 0.75, // Controla a proporção das células
                    ),
                    itemCount: _filteredProperties.length,
                    itemBuilder: (context, index) {
                      var property = _filteredProperties[index];
                      return _buildPropertyCard(property);
                    },
                  ),
          ),
        ],
      ),
      backgroundColor: Colors.black, // Dark background for the entire screen
    );
  }

  Widget _buildFilterFields() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Column(
        children: [
          _buildFilterCheckbox('Buscar por UF', _filterUF, (value) {
            setState(() => _filterUF = value!);
            _filterProperties();
          }, _ufController),
          _buildFilterCheckbox('Buscar por Bairro', _filterBairro, (value) {
            setState(() => _filterBairro = value!);
            _filterProperties();
          }, _bairroController),
          _buildFilterCheckbox('Buscar por Cidade', _filterCidade, (value) {
            setState(() => _filterCidade = value!);
            _filterProperties();
          }, _cidadeController),
          _buildFilterCheckbox('Máximo de Hóspedes', _filterMaxGuests, (value) {
            setState(() => _filterMaxGuests = value!);
            _filterProperties();
          }, _maxGuestController),
        ],
      ),
    );
  }

  Widget _buildFilterCheckbox(String title, bool value, Function(bool?) onChanged, TextEditingController controller) {
    return Column(
      children: [
        CheckboxListTile(
          title: Text(title, style: TextStyle(color: Colors.white, fontSize: 16)),
          value: value,
          onChanged: onChanged,
          activeColor: Colors.grey[800], // Active color for checkbox in dark mode
          controlAffinity: ListTileControlAffinity.leading, // Checkbox before title
        ),
        if (value)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: 'Digite o filtro',
                labelStyle: TextStyle(color: Colors.white),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey[600]!)),
              ),
              style: TextStyle(color: Colors.white),
              onChanged: (value) => _filterProperties(),
            ),
          ),
      ],
    );
  }

  Widget _buildPropertyCard(dynamic property) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: Card(
        color: Colors.grey[850], // Dark background for the card
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // Rounded corners for cards
        ),
        elevation: 5, // Adding shadow to the card for a lifted effect
        child: ListTile(
          contentPadding: EdgeInsets.all(15),
          title: Text(property['title'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(property['description'], style: TextStyle(fontSize: 16, color: Colors.white)),
                SizedBox(height: 8),
                _buildPropertyDetails(property),
                if (_isValidUrl(property['thumbnail']))
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10), // Rounded image corners
                      child: Image.network(
                        property['thumbnail'],
                        width: 200,
                        height: 150,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          onTap: () {
            Navigator.pushNamed(
              context,
              '/each_prop',
              arguments: property,
            );
          },
        ),
      ),
    );
  }

  Widget _buildPropertyDetails(dynamic property) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('UF: ${property['uf']}', style: TextStyle(color: Colors.grey[600])),
        Text('Localidade: ${property['localidade']}', style: TextStyle(color: Colors.grey[600])),
        Text('Bairro: ${property['bairro']}', style: TextStyle(color: Colors.grey[600])),
        Text('Máximo de hóspedes: ${property['max_guest']}', style: TextStyle(color: Colors.grey[600])),
        Text('Preço: \$${property['price']}', style: TextStyle(color: Colors.grey[600])),
        Text('Número: ${property['number']}', style: TextStyle(color: Colors.grey[600])),
        Text('Complemento: ${property['complement'] ?? 'Não possui'}', style: TextStyle(color: Colors.grey[600])),
      ],
    );
  }
}

// detalhes de uma propriedade
class DT extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Obtém os argumentos passados pelo Navigator
    final Map<String, dynamic>? property =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (property == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            "Detalhes da Propriedade",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.black,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        backgroundColor: Colors.black, // Fundo escuro
        body: Center(
          child: Text(
            "Nenhuma propriedade selecionada",
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          property['title'] ?? 'Detalhes da Propriedade',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.black, // Fundo escuro
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Nome: ${property['title']}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            SizedBox(height: 10),
            Text(
              'Localização: ${property['localidade']}',
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),
            Text(
              'Preço: \$${property['price']}',
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),
            SizedBox(height: 10),
            Text(
              'Máximo de hóspedes: ${property['max_guest']}',
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),
            Text(
              'UF: ${property['uf']}',
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),
            Text(
              'Bairro: ${property['bairro']}',
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),
            Text(
              'Número: ${property['number']}',
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),
            Text(
              'Complemento: ${property['complement'] ?? 'Não possui'}',
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),
            if (property['thumbnail'] != null && Uri.tryParse(property['thumbnail'])?.isAbsolute == true)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Image.network(
                  property['thumbnail'],
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            Spacer(),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white, // Cor do botão
                  foregroundColor: Colors.redAccent, // Cor do texto
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  // Ação ao clicar no botão
                },
                child: Text('Ver menu'),
              ),
            ),
            Spacer(),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent, // Cor do botão
                  foregroundColor: Colors.white, // Cor do texto
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  // Ação ao clicar no botão
                },
                child: Text('Reservar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// gerenciamento de propriedades +_+
class GP extends StatefulWidget {
  @override
  _GPState createState() => _GPState();
}

class _GPState extends State<GP> {
  // Função para criar o botão de navegação
  Widget _buildButton(String label, String route) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(context, route);
        },
        child: Text(
          label,
          style: TextStyle(color: Colors.white), // Texto branco para visibilidade
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Minhas propriedades',
          style: TextStyle(color: Colors.white), // Cor do texto na AppBar
        ),
        backgroundColor: const Color.fromARGB(255, 0, 0, 0), // Cor de fundo da AppBar preta
      ),
      backgroundColor: const Color.fromARGB(255, 0, 0, 0), // Cor de fundo da tela preta
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Opção de opções agrupadas
            ExpansionTile(
              title: Text(
                'Opções',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              iconColor: Colors.white, // Cor do ícone de expansão
              children: [
                // Organizando os botões em uma grid 2x2, mas mantendo o estilo atual
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 20, // Espaçamento horizontal entre os botões
                  runSpacing: 20, // Espaçamento vertical entre os botões
                  children: [
                    _buildButton('Registrar', '/create_prop'),
                    _buildButton('Minhas propriedades', '/list_prop'),
                    _buildButton('Excluir', '/delete_prop'),
                    _buildButton('Editar', '/edit_prop'),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


// cadastro de propriedades +_+
class CreatePropertyScreen extends StatefulWidget {
  @override
  _CreatePropertyScreenState createState() => _CreatePropertyScreenState();
}

class _CreatePropertyScreenState extends State<CreatePropertyScreen> {
  final _formKey = GlobalKey<FormState>(); // Chave global para o formulário de validação
  final _controllers = {
    'title': TextEditingController(),
    'description': TextEditingController(),
    'number': TextEditingController(),
    'complement': TextEditingController(),
    'price': TextEditingController(),
    'maxGuests': TextEditingController(),
    'thumbnail': TextEditingController(),
    'cep': TextEditingController(),
  };

  // A lista de 'File' foi removida pois não é compatível com a web.
  // final List<File> _imageFiles = []; 
  final ImagePicker _picker = ImagePicker();

  // Esta função foi desativada para a web.
  void addImageField() {
    setState(() {
      // _imageFiles.add(File('')); 
    });
  }

  // Esta função foi desativada para a web.
  Future<void> pickImage(int index) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        // A linha abaixo usa 'File' e não é compatível com a web.
        // _imageFiles[index] = File(pickedFile.path); 
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Informações da Propriedade',
          style: TextStyle(color: Colors.white), // Define a cor do título como branco
        ),
        centerTitle: true, // Centraliza o título da AppBar
        backgroundColor: const Color.fromARGB(255, 0, 0, 0), // Cor de fundo da AppBar (preto)
        iconTheme: IconThemeData(color: Colors.white), // Cor dos ícones na AppBar (branco)
        elevation: 0, // Remove a sombra da AppBar
      ),
      backgroundColor: Colors.black, // Fundo preto
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título do Formulário
                Text(
                  '',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                SizedBox(height: 20),

                // Campos de texto
                _buildTextField('Título', _controllers['title'], 'invalido'),
                _buildTextField('Descrição', _controllers['description'], 'invalido'),
                _buildTextField('Número', _controllers['number'], 'invalido', isNumber: true),
                _buildTextField('Complemento', _controllers['complement'], null),
                _buildTextField('Preço', _controllers['price'], 'invalido', isNumber: true),
                _buildTextField('Máximo de Hospedes', _controllers['maxGuests'], 'invalido', isNumber: true),
                _buildTextField('Link da imagem', _controllers['thumbnail'], 'invalido'),
                _buildTextField('CEP', _controllers['cep'], 'invalido', isNumber: true),

                SizedBox(height: 20),

                // A seção de imagens foi desativada para a web
                _buildImagePicker(),

                // Botão de submissão do formulário
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget para construir cada campo de texto do formulário
  Widget _buildTextField(String label, TextEditingController? controller, String? errorText, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: TextFormField(
        controller: controller,
        style: TextStyle(color: Colors.white), // Texto branco
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white), // Cor do texto do rótulo
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        ),
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return errorText;
          }
          if (isNumber && (int.tryParse(value) == null || double.tryParse(value) == null)) {
            return 'invalido';
          }
          return null;
        },
      ),
    );
  }

  // Widget para exibir e selecionar as imagens (desativado para a web)
  Widget _buildImagePicker() {
    // Retornando um widget vazio para não mostrar a funcionalidade na web.
    return Container();
  }

  // Botão de envio do formulário
  Widget _buildSubmitButton() {
    return Center(
      child: ElevatedButton(
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            var db = DBADMN();
            await db.insertProperty(
              _controllers['title']!.text,
              _controllers['description']!.text,
              int.parse(_controllers['number']!.text),
              _controllers['complement']!.text,
              double.parse(_controllers['price']!.text),
              int.parse(_controllers['maxGuests']!.text),
              _controllers['thumbnail']!.text,
              _controllers['cep']!.text,
              [], // Enviando uma lista vazia de imagens, pois a função foi desativada para a web
            );
            // Removido o SnackBar
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => GP()),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 12.0),
          child: Text('registrar', style: TextStyle(fontSize: 16, color: Colors.white)),
        ),
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          backgroundColor: Colors.blue,
        ),
      ),
    );
  }
}

// editar propriedades
class edt extends StatelessWidget {
  
  Future<List<Map<String, dynamic>>> _fetchProperties() async {
    var db = DBADMN();
    return await db.getUserProperties();
  }

  bool _isValidUrl(String url) {
    final Uri? uri = Uri.tryParse(url);
    return uri != null && uri.isAbsolute && (uri.scheme == 'http' || uri.scheme == 'https');
  }

  void _showEditDialog(BuildContext context, Map<String, dynamic> property) {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController(text: property['title']);
    final descriptionController = TextEditingController(text: property['description']);
    final maxGuestController = TextEditingController(text: property['max_guest'].toString());
    final priceController = TextEditingController(text: property['price'].toString());
    final numberController = TextEditingController(text: property['number'].toString());
    final complementController = TextEditingController(text: property['complement']);
    final thumbnailController = TextEditingController(text: property['thumbnail']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900], // Fundo escuro
          title: Text('Editar Propriedade', style: TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  _buildTextField(titleController, 'Título'),
                  _buildTextField(descriptionController, 'Descrição'),
                  _buildTextField(maxGuestController, 'Máximo de Hóspedes', isNumber: true),
                  _buildTextField(priceController, 'Preço', isNumber: true),
                  _buildTextField(numberController, 'Número', isNumber: true),
                  _buildTextField(complementController, 'Complemento'),
                  _buildTextField(thumbnailController, 'Link', isUrl: true),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancelar', style: TextStyle(color: Colors.grey[400])),
            ),
            TextButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  var db = DBADMN();
                  db.updateProperty(
                    property['id'],
                    titleController.text,
                    descriptionController.text,
                    int.parse(numberController.text),
                    complementController.text,
                    double.parse(priceController.text),
                    int.parse(maxGuestController.text),
                    thumbnailController.text
                  );
                  Navigator.of(context).pop();
                  // Recarregar a página
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => edt()),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Todos os campos devem ser preenchidos corretamente')),
                  );
                }
              },
              child: Text('Salvar', style: TextStyle(color: Colors.blueAccent)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool isNumber = false, bool isUrl = false}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white70),
        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.blueAccent)),
      ),
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: TextStyle(color: Colors.white),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'invalido';
        }
        if (isNumber && int.tryParse(value) == null) {
          return 'invalido';
        }
        if (isUrl && !_isValidUrl(value)) {
          return 'invalido';
        }
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edição de Propriedades', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchProperties(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: Colors.white));
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar propriedades', style: TextStyle(color: Colors.white)));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Nenhuma propriedade encontrada', style: TextStyle(color: Colors.white)));
          } else {
            final properties = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(10.0),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Número de colunas
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.8, // Ajusta a altura proporcionalmente à largura
                ),
                itemCount: properties.length,
                itemBuilder: (context, index) {
                  final property = properties[index];
                  return GestureDetector(
                    onTap: () => _showEditDialog(context, property),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[850],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_isValidUrl(property['thumbnail']))
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                property['thumbnail'],
                                width: double.infinity,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                          SizedBox(height: 8),
                          Text(
                            property['title'],
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                          ),
                          SizedBox(height: 4),
                          Text(
                            property['description'],
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 14, color: Colors.white70),
                          ),
                          Spacer(),
                          Text(
                            'Máx. hóspedes: ${property['max_guest'].toString()}',
                            style: TextStyle(color: Colors.grey[400], fontSize: 12),
                          ),
                          Text(
                            'Preço: \$${property['price'].toString()}',
                            style: TextStyle(color: Colors.grey[400], fontSize: 12),
                          ),
                          Text(
                            'Número: ${property['number'].toString()}',
                            style: TextStyle(color: Colors.grey[400], fontSize: 12),
                          ),
                          Text(
                            'Complemento: ${property['complement'] ?? 'Não possui'}',
                            style: TextStyle(color: Colors.grey[400], fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }
}

// tela de propriedades 
class lisl extends StatelessWidget {
  
  Future<List<Map<String, dynamic>>> _fetchProperties() async {
    var db = DBADMN();
    return await db.getUserProperties();
  }

  bool _isValidUrl(String url) {
    final Uri? uri = Uri.tryParse(url);
    return uri != null && uri.isAbsolute && (uri.scheme == 'http' || uri.scheme == 'https');
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Propriedades', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Color.fromARGB(255, 0, 0, 0),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchProperties(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: Colors.white));
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar propriedades', style: TextStyle(color: Colors.white)));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Nenhuma propriedade encontrada', style: TextStyle(color: Colors.white)));
          } else {
            final properties = snapshot.data!;
            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Definindo duas colunas
                crossAxisSpacing: 10, // Espaçamento entre as colunas
                mainAxisSpacing: 10, // Espaçamento entre as linhas
                childAspectRatio: 0.75, // Proporção entre largura e altura dos itens
              ),
              itemCount: properties.length,
              itemBuilder: (context, index) {
                final property = properties[index];
                return Container(
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 30, 30, 30),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        property['title'],
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                        overflow: TextOverflow.ellipsis, // Para evitar que o título ultrapasse
                      ),
                      SizedBox(height: 8),
                      Text(
                        property['description'],
                        style: TextStyle(fontSize: 14, color: Colors.white70),
                        overflow: TextOverflow.ellipsis, // Para evitar textos longos
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Máximo de hóspedes: ${property['max_guest'].toString()}',
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                      Text(
                        'Preço: \$${property['price'].toString()}',
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                      SizedBox(height: 8),
                      if (_isValidUrl(property['thumbnail']))
                        Container(
                          height: 120, // Definindo uma altura fixa para a imagem
                          width: double.infinity, // Imagem ocupará toda a largura do container
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            image: DecorationImage(
                              image: NetworkImage(property['thumbnail']),
                              fit: BoxFit.cover, // Garantindo que a imagem cubra o container sem distorcer
                            ),
                          ),
                        ),
                    ],
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

// criação de novo usuario +_+
class CNU extends StatefulWidget {
  @override
  _CNUState createState() => _CNUState();
}

class _CNUState extends State<CNU> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Process data
      String name = _nameController.text;
      String email = _emailController.text;
      String password = _passwordController.text;
      var db = DBADMN();
      var userCreated = await db.insertUser(name, email, password);
      if (userCreated) {
        // Retirado o SnackBar
        Navigator.pop(context);
      } else {
        // Retirado o SnackBar
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Criar nova conta', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: SingleChildScrollView(  // Adicionando rolagem
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 32.0), // Espaçamento maior
          child: Container(
            decoration: BoxDecoration(
              color: const Color.fromARGB(221, 255, 255, 255),
              borderRadius: BorderRadius.circular(20), // Bordas arredondadas
              boxShadow: [
                BoxShadow(
                  color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.4),
                  spreadRadius: 4,
                  blurRadius: 8,
                  offset: Offset(0, 4), // Sombra mais sutil
                ),
              ],
            ),
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch, // Stretching os campos
                children: <Widget>[
                  Text(
                    'Crie sua conta',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color.fromARGB(255, 0, 0, 0),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 40),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Nome',
                      labelStyle: TextStyle(color: const Color.fromARGB(255, 0, 0, 0)),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: const Color.fromARGB(255, 0, 0, 0)),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: const Color.fromARGB(255, 0, 0, 0)),
                      ),
                    ),
                    style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0)),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'invalido';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: TextStyle(color: const Color.fromARGB(255, 0, 0, 0)),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: const Color.fromARGB(255, 0, 0, 0)),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: const Color.fromARGB(255, 0, 0, 0)),
                      ),
                    ),
                    style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0)),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'invalido';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Senha',
                      labelStyle: TextStyle(color: const Color.fromARGB(255, 0, 0, 0)),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: const Color.fromARGB(255, 0, 0, 0)),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: const Color.fromARGB(255, 0, 0, 0)),
                      ),
                    ),
                    obscureText: true,
                    style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0)),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'invalido';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: _submitForm,
                    child: Text(
                    'Criar Conta',
                    style: TextStyle(color: Colors.black),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 243, 33, 33),
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      textStyle: TextStyle(fontSize: 16, color: const Color.fromARGB(255, 0, 0, 0)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30), // Botão com bordas arredondadas
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// responsavel pela tele pos login
class poslogin extends StatefulWidget {
  @override
  _posloginState createState() => _posloginState();
}

class _posloginState extends State<poslogin> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Menu de opções',
          style: TextStyle(color: Colors.white), // Texto branco na AppBar
        ),
        backgroundColor: Colors.black, // Cor de fundo da AppBar preta
      ),
      backgroundColor: const Color.fromARGB(255, 0, 0, 0), // Cor de fundo da tela preta
      drawer: Drawer(
        backgroundColor: Colors.black, // Cor de fundo da Drawer
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
              ),
              child: Text(
                'Menu de Opções',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.house, color: Colors.white), // Ícone de casa
              title: Text(
                'Minhas propriedades',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                print(ONU().id);
                Navigator.pushNamed(context, '/manage_prop');
              },
            ),
            ListTile(
              leading: Icon(Icons.search, color: Colors.white), // Ícone de lupa
              title: Text(
                'Pesquizar',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                print(ONU().id);
                Navigator.pushNamed(context, '/rent_prop');
              },
            ),
            // Adicionando o botão de logout para retornar à tela de login
            Spacer(), // Espaço para empurrar o botão para o final da lista
            ListTile(
              leading: Icon(Icons.exit_to_app, color: Colors.white), // Ícone de sair
              title: Text(
                'Sair',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                // Aqui você pode adicionar a lógica para deslogar o usuário
                Navigator.pushNamedAndRemoveUntil(context, '/', (Route<dynamic> route) => false);
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Text(
          'Bem-vindo ao menu de opções!',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
    );
  }
}

// responsavel pela tela de login +_+
class TLG extends StatefulWidget {
  @override
  _TLGState createState() => _TLGState();
}

class _TLGState extends State<TLG> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _validateLogin() async {
    try {
      var db = DBADMN();
      final username = _usernameController.text;
      final password = _passwordController.text;

      final user = await db.checkCredentials(username, password);

      if (!mounted) return;

      if (user != null) {
        int userId = user['id'];
        ONU().setUser(userId);
        // Retirado o SnackBar
        Navigator.pushNamed(context, '/intermed');
      } else {
        // Retirado o SnackBar
      }
    } catch (e) {
      print("Erro ao validar login: $e");
      // Retirado o SnackBar
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ifood',
          style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0)),
        ),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        iconTheme: IconThemeData(color: Colors.black), // Garante que o ícone do menu seja preto
      ),
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      drawer: Drawer(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 255, 255, 255),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Ifood',
                    style: TextStyle(
                      color: const Color.fromARGB(255, 0, 0, 0), // Texto visível
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.person_add, color: const Color.fromARGB(255, 0, 0, 0)),
              title: Text(
                'Criar Conta',
                style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0)),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CNU()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.login, color: const Color.fromARGB(255, 0, 0, 0)),
              title: Text(
                'Entrar anônimo',
                style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0)),
              ),
              onTap: () {
                Navigator.pushNamed(context, '/rent_prop');
                // Retirado o SnackBar
              },
            ),
            ListTile(
              leading: Icon(Icons.delivery_dining, color: const Color.fromARGB(255, 0, 0, 0)),
              title: Text(
                'Sou Entregador',
                style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0)),
              ),
              onTap: () {
                Navigator.pushNamed(context, Abaentregador.routeName);
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Nome',
                    labelStyle: TextStyle(color: const Color.fromARGB(255, 0, 0, 0)),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: const Color.fromARGB(255, 0, 0, 0)),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: const Color.fromARGB(255, 0, 0, 0)),
                    ),
                  ),
                  style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0)),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'invalido';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    labelStyle: TextStyle(color: const Color.fromARGB(255, 0, 0, 0)),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: const Color.fromARGB(255, 0, 0, 0)),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: const Color.fromARGB(255, 0, 0, 0)),
                    ),
                  ),
                  obscureText: true,
                  style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0)),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'invalido';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _validateLogin();
                    }
                  },
                  child: Text(
                  'Entrar',
                  style: TextStyle(color: Colors.black),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 255, 0, 0),
                    padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 40.0),
                    textStyle: TextStyle(fontSize: 16, color: const Color.fromARGB(255, 0, 0, 0)),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Cardapio()),
                  );
                  },
                  child: Text(
                  'Cardápio',
                  style: TextStyle(color: Colors.black),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 255, 0, 0),
                    padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 40.0),
                    textStyle: TextStyle(fontSize: 16, color: const Color.fromARGB(255, 0, 0, 0)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}


// codigo main +_+
void main() => runApp(Main()); // Inicia o aplicativo Flutter, executando o widget Main

class Main extends StatelessWidget {
  const Main({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Desativa o banner de depuração (para produção)
      title: 'Flutter Demo', // Título do aplicativo
      theme: _buildAppTheme(), // Aplica o tema do aplicativo (cores e estilo)
      initialRoute: '/', // Rota inicial
      routes: _defineRoutes(), // Rotas nomeadas do aplicativo
      onUnknownRoute: _handleUnknownRoute, // Lidar com rotas desconhecidas
    );
  }

  // Função para criar e retornar o tema do aplicativo
  ThemeData _buildAppTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      useMaterial3: true, // Usa o Material 3 para design moderno
    );
  }

  // Função que define as rotas do aplicativo
  Map<String, WidgetBuilder> _defineRoutes() {
    return {
      '/': (context) => TLG(), // Tela inicial de login
      '/intermed': (context) => poslogin(), // Tela intermediária
      '/manage_prop': (context) => GP(), // Gerenciamento de propriedades
      '/rent_prop': (context) => AL(), // Tela para alugar propriedades
      '/create_prop': (context) => CreatePropertyScreen(), // Tela para criar uma propriedade
      '/list_prop': (context) => lisl(), // Tela para listar propriedades
      '/edit_prop': (context) => edt(), // Tela para editar propriedades
      '/each_prop': (context) => DT(), // Tela de detalhes de uma propriedadez
      '/delete_prop': (context) => del(),// Tela de deletar uma propriedade
      
      // Rotas adicionadas para o entregador
      Abaentregador.routeName: (context) => Abaentregador.name("Nome do Entregador"), // Rota para a tela do entregador
      AbaPedidosEntregador.routeName: (context) => AbaPedidosEntregador(), // Rota para a lista de pedidos

      '/Cardapio': (context) => Cardapio() // Rota para o cardápio
    };
  }

  // Função para lidar com rotas desconhecidas
  MaterialPageRoute _handleUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(title: const Text('Erro')), // Título da tela de erro
        body: Center(
          // Mensagem informando que a rota não foi encontrada
          child: Text('Rota não encontrada: ${settings.name}'),
        ),
      ),
    );
  }
}
