# 📋 Documentação da Arquitetura - EstoqueMax

## 🎯 Visão Geral do Projeto

O **EstoqueMax** é uma plataforma completa de gestão de estoque familiar/doméstico que combina funcionalidades modernas como IA, tempo real, partilha familiar e modelo freemium. O projeto é composto por:

- **Backend API**: ASP.NET Core 6+ com Entity Framework
- **Mobile App**: Flutter multiplataforma
- **Funcionalidades Avançadas**: IA para previsão, SignalR para tempo real, sistema de assinaturas

---

## 🏗️ Arquitetura Geral

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Flutter App   │    │  ASP.NET API    │    │   SQLite/Postgres│
│   (Mobile/Web)  │◄──►│   Backend       │◄──►│   Database      │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                              │
                       ┌─────────────────┐
                       │    SignalR      │
                       │  (Tempo Real)   │
                       └─────────────────┘
```

---

## 🎯 Principais Funcionalidades Implementadas

### ✅ Funcionalidades Core
- [x] **Gestão de Estoque** - CRUD completo de produtos e quantidades
- [x] **Sistema de Despensas** - Múltiplas despensas por usuário
- [x] **Partilha Familiar** - Convites e acesso compartilhado
- [x] **Lista de Compras** - Geração automática baseada em estoque mínimo
- [x] **Autenticação JWT** - Login tradicional + Google Sign-In
- [x] **Modelo Freemium** - Planos Free e Premium com Stripe
- [x] **Tempo Real** - Notificações via SignalR
- [x] **IA de Previsão** - Consumo inteligente baseado em histórico
- [x] **Analytics** - Dashboard com insights e métricas

---

## 🗂️ Estrutura do Backend (ASP.NET Core)

### 📁 Estrutura de Diretórios
```
EstoqueMax/EstoqueApp.Api/
├── Controllers/           # Endpoints da API
│   ├── AuthController.cs          # Autenticação/Login
│   ├── EstoqueController.cs       # Gestão de estoque
│   ├── DespensasController.cs     # Gestão de despensas
│   ├── ProdutosController.cs      # Catálogo de produtos
│   ├── ListaDeComprasController.cs # Lista de compras
│   ├── ConvitesController.cs      # Sistema de convites
│   ├── SubscriptionController.cs  # Assinaturas/Pagamentos
│   ├── PaymentsController.cs      # Processamento Stripe
│   └── AnalyticsController.cs     # Dashboard e métricas
├── Models/                # Entidades do banco de dados
│   ├── Usuario.cs                 # Usuários do sistema
│   ├── Despensa.cs               # Despensas/armazéns
│   ├── Produto.cs                # Catálogo de produtos
│   ├── EstoqueItem.cs            # Itens do estoque
│   ├── ListaDeComprasItem.cs     # Itens da lista de compras
│   ├── MembroDespensa.cs         # Relacionamento usuário-despensa
│   ├── ConviteDespensa.cs        # Sistema de convites
│   └── HistoricoConsumo.cs       # Histórico para IA
├── Services/              # Lógica de negócio
│   ├── IPermissionService.cs     # Interface de permissões
│   ├── PermissionService.cs      # Controle de acesso
│   ├── SubscriptionService.cs    # Gestão de assinaturas
│   ├── Analytics/
│   │   ├── IAnalyticsService.cs  # Interface de analytics
│   │   └── AnalyticsService.cs   # Métricas e insights
│   └── AI/
│       ├── PredictionService.cs          # IA de previsão
│       └── AITrainingBackgroundService.cs # Treinamento em background
├── Hubs/                  # SignalR para tempo real
│   └── EstoqueHub.cs             # Hub principal
├── Data/                  # Contexto do banco
│   └── EstoqueContext.cs         # EF Core Context
├── Dtos/                  # Objetos de transferência
├── Migrations/            # Migrações do EF Core
└── Program.cs             # Configuração da aplicação
```

### 🔑 Tecnologias e Padrões Backend
- **Framework**: ASP.NET Core 6+
- **ORM**: Entity Framework Core
- **Banco**: SQLite (dev) / PostgreSQL (prod)
- **Autenticação**: JWT Bearer + Google OAuth
- **Tempo Real**: SignalR
- **Pagamentos**: Stripe
- **Arquitetura**: Repository Pattern + Services
- **Documentação**: Swagger/OpenAPI

---

## 📱 Estrutura do Mobile (Flutter)

### 📁 Estrutura de Diretórios
```
estoque_app_mobile/
├── lib/
│   ├── main.dart              # Ponto de entrada
│   ├── core/                  # Funcionalidades centrais
│   │   ├── theme/            # Temas e estilos
│   │   ├── services/         # Serviços HTTP/API
│   │   └── models/           # Modelos de dados
│   └── features/             # Funcionalidades por módulo
│       └── auth/             # Autenticação/Login
├── assets/
│   └── images/               # Imagens e recursos
├── pubspec.yaml              # Dependências Flutter
└── [plataformas]/            # android/, ios/, web/, windows/
```

### 📦 Principais Dependências Flutter
```yaml
dependencies:
  flutter_bloc: ^9.1.1          # Gerência de estado
  dio: ^5.8.0                   # Cliente HTTP
  google_sign_in: ^7.1.0        # Login Google
  flutter_secure_storage: ^9.2.4 # Armazenamento seguro
  google_fonts: ^6.2.1          # Fontes Google
  equatable: ^2.0.7             # Comparação de objetos
