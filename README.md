# Digital Delta

> **Hackathon Project** by Team **LU_Furious**
> **Event:** INNONATION Inter-University National Hackathon, HACKFUSION 2026

> A disaster-resilient, offline-first Mobile application for flood-zone relief coordination in Bangladesh.

---

## Overview

**Digital Delta** is a peer-to-peer mesh networking application designed to operate in connectivity-degraded environments — exactly the conditions faced during floods in low-lying delta regions. It enables rescue teams, volunteers, and affected communities to communicate, coordinate supply logistics, and share real-time situational data **without relying on internet infrastructure**.

The app uses **Bluetooth/Wi-Fi Direct mesh networking** (via Google Nearby Connections), **CRDT-based conflict-free data sync**, **end-to-end encryption**, and a **local-first SQLite ledger** to ensure data integrity even when devices go offline and reconnect later.

> **YouTube Demo Video:** [https://youtu.be/1j4evOQcyHY](https://youtu.be/1j4evOQcyHY)

---

## Key Features

| Feature | Description |
|---|---|
| 🔐 **Offline Auth** | OTP-based TOTP authentication with Ed25519 key pairs — no server needed |
| 📡 **Mesh Networking** | Bluetooth/Wi-Fi P2P discovery and relay using Google Nearby Connections |
| 🔄 **CRDT Sync** | Last-Write-Wins registers with Hybrid Logical Clocks for conflict-free data sync |
| ⏱ **Vector Clocks** | Causality tracking across distributed nodes for ordering concurrent events |
| 🔒 **E2E Encryption** | X25519 key exchange + AES-GCM; relay nodes cannot read message content |
| 🗺 **Offline Maps** | Custom-painted Sylhet region map with path-finding; no tile server required |
| 📦 **Store & Forward** | Messages queued with TTL-based relay when destination peer is not directly reachable |
| 🧩 **Conflict Resolution UI** | Visual screen for manually reviewing and resolving CRDT conflicts |
| 📋 **Audit Ledger** | Hash-chained tamper-evident ledger of all critical events |

---

## Architecture Overview

See the [Architecture Diagram](#-architecture-diagram-structure) section below for the full layered diagram description.

```
lib/
├── main.dart                        # App entry point
├── routes/
│   └── app_routes.dart              # Named route definitions
├── core/
│   ├── config/                      # App-level configuration
│   ├── theme/                       # Light/dark theme (AppTheme)
│   ├── utils/                       # Shared helpers
│   ├── manager/
│   │   └── ledger_manager.dart      # Hash-chained audit ledger
│   └── services/
│       ├── auth_service.dart        # TOTP OTP + Ed25519 identity
│       ├── mesh_service.dart        # Nearby Connections mesh manager
│       ├── crdt_service.dart        # LWW-Register CRDT operations
│       ├── vector_clock_service.dart# Hybrid Logical Clock (HLC)
│       └── encryption_service.dart  # X25519 + AES-GCM E2E crypto
├── data/
│   ├── local/
│   │   └── db_helper.dart           # SQLite schema (v3) — 10 tables
│   └── models/
│       ├── crdt_entry_model.dart    # CRDT entry ↔ SQLite mapping
│       └── mesh_message_model.dart  # Mesh message ↔ SQLite mapping
├── generated/                       # Protobuf-generated Dart code
│   ├── mesh.proto                   # (see proto/ directory)
│   ├── mesh.pb.dart                 # Messages: LedgerEntry, MeshEnvelope, etc.
│   ├── mesh.pbenum.dart             # Enums: EntryType, PayloadType
│   ├── mesh.pbgrpc.dart             # gRPC service stubs: MeshSyncService
│   └── mesh.pbjson.dart             # JSON descriptors
├── features/
│   ├── auth/screens/                # Login, Register, OTP verification
│   ├── dashboard/                   # Main dashboard screen
│   ├── bottom_navigation/           # Main nav bar shell
│   ├── mesh/screens/                # Mesh dashboard, chat, conflict resolution, logs
│   ├── recover_rescue/screens/      # Rescue, supply, camp, volunteer, recovery
│   ├── profile/screens/             # User profile
│   └── sync/screens/                # Manual sync trigger screen
├── mapupdated/                      # Active offline map module
│   ├── data/                        # Sylhet region static map data
│   ├── logic/                       # Path-finding algorithm
│   ├── models/                      # MapDataModel
│   ├── providers/                   # MapProvider (state management)
│   ├── services/                    # BluetoothMeshService, PermissionService, StorageService
│   └── widgets/                     # MapPainter (CustomPainter), MapScreen, dialogs
└── map/                             # Legacy map module (superseded by mapupdated)
    ├── models/                      # Node, Edge, PathFinder
    ├── services/                    # MapProvider
    └── visuals/                     # MapPainter, MapScreen
```

---

## Architecture Diagrams

Available at /docs folder in the root directory.

 - Layered Architecture Diagram
 - CRDT Sync Data Flow Diagram
 - Message Relay Diagram
 - Database Schema Diagram

---

## Database Schema

Digital Delta uses **SQLite (sqflite)** with a 10-table schema (v3):

| Table | Purpose |
|---|---|
| `users` | Local identity store — id, username, mobile, role, public_key |
| `audit_logs` | Hash-chained tamper-evident event log |
| `messages` | Derived message cache from ledger entries |
| `posts` | User posts (relief updates, announcements) |
| `ledger_entries` | Core append-only ledger with hash chaining |
| `sync_state` | Per-peer last-synced hash for delta sync |
| `peers` | Known Bluetooth peers with their public keys |
| `mesh_messages` | Store-and-forward message queue with TTL and hop list |
| `crdt_entries` | LWW-Register entries with vector clocks and conflict flags |
| `relay_queue` | Pending relay envelopes awaiting forwarding |
| `mesh_events_log` | Structured log of all mesh topology events |

---

## Setup Instructions

### Prerequisites

| Tool | Version |
|---|---|
| Flutter SDK | `≥ 3.10.0` |
| Dart SDK | `≥ 3.0.0` |
| Android SDK | API Level 21+ (Android 5.0 Lollipop) |
| Protobuf compiler (`protoc`) | `≥ 3.21` |
| Dart protoc plugin | `protoc-gen-dart` |

> **iOS** is not a primary target. The `nearby_connections` package requires Android. iOS builds may require additional configuration.

---

### 1. Clone the Repository

```bash
git clone https://github.com/LU-Furious/digital-delta.git
cd digital-delta
```

---

### 2. Install Flutter Dependencies

```bash
flutter pub get
```

---

### 3. Configure Android Permissions

Ensure your `android/app/src/main/AndroidManifest.xml` includes the following permissions for Nearby Connections and Bluetooth mesh:

```xml
<!-- Bluetooth -->
<uses-permission android:name="android.permission.BLUETOOTH" />
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />
<uses-permission android:name="android.permission.BLUETOOTH_SCAN" />
<uses-permission android:name="android.permission.BLUETOOTH_ADVERTISE" />
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />

<!-- Wi-Fi Direct / Nearby -->
<uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
<uses-permission android:name="android.permission.CHANGE_WIFI_STATE" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />

<!-- Nearby Connections -->
<uses-permission android:name="android.permission.NEARBY_WIFI_DEVICES" />
```

---

### 4. (Optional) Regenerate Protobuf Files

The generated files are already committed to `lib/generated/`. Only re-run this if you modify `proto/mesh.proto`:

```bash
# Install protoc-gen-dart if not already installed
dart pub global activate protoc_plugin

# Regenerate
protoc --dart_out=grpc:lib/generated -I proto proto/mesh.proto
```

---

### 5. Build and Run

**Debug (USB-connected Android device):**
```bash
flutter run
```

**Release APK:**
```bash
flutter build apk --release
```

The APK will be at: `build/app/outputs/flutter-apk/app-release.apk`

**Install directly to connected device:**
```bash
flutter install
```

---

### 6. Multi-Device Testing (Mesh Demo)

To observe mesh networking, you need **at least 2 physical Android devices**. Emulators do not support Bluetooth or Wi-Fi Direct.

```bash
# Terminal 1 — Device A
flutter run -d <device_id_A>

# Terminal 2 — Device B
flutter run -d <device_id_B>
```

List connected devices:
```bash
flutter devices
```

---

## Architecture Diagram Structure

> The following is a description for manual illustration. Use this as your reference to draw the architecture diagram.

### Diagram: Layered Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        PRESENTATION LAYER                       │
│                                                                 │
│  LoginScreen  RegisterScreen  OTPScreen  DashboardScreen        │
│  MeshDashboard  MeshChatScreen  ConflictResolutionScreen        │
│  RecoverRescueScreen  SuppliesScreen  CampLocationScreen        │
│  VolunteerLocationScreen  SyncScreen  ProfileScreen             │
│  MapScreen (CustomPainter)  TopReportDialog                     │
└──────────────────────────┬──────────────────────────────────────┘
                           │ uses
┌──────────────────────────▼──────────────────────────────────────┐
│                         SERVICE LAYER                           │
│                                                                 │
│  AuthService          MeshSyncManager        CrdtService        │
│  (TOTP + Ed25519)     (Nearby Connections)   (LWW-Register)     │
│                                                                 │
│  VectorClockService   EncryptionService      LedgerManager      │
│  (HLC)                (X25519 + AES-GCM)     (Hash-chain)       │
│                                                                 │
│  BluetoothMeshService  PermissionService  StorageService        │
└──────────────────────────┬──────────────────────────────────────┘
                           │ persists
┌──────────────────────────▼──────────────────────────────────────┐
│                          DATA LAYER                             │
│                                                                 │
│  DbHelper (SQLite v3)                                           │
│  ┌─────────────┬──────────────┬──────────────┬────────────────┐ │
│  │   users     │ ledger_entries│ crdt_entries │ mesh_messages │ │
│  │ audit_logs  │  sync_state  │ relay_queue  │ mesh_events_log│ │
│  │  messages   │    posts     │   peers      │                │ │
│  └─────────────┴──────────────┴──────────────┴────────────────┘ │
│                                                                 │
│  CrdtEntryModel    MeshMessageModel    MapDataModel             │
└──────────────────────────┬──────────────────────────────────────┘
                           │ serializes via
┌──────────────────────────▼──────────────────────────────────────┐
│                      PROTOBUF / gRPC LAYER                      │
│                                                                 │
│  LedgerEntry   SyncRequest / SyncResponse                       │
│  CrdtEntry     CrdtSyncRequest / CrdtSyncResponse               │
│  MeshMessage   NodeInfo   VectorClock   MeshEnvelope            │
│                                                                 │
│  MeshSyncServiceClient / MeshSyncServiceBase (gRPC stubs)       │
└──────────────────────────┬──────────────────────────────────────┘
                           │ transported over
┌──────────────────────────▼──────────────────────────────────────┐
│                     TRANSPORT LAYER                             │
│                                                                 │
│         Google Nearby Connections API                           │
│         Strategy: P2P_CLUSTER (many-to-many)                    │
│         Service ID: com.digitaldelta.mesh                       │
│                                                                 │
│    [Device A] ←──BT/WiFi Direct──→ [Device B]                   │
│         ↑                                ↓                      │
│    [Relay Node] ←─────────────────── [Device C]                 │
└─────────────────────────────────────────────────────────────────┘
```

### Diagram: Data Flow — CRDT Sync

```
Device A                              Device B
   │                                      │
   │  increment VectorClock               │
   │  write crdt_entries (LWW)            │
   │                                      │
   │──── CrdtSyncRequest (VectorClock) ──→│
   │                                      │  compare clocks
   │                                      │  find delta entries
   │←── CrdtSyncResponse (CrdtEntries) ───│
   │                                      │
   │  merge entries                       │
   │  detect conflicts (concurrent edits) │
   │  flag is_conflict = 1                │
   │  surface to ConflictResolutionScreen │
```

### Diagram: Message Relay (Store & Forward)

```
  Source ──→ Relay Node A ──→ Relay Node B ──→ Destination
               (TTL=5)          (TTL=4)
               store in         store in
               relay_queue      relay_queue
               forward when     forward when
               next peer seen   dest seen
```

---

## Key Dependencies

| Package | Purpose |
|---|---|
| `nearby_connections` | Bluetooth/Wi-Fi Direct P2P mesh transport |
| `sqflite` | Local SQLite database |
| `protobuf` | Protobuf serialization for mesh payloads |
| `cryptography` | X25519 key exchange, AES-GCM encryption |
| `flutter_secure_storage` | Secure storage for private keys and OTP secrets |
| `otp` | TOTP OTP generation (M1.1) |
| `crypto` | SHA-256 hash chaining for ledger |
| `uuid` | UUID generation for entries and messages |
| `fixnum` | 64-bit integer support for Protobuf timestamps |
| `path_provider` | File system paths for SQLite |

---

## Team

**LU_Furious** — Leading University, Sylhet

| Name | GitHub | LinkedIn |
|------|--------|----------|
| Abidur Rahman | [abidurrahman11](https://github.com/abidurrahman11) | [abidurrahman11](https://www.linkedin.com/in/abidurrahman11) |
| A S M Rayhan Chowdhury | [asmrayhan1](https://github.com/asmrayhan1) | [asmrayhan](https://www.linkedin.com/in/asmrayhan) |
| Binoy Bhushan Barman Dipu | [binoydipu](https://github.com/binoydipu) | [binoydipu](https://www.linkedin.com/in/binoydipu) |

---

## License

This project was developed during a hackathon. All rights reserved by Team LU_Furious.