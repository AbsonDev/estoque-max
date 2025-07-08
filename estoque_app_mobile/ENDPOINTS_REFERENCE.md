# 📋 Referência de Endpoints - EstoqueMax API

Base URL: `http://localhost:5265/api`

## 🔐 Autenticação (`/auth`)
- **POST** `/auth/registrar` - Registrar novo usuário
- **POST** `/auth/login` - Login tradicional
- **POST** `/auth/google-login` - Login com Google

## 👤 Usuários (`/estoque`)
- **GET** `/estoque/usuario-info` - Obter informações do usuário

## 🏪 Despensas (`/despensas`)
- **GET** `/despensas` - Listar despensas do usuário
- **GET** `/despensas/{id}` - Obter despensa específica
- **POST** `/despensas` - Criar nova despensa
- **PUT** `/despensas/{id}` - Atualizar despensa
- **DELETE** `/despensas/{id}` - Deletar despensa
- **POST** `/despensas/{id}/convidar` - Convidar membro
- **DELETE** `/despensas/{id}/membros/{membroId}` - Remover membro

## 📦 Produtos (`/produtos`)
- **GET** `/produtos` - Listar todos os produtos
- **GET** `/produtos/{id}` - Obter produto específico
- **POST** `/produtos` - Criar novo produto
- **PUT** `/produtos/{id}` - Atualizar produto
- **DELETE** `/produtos/{id}` - Deletar produto

## 📊 Estoque (`/estoque`)
- **GET** `/estoque?despensaId={id}` - Obter estoque (filtro opcional por despensa)
- **POST** `/estoque` - Adicionar item ao estoque
- **PUT** `/estoque/{id}` - Atualizar item do estoque
- **POST** `/estoque/{id}/consumir` - Consumir do estoque
- **DELETE** `/estoque/{id}` - Remover item do estoque
- **GET** `/estoque/{id}/previsao-consumo` - Previsão de consumo AI

## 🛒 Lista de Compras (`/lista-de-compras`)
- **GET** `/lista-de-compras` - Obter lista de compras
- **POST** `/lista-de-compras/aceitar-sugestao/{estoqueItemId}` - Aceitar sugestão preditiva
- **POST** `/lista-de-compras/adicionar-manual` - Adicionar item manual
- **PUT** `/lista-de-compras/{id}/marcar-comprado` - Marcar como comprado
- **DELETE** `/lista-de-compras/{id}` - Remover item
- **GET** `/lista-de-compras/historico` - Histórico de compras

## 📨 Convites (`/convites`)
- **GET** `/convites` - Convites recebidos
- **POST** `/convites/{id}/aceitar` - Aceitar convite
- **POST** `/convites/{id}/recusar` - Recusar convite
- **DELETE** `/convites/{id}` - Deletar convite
- **GET** `/convites/enviados` - Convites enviados

## 📈 Analytics (`/analytics`)
- **GET** `/analytics/dashboard` - Dashboard completo
- **GET** `/analytics/consumo-por-categoria` - Consumo por categoria
- **GET** `/analytics/top-produtos` - Top produtos
- **GET** `/analytics/gastos-mensais` - Gastos mensais
- **GET** `/analytics/gastos-por-categoria` - Gastos por categoria
- **GET** `/analytics/tendencia-desperdicio` - Tendência de desperdício
- **GET** `/analytics/itens-expirados-no-mes` - Itens expirados
- **GET** `/analytics/heatmap-consumo` - Heatmap de consumo
- **GET** `/analytics/indicadores-chave` - Indicadores chave
- **GET** `/analytics/insights` - Insights AI
- **GET** `/analytics/dashboard-despensa/{despensaId}` - Dashboard por despensa
- **GET** `/analytics/comparacao-consumo-periodica` - Comparação de consumo
- **POST** `/analytics/refresh` - Atualizar analytics
- **GET** `/analytics/exportar-dados` - Exportar dados

## 💳 Pagamentos (`/payments`)
- **POST** `/payments/create-checkout-session` - Criar sessão de checkout
- **POST** `/payments/create-customer-portal-session` - Portal do cliente
- **POST** `/payments/stripe-webhook` - Webhook do Stripe

## 🔔 Assinaturas (`/subscription`)
- **GET** `/subscription/status` - Status da assinatura
- **GET** `/subscription/plans` - Planos disponíveis
- **GET** `/subscription/features` - Comparação de features
- **GET** `/subscription/analytics` - Analytics de assinatura
- **GET** `/subscription/history` - Histórico de assinatura
- **POST** `/subscription/cancel` - Cancelar assinatura
- **POST** `/subscription/upgrade` - Upgrade de assinatura

## 🔧 Estruturas de Dados

### LoginRequest
```json
{
  "email": "string",
  "senha": "string"
}
```

### RegisterRequest
```json
{
  "nome": "string",
  "email": "string",
  "senha": "string"
}
```

### GoogleLoginRequest
```json
{
  "idToken": "string"
}
```

### User
```json
{
  "id": "number",
  "nome": "string",
  "email": "string",
  "provider": "string?"
}
```

## 🔒 Autenticação
- Todos os endpoints (exceto auth) requerem header: `Authorization: Bearer {token}`
- Token JWT é obtido através dos endpoints de login

## 📝 Notas
- Todos os endpoints retornam JSON
- Códigos de status HTTP padrão (200, 201, 400, 401, 404, 500)
- Campos opcionais são marcados com `?`
- Parâmetros de query são opcionais quando não especificado contrário 