```

---

## 🗄️ Modelo de Dados

### 📊 Entidades Principais

#### 👤 Usuario
```csharp
public class Usuario {
    int Id
    string Nome, Email
    string? SenhaHash
    string? Provider          // "Email", "Google"
    TipoDePlano Plano         // Free, Premium
    DateTime? DataExpiracaoAssinatura
    
    // Relacionamentos
    ICollection<ListaDeComprasItem> ListaDeCompras
    ICollection<MembroDespensa> AcessosDespensa
    ICollection<ConviteDespensa> ConvitesEnviados
    ICollection<ConviteDespensa> ConvitesRecebidos
}
```

#### 🏠 Despensa
```csharp
public class Despensa {
    int Id
    string Nome
    DateTime DataCriacao
    
    // Relacionamentos
    ICollection<EstoqueItem> EstoqueItens
    ICollection<MembroDespensa> Membros
    ICollection<ConviteDespensa> Convites
}
```

#### 📦 EstoqueItem
```csharp
public class EstoqueItem {
    int Id
    int DespensaId, ProdutoId
    int Quantidade, QuantidadeMinima
    DateTime? DataValidade
    
    // Relacionamentos
    Despensa Despensa
    Produto Produto
}
```

#### 🤝 Sistema de Partilha
```csharp
public class MembroDespensa {         // Many-to-Many
    int UsuarioId, DespensaId
    TipoDePermissao Permissao        // Admin, Membro, SoLeitura
    DateTime DataAdesao
}

public class ConviteDespensa {
    int Id
    int DespensaId, RemetenteId, DestinatarioId
    string EmailConvidado
    EstadoConvite Estado             // Pendente, Aceito, Rejeitado
    DateTime DataCriacao, DataResposta?
}
```

---

## 🔧 APIs e Endpoints Principais

### 🔐 Autenticação (`/api/auth`)
```http
POST /api/auth/register         # Registro tradicional
POST /api/auth/login           # Login email/senha
POST /api/auth/google-login    # Login Google OAuth
POST /api/auth/refresh-token   # Renovar token JWT
```

### 📦 Estoque (`/api/estoque`)
```http
GET    /api/estoque                    # Listar estoque (todas despensas)
GET    /api/estoque?despensaId=1       # Estoque de despensa específica
POST   /api/estoque                    # Adicionar item
PUT    /api/estoque/{id}               # Atualizar item
DELETE /api/estoque/{id}               # Remover item
POST   /api/estoque/{id}/consumir      # Registrar consumo
GET    /api/estoque/{id}/previsao      # IA: Previsão de consumo
```

### 🏠 Despensas (`/api/despensas`)
```http
GET    /api/despensas                  # Despensas do usuário
POST   /api/despensas                  # Criar despensa
PUT    /api/despensas/{id}             # Atualizar despensa
DELETE /api/despensas/{id}             # Excluir despensa
GET    /api/despensas/{id}/membros     # Listar membros
```

### 🤝 Convites (`/api/convites`)
```http
POST   /api/convites                   # Enviar convite
GET    /api/convites/recebidos         # Convites recebidos
GET    /api/convites/enviados          # Convites enviados
POST   /api/convites/{id}/aceitar      # Aceitar convite
POST   /api/convites/{id}/rejeitar     # Rejeitar convite
```

### 🛒 Lista de Compras (`/api/listadecompras`)
```http
GET    /api/listadecompras             # Lista do usuário
POST   /api/listadecompras             # Adicionar item
PUT    /api/listadecompras/{id}        # Atualizar item
DELETE /api/listadecompras/{id}        # Remover item
POST   /api/listadecompras/gerar-automatica # Gerar baseada em estoque mínimo
```

### 💳 Assinaturas (`/api/subscription`)
```http
GET    /api/subscription/status        # Status da assinatura
POST   /api/subscription/upgrade       # Upgrade para Premium
POST   /api/subscription/cancel        # Cancelar assinatura
```

### 📊 Analytics (`/api/analytics`)
```http
GET    /api/analytics/dashboard        # Dashboard principal
GET    /api/analytics/consumo-periodo  # Consumo por período
GET    /api/analytics/produtos-populares # Produtos mais consumidos
GET    /api/analytics/desperdicio      # Análise de desperdício
```

---

## ⚡ Funcionalidades em Tempo Real (SignalR)

### 🔌 Hub: `/estoqueHub`

#### 📡 Métodos do Cliente → Servidor
```csharp
// Gestão de grupos
JuntarAoGrupoDespensa(string despensaId)
SairDoGrupoDespensa(string despensaId)

