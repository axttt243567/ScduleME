# API Configuration Architecture

## System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         User Interface                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  ┌───────────────┐      ┌──────────────────┐                   │
│  │ Profile Page  │ ───> │ Account Settings │                   │
│  └───────────────┘      └──────────────────┘                   │
│                                 │                                 │
│                                 ▼                                 │
│                    ┌─────────────────────────┐                  │
│                    │ API Configuration Page  │                  │
│                    └─────────────────────────┘                  │
│                                 │                                 │
│                    ┌────────────┴────────────┐                  │
│                    ▼                          ▼                  │
│          ┌──────────────────┐      ┌──────────────────┐        │
│          │  Add Key Dialog  │      │   Key Card List  │        │
│          └──────────────────┘      └──────────────────┘        │
│                                              │                   │
│                                     ┌────────┼────────┐         │
│                                     ▼        ▼        ▼         │
│                              [Validate] [Activate] [Delete]     │
│                                                                   │
└─────────────────────────────────────────────────────────────────┘
                                 │
                                 ▼
┌─────────────────────────────────────────────────────────────────┐
│                        State Management                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│                      ┌──────────────────┐                       │
│                      │ ApiKeyProvider   │                       │
│                      │  (ChangeNotifier)│                       │
│                      └──────────────────┘                       │
│                                │                                 │
│           ┌────────────────────┼────────────────────┐          │
│           ▼                    ▼                    ▼          │
│    [Load Keys]          [Manage Keys]        [Update Status]   │
│                                                                   │
└─────────────────────────────────────────────────────────────────┘
                                 │
                    ┌────────────┼────────────┐
                    ▼                          ▼
┌──────────────────────────────┐  ┌──────────────────────────────┐
│      Database Layer          │  │    External API Layer        │
├──────────────────────────────┤  ├──────────────────────────────┤
│                              │  │                              │
│  ┌────────────────────┐     │  │  ┌────────────────────┐     │
│  │ DatabaseHelper     │     │  │  │  GeminiService     │     │
│  └────────────────────┘     │  │  └────────────────────┘     │
│           │                  │  │           │                  │
│           ▼                  │  │           ▼                  │
│  ┌────────────────────┐     │  │  ┌────────────────────┐     │
│  │   SQLite DB        │     │  │  │   Gemini API       │     │
│  │                    │     │  │  │ (Google AI Studio) │     │
│  │  ┌──────────────┐  │     │  │  └────────────────────┘     │
│  │  │ api_keys     │  │     │  │                              │
│  │  │ table        │  │     │  │  Functions:                  │
│  │  └──────────────┘  │     │  │  • validateApiKey()         │
│  │                    │     │  │  • generateContent()        │
│  │  Methods:          │     │  │  • generateContentStream()  │
│  │  • createApiKey    │     │  │  • startChat()              │
│  │  • readAllApiKeys  │     │  │                              │
│  │  • updateApiKey    │     │  │                              │
│  │  • deleteApiKey    │     │  │                              │
│  │  • setActiveApiKey │     │  │                              │
│  └────────────────────┘     │  └──────────────────────────────┘
│                              │
└──────────────────────────────┘
```

## Data Flow Diagrams

### 1. Adding a New API Key

```
User Input ──> Validation ──> Provider ──> Database ──> UI Update
   │              │              │            │           │
   │              │              │            │           │
   ▼              ▼              ▼            ▼           ▼
[Name]      [Format Check]  [addApiKey()]  [INSERT]  [Rebuild]
[Key]       [Duplicate Check] [Load Keys]  [api_keys] [Show Card]
[Active?]                                              [Feedback]
```

### 2. Validating an API Key

```
User Action ──> Service ──> External API ──> Provider ──> Database ──> UI
    │             │            │               │            │          │
    │             │            │               │            │          │
    ▼             ▼            ▼               ▼            ▼          ▼
[Tap Validate] [Send Test] [Process] [Update Status] [UPDATE] [Show Result]
               [Request]   [Response]  [isValid=true]  [record] [✓ or ✗]
```

### 3. Using Active API Key in App

```
App Feature ──> Provider ──> Check Active ──> Get Key ──> Gemini API ──> Result
    │             │              │              │            │            │
    │             │              │              │            │            │
    ▼             ▼              ▼              ▼            ▼            ▼
[Generate]  [activeApiKey]  [hasActiveKey] [keyValue] [API Call] [Content]
[Summary]                       [true]                             [Text]
                                  │
                                  ├──> Update lastUsed timestamp
                                  └──> Return to UI
