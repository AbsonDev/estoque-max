# 🧠 **Modelo de IA para Previsão de Consumo** - EstoqueMax

## 📋 **Resumo da Funcionalidade**

O **Modelo de IA para Previsão de Consumo** transforma o EstoqueMax de uma plataforma reativa para uma plataforma **preditiva e inteligente**. Utilizando **Machine Learning com ML.NET**, a aplicação aprende os padrões de consumo de cada família e prevê quando os produtos irão acabar, permitindo planejamento antecipado.

## 🎯 **Problema Resolvido**

**Antes:** Os usuários eram avisados apenas quando o produto já havia acabado, sendo tarde demais para planejamento.

**Depois:** A aplicação funciona como um assistente pessoal inteligente que avisa: *"Ana, provavelmente precisarás de comprar ovos daqui a 3 dias."*

## 🚀 **Proposta de Valor**

### **Para o Utilizador:**
- **Planejamento Antecipado**: Recebe alertas antes que os produtos acabem
- **Sugestões Inteligentes**: Lista de compras preditiva baseada em padrões reais
- **Otimização de Compras**: Sabe exatamente quando e quanto comprar

### **Para o Negócio:**
- **Diferenciação Competitiva**: Funcionalidade única no mercado
- **Fidelização**: Usuários dependem da IA para planejamento doméstico
- **Dados Valiosos**: Insights sobre padrões de consumo familiares

## 🏗️ **Arquitetura Técnica**

### **1. Recolha de Dados (HistoricoConsumo)**
```csharp
public class HistoricoConsumo
{
    public int Id { get; set; }
    public int EstoqueItemId { get; set; }
    public int QuantidadeConsumida { get; set; }
    public DateTime DataDoConsumo { get; set; }
    public int UsuarioId { get; set; }
    public int QuantidadeRestanteAposConsumo { get; set; }
    public DayOfWeek DiaSemanaDaConsumo { get; set; } // Padrões semanais
    public int HoraDaConsumo { get; set; } // Padrões diários
}
```

### **2. Motor de IA (ML.NET)**
- **Algoritmo**: SSA (Singular Spectrum Analysis) para séries temporais
- **Janela de Análise**: 7 dias (padrões semanais)
- **Dados de Treino**: Até 6 meses de histórico
- **Horizonte de Previsão**: 7 dias futuros
- **Confiança**: 95% de nível de confiança

### **3. Serviço de Previsão (PredictionService)**
```csharp
public class PrevisaoResultado
{
    public int DiasRestantesEstimados { get; set; }
    public float ConsumoMedioDiario { get; set; }
    public float[] PrevisaoProximos7Dias { get; set; }
    public string StatusConfianca { get; set; } // Alta, Média, Baixa
    public int TotalRegistrosUtilizados { get; set; }
}
```

### **4. Treino Automático (Background Service)**
- **Frequência**: A cada 6 horas
- **Processamento**: Assíncrono, sem impacto na performance
- **Notificações**: SignalR para atualizações em tempo real
- **Limpeza**: Remoção automática de modelos antigos

## 🔌 **Endpoints da API**

### **GET /api/estoque/{id}/previsao**
**Descrição**: Obtém previsão de consumo para um item específico

**Resposta**:
```json
{
  "estoqueItemId": 1,
  "produto": {
    "nome": "Leite Integral",
    "marca": "Vigor"
  },
  "quantidadeAtual": 2,
  "quantidadeMinima": 1,
  "diasRestantesEstimados": 3,
  "consumoMedioDiario": 0.75,
  "statusConfianca": "Alta",
  "previsaoProximos7Dias": [0.8, 0.7, 0.9, 0.6, 0.8, 0.5, 0.7],
  "totalRegistrosHistorico": 45,
  "alertas": [
    "⚡ Atenção: Acabará em breve"
  ],
  "recomendacoes": [
    "🛒 Comprar nos próximos 2 dias",
    "💡 Sugestão: Comprar 11 unidades (2 semanas)"
  ],
  "dataUltimaAtualizacao": "2025-07-07T19:30:00Z"
}
```

