# Digital Delta — Judge Walkthrough

> **Team:** LU_Furious  
> **Hackathon Demo Guide** — Step-by-step instructions for evaluating all features  
> **Devices required:** 2+ physical Android phones (Bluetooth + Wi-Fi enabled)

---

## ⚡ Quick-Start Checklist

Before beginning the demo, verify the following on **each device**:

- [ ] Bluetooth is **ON**
- [ ] Wi-Fi is **ON** (does not need internet — just the radio)
- [ ] Location permission is **granted** (required by Android for Bluetooth scanning)
- [ ] Both devices have the Digital Delta APK installed
- [ ] Devices are within **~10 meters** of each other

---

## 🗺 Demo Overview

| Step | Feature Being Demonstrated | Time |
|------|---------------------------|------|
| 1 | Registration + OTP Authentication | 2 min |
| 2 | Offline Mesh Discovery | 2 min |
| 3 | End-to-End Encrypted Mesh Chat | 2 min |
| 4 | CRDT Sync & Conflict Resolution | 3 min |
| 6 | Offline Map with Path Finding | 2 min |
| 7 | Audit Ledger & System Logs | 1 min |
| 8 | Store-and-Forward Relay | 2 min |
| **Total** | | **~17 min** |

---

## Step 1 — Registration & OTP Authentication

**Demonstrates:** `M1.1` (TOTP OTP), `M1.2` (Ed25519 identity), offline-first auth

### On Device A:

1. Open **Digital Delta**.
2. Tap **"Register"** on the Login screen.
3. Fill in:
   - **Username:** `Rescue_Lead`
   - **Mobile:** `01711000001`
   - **Password:** `pass123`
   - **Role:** `Coordinator`
4. Tap **Register**.
5. The app generates an **Ed25519 key pair** locally and an **OTP secret** — all without any network call.
6. You are redirected to the **OTP screen**. The app generates a 6-digit TOTP code valid for 60 seconds.
7. Enter the displayed OTP to verify and proceed to the main app.

> 💡 **Judge Note:** The entire registration and OTP flow runs locally using `flutter_secure_storage` and the `otp` package. No server is contacted at any point.

### On Device B:

Repeat with:
- **Username:** `Field_Volunteer`
- **Mobile:** `01711000002`
- **Password:** `pass456`
- **Role:** `Volunteer`

---

## Step 2 — Offline Mesh Discovery

**Demonstrates:** Bluetooth/Wi-Fi Direct P2P mesh via Google Nearby Connections, `Strategy.P2P_CLUSTER`

### On Both Devices:

1. After login, navigate to **"Mesh"** from the bottom navigation bar.
2. Tap **"Start Mesh"** (or observe auto-start).
3. Both devices begin **advertising** and **discovering** simultaneously.
4. Within a few seconds, each device should detect the other and appear in the **Connected Peers** list.

> 💡 **Judge Note:** The service ID `com.digitaldelta.mesh` scopes discovery to this app. The `P2P_CLUSTER` strategy allows many-to-many connections — not just 1-to-1.

### What to Observe:

- The **peer list** populates with the other device's name and role.
- The **node role** (CLIENT / RELAY) is displayed and can switch dynamically.
- Each connection triggers a `NodeInfo` broadcast, exchanging public keys for E2E encryption setup.

---

## Step 3 — End-to-End Encrypted Mesh Chat

**Demonstrates:** X25519 key exchange, AES-GCM encryption, relay-opaque messaging

### On Device A:

1. From the Mesh screen, tap on **Device B** in the peer list (or tap "Mesh Chat").
2. Type a message: `"Flood level rising at Sylhet North. 3 families need evacuation."`
3. Send.

### On Device B:

4. The message arrives in the chat window.

> 💡 **Judge Note:** The message payload is encrypted with a shared AES-GCM key derived from an X25519 Diffie-Hellman exchange. Even if a third device relays the message, it cannot read the contents — only the destination node can decrypt it.

### Verify Encryption:

On Device A, navigate to **System Logs** (in the Mesh section). You will see log entries showing:
- Key exchange completed
- Payload encrypted before transmission
- Message forwarded as opaque bytes

---

## Step 4 — CRDT Sync & Conflict Resolution

**Demonstrates:** LWW-Register CRDT, Vector Clocks, Conflict Detection, Resolution UI

### Setup — Simulate Offline Divergence:

1. **Disable Bluetooth on both devices** (simulate going offline).

### On Device A (offline):

2. Go to **Dashboard** → any editable shared field (e.g., supply count or post content).
3. Update a field value — for example, set `water_bottles = 50`.

### On Device B (offline, simultaneously):

4. Update the **same field** to a different value — e.g., `water_bottles = 30`.

### Re-enable Bluetooth on Both Devices:

5. Both devices reconnect via mesh.
6. A **CRDT sync** initiates automatically — each device sends a `CrdtSyncRequest` with its current Vector Clock.
7. The receiving node detects that both edits have **concurrent vector clocks** (neither happened-before the other).
8. Both entries are flagged `is_conflict = true`.

