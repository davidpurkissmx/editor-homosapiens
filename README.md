# Editor Homosapiens

Editor de video multiplataforma (Windows, Android, Web) construido con Flutter.

## Funcionalidades

- Agregar y ordenar videos
- Rotar a vertical (90° derecha/izquierda)
- Cambiar velocidad (0.5x - 2x)
- Musica de fondo con mezcla de audio, fade in/out
- Recortar duracion (30/60/90 seg)
- Transiciones fade in/out
- Filtros de color (B&N, Sepia, Dramatico, etc.)
- Marca de agua con logo PNG
- Outro con logo centrado al final
- Reproductor de musica integrado

## Requisitos

- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- Para Windows: Visual Studio 2022 con "Desktop development with C++"
- Para Android: Android Studio + Android SDK

## Ejecutar

```bash
flutter pub get
flutter run -d chrome    # Web
flutter run -d windows   # Windows desktop
flutter run -d android   # Android (emulador/dispositivo)
```

## Version original

La version original en Python/Tkinter esta disponible en el repositorio como referencia.