### **GET /api/listadecompras**
**Descrição**: Lista de compras com sugestões preditivas

**Resposta**:
```json
{
  "totalItens": 3,
  "itensAutomaticos": 2,
  "itensManuais": 1,
  "listaDeCompras": [...],
  "sugestoesPreditivas": {
    "totalSugestoes": 4,
    "sugestoesUrgentes": 1,
    "sugestoesModeradas": 3,
    "itens": [
      {
        "estoqueItemId": 1,
        "produto": {
          "nome": "Leite Integral",
          "marca": "Vigor"
        },
        "despensa": {
          "nome": "Cozinha"
        },
        "diasRestantes": 2,
        "consumoMedioDiario": 0.75,
        "quantidadeSugerida": 11,
        "prioridade": "Crítica",
        "confianca": "Alta",
        "tipo": "preditiva",
        "motivoSugestao": "🚨 Produto acabará em 2 dia(s)"
      }
    ]
  },
  "dataUltimaAtualizacao": "2025-07-07T19:30:00Z",
  "versaoIA": "v1.0"
}
```

### **POST /api/listadecompras/aceitar-sugestao/{estoqueItemId}**
**Descrição**: Aceita uma sugestão preditiva e adiciona à lista

**Payload**:
```json
{
  "quantidadeDesejada": 10
}
```

## 📊 **Níveis de Confiança da IA**

| Confiança | Condições | Descrição |
|-----------|-----------|-----------|
| **Alta** | ≥50 registros + modelo treinado | Previsão muito confiável |
| **Média** | 20-49 registros + modelo treinado | Previsão razoavelmente confiável |
| **Baixa** | 5-19 registros + modelo treinado | Previsão com incerteza |
| **Dados Insuficientes** | <5 registros | Não é possível prever |

## 🎯 **Algoritmos de Priorização**

### **Prioridade de Sugestões**
- **Crítica**: Produto acaba em ≤2 dias
- **Alta**: Produto acaba em 3-5 dias
- **Moderada**: Produto acaba em 6-7 dias

### **Cálculo de Quantidade Sugerida**
```csharp
quantidadeSugerida = Math.Ceiling(consumoMedioDiario * 14) // 2 semanas
```

## 🔄 **Fluxo de Funcionamento**

### **1. Recolha de Dados**
1. Utilizador consome produto via `POST /api/estoque/{id}/consumir`
2. Sistema regista automaticamente em `HistoricoConsumo`
3. Dados incluem: quantidade, data, hora, dia da semana, utilizador

### **2. Treino Automático**
1. **AITrainingBackgroundService** executa a cada 6 horas
2. Processa todos os itens de estoque ativos
3. Treina modelos ML.NET individuais para cada item
4. Atualiza previsões e notifica via SignalR

### **3. Sugestões Preditivas**
1. `GET /api/listadecompras` calcula sugestões em tempo real
2. IA identifica produtos que acabarão em ≤7 dias
3. Filtra itens já adicionados manualmente
4. Ordena por urgência (dias restantes)

### **4. Interação do Utilizador**
1. Frontend mostra sugestões com prioridade visual
2. Utilizador pode aceitar sugestão com `POST /api/listadecompras/aceitar-sugestao/{id}`
3. Item é adicionado à lista tradicional
4. Notificação via SignalR confirma ação

## 📱 **Eventos SignalR**

### **PrevisõesAtualizadas**
**Quando**: Após treino automático do background service
**Destinatários**: Membros da despensa
**Payload**:
```json
{
  "despensaId": 1,
  "itensAtualizados": [
    {
      "estoqueItemId": 1,
      "diasRestantes": 3
    }
  ],
  "dataAtualizacao": "2025-07-07T19:30:00Z"
}
```

### **SugestaoPreditivaAceita**
**Quando**: Utilizador aceita sugestão da IA
**Destinatários**: Próprio utilizador
**Payload**:
```json
{
  "estoqueItemId": 1,
  "produto": "Leite Integral",
  "quantidadeAdicionada": 10,
  "novoItemId": 25
}
```

## 🧪 **Cenários de Teste**