```

## Component Relationships

```
┌─────────────────────────────────────────────────────────────┐
│                         Models                              │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌──────────────────────────────────────────────────┐     │
│  │ ApiKey Model                                      │     │
│  ├──────────────────────────────────────────────────┤     │
│  │ Properties:                                       │     │
│  │ • id: String                                      │     │
│  │ • name: String                                    │     │
│  │ • keyValue: String                                │     │
│  │ • isActive: bool                                  │     │
│  │ • createdAt: DateTime                             │     │
│  │ • lastUsedAt: DateTime?                           │     │
│  │ • lastValidatedAt: DateTime?                      │     │
│  │ • isValid: bool?                                  │     │
│  │                                                    │     │
│  │ Methods:                                          │     │
│  │ • toMap() → Map<String, dynamic>                 │     │
│  │ • fromMap(map) → ApiKey                          │     │
│  │ • copyWith(...) → ApiKey                         │     │
│  │ • maskedKey → String (getter)                    │     │
│  └──────────────────────────────────────────────────┘     │
│                                                             │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                    State Management                         │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌──────────────────────────────────────────────────┐     │
│  │ ApiKeyProvider (ChangeNotifier)                  │     │
│  ├──────────────────────────────────────────────────┤     │
│  │ Private State:                                    │     │
│  │ • _apiKeys: List<ApiKey>                         │     │
│  │ • _activeApiKey: ApiKey?                         │     │
│  │ • _isLoading: bool                               │     │
│  │ • _dbHelper: DatabaseHelper                      │     │
│  │                                                    │     │
│  │ Public Getters:                                   │     │
│  │ • apiKeys                                         │     │
│  │ • activeApiKey                                    │     │
│  │ • isLoading                                       │     │
│  │ • hasActiveKey                                    │     │
│  │ • totalKeys                                       │     │
│  │ • validKeysCount                                  │     │
│  │                                                    │     │
│  │ Public Methods:                                   │     │
│  │ • initialize()                                    │     │
│  │ • loadApiKeys()                                   │     │
│  │ • addApiKey(...)                                  │     │
│  │ • updateApiKey(...)                               │     │
│  │ • setActiveKey(...)                               │     │
│  │ • deleteApiKey(...)                               │     │
│  │ • updateValidationStatus(...)                     │     │
│  │ • updateLastUsed(...)                             │     │
│  └──────────────────────────────────────────────────┘     │
│                                                             │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                     Utility Services                        │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌──────────────────────────────────────────────────┐     │
│  │ GeminiService (Static Utilities)                 │     │
│  ├──────────────────────────────────────────────────┤     │
│  │ Static Methods:                                   │     │
│  │                                                    │     │
│  │ • validateApiKey(apiKey)                         │     │
│  │   → Future<bool>                                  │     │
│  │                                                    │     │
│  │ • generateContent(apiKey, prompt, [model])       │     │
│  │   → Future<String?>                               │     │
│  │                                                    │     │
│  │ • generateContentStream(apiKey, prompt, [model]) │     │
│  │   → Stream<String>                                │     │
│  │                                                    │     │
│  │ • startChat(apiKey, [model], [history])          │     │
│  │   → Future<ChatSession>                           │     │
│  │                                                    │     │
│  │ • getAvailableModels(apiKey)                     │     │
│  │   → Future<List<String>>                          │     │
│  │                                                    │     │
│  │ • isValidKeyFormat(apiKey)                       │     │
│  │   → bool                                          │     │
│  │                                                    │     │
│  │ • getErrorMessage(error)                         │     │
│  │   → String                                        │     │
│  └──────────────────────────────────────────────────┘     │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Database Schema Visualization

```
┌──────────────────────────────────────────────────────────┐
│                      api_keys Table                       │
├──────────────────────────────────────────────────────────┤
│                                                          │
│  id (TEXT PRIMARY KEY)                                  │
│  ├─ "1234567890123"                                     │
│  └─ "1234567890124"                                     │
│                                                          │
│  name (TEXT NOT NULL)                                   │
│  ├─ "Personal Key"                                      │
│  └─ "Work API Key"                                      │
│                                                          │
│  keyValue (TEXT NOT NULL)                               │
│  ├─ "AIzaSyABC...XYZ123"                               │
│  └─ "AIzaSyDEF...XYZ456"                               │
│                                                          │
│  isActive (INTEGER NOT NULL)    [INDEX]                │
│  ├─ 1 (true)                                           │
│  └─ 0 (false)                                          │
│                                                          │
│  createdAt (TEXT NOT NULL)                              │
│  ├─ "2025-10-23T10:30:00.000Z"                        │
│  └─ "2025-10-23T11:45:00.000Z"                        │
│                                                          │
│  lastUsedAt (TEXT)                                      │
│  ├─ "2025-10-23T14:20:00.000Z"                        │
│  └─ null                                               │
│                                                          │
│  lastValidatedAt (TEXT)                                 │
│  ├─ "2025-10-23T10:35:00.000Z"                        │
│  └─ "2025-10-23T11:50:00.000Z"                        │
│                                                          │
│  isValid (INTEGER)                                      │
│  ├─ 1 (true - validated successfully)                  │
│  └─ 0 (false - validation failed)                      │
│                                                          │
└──────────────────────────────────────────────────────────┘
```

