using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using EstoqueApp.Api.Services;
using EstoqueApp.Api.Models;

namespace EstoqueApp.Api.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class SubscriptionController : ControllerBase
    {
        private readonly ISubscriptionService _subscriptionService;

        public SubscriptionController(ISubscriptionService subscriptionService)
        {
            _subscriptionService = subscriptionService;
        }

        // GET: api/subscription/status
        [HttpGet("status")]
        public async Task<IActionResult> GetSubscriptionStatus()
        {
            var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            
            if (userId == null)
            {
                return Unauthorized();
            }

            var status = await _subscriptionService.ObterStatusAssinaturaAsync(int.Parse(userId));
            var numeroDespensas = await _subscriptionService.ObterNumeroDeDespensasDoUsuarioAsync(int.Parse(userId));

            return Ok(new {
                subscription = new {
                    isValid = status.IsValid,
                    currentPlan = status.PlanoAtual.ToString(),
                    expirationDate = status.DataExpiracao,
                    daysUntilExpiration = status.DaysUntilExpiration,
                    canUpgrade = status.CanUpgrade
                },
                limits = new {
                    despensas = new {
                        current = numeroDespensas,
                        limit = status.PlanoAtual == TipoDePlano.Free ? 3 : -1, // -1 = ilimitado
                        canCreateMore = await _subscriptionService.UsuarioPodeCriarMaisDespensasAsync(int.Parse(userId))
                    }
                },
                features = new {
                    familySharing = await _subscriptionService.UsuarioPodeEnviarConvitesAsync(int.Parse(userId)),
                    aiPredictions = await _subscriptionService.UsuarioTemAcessoAIAsync(int.Parse(userId)),
                    advancedAnalytics = await _subscriptionService.UsuarioTemAcessoAnalyticsCompletaAsync(int.Parse(userId))
                }
            });
        }

        // GET: api/subscription/plans
        [HttpGet("plans")]
        public async Task<IActionResult> GetAvailablePlans()
        {
            try
            {
                var plans = await GetDynamicPlansAsync();
                return Ok(new { plans });
            }
            catch
            {
                // Fallback para preços estáticos se falhar
            return Ok(new {
                    plans = GetStaticPlans(),
                    note = "Usando preços de fallback"
                });
            }
        }

        private async Task<object[]> GetDynamicPlansAsync()
        {
            var priceService = new Stripe.PriceService();
            
            // Buscar preços do Premium (configurar os IDs no appsettings)
            var monthlyPriceId = "price_monthly_premium"; // Configurar no appsettings
            var yearlyPriceId = "price_yearly_premium";   // Configurar no appsettings
            
            try
            {
                var monthlyPrice = await priceService.GetAsync(monthlyPriceId);
                var yearlyPrice = await priceService.GetAsync(yearlyPriceId);

                var monthlyAmount = (monthlyPrice.UnitAmount ?? 0) / 100m;
                var yearlyAmount = (yearlyPrice.UnitAmount ?? 0) / 100m;
                var yearlyMonthlyEquivalent = yearlyAmount / 12;
                var savingsPercentage = monthlyAmount > 0 ? (int)((monthlyAmount - yearlyMonthlyEquivalent) / monthlyAmount * 100) : 0;

                return new object[] {
                    new {
                        id = "free",
                        name = "EstoqueMax Free",
                        description = "O essencial para gestão pessoal de estoque",
                        price = new {
                            monthly = 0,
                            yearly = 0,
                            currency = "EUR"
                        },
                        features = new string[] {
                            "Até 3 despensas",
                            "Itens ilimitados",
                            "Lista de compras automática",
                            "Dashboard básico"
                        },
                        limitations = new string[] {
                            "Sem partilha familiar",
                            "Sem previsões de IA",
                            "Analytics limitadas"
                        }
                    },
                    new {
                        id = "premium",
                        stripeIds = new {
                            monthly = monthlyPriceId,
                            yearly = yearlyPriceId
                        },
                        name = "EstoqueMax Premium",
                        description = "A experiência completa para famílias inteligentes",
                        price = new {
                            monthly = monthlyAmount,
                            yearly = yearlyAmount,
                            currency = monthlyPrice.Currency.ToUpper()
                        },
                        features = new string[] {
                            "Despensas ilimitadas",
                            "Partilha familiar (até 5 membros)",
                            "Previsões de IA avançadas",
                            "Analytics completa",
                            "Sincronização em tempo real",
                            "Suporte prioritário"
                        },
                        limitations = new string[] {
                            // Sem limitações
                        },
                        savings = new {
                            yearly = savingsPercentage > 0 ? $"{savingsPercentage}% de desconto" : "Sem desconto",
                            percentage = savingsPercentage,
                            monthlyEquivalent = yearlyMonthlyEquivalent
                        }
                    }
                };
            }
            catch
            {
                return GetStaticPlans();
            }
        }

        private static object[] GetStaticPlans()
        {
            return new object[] {
                new {
                    id = "free",
                    name = "EstoqueMax Free",
                    description = "O essencial para gestão pessoal de estoque",
                    price = new {
                        monthly = 0,
                        yearly = 0,
                        currency = "EUR"
                    },
                    features = new string[] {
                        "Até 3 despensas",
                        "Itens ilimitados",
                        "Lista de compras automática",
                        "Dashboard básico"
                    },
                    limitations = new string[] {
                        "Sem partilha familiar",
                        "Sem previsões de IA",
                        "Analytics limitadas"
                    }
                },
                new {
                    id = "premium",
                    stripeIds = new {
                        monthly = "price_monthly_premium",
                        yearly = "price_yearly_premium"
                    },
                    name = "EstoqueMax Premium",
                    description = "A experiência completa para famílias inteligentes",
                    price = new {
                        monthly = 4.99,
                        yearly = 49.99,
                        currency = "EUR"
                    },
                    features = new string[] {
                        "Despensas ilimitadas",
                        "Partilha familiar (até 5 membros)",
                        "Previsões de IA avançadas",
                        "Analytics completa",
                        "Sincronização em tempo real",
                        "Suporte prioritário"
                    },
                    limitations = new string[] {
                        // Sem limitações
                    },
                    savings = new {
                        yearly = "17% de desconto",
                        percentage = 17,
                        monthlyEquivalent = 4.16
                    }
                }
            };
        }

        // GET: api/subscription/features
        [HttpGet("features")]
        public async Task<IActionResult> GetFeatureComparison()
        {
            var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            
            if (userId == null)
            {
                return Unauthorized();
            }

            var currentAccess = new {
                familySharing = await _subscriptionService.UsuarioPodeEnviarConvitesAsync(int.Parse(userId)),
                aiPredictions = await _subscriptionService.UsuarioTemAcessoAIAsync(int.Parse(userId)),
                advancedAnalytics = await _subscriptionService.UsuarioTemAcessoAnalyticsCompletaAsync(int.Parse(userId)),
                unlimitedPantries = await _subscriptionService.UsuarioTemAcessoPremiumAsync(int.Parse(userId))
            };

            return Ok(new {
                currentAccess = currentAccess,
                featureComparison = new object[] {
                    new {
                        category = "Gestão de Despensas",
                        features = new object[] {
                            new {
                                name = "Número de despensas",
                                free = "Até 3",
                                premium = "Ilimitadas",
                                userHasAccess = await _subscriptionService.UsuarioPodeCriarMaisDespensasAsync(int.Parse(userId))
                            },
                            new {
                                name = "Itens por despensa",
                                free = "Ilimitados",
                                premium = "Ilimitados",
                                userHasAccess = true
                            }
                        }
                    },
                    new {
                        category = "Colaboração",
                        features = new object[] {
                            new {
                                name = "Partilha familiar",
                                free = "❌ Não disponível",
                                premium = "✅ Até 5 membros",
                                userHasAccess = currentAccess.familySharing
                            },
                            new {
                                name = "Sincronização em tempo real",
                                free = "N/A",
                                premium = "✅ Completa",
                                userHasAccess = currentAccess.familySharing
                            }
                        }
                    },
                    new {
                        category = "Inteligência Artificial",
                        features = new object[] {
                            new {
                                name = "Previsões de consumo",
                                free = "❌ Não disponível",
                                premium = "✅ Algoritmos avançados",
                                userHasAccess = currentAccess.aiPredictions
                            },
                            new {
                                name = "Sugestões automáticas",
                                free = "❌ Não disponível",
                                premium = "✅ Baseadas em IA",
                                userHasAccess = currentAccess.aiPredictions
                            }
                        }
                    },
                    new {
                        category = "Analytics & Relatórios",
                        features = new object[] {
                            new {
                                name = "Dashboard básico",
                                free = "✅ KPIs essenciais",
                                premium = "✅ KPIs essenciais",
                                userHasAccess = true
                            },
                            new {
                                name = "Analytics avançada",
                                free = "❌ Não disponível",
                                premium = "✅ Gráficos financeiros e desperdício",
                                userHasAccess = currentAccess.advancedAnalytics
                            }
                        }
                    }
                }
            });
        }

        // GET: api/subscription/analytics
        [HttpGet("analytics")]
        [Authorize(Roles = "Admin")] // Só admins podem ver analytics
        public async Task<IActionResult> GetSubscriptionAnalytics()
        {
            try
            {
                var analytics = await _subscriptionService.ObterAnalyticsAssinaturasAsync();
                
                return Ok(new {
                    mrr = new {
                        value = analytics.MRR,
                        currency = "EUR",
                        description = "Monthly Recurring Revenue"
                    },
                    arr = new {
                        value = analytics.ARR,
                        currency = "EUR", 
                        description = "Annual Recurring Revenue"
                    },
                    metrics = new {
                        churnRate = new {
                            value = analytics.ChurnRate,
                            percentage = $"{analytics.ChurnRate:P2}",
                            description = "Taxa de cancelamento mensal"
                        },
                        conversionRate = new {
                            value = analytics.ConversionRate,
                            percentage = $"{analytics.ConversionRate:P2}",
                            description = "Taxa de conversão Free para Premium"
                        },
                        arpu = new {
                            value = analytics.ARPU,
                            currency = "EUR",
                            description = "Average Revenue Per User"
                        }
                    },
                    counters = new {
                        activeSubscriptions = analytics.AssinaturasAtivas,
                        newSubscriptionsThisMonth = analytics.NovasAssinaturasUltimoMes,
                        cancellationsThisMonth = analytics.CancelamentosUltimoMes,
                        trialConversions = analytics.TrialConversions
                    },
                    trends = new {
                        growthRate = analytics.NovasAssinaturasUltimoMes - analytics.CancelamentosUltimoMes,
                        netGrowth = analytics.NovasAssinaturasUltimoMes > analytics.CancelamentosUltimoMes ? "positive" : "negative"
                    }
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { error = "Erro ao obter analytics", details = ex.Message });
            }
        }

        // GET: api/subscription/history
        [HttpGet("history")]
        public async Task<IActionResult> GetSubscriptionHistory()
        {
            var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            
            if (userId == null)
            {
                return Unauthorized();
            }

            try
            {
                var assinaturaAtiva = await _subscriptionService.ObterAssinaturaAtivaAsync(int.Parse(userId));
                
                if (assinaturaAtiva == null)
                {
                    return Ok(new { 
                        hasSubscription = false,
                        message = "Nenhuma assinatura ativa encontrada"
                    });
                }

                return Ok(new {
                    hasSubscription = true,
                    subscription = new {
                        id = assinaturaAtiva.Id,
                        status = assinaturaAtiva.Status.ToString(),
                        startDate = assinaturaAtiva.DataInicio,
                        nextBilling = assinaturaAtiva.ProximaCobranca,
                        currentPeriodEnd = assinaturaAtiva.FimPeriodoAtual,
                        amount = assinaturaAtiva.Valor,
                        currency = assinaturaAtiva.Moeda,
                        interval = assinaturaAtiva.Intervalo,
                        canceledAtPeriodEnd = assinaturaAtiva.CanceladaFimPeriodo
                    },
                    paymentHistory = assinaturaAtiva.Pagamentos
                        .OrderByDescending(p => p.DataPagamento)
                        .Take(10)
                        .Select(p => new {
                            id = p.Id,
                            amount = p.Valor,
                            currency = p.Moeda,
                            status = p.Status.ToString(),
                            date = p.DataPagamento,
                            periodStart = p.InicioPeriodo,
                            periodEnd = p.FimPeriodo,
                            failureReason = p.MotivoFalha
                        })
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { error = "Erro ao obter histórico", details = ex.Message });
            }
        }

        // POST: api/subscription/cancel
        [HttpPost("cancel")]
        public async Task<IActionResult> CancelSubscription([FromBody] CancelSubscriptionRequest request)
        {
            var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            
            if (userId == null)
            {
                return Unauthorized();
            }

            try
            {
                var assinaturaAtiva = await _subscriptionService.ObterAssinaturaAtivaAsync(int.Parse(userId));
                
                if (assinaturaAtiva == null)
                {
                    return BadRequest(new { 
                        error = "Nenhuma assinatura ativa encontrada" 
                    });
                }

                var dataFinalizacao = request.CancelAtPeriodEnd ? assinaturaAtiva.FimPeriodoAtual : (DateTime?)null;
                
                var sucesso = await _subscriptionService.CancelarAssinaturaAsync(
                    assinaturaAtiva.StripeSubscriptionId, 
                    dataFinalizacao
                );

                if (sucesso)
                {
                    var tipoCancelamento = request.CancelAtPeriodEnd ? "no fim do período" : "imediatamente";
                    
                    return Ok(new {
                        success = true,
                        message = $"Assinatura cancelada {tipoCancelamento}",
                        cancelationType = request.CancelAtPeriodEnd ? "end_of_period" : "immediate",
                        accessUntil = dataFinalizacao
                    });
                }
                else
                {
                    return StatusCode(500, new { error = "Erro ao cancelar assinatura" });
                }
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { error = "Erro interno", details = ex.Message });
            }
        }

        // PUT: api/subscription/upgrade
        [HttpPut("upgrade")]
        public async Task<IActionResult> UpdateUpgradeEndpoint([FromBody] UpgradeRequestDto request)
        {
            var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            
            if (userId == null)
            {
                return Unauthorized();
            }

            var status = await _subscriptionService.ObterStatusAssinaturaAsync(int.Parse(userId));
            
            if (!status.CanUpgrade)
            {
                return BadRequest(new {
                    error = "Upgrade não disponível",
                    message = "Você já possui um plano Premium ativo.",
                    currentPlan = status.PlanoAtual.ToString(),
                    expirationDate = status.DataExpiracao
                });
            }

            // Retornar informações para redirecionamento ao Stripe Checkout
            var priceId = request.BillingCycle == "yearly" ? "price_yearly_premium" : "price_monthly_premium";
            
            return Ok(new {
                message = "Pronto para upgrade",
                checkout = new {
                    priceId = priceId,
                    billingCycle = request.BillingCycle,
                    redirectUrl = $"/api/payments/create-checkout-session"
                },
                upgrade = new {
                    fromPlan = status.PlanoAtual.ToString(),
                    toPlan = "Premium",
                    billingCycle = request.BillingCycle
                }
            });
        }
    }

    // DTOs
    public class UpgradeRequestDto
    {
        public string BillingCycle { get; set; } = "monthly"; // "monthly" ou "yearly"
    }

    public class CancelSubscriptionRequest
    {
        public bool CancelAtPeriodEnd { get; set; } = true;
        public string? Reason { get; set; }
    }
} 