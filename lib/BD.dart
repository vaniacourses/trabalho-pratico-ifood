import 'package:flutter/foundation.dart';
import 'package:projetofinal/uson.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class DBADMN {
  // Inicializa o banco de dados
  Future<Database> initializeDatabase() async {
    DatabaseFactory databaseFactory;

    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
    } else {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final path = 'DB.db';

    return await databaseFactory.openDatabase(path,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: _onCreate,
        ));
  }

  Future<void> _insertInitialPedidos(Database db) async {
    final pedidos = [
      {'nomeCliente': 'João Silva', 'endereco': 'Rua das Flores, 123', 'status': 'Pendente'},
      {'nomeCliente': 'Maria Santos', 'endereco': 'Avenida Brasil, 456', 'status': 'Em trânsito'},
      {'nomeCliente': 'Carlos Oliveira', 'endereco': 'Praça da Sé, 789', 'status': 'Entregue'},
      {'nomeCliente': 'Ana Costa', 'endereco': 'Rua da Paz, 101', 'status': 'Pendente'},
    ];

    for (var pedido in pedidos) {
      await db.insert('pedidos', pedido, conflictAlgorithm: ConflictAlgorithm.ignore);
    }
  }

  Future<void> _insertInitialItems(Database db) async {
    final items = [
      {'cardapio_id': '0', 'nome': 'Pão de queijo', 'descricao': 'Pão de queijo mineiro', 'preco': '1 real', 'thumbnail': 'https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fbloogao.com%2Fwp-content%2Fuploads%2F2023%2F05%2Fpao-de-queijo.jpg&f=1&nofb=1&ipt=09fb4e0b81e6aaeadaec27bceaf93bedee777205005d85f27a98bc9ec2a5f684'},
      {'cardapio_id': '0', 'nome': 'Tijolo', 'descricao': 'Tijolo tradicional de cerâmica', 'preco': '25 centavos', 'thumbnail': 'https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fd2r9epyceweg5n.cloudfront.net%2Fstores%2F003%2F317%2F653%2Fproducts%2Ftijolo-ceramico-tipo-baianao-115-x-14-x24-medidas2-b4ce3e8dcee92bec0516884127892614-1024-1024.png&f=1&nofb=1&ipt=5eafcf4e4559d76b2a9b1fb54c7a29652b3d033202bcd814a9996f860401d090'}
    ];
    for (var item in items) {
      await db.insert('item', item, conflictAlgorithm: ConflictAlgorithm.ignore);
    }
  }

  // Criação das tabelas no banco de dados
  Future<void> _onCreate(Database db, int version) async {
    // [CORREÇÃO 1]: A tabela 'user' agora está entre aspas para evitar conflito com a palavra reservada do SQL.
    final createUserTable = '''CREATE TABLE "user" (
        id INTEGER PRIMARY KEY AUTOINCREMENT, 
        name TEXT NOT NULL, 
        email TEXT NOT NULL, 
        password TEXT NOT NULL
      )''';
      
    final createAddressTable = '''CREATE TABLE address (
        id INTEGER PRIMARY KEY AUTOINCREMENT, 
        cep TEXT NOT NULL UNIQUE, 
        logradouro TEXT NOT NULL, 
        bairro TEXT NOT NULL, 
        localidade TEXT NOT NULL, 
        uf TEXT NOT NULL, 
        estado TEXT 
      )''';
      
    // [CORREÇÃO 2]: A referência à tabela 'user' na chave estrangeira também foi colocada entre aspas.
    final createPropertyTable = '''CREATE TABLE property (
        id INTEGER PRIMARY KEY AUTOINCREMENT, 
        user_id INTEGER NOT NULL, 
        address_id INTEGER NOT NULL, 
        title TEXT NOT NULL, 
        description TEXT NOT NULL, 
        number INTEGER NOT NULL, 
        complement TEXT, 
        price REAL NOT NULL, 
        max_guest INTEGER NOT NULL, 
        thumbnail TEXT NOT NULL,
        FOREIGN KEY(user_id) REFERENCES "user"(id),
        FOREIGN KEY(address_id) REFERENCES address(id)
      )''';
      
    final createImagesTable = '''CREATE TABLE images (
        id INTEGER PRIMARY KEY AUTOINCREMENT, 
        property_id INTEGER NOT NULL, 
        path TEXT NOT NULL,
        FOREIGN KEY(property_id) REFERENCES property(id)
      )''';

    // [CORREÇÃO 3]: A referência à tabela 'user' aqui também foi corrigida.
    final createBookingTable = '''CREATE TABLE booking (
        id INTEGER PRIMARY KEY AUTOINCREMENT, 
        user_id INTEGER NOT NULL, 
        property_id INTEGER NOT NULL, 
        checkin_date TEXT NOT NULL, 
        checkout_date TEXT NOT NULL, 
        total_days INTEGER NOT NULL, 
        total_price REAL NOT NULL, 
        amount_guest INTEGER NOT NULL, 
        rating REAL, 
        FOREIGN KEY(user_id) REFERENCES "user"(id),
        FOREIGN KEY(property_id) REFERENCES property(id)
      )''';
    
    final createPedidosTable = '''CREATE TABLE pedidos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nomeCliente TEXT NOT NULL,
        endereco TEXT NOT NULL,
        status TEXT NOT NULL
      )''';

    final createCardapioTable = '''CREATE TABLE cardapio (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        dono_id INTEGER NOT NULL,
        FOREIGN KEY(dono_id) REFERENCES user(id)
      )''';
      
    final createItemTable = '''CREATE TABLE item (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        cardapio_id INTEGER NOT NULL,
        nome TEXT NOT NULL,
        descricao TEXT,
        preco REAL NOT NULL,
        thumbnail TEXT,
        FOREIGN KEY(cardapio_id) REFERENCES cardapio(id)
      )''';

    await Future.wait([
      db.execute(createUserTable),
      db.execute(createAddressTable),
      db.execute(createPropertyTable),
      db.execute(createImagesTable),
      db.execute(createBookingTable),
      db.execute(createPedidosTable),
      db.execute(createCardapioTable),// Adicionada a execução
      db.execute(createItemTable)
    ]);
    
    await _insertInitialPedidos(db);

    await _insertInitialItems(db);
    print('Database initialized');
  }

  // Insere um novo usuário
  Future<bool> insertUser(String name, String email, String password) async {
    final db = await initializeDatabase();
    // [CORREÇÃO 4]: Usando o nome da tabela com aspas aqui também.
    await db.insert(
        '"user"', {'name': name, 'email': email, 'password': password},
        conflictAlgorithm: ConflictAlgorithm.replace);
    print('User inserted');
    return true;
  }

  // Verifica as credenciais de um usuário
  Future<Map<String, dynamic>?> checkCredentials(
      String name, String password) async {
    final db = await initializeDatabase();
    // [CORREÇÃO 5]: E aqui também.
    final result = await db.query('"user"',
        where: 'name = ? AND password = ?', whereArgs: [name, password]);

    if (result.isNotEmpty) {
      print('Usuário encontrado');
      return result.first;
    } else {
      print('Usuário não encontrado');
      return null;
    }
  }
  
  // NOVA FUNÇÃO para buscar todos os pedidos
  Future<List<Map<String, dynamic>>> getAllPedidos() async {
    final db = await initializeDatabase();
    return await db.query('pedidos');
  }

  // Insere uma nova propriedade
  Future<void> insertProperty(
      String title,
      String description,
      int number,
      String? complement,
      double price,
      int maxGuest,
      String thumbnail,
      String cep,
      List<String> images) async {
    final db = await initializeDatabase();
    final userId = ONU().id;
    final addressId = await createAddress(cep);

    final propertyId = await db.insert(
        'property',
        {
          'user_id': userId,
          'address_id': addressId,
          'title': title,
          'description': description,
          'number': number,
          'complement': complement,
          'price': price,
          'max_guest': maxGuest,
          'thumbnail': thumbnail,
        },
        conflictAlgorithm: ConflictAlgorithm.replace);

    print('Property inserted');

    // Inserir as imagens associadas à propriedade
    for (final image in images) {
      await db.insert('images', {'property_id': propertyId, 'path': image},
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  // Cria ou busca um endereço pelo CEP
  Future<int> createAddress(String cep) async {
    final db = await initializeDatabase();
    final response =
        await http.get(Uri.parse('https://viacep.com.br/ws/$cep/json/'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data['erro'] != null) {
        throw Exception('CEP não encontrado');
      }

      final isCepInDatabase = await db.query('address',
          where: 'cep = ?', whereArgs: [data['cep']], limit: 1);
      if (isCepInDatabase.isNotEmpty) return isCepInDatabase.first['id'] as int;

      final addressId = await db.insert(
          'address',
          {
            'cep': data['cep'],
            'logradouro': data['logradouro'],
            'bairro': data['bairro'],
            'localidade': data['localidade'],
            'uf': data['uf'],
            'estado': data['estado'],
          },
          conflictAlgorithm: ConflictAlgorithm.replace);

      return addressId;
    } else {
      throw Exception('Erro ao buscar o CEP');
    }
  }

  // Retorna as propriedades do usuário
  Future<List<Map<String, dynamic>>> getUserProperties() async {
    final db = await initializeDatabase();
    final userId = ONU().id;
    return await db
        .query('property', where: 'user_id = ?', whereArgs: [userId]);
  }

  Future<List<Map<String, dynamic>>> getCardapioItems() async {
    final db = await initializeDatabase();
    
    return await db.rawQuery('''SELECT * FROM item''');
  }

  // Retorna todas as propriedades
  Future<List<Map<String, dynamic>>> getAllProperties() async {
    final db = await initializeDatabase();
    return await db.rawQuery('''SELECT 
        property.*, 
        address.uf, 
        address.localidade,
        address.bairro
      FROM property
      JOIN address ON property.address_id = address.id''');
  }

  // Exclui uma propriedade
  Future<void> deleteProperty(int propertyId) async {
    final db = await initializeDatabase();
    await db.delete('property', where: 'id = ?', whereArgs: [propertyId]);
    print('Property deleted');
  }

  // Atualiza uma propriedade
  Future<void> updateProperty(
      int propertyId,
      String title,
      String description,
      int number,
      String? complement,
      double price,
      int maxGuest,
      String thumbnail) async {
    final db = await initializeDatabase();
    await db.update(
        'property',
        {
          'title': title,
          'description': description,
          'number': number,
          'complement': complement,
          'price': price,
          'max_guest': maxGuest,
          'thumbnail': thumbnail,
        },
        where: 'id = ?',
        whereArgs: [propertyId]);
    print('Property updated');
  }


}
