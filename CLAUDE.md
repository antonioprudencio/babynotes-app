├── main.dart                          // Application entry point
├── main_development.dart              // Configuration for development
├── main_staging.dart                  // Configuration for staging
├── config/                            // App configurations (URLs, constants)
├── utils/                             // Utilities and helpers
├── routing/                           // Route configuration
├── ui/                                // Presentation layer (UI)
│   ├── core/                          // Shared components
│   │   ├── ui/                        // Reusable widgets
│   │   │   └── <shared_widgets>       // Ex: custom_button.dart, loading_widget.dart
│   │   └── themes/                    // App themes and styles
│   └── <FEATURE_NAME>/                // Specific features (ex: book_reading/)
│       ├── view_model/                // Presentation logic and state
│       │   └── <feature>_view_model.dart
│       └── widgets/                   // Feature-specific widgets
│           ├── <feature>_screen.dart
│           └── <other_widgets>        // Feature auxiliary widgets
├── domain/                            // Business layer (entities and rules)
│   └── models/                        // Domain models (business entities)
│       └── <model_name>.dart          // Ex: book.dart, verse.dart
├── data/                              // Data layer (external data access)
│   ├── repositories/                  // Repository implementations
│   │   └── <repository>.dart          // Ex: book_repository.dart
│   ├── services/                      // Services (API, database, storage)
│   │   └── <service>.dart             // Ex: bible_database_service.dart
│   └── model/                         // Data models (DTOs, JSON models)
│       └── <api_model>.dart           // Ex: book_api_model.dart