// Teste de conectividade
Ping()
```

#### 📢 Eventos Servidor → Cliente
```csharp
// Confirmações de conexão
"ConexaoEstabelecida"
"JuntouAoGrupo" / "SaiuDoGrupo"

// Atualizações de estoque
"EstoqueItemAdicionado"
"EstoqueItemAtualizado"
"EstoqueItemRemovido"
"EstoqueItemConsumido"

// Lista de compras
"ListaDeComprasAtualizada"

// Sistema de convites
"NovoConviteRecebido"
"ConviteRespondido"

// Teste
"Pong"
```

#### 🎯 Grupos SignalR
- `Despensa-{id}`: Membros de uma despensa específica
- `User-{userId}`: Notificações diretas para usuário

---

## 🤖 Sistema de IA

### 🧠 Funcionalidades de IA Implementadas

#### 📈 Previsão de Consumo (`PredictionService`)
```csharp
// Análise baseada em histórico
public class PrevisaoResultado {
    double ConsumoMedioPorDia        // Média diária
    int DiasParaAcabar              // Estimativa de duração
    double TendenciaConsumo         // Crescente/Decrescente
    List<double> ConsumoProjetado    // Projeção futura
    DateTime? DataEstimadaFimEstoque // Quando vai acabar
}
```

#### 🔄 Treinamento Automático (`AITrainingBackgroundService`)
- **Frequência**: A cada 6 horas
- **Função**: Atualiza modelos baseados em novos dados de consumo
- **Melhoria**: Precisão das previsões aumenta com uso

#### 🎯 Aplicações da IA
1. **Alertas Inteligentes**: "Produto acabando em X dias"
2. **Lista de Compras Automática**: Baseada em padrões de consumo
3. **Detecção de Desperdício**: Produtos próximos ao vencimento
4. **Otimização de Compras**: Sugestões de quantidade ideal

---

## 📊 Sistema de Analytics

### 📈 Métricas Implementadas

#### 🎯 Dashboard Principal
```csharp
// Métricas do período
public class DashboardData {
    int TotalDespensas
    int TotalProdutos
    int TotalItensEstoque
    int ItensAbaixoMinimo
    
    // Tendências
    double PercentualMudancaEstoque
    List<ConsumoMensal> ConsumoUltimosMeses
    List<ProdutoPopular> ProdutosMaisConsumidos
    
    // Alertas
    List<ItemVencendoSoon> ItensVencendo
    List<ItemSemEstoque> ItensSemEstoque
    