### **Cenário 1: Primeira Utilização**
1. **Ana** começa a usar o sistema
2. Durante 2 semanas, consome leite regularmente
3. Sistema recolhe dados: 14 registros de consumo
4. IA ainda não consegue prever (dados insuficientes)
5. Após 1 mês (30+ registros), IA começa a fazer previsões

### **Cenário 2: Padrão Estabelecido**
1. **João** usa o sistema há 3 meses
2. Consome 1 litro de leite a cada 2 dias
3. IA detecta padrão: 0.5L/dia
4. Quando restam 3 litros, IA prevê: "Acabará em 6 dias"
5. Sistema sugere compra com 3 dias de antecedência

### **Cenário 3: Mudança de Padrão**
1. **Maria** aumenta consumo (férias escolares)
2. IA detecta aumento no consumo diário
3. Ajusta previsões automaticamente
4. Sugere compras mais frequentes
5. Após período, readapta ao padrão normal

### **Cenário 4: Colaboração Familiar**
1. **Ana** vê sugestão: "Ovos acabarão em 2 dias"
2. **João** aceita sugestão e adiciona à lista
3. **Ana** recebe notificação em tempo real
4. Ambos veem a lista atualizada instantaneamente

## 🔒 **Segurança e Privacidade**

### **Proteção de Dados**
- **Dados Locais**: Histórico nunca sai do servidor da família
- **Agregação**: Modelos ML não expostos externamente
- **Permissões**: Apenas membros da despensa veem previsões
- **Anonimização**: Logs sem dados pessoais sensíveis

### **Performance**
- **Treino Assíncrono**: Não impacta responsividade da API
- **Cache Inteligente**: Previsões calculadas sob demanda
- **Limpeza Automática**: Modelos antigos removidos automaticamente
- **Índices Otimizados**: Consultas históricas ultra-rápidas

## 📈 **Métricas de Sucesso**

### **Precisão da IA**
- **Acurácia**: % de previsões corretas (±1 dia)
- **Recall**: % de produtos esgotados previstos
- **Precision**: % de alertas que eram realmente necessários

### **Adoção pelos Utilizadores**
- **Taxa de Aceitação**: % de sugestões aceitas
- **Tempo de Resposta**: Velocidade de aceitar sugestões
- **Retenção**: Utilizadores que continuam usando após 1 mês

### **Impacto no Negócio**
- **Redução de Waste**: Menos produtos vencidos
- **Satisfação**: NPS específico para funcionalidade IA
- **Engagement**: Tempo médio na aplicação

## 🎨 **Experiência do Utilizador**

### **Indicadores Visuais**
- **🚨 Crítico**: Vermelho, acabará em ≤2 dias
- **⚡ Alta**: Laranja, acabará em 3-5 dias
- **📅 Moderada**: Amarelo, acabará em 6-7 dias
- **🤖 IA**: Ícone especial para sugestões preditivas

### **Linguagem Natural**
- ✅ "Produto acabará em 3 dias"
- ❌ "Previsão: 0.75 unidades/dia"
- ✅ "Compra nos próximos 2 dias"
- ❌ "Threshold: 2 dias"

## 🔮 **Roadmap Futuro**

### **Versão 2.0 - IA Avançada**
- **Sazonalidade**: Detectar padrões mensais/anuais
- **Eventos**: Considerar feriados e eventos especiais
- **Preços**: Integração com APIs de preços de supermercados
- **Nutrição**: Sugestões baseadas em necessidades nutricionais

### **Versão 3.0 - Inteligência Coletiva**
- **Benchmarks**: Comparar com famílias similares (anonimamente)
- **Recomendações**: Produtos alternativos baseados em padrões
- **Otimização**: Sugestões de compras em bulk
- **Sustentabilidade**: Reduzir desperdício alimentar

---

**Status:** ✅ **Completo e Funcional**  
**Tecnologia:** ML.NET + SSA Algorithm  
**Endpoints:** 3 novos endpoints implementados  
**Background Service:** Treino automático a cada 6 horas  
**Precisão:** 95% de nível de confiança  
**Impacto:** Transformação para experiência preditiva inteligente 