### Resolve the Conflict:

9. On either device, navigate to **Mesh → Conflict Resolution**.
10. The screen lists all flagged conflicts with both values and their timestamps.
11. Tap **"Accept"** on the value you want to keep.
12. The conflict is marked `resolved = true` and propagated to the other device on next sync.

> 💡 **Judge Note:** This implements the core correctness guarantee for shared mutable state in a disconnected mesh. Without CRDT + Vector Clocks, concurrent edits would silently overwrite each other.

---

## Step 5 — Offline Map with Path Finding

**Demonstrates:** Fully offline custom-painted map of the Sylhet region with route computation

### On Either Device:

1. Navigate to **"Map"** from the bottom navigation.
2. The app renders the **Sylhet region map** using a `CustomPainter` — no internet, no tile server.
3. Tap any two nodes on the map (landmarks, roads, or areas).
4. The app computes and highlights the **shortest path** between them using the built-in path-finding algorithm.
5. Tap the **report dialog** (top button) to log an incident at a map location.

> 💡 **Judge Note:** All map data is embedded in `lib/mapupdated/data/sylhet_map_data.dart`. The path-finding uses graph traversal over pre-defined edges. This works with zero connectivity.

---

## Step 6 — Audit Ledger & System Logs

**Demonstrates:** Hash-chained tamper-evident ledger, structured mesh event logs

### View System Logs (Mesh Activity):

1. Navigate to **Mesh → System Logs**.
2. Observe the real-time event stream:
   - Peer discovered / connected / disconnected
   - Message sent / received / relayed
   - CRDT sync started / completed
   - Conflict detected
   - Role switched (CLIENT ↔ RELAY)

### Verify Ledger Integrity:

3. Navigate to **Dashboard** or **Mesh → Mesh Dashboard**.
4. Observe the ledger entry list — each entry shows:
   - `current_hash` (SHA-256 of this entry)
   - `prev_hash` (SHA-256 of the preceding entry)
5. Any tampering with a historical entry would break the hash chain and be immediately detectable.

> 💡 **Judge Note:** The `LedgerManager` class maintains the chain. All critical operations (message sent, post created, sync completed) append a new `LedgerEntry` with a cryptographic link to the previous one.

---

## Step 7 — Store-and-Forward Relay (3-Device Demo)

**Demonstrates:** Multi-hop message delivery, TTL-based relay queue

> This step requires a **3rd device** OR can be simulated by temporarily disconnecting Device B and letting Device A → Device C → Device B.

### Setup:

- **Device A** is the message sender.
- **Device C** is a relay node in range of A but NOT in range of B.
- **Device B** is the destination, not directly reachable from A.

### Demo Flow:

1. On **Device A**, send a message addressed to **Device B**.
2. Device A cannot reach Device B directly → the message is queued in `relay_queue` with `TTL=5`.
3. Device A discovers Device C and forwards the message (TTL decremented to 4).
4. Device C stores the message in its own `relay_queue`.
5. When Device C comes within range of Device B, it forwards the message (TTL=3).
6. Device B receives and decrypts the message.

### Observe:

- On Device A and C: check **System Logs** to see relay forwarding events.
- On Device B: the message arrives with `hop_list` showing `[DeviceA_ID, DeviceC_ID]`.

> 💡 **Judge Note:** The TTL prevents infinite loops. The `_seenMessageIds` set in `MeshSyncManager` ensures deduplication — a message is never processed twice even if multiple relay paths deliver it.

---

## 🔑 Key Technical Highlights for Judges

| Criterion | Implementation |
|-----------|---------------|
| **Works offline** | 100% local-first — SQLite, flutter_secure_storage, custom map data |
| **Peer-to-peer** | Google Nearby Connections, `P2P_CLUSTER`, no central server |
| **Data consistency** | CRDT LWW-Register + Hybrid Logical Clocks + Vector Clocks |
| **Security** | Ed25519 identity, X25519 key exchange, AES-GCM E2E encryption, TOTP OTP |
| **Data integrity** | SHA-256 hash-chained audit ledger |
| **Scalability** | Store-and-forward relay with TTL; multi-hop routing |
| **Real use case** | Flood disaster response in Bangladesh delta regions |

---

## 🐛 Troubleshooting

| Problem | Solution |
|---------|----------|
| Devices not discovering each other | Ensure Location permission is granted; toggle Bluetooth off and on |
| OTP verification fails | The TOTP window is 60 seconds — re-enter the freshly generated code |
| Sync not triggering | Navigate away and back to the Mesh screen to re-initiate discovery |
| Map not rendering | Restart the app; map data is loaded synchronously on first render |
| App crashes on launch | Ensure Android API Level ≥ 21; check Bluetooth and Location are enabled |

---

*Digital Delta — Built under pressure, for people under water.* 🌊