    // Analytics avançadas
    double IndiceAproveitamento
    decimal ValorTotalEstoque
    List<CategoriaConsumo> ConsumoCategories
}
```

#### 📊 Tipos de Análises
1. **Consumo Temporal**: Padrões ao longo do tempo
2. **Análise de Categorias**: Quais tipos de produtos mais consumidos
3. **Eficiência do Estoque**: Taxa de aproveitamento
4. **Desperdício**: Produtos vencidos vs. consumidos
5. **Previsão de Gastos**: Estimativa mensal baseada em padrões

---

## 💳 Sistema de Assinaturas (Freemium)

### 📋 Planos Disponíveis

#### 🆓 Plano Free
- ✅ 1 despensa
- ✅ Até 50 produtos
- ✅ Funcionalidades básicas
- ❌ IA limitada
- ❌ Analytics básicos

#### 💎 Plano Premium
- ✅ Despensas ilimitadas
- ✅ Produtos ilimitados
- ✅ IA completa com previsões
- ✅ Analytics avançados
- ✅ Relatórios detalhados
- ✅ Suporte prioritário

### 💰 Integração Stripe
- **Checkout**: Stripe Checkout sessions
- **Webhooks**: Confirmação automática de pagamentos
- **Gestão**: Upgrade/downgrade automático
- **Cancelamento**: Self-service

---

## 🔒 Segurança e Permissões

### 🛡️ Autenticação
- **JWT Bearer Tokens**: Para APIs
- **Google OAuth 2.0**: Login social
- **Refresh Tokens**: Renovação automática
- **Secure Storage**: Tokens no mobile

### 🔐 Autorização
```csharp
public interface IPermissionService {
    Task<bool> PodeAcederDespensa(int userId, int despensaId)
    Task<List<int>> GetDespensasDoUsuario(int userId)
    Task<bool> EhAdminDaDespensa(int userId, int despensaId)
}
```

### 👥 Níveis de Permissão
1. **Admin**: Criador da despensa, acesso total
2. **Membro**: Pode editar estoque e lista de compras
3. **Somente Leitura**: Visualização apenas

---

## 🚀 Configuração e Deploy

### 🛠️ Configuração de Desenvolvimento

#### Backend (ASP.NET Core)
```json
// appsettings.Development.json
{
  "ConnectionStrings": {
    "SQLiteConnection": "Data Source=EstoqueMax.db"
  },
  "Jwt": {
    "Key": "sua-chave-secreta-jwt-aqui",
    "Issuer": "EstoqueMaxAPI",
    "Audience": "EstoqueMaxClients"
  },
  "Google": {
    "ClientId": "seu-google-client-id",
    "ClientSecret": "seu-google-client-secret"
  },
  "Stripe": {
    "SecretKey": "sk_test_...",
    "PublicKey": "pk_test_..."
  }
}
```

#### Mobile (Flutter)
```bash
# Instalar dependências
flutter pub get

# Executar no Android
flutter run

# Build para produção
flutter build apk --release
flutter build web --release
```

### 🌐 Deploy Produção
- **Backend**: Docker + Azure/AWS
- **Database**: PostgreSQL
- **Mobile**: Play Store / App Store / Firebase Hosting (Web)

---

## 📈 Roadmap Futuro

### 🎯 Próximas Funcionalidades
- [ ] **Receitas Inteligentes**: Sugestões baseadas no estoque
- [ ] **Integração IoT**: Balanças inteligentes
- [ ] **Código de Barras**: Scanner integrado
- [ ] **Geolocalização**: Lojas próximas
- [ ] **Nutrição**: Tracking nutricional
- [ ] **Compartilhamento Social**: Posts de receitas

### 🔧 Melhorias Técnicas
- [ ] **Testes Automatizados**: Unit + Integration tests
- [ ] **Monitoramento**: Application Insights
- [ ] **Cache**: Redis para performance
- [ ] **CDN**: Para assets estáticos
- [ ] **Microserviços**: Separação por domínios

---

## 🎉 Conclusão

O **EstoqueMax** é um projeto muito bem arquitetado que demonstra:

### 💪 Pontos Fortes
1. **Arquitetura Sólida**: Clean Architecture com separação de responsabilidades
2. **Tecnologias Modernas**: ASP.NET Core + Flutter + SignalR + IA
3. **Funcionalidades Completas**: Do básico ao avançado (IA, analytics, tempo real)
4. **Modelo de Negócio**: Freemium sustentável com Stripe
5. **UX Moderno**: Tempo real + mobile responsivo
6. **Escalabilidade**: Preparado para crescimento

### 🚀 Potencial Comercial
- **Mercado Grande**: Gestão doméstica é universal
- **Diferencial Técnico**: IA + tempo real + partilha familiar
- **Monetização Clara**: Freemium + assinaturas
- **Expansão Fácil**: Múltiplas plataformas já cobertas

**Parabéns pelo excelente trabalho! Este é um projeto profissional de alta qualidade.** 🎊 