# NGen Backend — API para App y Webapp

Proyecto Firebase: **ngen-495404**  
Callable base (prod): `https://us-central1-ngen-495404.cloudfunctions.net/<functionName>`

## Roles (Firebase Auth custom claims)

| Rol | Claim | Uso |
|-----|-------|-----|
| Admin | `role: "admin"` | Usuarios, recargas créditos, payouts |
| Operador | `role: "operator"` | Subir tours, audio, traducciones, QR |
| Turista | sin role o app | Consumir tours, mapa, pagos |

Tras `updateUser` con `role`, el cliente debe **`getIdToken(true)`**.

---

## Modelo de datos Firestore

```
tours/{countryId}/list/{tourId}
  operatorId, createdBy, active, tier
  sourceLanguage, targetLanguages[]
  languages[]  { code, name }
  title{}, description{}     // map por idioma
  isPresentation: boolean     // tour preview en mapa
  price, currency
  unlockDurationHours        // default 24
  qrSlug

steps/{tourId}/list/{stepId}
  position, location, image
  title{}, description{}, audio{}   // map por idioma
  sourceStoragePath
  sourceLanguage
  translationStatus.{lang}   // pending | ready

tourQr/{qrSlug}
  countryId, tourId, operatorId

tourUnlocks/{uid}_{tourId}
  uid, tourId, countryId, operatorId
  accessType: qr | purchase | presentation
  expiresAt, paymentId?, amount?

operators/{operatorId}
  creditsBalance              // puede ser negativo (postpago)

creditMovements/{id}
  operatorId, action, creditsDebited, tourId, stepId, targetLang
  billingStatus: pending

operatorWallets/{operatorId}
  balancePending, totalEarned, totalPaidOut

walletMovements/{id}
  operatorId, touristUid, tourId, grossAmount, netAmount, status

translationCache/{hash}       // solo backend
```

---

## Flujo operador (implementado)

### 1. Configurar tour

**`updateTourSettings`** (operator/admin)

```json
{
  "countryId": "cl",
  "tourId": "demo-santiago-centro",
  "targetLanguages": ["en", "pt"],
  "sourceLanguage": "es",
  "isPresentation": true,
  "price": 5000,
  "currency": "CLP",
  "unlockDurationHours": 24
}
```

### 2. Subir audio de un paso

1. App/web sube MP3 a **Firebase Storage** (ej. `tours-audio/{tourId}/{stepId}/source.mp3`).
2. Llama **`registerStepAudio`**:

```json
{
  "countryId": "cl",
  "tourId": "...",
  "stepId": "...",
  "storagePath": "tours-audio/.../source.mp3",
  "sourceLang": "es",
  "targetLangs": ["en"],
  "autoTranslate": true
}
```

Traduce automáticamente:
- **Texto** → OpenAI (`gpt-4o-mini`) + caché Firestore
- **Audio** → ElevenLabs TTS si `LIVE_TRANSLATION_WITH_VOICE=true`, si no dubbing ElevenLabs
- **Créditos** → descuenta al operador (postpago; saldo puede quedar negativo)

### 3. QR del tour

**`assignTourQr`** → `{ qrSlug, qrUrl }`  
**`resolveTourQr`** → metadatos tour (app al escanear)

### 4. Créditos operador

- **`getMyCredits`** — saldo y deuda (`creditsOwed`)
- **`listMyCreditMovements`** — historial
- **`addOperatorCredits`** — solo admin (recargas)

Costes env (ajustables):

| Variable | Default | Qué cobra |
|----------|---------|-----------|
| `CREDITS_PER_TEXT_LANG` | 0.25 | Traducción texto / idioma |
| `CREDITS_PER_AUDIO_LANG` | 1 | Audio TTS o dub / idioma |

---

## Flujo turista (implementado)

### Mapa — tours disponibles

**`listMapTours`** `{ countryId: "cl" }`  
Lista tours `active: true` con precio, presentación, idiomas.

### Presentación (preview)

Tour con `isPresentation: true` → **`startPresentationAccess`**  
Acceso temporal (`unlockDurationHours`, default 24h).

### QR

1. Escanear → **`resolveTourQr`** `{ qrSlug }`
2. **`startTourFromQr`** — crea `tourUnlocks` con expiración

### Compra en app

Tras pago (Webpay/PayPal en cliente) → **`unlockTourPurchase`**:

```json
{
  "countryId": "cl",
  "tourId": "...",
  "paymentId": "token_o_id_pago",
  "amount": 5000,
  "currency": "CLP"
}
```

- Crea unlock con expiración
- Acredita **wallet operador** (`balancePending`, menos `PLATFORM_FEE_PERCENT` default 15%)

### Consumir paso

Antes de mostrar paso → **`checkTourAccess`** `{ tourId, stepId?, lang? }`  
Si `needsTranslation: true` → **`ensureStepTranslation`** (cobra al **operador**, no al turista).

### Bloqueo a 24h

`checkTourAccess` devuelve `allowed: false, reason: "expired"` cuando `expiresAt` pasó.

---

## Wallet operador (implementado)

| Function | Quién | Descripción |
|----------|-------|-------------|
| `getOperatorWallet` | operator/admin | Saldo pendiente de transferencia |
| `listWalletMovements` | operator | Ventas por tour |
| `recordOperatorPayout` | admin | Marca pago manual al operador |

---

## Functions legacy (siguen activas)

| Function | Notas |
|----------|-------|
| `dubAudio`, `completeDubbing` | Doblaje ElevenLabs directo (admin/operator) |
| `activatePayment`, Webpay | Suscripción / pagos antiguos |
| `addUser`, `updateUser`, … | Auth admin |
| `loadPlaces`, `fixTours` | Google POI / mantenimiento |

