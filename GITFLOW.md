# 🔄 Git Flow - EstoqueMax

## 📋 Visão Geral

Este documento define o fluxo de trabalho Git para o projeto **EstoqueMax**. Seguimos uma versão adaptada do **Git Flow** para garantir desenvolvimento organizado, releases estáveis e colaboração eficiente.

## 🌳 Estrutura de Branches

### 📌 Branches Principais

#### `main` 
- **Propósito**: Código em produção
- **Estabilidade**: 100% estável e testado
- **Deploy**: Automático para produção
- **Proteção**: Merge apenas via PR aprovado
- **Tags**: Releases são taggeadas aqui

#### `develop`
- **Propósito**: Branch de desenvolvimento principal
- **Estabilidade**: Código integrado e testado
- **Deploy**: Automático para ambiente de staging
- **Merge**: Features e bugfixes são mergeados aqui

### 🚀 Branches de Trabalho

#### `feature/*`
```bash
# Naming convention:
feature/EST-123-nome-da-funcionalidade
feature/login-google
feature/dashboard-analytics
```
- **Origem**: `develop`
- **Destino**: `develop`
- **Propósito**: Desenvolvimento de novas funcionalidades
- **Duração**: Curta (max 1-2 semanas)

#### `bugfix/*`
```bash
# Naming convention:
bugfix/EST-456-corrigir-crash-login
bugfix/memoria-leak-listview
```
- **Origem**: `develop`
- **Destino**: `develop`
- **Propósito**: Correção de bugs não-críticos

#### `hotfix/*`
```bash
# Naming convention:
hotfix/1.2.1-corrigir-crash-critico
hotfix/seguranca-auth-token
```
- **Origem**: `main`
- **Destino**: `main` E `develop`
- **Propósito**: Correções urgentes em produção
- **Release**: Imediato após merge

#### `release/*`
```bash
# Naming convention:
release/1.3.0
release/2.0.0-beta
```
- **Origem**: `develop`
- **Destino**: `main` E `develop`
- **Propósito**: Preparação de release
- **Atividades**: Ajustes finais, bump de versão, testes

## 🔧 Comandos Essenciais

### 🆕 Iniciando uma Feature
```bash
# 1. Atualizar develop
git checkout develop
git pull origin develop

# 2. Criar feature branch
git checkout -b feature/EST-123-nova-funcionalidade

# 3. Desenvolver...
# 4. Commit frequente
git add .
git commit -m "feat: implementa autenticação biométrica"

# 5. Push para remote
git push -u origin feature/EST-123-nova-funcionalidade
```

### 🔄 Finalizando uma Feature
```bash
# 1. Atualizar develop
git checkout develop
git pull origin develop

# 2. Voltar para feature e rebase
git checkout feature/EST-123-nova-funcionalidade
git rebase develop

# 3. Push e criar PR
git push --force-with-lease origin feature/EST-123-nova-funcionalidade
# Criar PR: feature/EST-123-nova-funcionalidade -> develop
```

### 🚨 Hotfix Urgente
```bash
# 1. Criar hotfix do main
git checkout main
git pull origin main
git checkout -b hotfix/1.2.1-corrigir-crash-critico

# 2. Fazer correção
git add .
git commit -m "fix: corrige crash na tela de login"

# 3. Push e PR para main
git push -u origin hotfix/1.2.1-corrigir-crash-critico
# PR: hotfix/1.2.1-corrigir-crash-critico -> main

# 4. Após merge no main, fazer PR para develop
# PR: hotfix/1.2.1-corrigir-crash-critico -> develop
```

### 🏷️ Release Process
```bash
# 1. Criar release branch
git checkout develop
git pull origin develop
git checkout -b release/1.3.0

# 2. Bump version e ajustes finais
# Editar pubspec.yaml, CHANGELOG.md, etc.
git add .
git commit -m "chore: bump version to 1.3.0"

# 3. PR para main
git push -u origin release/1.3.0
# PR: release/1.3.0 -> main

# 4. Após merge, tag no main
git checkout main
git pull origin main
git tag -a v1.3.0 -m "Release version 1.3.0"
git push origin v1.3.0

# 5. Merge back para develop
# PR: release/1.3.0 -> develop
```

## 📝 Convenções de Commit

