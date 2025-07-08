using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Stripe;
using Stripe.Checkout;
using System.Security.Claims;
using EstoqueApp.Api.Data;
using EstoqueApp.Api.Models;
using EstoqueApp.Api.Services;

namespace EstoqueApp.Api.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class PaymentsController : ControllerBase
    {
        private readonly IConfiguration _config;
        private readonly IServiceProvider _serviceProvider;
        private readonly ILogger<PaymentsController> _logger;
        private readonly ISubscriptionService _subscriptionService;
        private readonly string? _webhookSecret;

        public PaymentsController(
            IConfiguration config, 
            IServiceProvider serviceProvider, 
            ILogger<PaymentsController> logger,
            ISubscriptionService subscriptionService)
        {
            _config = config;
            _serviceProvider = serviceProvider;
            _logger = logger;
            _subscriptionService = subscriptionService;
            _webhookSecret = _config["Stripe:WebhookSecret"];
        }

        [HttpPost("create-checkout-session")]
        [Authorize]
        public async Task<ActionResult> CreateCheckoutSession([FromBody] CreateCheckoutSessionRequest request)
        {
            try
            {
                var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
                
                if (string.IsNullOrEmpty(userId))
                {
                    return Unauthorized("Utilizador não autenticado");
                }

                // Verificar se o usuário pode fazer upgrade
                var status = await _subscriptionService.ObterStatusAssinaturaAsync(int.Parse(userId));
                if (!status.CanUpgrade)
                {
                    return BadRequest(new { error = "Usuário já possui assinatura ativa" });
                }

                // Buscar ou criar customer no Stripe
                var usuario = await _subscriptionService.ObterUsuarioComPlanoAsync(int.Parse(userId));
                var customerId = await GetOrCreateStripeCustomerAsync(usuario);

                var options = new SessionCreateOptions
                {
                    Customer = customerId,
                    PaymentMethodTypes = new List<string> { "card" },
                    LineItems = new List<SessionLineItemOptions>
                    {
                        new SessionLineItemOptions
                        {
                            Price = request.PriceId,
                            Quantity = 1,
                        },
                    },
                    Mode = "subscription",
                    SuccessUrl = request.SuccessUrl ?? "https://seu-site.com/sucesso?session_id={CHECKOUT_SESSION_ID}",
                    CancelUrl = request.CancelUrl ?? "https://seu-site.com/cancelado",
                    SubscriptionData = new SessionSubscriptionDataOptions
                    {
                        Metadata = new Dictionary<string, string>
                        {
                            { "UserId", userId },
                            { "UserEmail", usuario.Email }
                        }
                    },
                    ClientReferenceId = userId,
                    AllowPromotionCodes = true,
                };

                var service = new SessionService();
                Session session = await service.CreateAsync(options);

                _logger.LogInformation("Sessão de checkout criada para usuário {UserId}: {SessionId}", userId, session.Id);

                return Ok(new CreateCheckoutSessionResponse
                {
                    SessionId = session.Id,
                    CheckoutUrl = session.Url
                });
            }
            catch (StripeException ex)
            {
                _logger.LogError(ex, "Erro do Stripe ao criar sessão de checkout");
                return BadRequest(new { error = "Erro ao processar pagamento", details = ex.Message });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Erro interno ao criar sessão de checkout");
                return StatusCode(500, new { error = "Erro interno do servidor" });
            }
        }

        [HttpPost("customer-portal")]
        [Authorize]
        public async Task<ActionResult> CreateCustomerPortalSession([FromBody] CustomerPortalRequest request)
        {
            try
            {
                var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
                
                if (string.IsNullOrEmpty(userId))
                {
                    return Unauthorized("Utilizador não autenticado");
                }

                var usuario = await _subscriptionService.ObterUsuarioComPlanoAsync(int.Parse(userId));
                var customerId = await GetOrCreateStripeCustomerAsync(usuario);

                var options = new Stripe.BillingPortal.SessionCreateOptions
                {
                    Customer = customerId,
                    ReturnUrl = request.ReturnUrl ?? "https://seu-site.com/settings"
                };

                var service = new Stripe.BillingPortal.SessionService();
                var session = await service.CreateAsync(options);

                _logger.LogInformation("Portal do cliente criado para usuário {UserId}", userId);

                return Ok(new { url = session.Url });
            }
            catch (StripeException ex)
            {
                _logger.LogError(ex, "Erro do Stripe ao criar portal do cliente");
                return BadRequest(new { error = "Erro ao acessar portal", details = ex.Message });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Erro interno ao criar portal do cliente");
                return StatusCode(500, new { error = "Erro interno do servidor" });
            }
        }

        [HttpPost("webhook")]
        [AllowAnonymous]
        public async Task<IActionResult> StripeWebhook()
        {
            var json = await new StreamReader(HttpContext.Request.Body).ReadToEndAsync();
            
            try
            {
                Event stripeEvent;

                if (!string.IsNullOrEmpty(_webhookSecret))
                {
                    stripeEvent = EventUtility.ConstructEvent(json, Request.Headers["Stripe-Signature"], _webhookSecret);
                }
                else
                {
                    stripeEvent = Event.FromJson(json);
                }

                _logger.LogInformation("Webhook recebido: {EventType} - {EventId}", stripeEvent.Type, stripeEvent.Id);

                // Registrar evento (básico)
                await RegistrarEventoBasicoAsync(stripeEvent, json);

                // Processar eventos básicos
                await ProcessarEventoBasicoAsync(stripeEvent);

                return Ok();
            }
            catch (StripeException ex)
            {
                _logger.LogError(ex, "Erro do Stripe ao processar webhook");
                return BadRequest();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Erro interno ao processar webhook");
                return StatusCode(500);
            }
        }

        // MÉTODOS PRIVADOS SIMPLIFICADOS

        private async Task RegistrarEventoBasicoAsync(Event stripeEvent, string payload)
        {
            using var scope = _serviceProvider.CreateScope();
                var context = scope.ServiceProvider.GetRequiredService<EstoqueContext>();
                
            // Verificar se já foi processado
            var existeEvento = await context.WebhookEvents
                .AnyAsync(w => w.StripeEventId == stripeEvent.Id);

            if (!existeEvento)
            {
                var webhookEvent = new WebhookEvent
                {
                    StripeEventId = stripeEvent.Id,
                    EventType = stripeEvent.Type,
                    ProcessadoEm = DateTime.UtcNow,
                    PayloadCompleto = payload
                };

                context.WebhookEvents.Add(webhookEvent);
                    await context.SaveChangesAsync();
            }
        }

        private async Task ProcessarEventoBasicoAsync(Event stripeEvent)
        {
            try
            {
                switch (stripeEvent.Type)
                {
                    case "customer.subscription.created":
                        var newSubscription = stripeEvent.Data.Object as Subscription;
                        await HandleSubscriptionCreated(newSubscription!);
                        break;

                    case "customer.subscription.updated":
                        var updatedSubscription = stripeEvent.Data.Object as Subscription;
                        await HandleSubscriptionUpdated(updatedSubscription!);
                        break;

                    case "customer.subscription.deleted":
                        var deletedSubscription = stripeEvent.Data.Object as Subscription;
                        await HandleSubscriptionDeleted(deletedSubscription!);
                        break;

                    default:
                        _logger.LogInformation("Evento não processado: {EventType}", stripeEvent.Type);
                        break;
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Erro ao processar evento {EventType}: {EventId}", stripeEvent.Type, stripeEvent.Id);
            }
        }

        private async Task HandleSubscriptionCreated(Subscription subscription)
        {
            var userId = subscription.Metadata?.GetValueOrDefault("UserId");
            if (string.IsNullOrEmpty(userId))
            {
                _logger.LogWarning("Assinatura criada sem user ID: {SubscriptionId}", subscription.Id);
                    return;
                }

            await _subscriptionService.CriarAssinaturaAsync(
                int.Parse(userId),
                subscription.Id,
                subscription.CustomerId,
                subscription.Items.Data.First().Price.Id
            );

            _logger.LogInformation("Assinatura criada para usuário {UserId}: {SubscriptionId}", userId, subscription.Id);
        }

        private async Task HandleSubscriptionUpdated(Subscription subscription)
        {
            var statusAtual = MapearStatusStripe(subscription.Status);
            await _subscriptionService.AtualizarStatusAssinaturaAsync(subscription.Id, statusAtual);

            _logger.LogInformation("Assinatura atualizada: {SubscriptionId} - Status: {Status}", subscription.Id, subscription.Status);
        }

        private async Task HandleSubscriptionDeleted(Subscription subscription)
        {
            await _subscriptionService.CancelarAssinaturaAsync(subscription.Id, DateTime.UtcNow.AddDays(30));
            _logger.LogInformation("Assinatura cancelada: {SubscriptionId}", subscription.Id);
        }

        private async Task<string> GetOrCreateStripeCustomerAsync(Usuario usuario)
        {
            // Verificar se já existe customer para este usuário
            var assinaturaExistente = await _subscriptionService.ObterAssinaturaAtivaAsync(usuario.Id);
            if (assinaturaExistente != null && !string.IsNullOrEmpty(assinaturaExistente.StripeCustomerId))
            {
                return assinaturaExistente.StripeCustomerId;
            }

            // Buscar no Stripe por email
            var customerService = new CustomerService();
            var customers = await customerService.ListAsync(new CustomerListOptions
            {
                Email = usuario.Email,
                Limit = 1
            });

            if (customers.Data.Any())
            {
                return customers.Data.First().Id;
            }

            // Criar novo customer
            var newCustomer = await customerService.CreateAsync(new CustomerCreateOptions
            {
                Email = usuario.Email,
                Name = usuario.Nome,
                Metadata = new Dictionary<string, string>
                {
                    { "UserId", usuario.Id.ToString() }
                }
            });

            return newCustomer.Id;
        }

        private static StatusAssinatura MapearStatusStripe(string stripeStatus)
        {
            return stripeStatus.ToLower() switch
            {
                "active" => StatusAssinatura.Ativa,
                "canceled" => StatusAssinatura.Cancelada,
                "past_due" => StatusAssinatura.PagamentoPendente,
                "trialing" => StatusAssinatura.EmTeste,
                "paused" => StatusAssinatura.Pausada,
                "unpaid" => StatusAssinatura.Inadimplente,
                "incomplete" => StatusAssinatura.Incompleta,
                _ => StatusAssinatura.Incompleta
            };
        }
    }

    // DTOs
    public class CreateCheckoutSessionRequest
    {
        public string PriceId { get; set; } = string.Empty;
        public string? SuccessUrl { get; set; }
        public string? CancelUrl { get; set; }
    }

    public class CreateCheckoutSessionResponse
    {
        public string SessionId { get; set; } = string.Empty;
        public string CheckoutUrl { get; set; } = string.Empty;
    }

    public class CustomerPortalRequest
    {
        public string? ReturnUrl { get; set; }
    }
} 