---

## Variables `.env` (deploy)

Copiar a `functions/.env.ngen-495404`:

- `OPENAI_API_KEY` — traducción texto
- `ELEVEN_LABS_API_KEY`, `ELEVENLABS_VOICE_ID`, `LIVE_TRANSLATION_WITH_VOICE`
- `CREDITS_PER_TEXT_LANG`, `CREDITS_PER_AUDIO_LANG`
- `TOUR_QR_BASE_URL`, `TOUR_UNLOCK_HOURS`, `PLATFORM_FEE_PERCENT`

`REDIS_*` en tu `.env` local: **no usado aún** en Functions (caché = Firestore).

---

## Deploy

```powershell
cd backend\functions
firebase login:use waldo@chilsmart.com   # cuenta con acceso al proyecto
firebase login --reauth
npm run deploy          # solo functions
npm run deploy:all    # functions + rules + indexes
```

Desde `backend/`: `npm run deploy:all`

---

## Checklist integración App / Webapp

### Operador (webapp)

- [ ] Pantalla subir audio → Storage → `registerStepAudio`
- [ ] Selector idiomas destino → `updateTourSettings` / payload `targetLangs`
- [ ] Generar QR → `assignTourQr`, mostrar `qrUrl`
- [ ] Dashboard créditos → `getMyCredits`, `listMyCreditMovements`
- [ ] Marcar tour como presentación → `isPresentation: true`
- [ ] Wallet ventas → `getOperatorWallet`, `listWalletMovements`

### Turista (app)

- [ ] Mapa → `listMapTours`
- [ ] Preview presentación → `startPresentationAccess`
- [ ] Escanear QR → `resolveTourQr` → `startTourFromQr`
- [ ] Pago tour → pasarela existente → `unlockTourPurchase`
- [ ] Antes de cada paso → `checkTourAccess`
- [ ] Si falta idioma → `ensureStepTranslation` + mostrar loading
- [ ] UI bloqueado si `reason: "expired"`

### Admin

- [ ] `addOperatorCredits`, `recordOperatorPayout`
- [ ] Crear operadores: `addUser` / `updateUser` con `role: "operator"`

---

## Ahorro de créditos (config actual)

1. Texto siempre por **OpenAI mini** + caché.
2. Audio por **TTS** desde texto traducido (más barato que dubbing completo).
3. Dubbing ElevenLabs solo si `LIVE_TRANSLATION_WITH_VOICE=false` o sin texto.
4. Ajustar `CREDITS_PER_TEXT_LANG=0.25` y `CREDITS_PER_AUDIO_LANG=1`.

---

## Pendiente / evolución (no en backend aún)

- Redis/BullMQ para cola analítica (`ANALYTICS_QUEUE_NAME` en .env)
- WebSocket live translation (`DEBUG_WS`, `LIVE_TRANSLATION_CHUNK_MS`)
- Pasarela de pago tour unificada con validación server-side del monto
- Reglas Firestore más estrictas (hoy catch-all `auth != null`)

---

## Desarrollo local (app Flutter)

### 1. Backend

```powershell
cd C:\Users\PC\Desktop\GitHub\ngen\ngenflutter\backend
npm install
npm run dev
```

Emuladores: UI `:4000`, Functions `:5001`, Firestore `:8080`, Auth `:9099`, Storage `:9199`.

Operador de prueba (otra terminal): `npm run seed:operator` → `operator@ngen.test` / `operator123`.

### 2. App — elegir entorno

**Opción A — `--dart-define` (recomendado, sin editar archivos)**

| Entorno | Comando / configuración |
|---------|-------------------------|
| Local + emulador Android | `--dart-define=NGEN_ENV=local` |
| Local + teléfono físico | `--dart-define=NGEN_ENV=local --dart-define=NGEN_HOST=192.168.x.x` (IP LAN del PC) |
| Producción | `--dart-define=NGEN_ENV=production` o Run normal |

En **Android Studio**: Run → Edit Configurations → tu app Flutter → **Additional run args**:

```
--dart-define=NGEN_ENV=local
```

Teléfono USB (SM A055M): usa la IP de tu PC, no `localhost`:

```
--dart-define=NGEN_ENV=local --dart-define=NGEN_HOST=192.168.100.9
```

En **VS Code / Cursor**: elegir configuración en `.vscode/launch.json` (`NGen · local …`).

**Opción B — script + `settings.json`**

```powershell
cd app
.\scripts\use-env.ps1 local    # copia assets/cfg/settings.local.json
.\scripts\use-env.ps1 prod     # copia settings.production.json
```

Plantillas: `assets/cfg/settings.local.json`, `assets/cfg/settings.production.json`.

### 3. Reiniciar la app

Stop + Run (hot reload **no** recarga emuladores ni `settings.json`).

### 4. Comprobar

- Banner naranja **LOCAL** en la esquina = emuladores activos.
- Log: `[NGen] env=local emulatorHost=10.0.2.2` (AVD) o tu IP LAN (teléfono).
- Login dev automático si `devEmail` / `devPassword` están en settings local.
- Callable: `lib/core/api/ngen_functions.dart` (región `us-central1`).

### Host según dispositivo

| Dispositivo | `host` / `NGEN_HOST` |
|-------------|----------------------|
| Emulador Android | `localhost` (→ `10.0.2.2` automático) |
| iOS Simulator | `localhost` / `127.0.0.1` |
| Teléfono físico (misma Wi‑Fi) | IP LAN del PC (`ipconfig`) |
