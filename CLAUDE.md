# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

EstoqueMax is a comprehensive family inventory management platform that combines modern technologies like AI, real-time features, family sharing, and a freemium model. The project consists of:

- **Backend API**: ASP.NET Core 8 with Entity Framework
- **Mobile App**: Flutter cross-platform
- **Advanced Features**: AI prediction, SignalR real-time updates, subscription system

## Development Commands

### Backend (ASP.NET Core API)
```bash
# Navigate to API directory
cd EstoqueMax/EstoqueApp.Api

# Restore packages
dotnet restore

# Run development server
dotnet run

# Build project
dotnet build

# Run migrations
dotnet ef database update

# Create new migration
dotnet ef migrations add <MigrationName>

# Clean build
dotnet clean
```

The API runs on:
- HTTP: http://localhost:5265
- HTTPS: https://localhost:7063

### Mobile App (Flutter)
```bash
# Navigate to mobile directory
cd estoque_app_mobile

# Install dependencies
flutter pub get

# Run on connected device/emulator
flutter run

# Build for Android
flutter build apk --release

# Build for web
flutter build web --release

# Analyze code
flutter analyze

# Run tests
flutter test

# Clean build cache
flutter clean
```

## Architecture Overview

### Backend Structure
The API follows clean architecture principles with Entity Framework Core:

- **Controllers/**: API endpoints organized by feature
- **Models/**: Entity classes for database
- **Services/**: Business logic layer
- **Data/**: Entity Framework context and configurations
- **Hubs/**: SignalR hubs for real-time communication
- **Migrations/**: Database schema changes

### Frontend Structure
The Flutter app uses BLoC pattern for state management:

- **core/**: Shared utilities, themes, and services
- **features/**: Feature-based modules (auth, estoque, despensas, etc.)
- Each feature contains: data/, presentation/bloc/, presentation/screens/, presentation/widgets/

### Key Technologies
- **Backend**: ASP.NET Core 8, Entity Framework Core, PostgreSQL, SignalR, Stripe, JWT Authentication
- **Frontend**: Flutter, BLoC, Dio (HTTP), SignalR client, Google Sign-In
- **AI/ML**: Microsoft.ML for consumption prediction
- **Real-time**: SignalR hub for live updates across family members

## Database Configuration

The application uses PostgreSQL for both development and production. Connection string is configured in appsettings.json. The database includes:

- User management with Google OAuth support
- Multi-pantry system with family sharing
- Inventory items with expiration tracking
- Shopping lists with AI suggestions
- Subscription management with Stripe integration
- Consumption history for AI predictions

## Key Features Implemented

1. **Inventory Management**: Full CRUD for products and quantities
2. **Family Sharing**: Invite system with role-based permissions
3. **Real-time Updates**: SignalR for live inventory changes
4. **AI Predictions**: Consumption forecasting based on usage patterns
5. **Shopping Lists**: Auto-generation based on minimum stock levels
6. **Subscription System**: Freemium model with Stripe integration
7. **Analytics Dashboard**: Usage insights and consumption trends

## SignalR Real-time Communication

The app uses SignalR for real-time features:
- Hub endpoint: `/estoqueHub`
- Automatic group management by pantry
- Events: inventory updates, shopping list changes, invitations
- JWT authentication integrated with query string tokens

## Common Development Patterns

### API Controllers
- Use `[Authorize]` attribute for protected endpoints
- Implement `IPermissionService` for role-based access
- Follow RESTful conventions
- Return appropriate HTTP status codes

### Flutter BLoC Pattern
- Each feature has its own BLoC for state management
- Use `RepositoryProvider` for dependency injection
- Implement proper error handling in UI
- Use `BlocListener` for side effects and `BlocBuilder` for UI updates

### Responsive Design
- Use `ResponsiveUtils` to detect screen size and type
- Web layout activates automatically on desktop/large screens
- Mobile/tablet uses bottom navigation, desktop uses sidebar
- `WebPageLayout` and `WebCard` components for consistent web styling
- `ResponsiveGrid` and `WebGrid` for adaptive layouts
- Color system uses `AppColors` class for consistent theming

### Database Migrations
- Always test migrations in development first
- Use descriptive migration names
- Handle data transformations carefully
- The application includes automatic schema fixes for development

## Security Considerations

- JWT tokens for API authentication
- Google OAuth 2.0 for social login
- Role-based access control for pantries
- Secure storage for sensitive data in mobile app
- CORS properly configured for production domains

## Subscription System

The app implements a freemium model:
- **Free Plan**: 1 pantry, up to 50 products, basic features
- **Premium Plan**: Unlimited pantries and products, full AI features, advanced analytics
- Stripe integration for payment processing
- Webhook handling for subscription status updates