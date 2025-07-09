class ONU {
  // Instância única do Singleton
  static final ONU _instance = ONU._internal();

  // ID do usuário (pode ser null caso o usuário não esteja logado)
  int? id;

  // Fábrica que retorna sempre a mesma instância
  factory ONU() {
    return _instance;
  }

  // Construtor privado que só pode ser chamado internamente
  ONU._internal();

  // Define o ID do usuário
  void setUser(int userId) {
    id = userId;
  }

  // Recupera o ID do usuário
  int? getUser() {
    return id;
  }

  // Verifica se o usuário está logado
  bool isLoggedIn() {
    return id != null;
  }

  // Realiza o logout, limpando o ID
  void logout() {
    id = null;
    print('Usuário deslogado');
  }
}