### 🎯 Formato
```
<tipo>(<escopo>): <descrição>

<corpo opcional>

<footer opcional>
```

### 📋 Tipos Permitidos
- `feat`: Nova funcionalidade
- `fix`: Correção de bug
- `docs`: Mudanças na documentação
- `style`: Formatação (sem mudança de código)
- `refactor`: Refatoração de código
- `perf`: Melhoria de performance
- `test`: Adicionar/corrigir testes
- `chore`: Tarefas de build/config
- `ci`: Mudanças em CI/CD

### ✅ Exemplos Bons
```bash
feat(auth): adiciona login com Google
fix(dashboard): corrige crash ao carregar gráficos
docs(readme): atualiza instruções de instalação
perf(listview): otimiza renderização de grandes listas
```

### ❌ Exemplos Ruins
```bash
update stuff
fix bug
changes
wip
```

## 🔒 Regras de Proteção

### `main` Branch
- ✅ Require PR reviews (min 1)
- ✅ Require status checks
- ✅ Require branches up-to-date
- ✅ Include administrators
- ❌ Allow force pushes
- ❌ Allow deletions

### `develop` Branch
- ✅ Require PR reviews (min 1)
- ✅ Require status checks
- ❌ Allow force pushes
- ❌ Allow deletions

## 🧪 Processo de Review

### ✅ Checklist do Autor
- [ ] Código segue style guide
- [ ] Testes passando
- [ ] Build funcionando
- [ ] Performance testada
- [ ] Documentação atualizada
- [ ] CHANGELOG atualizado (se relevante)

### 👀 Checklist do Reviewer
- [ ] Código limpo e legível
- [ ] Lógica correta
- [ ] Performance adequada
- [ ] Segurança verificada
- [ ] Testes adequados
- [ ] UI/UX validada

## 📊 Automation

### 🤖 GitHub Actions
- **PR**: Analyze + Test + Build
- **Push to develop**: Deploy to staging
- **Push to main**: Deploy to production
- **Tags**: Create GitHub release

### 🔍 Quality Gates
- ✅ Flutter analyze passing
- ✅ Tests passing (min 80% coverage)
- ✅ Build successful
- ✅ Security scan clean

## 🚀 Deployment

### 🎯 Ambientes
- **main** → **Produção** (App Stores + Web)
- **develop** → **Staging** (TestFlight + Web Preview)
- **feature** → **Preview** (Firebase Hosting)

### 📱 Plataformas
- **Android**: Google Play Store (Internal/Beta/Production)
- **iOS**: App Store Connect (TestFlight/App Store)
- **Web**: Azure Static Web Apps
- **Desktop**: GitHub Releases

## 💡 Dicas e Boas Práticas

### ✅ Do's
- Mantenha commits pequenos e focados
- Use branches de vida curta
- Teste antes de criar PR
- Escreva mensagens de commit claras
- Faça rebase para manter histórico limpo
- Delete branches após merge

### ❌ Don'ts
- Nunca commite diretamente no main
- Não force push em branches compartilhadas
- Não merge sem review
- Não deixe features muito grandes
- Não ignore conflicts em rebase

## 🆘 Problemas Comuns

### 🔄 Resolver Conflicts
```bash
# Durante rebase
git rebase develop
# Resolver conflicts manualmente
git add .
git rebase --continue

# Durante merge
git merge develop
# Resolver conflicts manualmente
git add .
git commit
```

### 🔙 Reverter Changes
```bash
# Reverter último commit
git revert HEAD

# Reverter commit específico
git revert <commit-hash>

# Reset hard (CUIDADO!)
git reset --hard HEAD~1
```

### 🧹 Limpar Branches
```bash
# Listar branches mergeadas
git branch --merged

# Deletar branch local
git branch -d feature/branch-name

# Deletar branch remota
git push origin --delete feature/branch-name
```

## 📞 Suporte

Para dúvidas sobre o Git Flow:
- 📧 Crie uma issue no GitHub
- 💬 Contate @AbsonDev
- 📚 Consulte a [documentação oficial do Git Flow](https://nvie.com/posts/a-successful-git-branching-model/)

---

**Lembre-se**: Este fluxo evolui com o projeto. Sugestões de melhoria são sempre bem-vindas! 