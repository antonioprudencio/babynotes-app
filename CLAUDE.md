### Folder Structure  

|—— view_model/                // Presentation and state logic  
|   └── <feature>_view_model.dart
|—— widgets/                   // Feature-specific widgets  
|   |── <feature>_screen.dart
|   └── <other_widgets>        // Auxiliary feature widgets  
|—— domain/                    // Business layer (entities and rules)  
|   └── models/                // Domain models (business entities)  
|       └── <model_name>.dart  // Ex: book.dart, verse.dart  
|—— data/                      // Data layer (external data access)  
|   |── repositories/          // Repository implementation  
|   |   └── <repository>.dart  // Ex: book_repository.dart  
|   |── services/              // Services (API, database, storage)  
|   |   └── <service>.dart     // Ex: bible_database_service.dart  
|   └── model/                 // Data models (DTOs, JSON models)  
|       └── <api_model>.dart   // Ex: book_api_model.dart  
|——————————————————————————————————————————————