## State Updates Flow

```
┌─────────────────────────────────────────────────────────────┐
│                    State Change Events                       │
└─────────────────────────────────────────────────────────────┘
                            │
        ┌───────────────────┼───────────────────┐
        ▼                   ▼                   ▼
  ┌──────────┐        ┌──────────┐        ┌──────────┐
  │   Add    │        │  Update  │        │  Delete  │
  │   Key    │        │   Key    │        │   Key    │
  └──────────┘        └──────────┘        └──────────┘
        │                   │                   │
        └───────────────────┼───────────────────┘
                            ▼
                    ┌───────────────┐
                    │ notifyListeners()
                    └───────────────┘
                            │
        ┌───────────────────┼───────────────────┐
        ▼                   ▼                   ▼
  ┌──────────┐        ┌──────────┐        ┌──────────┐
  │ Consumer │        │  Selector│        │  context │
  │ rebuilds │        │ rebuilds │        │  .watch  │
  └──────────┘        └──────────┘        └──────────┘
        │                   │                   │
        └───────────────────┼───────────────────┘
                            ▼
                    ┌───────────────┐
                    │  UI Updates   │
                    └───────────────┘
```

## Integration Points

```
┌─────────────────────────────────────────────────────────────┐
│              Where to Use Gemini API Keys                    │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  1. Notes Enhancement                                        │
│     • Summarize notes                                        │
│     • Expand bullet points                                   │
│     • Format content                                         │
│                                                              │
│  2. Event Suggestions                                        │
│     • Suggest event descriptions                             │
│     • Generate event titles                                  │
│     • Create study plans                                     │
│                                                              │
│  3. Calendar Assistant                                       │
│     • Analyze schedule                                       │
│     • Suggest optimal times                                  │
│     • Conflict detection                                     │
│                                                              │
│  4. Study Helper                                             │
│     • Create study guides                                    │
│     • Generate quiz questions                                │
│     • Explain concepts                                       │
│                                                              │
│  5. Task Breakdown                                           │
│     • Break large tasks into steps                           │
│     • Estimate time required                                 │
│     • Prioritize tasks                                       │
│                                                              │
│  6. Writing Assistant                                        │
│     • Grammar checking                                       │
│     • Tone adjustment                                        │
│     • Paraphrasing                                           │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

## Security Considerations

```
┌─────────────────────────────────────────────────────────────┐
│                     Security Layers                          │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌────────────────────────────────────────────────┐        │
│  │ Level 1: Input Validation                      │        │
│  │ • Format checking                               │        │
│  │ • Duplicate prevention                          │        │
│  │ • Length validation                             │        │
│  └────────────────────────────────────────────────┘        │
│                       │                                      │
│                       ▼                                      │
│  ┌────────────────────────────────────────────────┐        │
│  │ Level 2: Storage (Current Implementation)      │        │
│  │ • SQLite database                               │        │
│  │ • Local device only                             │        │
│  │ • No cloud sync                                 │        │
│  └────────────────────────────────────────────────┘        │
│                       │                                      │
│                       ▼                                      │
│  ┌────────────────────────────────────────────────┐        │
│  │ Level 3: Display Security                      │        │
│  │ • Masked key display                            │        │
│  │ • Show/hide toggle                              │        │
│  │ • No clipboard by default                       │        │
│  └────────────────────────────────────────────────┘        │
│                       │                                      │
│                       ▼                                      │
│  ┌────────────────────────────────────────────────┐        │
│  │ Level 4: API Communication                     │        │
│  │ • HTTPS only                                    │        │
│  │ • Timeout protection                            │        │
│  │ • Error sanitization                            │        │
│  └────────────────────────────────────────────────┘        │
│                                                              │
│  ┌────────────────────────────────────────────────┐        │
│  │ Future Enhancement: Encryption Layer            │        │
│  │ • flutter_secure_storage                        │        │
│  │ • AES encryption                                 │        │
│  │ • Biometric protection                           │        │
│  └────────────────────────────────────────────────┘        │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

## File Structure

```
lib/
├── models/
│   └── api_key.dart                 ← Data model
│
├── providers/
│   └── api_key_provider.dart        ← State management
│
├── utils/
│   └── gemini_service.dart          ← API integration
│
├── pages/
│   ├── api_configuration_page.dart  ← Full management UI
│   └── account_settings_page.dart   ← Navigation entry point
│
├── database/
│   └── database_helper.dart         ← CRUD + migration
│
└── main.dart                         ← Provider setup

docs/
├── GEMINI_API_GUIDE.md              ← User guide
├── API_CONFIGURATION_SUMMARY.md     ← Implementation summary
├── GEMINI_API_QUICK_REF.md          ← Developer quick ref
└── API_ARCHITECTURE.md              ← This file
```
