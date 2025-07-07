# ⚡ **Sincronização em Tempo Real com SignalR** - EstoqueMax

## 📋 **Resumo da Funcionalidade**

A **Sincronização em Tempo Real** implementa comunicação bidirecional instantânea entre servidor e clientes usando **ASP.NET Core SignalR**. Esta funcionalidade transforma o EstoqueMax numa plataforma verdadeiramente colaborativa, onde todas as ações são refletidas instantaneamente para todos os membros.

## 🎯 **Problema Resolvido**

**Antes:** Usuários precisavam atualizar manualmente a aplicação para ver mudanças feitas por outros membros da família, causando inconsistências e frustração.

**Depois:** Todas as mudanças são propagadas instantaneamente para todos os dispositivos conectados, garantindo que todos vejam sempre a informação mais atual.

## ⚙️ **Arquitetura Implementada**

### **1. SignalR Hub**
- **Localização**: `/estoqueHub`
- **Autenticação**: JWT Bearer Token (via query string para WebSockets)
- **Grupos Dinâmicos**: 
  - `Despensa-{id}` para notificações por despensa
  - `User-{id}` para notificações pessoais

### **2. Sistema de Grupos**
```csharp
// Grupos por Despensa - para mudanças no estoque
"Despensa-1", "Despensa-2", etc.

// Grupos por Usuário - para convites e listas pessoais
"User-1", "User-2", etc.
```

### **3. Verificação de Permissões**
- **Hub Seguro**: Verificação de permissões no momento de juntar-se a grupos
- **Integração com IPermissionService**: Apenas membros autorizados recebem notificações
- **Proteção Automática**: Usuários só podem acessar grupos de despensas onde são membros

## 🚀 **Eventos em Tempo Real Implementados**

### **EstoqueController - Mudanças no Estoque**
| Evento | Quando Disparado | Destinatários | Payload |
|--------|------------------|---------------|---------|
| `EstoqueItemAdicionado` | Novo item no estoque | Membros da despensa | Item completo |
| `EstoqueItemAtualizado` | Item modificado/consumido | Membros da despensa | Item atualizado + ação |
| `EstoqueItemRemovido` | Item deletado | Membros da despensa | Info do item removido |

### **ListaDeComprasController - Mudanças na Lista**
| Evento | Quando Disparado | Destinatários | Payload |
|--------|------------------|---------------|---------|
| `ListaDeComprasAtualizada` | Item adicionado/comprado/removido | Dono da lista | Ação + dados |

### **ConvitesController - Gestão de Convites**
| Evento | Quando Disparado | Destinatários | Payload |
|--------|------------------|---------------|---------|
| `NovoConviteRecebido` | Convite enviado | Destinatário | Dados do convite |
| `ConviteAceito` | Convite aceito | Remetente | Info do aceite |
| `ConviteRecusado` | Convite recusado | Remetente | Info da recusa |
| `NovoMembroAdicionado` | Membro aceita convite | Todos membros da despensa | Info do novo membro |
| `NovaDespensaDisponivel` | Usuário aceita convite | Novo membro | Info da nova despensa |

### **DespensasController - Gestão de Despensas**
| Evento | Quando Disparado | Destinatários | Payload |
|--------|------------------|---------------|---------|
| `DespensaCriada` | Nova despensa criada | Criador | Info da despensa |
| `DespensaAtualizada` | Nome alterado | Todos membros | Dados atualizados |
| `DespensaDeletada` | Despensa removida | Todos membros | Info da despensa |
| `MembroRemovido` | Membro expulso | Todos membros | Info do membro |
| `RemovidoDaDespensa` | Usuário foi expulso | Membro removido | Info da remoção |

## 🔧 **Implementação Técnica**

### **1. Configuração do SignalR**
```csharp
// Program.cs
builder.Services.AddSignalR();
app.MapHub<EstoqueHub>("/estoqueHub");

// Configuração JWT para WebSockets
options.Events = new JwtBearerEvents
{
    OnMessageReceived = context =>
    {
        var accessToken = context.Request.Query["access_token"];
        var path = context.HttpContext.Request.Path;
        
        if (!string.IsNullOrEmpty(accessToken) && path.StartsWithSegments("/estoqueHub"))
        {
            context.Token = accessToken;
        }
        return Task.CompletedTask;
    }
};
```

### **2. Hub com Segurança**
```csharp
[Authorize]
public class EstoqueHub : Hub
{
    public async Task JuntarAoGrupoDespensa(string despensaId)
    {
        // Verificação de permissões antes de juntar ao grupo
        var podeAcessar = await _permissionService.PodeAcederDespensa(userId, despensaId);
        if (podeAcessar)
        {
            await Groups.AddToGroupAsync(Context.ConnectionId, $"Despensa-{despensaId}");
        }
    }
}
```

