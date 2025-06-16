# thermal_touch

Application Flutter permettant aux opérateurs en industrie d'accomplir plus facilement leurs tâches de maintenance guidés par des experts.

## 📋 Table des Matières

- [Fonctionnalités](#-fonctionnalités)
- [Architecture](#-architecture)
- [Installation](#-installation)
- [Configuration](#-configuration)
- [Structure du Projet](#-structure-du-projet)
- [Utilisation](#-utilisation)
- [Tests](#-tests)
- [Contribution](#-contribution)
- [Déploiement](#-déploiement)


## 🚀 Fonctionnalités

### Pour les Opérateurs (acteurs primaires)
- ✅ Création de compte et authentification
- ✅ Notifications push
- ✅ Lecture des instructions de maintenance fournis dans l'application en fonction d'un équipement

### Pour les Experts (acteurs secondaires)
- ✅ Création, lecture, mise à jour et suppression des instructions.

### Fonctionnalités Communes
- ✅ Interface responsive et intuitive

## 🏗️ Architecture

Le projet suit les principes de **Clean Architecture** avec une séparation claire des responsabilités :

```
📁 lib/
├── 🎯 core/                    # Utilitaires partagés
├── 🔧 features/               # Fonctionnalités métier
│   ├── authentication/       # Gestion des utilisateurs
│   └── reports/             # Gestion des signalements
├── 🎨 shared/                # Composants UI partagés
└── 📱 main.dart              # Point d'entrée de l'application

```

### Technologies Utilisées
- **Frontend**: Flutter 3.29+
- **Backend**: Supabase (BaaS)
- **State Management**: Provider
- **Navigation**: GoRouter
- **Base de données**: PostgreSQL (Supabase)
- **Storage**: Supabase Storage

## 🔧 Installation

### Prérequis
- Flutter SDK 3.29+
- Dart SDK 3.7+
- Android Studio / VS Code
- Compte Supabase

### Étapes d'installation

1. **Cloner le repository**
```bash
git clone https://github.com/camcoder337/smart-city-mobile.git
cd smart_city
```

2. **Installer les dépendances**
```bash
flutter pub get
```

3. **Configuration des variables d'environnement**
```bash
# Créer le fichier .env à la racine à partir de l'exemple et ajoutez vos clés
cp .env.example .env
```

5. **Lancer l'application**
```bash
flutter run
```

## ⚙️ Configuration

### Configuration Supabase

1. **Créer un nouveau projet Supabase**
2. **Exécuter les scripts SQL** (voir section Database Setup)
3. **Configurer l'authentification**
4. **Créer les buckets de storage**

### Database Setup


## 📁 Structure du Projet

```
lib/
├── core/
│   ├── constants/           # Constantes de l'app
│   ├── errors/             # Gestion des erreurs
│   ├── network/            # Vérification réseau
│   ├── utils/              # Utilitaires (validation, helpers)
│   └── usecases/           # Classes de base pour use cases
├── features/
│   ├── authentication/     # Feature d'authentification
│   │   ├── data/          # Sources de données, modèles
│   │   ├── domain/        # Entités, repositories, use cases
│   │   └── presentation/  # UI, providers, widgets
│   └── reports/           # Feature de signalements
│       ├── data/
│       ├── domain/
│       └── presentation/
│           └── pages/
│               ├── citizen/    # Pages citoyens
│               └── agent/      # Pages agents
├── shared/
│   ├── widgets/           # Widgets réutilisables
│   └── themes/            # Thèmes de l'app
└── main.dart
```

## 🎯 Utilisation


## 🧪 Tests

### Tests Unitaires
```bash
# Lancer tous les tests
flutter test

# Tests avec couverture
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

### Tests d'Intégration
```bash
# Tests d'intégration
flutter test integration_test/
```

### Tests par Feature
```bash
# Tests d'authentification
flutter test test/features/authentication/

# Tests de signalements
flutter test test/features/reports/
```

## 🤝 Contribution

### Règles de Contribution

1. **Fork** le repository
2. **Créer une branche** pour votre feature: `git checkout -b feature/nouvelle-fonctionnalite`
3. **Commit** vos changements: `git commit -m 'Add: nouvelle fonctionnalité'`
4. **Push** vers la branche: `git push origin feature/nouvelle-fonctionnalite`
5. **Créer une Pull Request**

### Standards de Code

#### Conventions de Nommage
- **Classes**: PascalCase (`UserProvider`, `ReportEntity`)
- **Variables/Fonctions**: camelCase (`isLoading`, `fetchReports`)
- **Fichiers**: snake_case (`user_provider.dart`, `home_page.dart`)
- **Constantes**: SCREAMING_SNAKE_CASE (`API_BASE_URL`)

#### Structure des Commits
```
Type: Description courte

Type peut être:
- feat: Nouvelle fonctionnalité
- fix: Correction de bug
- docs: Documentation
- style: Formatage
- refactor: Refactoring
- test: Tests
- chore: Maintenance

Exemples:
feat: Add user authentication
fix: Resolve location permission issue
docs: Update README with setup instructions
```

#### Linting et Formatage
```bash
# Analyse du code
flutter analyze

# Formatage automatique
dart format lib/

# Tri des imports
flutter pub run import_sorter:main
```

### Architecture Guidelines

#### 1. Clean Architecture Layers
- **Presentation**: UI, Providers, Widgets
- **Domain**: Entities, Use Cases, Repositories (interfaces)
- **Data**: Models, Data Sources, Repository Implementations


### 🚀 Workflow de Développement

#### 1. Développement de Feature
```bash
# 1. Créer une branche
git checkout -b feature/user-notifications

# 2. Développer selon Clean Architecture
# - Créer les entités (domain/entities/)
# - Créer les use cases (domain/usecases/)
# - Implémenter les data sources (data/datasources/)
# - Créer les providers (presentation/providers/)
# - Développer l'UI (presentation/pages/)

# 3. Tests
flutter test

# 4. Commit et push
git add .
git commit -m "feat: Add user notifications system"
git push origin feature/user-notifications
```

#### 2. Code Review Checklist
- [ ] Code suit Clean Architecture
- [ ] Tests unitaires couvrent la logique métier
- [ ] Gestion d'erreurs appropriée
- [ ] Performance optimisée (const, builders)
- [ ] Documentation des fonctions complexes
- [ ] Respect des conventions de nommage

## 🚀 Déploiement

### Android
```bash
# Build APK de debug
flutter build apk --debug

# Build APK de release
flutter build apk --release

# Build App Bundle (recommandé pour Play Store)
flutter build appbundle --release
```

### iOS
```bash
# Build pour iOS
flutter build ios --release

# Archive pour App Store
# Utiliser Xcode pour l'upload
```


**Fait avec ❤️ pour améliorer nos industries**