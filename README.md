# Drunk Mode - App Móvil

## Descripción

**Drunk Mode** es una aplicación móvil desarrollada en Flutter que forma parte de un sistema de seguridad ciudadana. La app permite a los usuarios gestionar contactos de confianza y activar un "Modo Borracho" que envía alertas automáticas a sus contactos en caso de emergencia, brindando una capa adicional de seguridad cuando el usuario se encuentra en situaciones de vulnerabilidad.

## 🚀 Tecnologías Utilizadas

- **[Flutter](https://flutter.dev/):** Framework para desarrollo multiplataforma (Android, iOS, Web, Desktop).
- **[Dart](https://dart.dev/):** Lenguaje de programación utilizado por Flutter.
- **Provider:** Manejo de estado de la aplicación.
- **Dio:** Cliente HTTP para consumo de APIs.
- **Flutter Secure Storage:** Almacenamiento seguro de tokens y credenciales.
- **Shared Preferences:** Almacenamiento persistente de preferencias locales.
- **REST API:** Consumo de servicios del backend SafeNight.

---

## 📁 Estructura del Proyecto

```
├── .dart_tool/                 # Archivos de herramientas de Dart (NO MODIFICAR)
├── .github/                    # Configuraciones de GitHub (workflows, hooks)
├── .idea/                      # Archivos de configuración de IDEA
├── android/                    # Código nativo para Android
│   ├── app/                    # Módulo principal de Android
│   ├── gradle/                 # Configuración de Gradle
│   ├── build.gradle.kts        # Archivo de build de Gradle
│   ├── gradle.properties       # Propiedades de Gradle
│   └── settings.gradle.kts     # Configuración de módulos de Gradle
├── assets/                     # Recursos estáticos
│   ├── animations/             # Animaciones (Lottie, Rive, etc.)
│   ├── fonts/                  # Fuentes personalizadas
│   ├── icons/                  # Iconos de la aplicación
│   └── images/                 # Imágenes y recursos gráficos
├── build/                      # Archivos de build generados (NO MODIFICAR)
├── ios/                        # Código nativo para iOS
│   ├── Flutter/                # Configuración de Flutter para iOS
│   ├── Runner/                 # Proyecto principal de iOS
│   └── Runner.xcworkspace/     # Workspace de Xcode
├── lib/                        # Código fuente principal de la aplicación
│   ├── core/                   # Módulo de núcleo y configuraciones globales
│   │   ├── constants/          # Constantes de la aplicación
│   │   ├── network/            # Configuración de red (Dio, interceptores)
│   │   ├── routes/             # Definición de rutas de navegación
│   │   ├── storage/            # Servicios de almacenamiento (Secure Storage)
│   │   ├── theme/              # Configuración de tema (colores, tipografía, espaciado)
│   │   └── utils/              # Utilidades (validadores, snackbar, etc.)
│   ├── features/               # Módulos de funcionalidades por feature
│   │   ├── auth/               # Autenticación (login, registro)
│   │   │   ├── presentation/   # Capa de presentación (screens)
│   │   │   └── providers/      # Providers de estado
│   │   ├── contacts/           # Gestión de contactos de confianza
│   │   │   ├── presentation/   # Screens de contactos
│   │   │   └── providers/      # Providers de contactos
│   │   ├── drunk-mode/         # Módulo principal "Modo Borracho"
│   │   │   ├── presentation/   # Screens del modo borracho
│   │   │   └── providers/      # Providers del modo borracho
│   │   ├── history/            # Historial de activaciones
│   │   │   ├── presentation/   # Screens de historial
│   │   │   └── providers/      # Providers de historial
│   │   ├── home/               # Pantalla principal
│   │   │   └── presentation/   # Screens de inicio
│   │   ├── onboarding/         # Flujo de onboarding
│   │   │   └── presentation/   # Screens de onboarding
│   │   ├── profile/            # Perfil de usuario
│   │   │   ├── presentation/   # Screens de perfil
│   │   │   └── providers/      # Providers de perfil
│   │   └── screens/            # Pantallas compartidas
│   │       └── pin_screen.dart # Pantalla de PIN de seguridad
│   ├── shared/                 # Componentes compartidos
│   │   ├── components/         # Componentes reutilizables
│   │   ├── design_system/      # Sistema de diseño (Glass Card, etc.)
│   │   └── widgets/            # Widgets personalizados
│   ├── app.dart                # Configuración principal de la app
│   └── main.dart               # Punto de entrada de la aplicación
├── linux/                      # Código nativo para Linux
├── macos/                      # Código nativo para macOS
├── test/                       # Pruebas unitarias y de widgets
├── web/                        # Código para la versión web
│   ├── icons/                  # Iconos para la web
│   ├── favicon.png             # Favicon de la web
│   ├── index.html              # Página principal de la web
│   └── manifest.json           # Manifest de la PWA
├── windows/                    # Código nativo para Windows
├── .env                        # Variables de entorno
├── .flutter-plugins-dependencies # Dependencias de plugins de Flutter
├── .gitignore                  # Archivos ignorados por Git
├── .metadata                   # Metadatos de Flutter
├── analysis_options.yaml       # Configuración de análisis de código
├── pubspec.lock                # Bloqueo de versiones de dependencias
├── pubspec.yaml                # Dependencias y configuración del proyecto
└── README.md                   # Este archivo
```

---

## ✨ Funcionalidades Principales

### 1. **Autenticación y Seguridad**
- Registro de nuevos usuarios.
- Inicio de sesión seguro con JWT.
- Almacenamiento seguro de tokens mediante `flutter_secure_storage`.
- Sistema de PIN de seguridad para accesos rápidos.

### 2. **Gestión de Contactos de Confianza**
- Agregar, editar y eliminar contactos de emergencia.
- Almacenar información de contacto (nombre, teléfono, relación).
- Visualizar lista de contactos guardados.

### 3. **Modo Borracho**
- **Activación Rápida:** Botón principal para activar el modo de emergencia.
- **Desactivación Segura:** Requiere confirmación para desactivar el modo.
- **Alertas Automáticas:** Envía notificaciones a los contactos de confianza con la ubicación del usuario.
- **Estado en Tiempo Real:** Visualización del estado actual del modo.

### 4. **Historial de Activaciones**
- Registro de todas las activaciones del modo borracho.
- Fecha, hora y estado de cada evento.
- Historial de alertas enviadas a contactos.

### 5. **Perfil de Usuario**
- Visualización y edición de información personal.
- Cambio de PIN de seguridad.
- Configuración de preferencias de la aplicación.

---

## 🛠️ Configuración y Ejecución

### **Prerrequisitos**

- **Flutter SDK:** Versión 3.0 o superior.
- **Dart SDK:** Versión 3.0 o superior.
- **Editor de código:** Android Studio, VS Code o IntelliJ.
- **Dispositivo o Emulador:** Para pruebas en Android/iOS.
- **Backend:** El backend de SafeNight debe estar corriendo (ver README del backend).

### **1. Clonar el repositorio**

```bash
git clone https://tu-repositorio.com/drunk-mode-flutter.git
cd drunk-mode-flutter
```

### **2. Instalar las dependencias**

```bash
flutter pub get
```

### **3. Configurar variables de entorno**

Crea un archivo `.env` en la raíz del proyecto con la siguiente configuración:

```env
# URL del backend API
API_URL=http://localhost:3000

# Otras variables de entorno necesarias
```

### **4. Configurar el emulador o dispositivo**

```bash
# Verificar dispositivos disponibles
flutter devices

# Seleccionar un dispositivo
flutter emulators --launch <emulator-id>
```

### **5. Ejecutar la aplicación**

```bash
# Modo desarrollo (con Hot Reload)
flutter run

# Ejecutar en modo release
flutter run --release
```

---

## 📱 Plataformas Soportadas

| Plataforma | Estado | Notas |
|------------|--------|-------|
| **Android** | ✅ Soporte completo | SDK 21+ |
| **iOS** | ✅ Soporte completo | iOS 12+ |
| **Web** | ✅ Soporte completo | Chrome, Firefox, Edge |
| **Windows** | ✅ Soporte completo | Windows 10+ |
| **macOS** | ✅ Soporte completo | macOS 10.15+ |
| **Linux** | ✅ Soporte completo | Ubuntu 20.04+ |

---

## 📚 Arquitectura del Proyecto

La aplicación sigue una arquitectura **Clean Architecture** con patrón **Provider** para el manejo de estado:

### **Capas de la Arquitectura**

1. **Presentación (Presentation Layer)**
   - `screens/`: Pantallas de la aplicación.
   - `widgets/`: Widgets reutilizables.
   - `components/`: Componentes específicos de UI.

2. **Estado (State Management)**
   - `providers/`: Providers de cada feature usando `ChangeNotifier`.
   - Manejo de estado reactivo y notificaciones a la UI.

3. **Núcleo (Core)**
   - `network/`: Cliente Dio con interceptores para autenticación.
   - `storage/`: Almacenamiento seguro y persistente.
   - `routes/`: Sistema de navegación con `go_router` o `auto_route`.

4. **Utils**
   - Validaciones, servicios de notificación, utilidades generales.

### **Dependencias Principales**

| Dependencia | Versión | Uso |
|-------------|---------|-----|
| `dio` | ^5.0.0 | Cliente HTTP |
| `provider` | ^6.0.0 | Manejo de estado |
| `flutter_secure_storage` | ^9.0.0 | Almacenamiento seguro |
| `shared_preferences` | ^2.0.0 | Almacenamiento local |
| `flutter_dotenv` | ^5.0.0 | Variables de entorno |
| `go_router` | ^13.0.0 | Navegación |
| `google_maps_flutter` | ^2.0.0 | Mapas y ubicación |
| `geolocator` | ^10.0.0 | Servicios de ubicación |

---

## 🧪 Pruebas

### **Ejecutar pruebas unitarias**

```bash
flutter test
```

### **Ejecutar pruebas de integración**

```bash
flutter test integration_test/
```

### **Cobertura de código**

```bash
flutter test --coverage
```

---

## 📱 Build para Producción

### **Android (APK)**

```bash
flutter build apk --release
```

### **Android (App Bundle)**

```bash
flutter build appbundle --release
```

### **iOS (IPA)**

```bash
flutter build ios --release
cd ios
pod install
flutter build ios --release
```

### **Web**

```bash
flutter build web --release
```

### **Windows**

```bash
flutter build windows --release
```

### **macOS**

```bash
flutter build macos --release
```

### **Linux**

```bash
flutter build linux --release
```

---

## 🔒 Seguridad

- **Almacenamiento Seguro:** Tokens y credenciales almacenados en `flutter_secure_storage`.
- **Autenticación:** Uso de JWT con renovación automática de tokens.
- **PIN de Seguridad:** Acceso rápido con PIN configurado por el usuario.
- **Permisos:** Gestión adecuada de permisos de ubicación y notificaciones.

---

