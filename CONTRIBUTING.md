# 🤝 Guia de Contribuição - EstoqueMax

Obrigado por considerar contribuir com o **EstoqueMax**! 🎉

Este documento fornece diretrizes e informações sobre como contribuir efetivamente para o projeto.

## 📋 Índice

- [Código de Conduta](#-código-de-conduta)
- [Como Posso Contribuir?](#-como-posso-contribuir)
- [Configuração do Ambiente](#-configuração-do-ambiente)
- [Processo de Desenvolvimento](#-processo-de-desenvolvimento)
- [Padrões de Código](#-padrões-de-código)
- [Testes](#-testes)
- [Documentação](#-documentação)

## 📜 Código de Conduta

Este projeto segue o [Código de Conduta do Contributor Covenant](https://www.contributor-covenant.org/). Ao participar, você concorda em manter um ambiente respeitoso e acolhedor.

### ✅ Comportamento Esperado
- Use linguagem acolhedora e inclusiva
- Respeite diferentes pontos de vista
- Aceite críticas construtivas
- Foque no que é melhor para a comunidade
- Mostre empatia com outros membros

### ❌ Comportamento Inaceitável
- Linguagem ou imagens sexualizadas
- Comentários insultuosos ou pejorativos
- Assédio público ou privado
- Publicar informações privadas sem permissão
- Qualquer conduta inadequada profissionalmente

## 🚀 Como Posso Contribuir?

### 🐛 Reportando Bugs
1. Use o template de [Bug Report](.github/ISSUE_TEMPLATE/bug_report.md)
2. Verifique se o bug já foi reportado
3. Inclua informações detalhadas e reproduzíveis
4. Adicione screenshots/videos quando relevante

### ✨ Sugerindo Funcionalidades
1. Use o template de [Feature Request](.github/ISSUE_TEMPLATE/feature_request.md)
2. Explique o problema que a funcionalidade resolve
3. Descreva a solução proposta
4. Considere alternativas

### 💻 Contribuindo com Código
1. Faça fork do repositório
2. Crie uma branch seguindo o [Git Flow](GITFLOW.md)
3. Implemente suas mudanças
4. Escreva/atualize testes
5. Execute o linter e testes
6. Crie um Pull Request

### 📝 Melhorando Documentação
- Correções de typos
- Clarificações em explicações
- Novos tutoriais ou guias
- Tradução para outros idiomas

## 🛠️ Configuração do Ambiente

### Pré-requisitos
```bash
# Ferramentas necessárias
- Flutter SDK 3.24.0+
- Dart SDK 3.5.0+
- Git 2.40+
- IDE (VS Code/Android Studio)
```

### Setup Inicial
```bash
# 1. Fork e clone o repositório
git clone https://github.com/SEU_USERNAME/estoque-max.git
cd estoque-max

# 2. Configure o upstream
git remote add upstream https://github.com/AbsonDev/estoque-max.git

# 3. Instale dependências Flutter
cd estoque_app_mobile
flutter pub get

# 4. Execute testes para verificar setup
flutter test

# 5. Execute o linter
flutter analyze
```

### Configuração IDE

#### VS Code
Instale as extensões recomendadas:
```json
{
  "recommendations": [
    "dart-code.flutter",
    "dart-code.dart-code",
    "ms-vscode.vscode-json",
    "bradlc.vscode-tailwindcss"
  ]
}
```

#### Android Studio
- Plugin Flutter
- Plugin Dart
- Git integration

## 🔄 Processo de Desenvolvimento

### 1. 📋 Planejamento
- Escolha uma issue ou crie uma nova
- Comente na issue que você vai trabalhar nela
- Discuta a abordagem se necessário

### 2. 🌿 Criação da Branch
```bash
# Para features
git checkout develop
git pull upstream develop
git checkout -b feature/EST-123-nome-da-funcionalidade

# Para bugfixes
git checkout develop
git pull upstream develop
git checkout -b bugfix/EST-456-corrigir-bug

# Para hotfixes
git checkout main
git pull upstream main
git checkout -b hotfix/1.2.1-corrigir-urgente
```

### 3. 💻 Desenvolvimento
- Faça commits pequenos e frequentes
- Use mensagens de commit descritivas
- Siga os padrões de código estabelecidos
- Escreva testes para novas funcionalidades

### 4. 🧪 Testes
```bash
# Execute todos os testes
flutter test

# Execute com coverage
flutter test --coverage

# Execute análise de código
flutter analyze

# Formate o código
dart format .
```

### 5. 📤 Pull Request
- Use o template de PR
- Preencha todas as seções
- Adicione screenshots/videos
- Marque reviewers apropriados

## 📐 Padrões de Código

### 🎯 Convenções de Nomenclatura
```dart
// Classes: PascalCase
class ProductService {}

// Variáveis/Funções: camelCase
String userName = '';
void fetchUserData() {}

// Constantes: SCREAMING_SNAKE_CASE
const String API_BASE_URL = '';

// Arquivos: snake_case
user_service.dart
product_repository.dart
```

### 🏗️ Estrutura de Arquivos
```
lib/
├── core/
│   ├── models/
│   ├── services/
│   └── theme/
├── features/
│   └── feature_name/
│       ├── data/
│       │   ├── models/
│       │   └── services/
│       └── presentation/
│           ├── screens/
│           ├── widgets/
│           └── bloc/
└── shared/
```

### 🎨 Formatação
- Use `dart format` para formatação automática
- Linha máxima: 80 caracteres
- Indentação: 2 espaços
- Vírgula trailing obrigatória

### 📋 Linting
O projeto segue as regras do `flutter_lints`:
```yaml
# analysis_options.yaml
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    prefer_const_constructors: true
    prefer_const_literals_to_create_immutables: true
    avoid_print: true
```

## 🧪 Testes

### 📊 Cobertura Esperada
- **Mínimo**: 80% de cobertura geral
- **Services**: 90%+ de cobertura
- **Models**: 100% de cobertura
- **UI**: 70%+ de cobertura

### 🏷️ Tipos de Testes
```bash
# Testes Unitários
test/unit/

# Testes de Widget
test/widget/

# Testes de Integração
test/integration/

# Testes End-to-End
integration_test/
```

### ✅ Exemplo de Teste
```dart
// test/unit/services/auth_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

void main() {
  group('AuthService', () {
    late AuthService authService;
    late MockApiService mockApiService;

    setUp(() {
      mockApiService = MockApiService();
      authService = AuthService(mockApiService);
    });

    test('deve fazer login com credenciais válidas', () async {
      // Arrange
      when(() => mockApiService.login(any()))
          .thenAnswer((_) async => AuthResponse(token: 'valid_token'));

      // Act
      final result = await authService.login('test@email.com', 'password');

      // Assert
      expect(result.isSuccess, true);
      expect(result.data?.token, 'valid_token');
    });
  });
}
```

## 📚 Documentação

### ✅ Comentários de Código
```dart
/// Serviço responsável pela autenticação de usuários.
/// 
/// Implementa login tradicional, login social e gerenciamento
/// de tokens JWT de forma segura.
class AuthService {
  /// Realiza login com email e senha.
  /// 
  /// [email] deve ser um email válido
  /// [password] deve ter pelo menos 6 caracteres
  /// 
  /// Retorna [AuthResult] com token ou erro
  Future<AuthResult> login(String email, String password) async {
    // implementação...
  }
}
```

### 📖 README
- Mantenha instruções atualizadas
- Inclua exemplos de uso
- Documente mudanças de API

### 🔄 CHANGELOG
- Documente todas as mudanças
- Siga o padrão [Keep a Changelog](https://keepachangelog.com/)
- Inclua breaking changes

## 🔍 Review Process

### 👀 Como Revisar
1. Verifique funcionalidade
2. Analise qualidade do código
3. Teste performance
4. Valide segurança
5. Confirme documentação

### ✅ Checklist do Reviewer
- [ ] Código segue padrões estabelecidos
- [ ] Testes adequados implementados
- [ ] Performance não foi degradada
- [ ] Documentação atualizada
- [ ] Sem breaking changes desnecessários
- [ ] UI/UX seguem design system

## 🆘 Precisa de Ajuda?

### 💬 Canais de Comunicação
- **Issues**: Para bugs e features
- **Discussions**: Para perguntas gerais
- **Email**: Para questões privadas

### 📚 Recursos Úteis
- [Documentação Flutter](https://flutter.dev/docs)
- [Git Flow Guide](GITFLOW.md)
- [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)

## 🙏 Reconhecimento

Contribuidores serão adicionados ao [CONTRIBUTORS.md](CONTRIBUTORS.md) e reconhecidos nas release notes.

### 🏆 Tipos de Contribuição
- 💻 Código
- 📖 Documentação
- 🐛 Bug Reports
- 💡 Ideias
- 🎨 Design
- 🌍 Tradução

---

**Obrigado por contribuir com o EstoqueMax!** 🚀

Suas contribuições tornam este projeto melhor para todos! 💙 