### **3. Integração nos Controllers**
```csharp
// Exemplo no EstoqueController
private readonly IHubContext<EstoqueHub> _hubContext;

// Após modificar estoque
await _hubContext.Clients.Group($"Despensa-{item.DespensaId}")
    .SendAsync("EstoqueItemAtualizado", itemData);
```

## 📱 **Contrato para Frontend**

### **URL de Conexão**
```javascript
const connection = new signalR.HubConnectionBuilder()
    .withUrl("/estoqueHub", {
        accessTokenFactory: () => getJWTToken()
    })
    .build();
```

### **Eventos do Cliente para Servidor**
```javascript
// Juntar-se a uma despensa
connection.invoke("JuntarAoGrupoDespensa", despensaId);

// Sair de uma despensa
connection.invoke("SairDoGrupoDespensa", despensaId);

// Testar conexão
connection.invoke("Ping");
```

### **Eventos do Servidor para Cliente**
```javascript
// Estoque
connection.on("EstoqueItemAdicionado", (item) => { /* atualizar UI */ });
connection.on("EstoqueItemAtualizado", (item) => { /* atualizar UI */ });
connection.on("EstoqueItemRemovido", (item) => { /* atualizar UI */ });

// Lista de Compras
connection.on("ListaDeComprasAtualizada", (data) => { /* recarregar lista */ });

// Convites
connection.on("NovoConviteRecebido", (convite) => { /* mostrar notificação */ });
connection.on("ConviteAceito", (data) => { /* atualizar status */ });
connection.on("ConviteRecusado", (data) => { /* atualizar status */ });

// Despensas
connection.on("NovoMembroAdicionado", (membro) => { /* atualizar lista */ });
connection.on("DespensaAtualizada", (despensa) => { /* atualizar nome */ });
```

## 🧪 **Fluxos de Teste**

### **Cenário 1: Colaboração em Tempo Real**
1. **Ana** e **João** estão conectados na mesma despensa "Cozinha"
2. **Ana** consome 2 unidades de leite: `POST /api/estoque/1/consumir`
3. **João** vê instantaneamente a quantidade atualizada no seu dispositivo
4. Sistema adiciona leite à lista de compras automaticamente
5. **João** recebe notificação instantânea de item adicionado à lista

### **Cenário 2: Gestão de Convites**
1. **Ana** convida **Maria**: `POST /api/despensas/1/convidar`
2. **Maria** recebe notificação instantânea do convite
3. **Maria** aceita: `PUT /api/convites/1/aceitar`
4. **Ana** recebe confirmação instantânea do aceite
5. Todos os membros veem **Maria** adicionada instantaneamente

### **Cenário 3: Compras Colaborativas**
1. **João** marca leite como comprado: `PUT /api/listadecompras/1/marcar-comprado`
2. **Ana** vê instantaneamente o item removido da sua lista
3. **Ana** vê instantaneamente o estoque de leite atualizado
4. Ciclo completo sem necessidade de refresh manual

## 📊 **Impacto na Experiência do Usuário**

### **Antes da Implementação**
- ❌ Usuários viam informações desatualizadas
- ❌ Necessidade de refresh manual constante
- ❌ Conflitos e duplicações na lista de compras
- ❌ Atraso na comunicação entre membros

### **Depois da Implementação**
- ✅ Informações sempre atualizadas automaticamente
- ✅ Experiência fluida e responsiva
- ✅ Colaboração sem conflitos
- ✅ Comunicação instantânea
- ✅ Sensação de aplicação "viva" e moderna

## 🔒 **Segurança e Performance**

### **Medidas de Segurança**
- **Autenticação Obrigatória**: Apenas usuários logados podem conectar
- **Verificação de Permissões**: Acesso restrito às despensas autorizadas
- **Grupos Seguros**: Usuários só recebem notificações relevantes
- **Validação Contínua**: Permissões verificadas a cada operação

### **Otimizações de Performance**
- **Grupos Dinâmicos**: Apenas membros relevantes recebem notificações
- **Payload Otimizado**: Dados mínimos necessários são transmitidos
- **Conexões Gerenciadas**: Auto-limpeza de conexões órfãs
- **Caching Inteligente**: Redução de consultas desnecessárias

## 🎯 **Próximos Passos**

1. **Frontend Implementation**: Integrar SignalR no cliente React/Vue
2. **Push Notifications**: Notificações móveis para usuários offline
3. **Presence Indicators**: Mostrar quem está online/ativo
4. **Typing Indicators**: "João está editando..." em tempo real
5. **Offline Sync**: Sincronização quando usuário volta online

---

**Status:** ✅ **Completo e Funcional**  
**Hub URL:** `/estoqueHub`  
**Autenticação:** JWT Bearer Token  
**Eventos:** 15+ eventos em tempo real implementados  
**Impacto:** Transformação para experiência colaborativa moderna 