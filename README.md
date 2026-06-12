# MacOS Display Disabler

Deshabilita la pantalla interna de un Mac al arranque usando APIs privadas de CoreGraphics. Para MacBooks en clamshell o Macs sin pantalla física que macOS insiste en reactivar.

## Uso

```sh
dd_disable         # deshabilitar pantalla built-in
dd_disable watch   # modo persistente (monitorea cambios)
dd_disable list    # listar displays conectados
dd_disable enable  # re-habilitar pantalla built-in
```

## Instalación rápida (binario pre-compilado)

Descargá el binario del [último release](https://github.com/m4rt0s/macos-display-disabler/releases/latest):

```sh
curl -L -o dd_disable https://github.com/m4rt0s/macos-display-disabler/releases/latest/download/dd_disable
chmod +x dd_disable
sudo mv dd_disable /usr/local/bin/
```

Luego instalá el LaunchDaemon:

```sh
sudo curl -L -o /Library/LaunchDaemons/com.local.dd_disable.plist \
  https://github.com/m4rt0s/macos-display-disabler/releases/latest/download/com.local.dd_disable.plist
sudo launchctl load /Library/LaunchDaemons/com.local.dd_disable.plist
```

## Instalar desde código

```sh
make install
```

Compila el binario, lo copia a `/usr/local/bin/dd_disable`, instala el LaunchDaemon en `/Library/LaunchDaemons/com.local.dd_disable.plist` y lo activa.

El LaunchDaemon ejecuta `dd_disable watch` al arranque (antes del login) y se mantiene vivo. Apenas macOS active una pantalla interna, la deshabilita al instante.

## Compilar

Requiere Xcode Command Line Tools (`xcode-select --install`).

```sh
make
```

## Desinstalar

```sh
sudo launchctl unload /Library/LaunchDaemons/com.local.dd_disable.plist 2>/dev/null || true
sudo rm -f /usr/local/bin/dd_disable /Library/LaunchDaemons/com.local.dd_disable.plist
```

O si lo instalaste desde código:

```sh
make uninstall
```

## Cómo funciona

Usa la función privada `CGSConfigureDisplayEnabled` de CoreGraphics para activar/desactivar la pantalla interna (identificada con `CGDisplayIsBuiltin`). En modo watch registra un `CGDisplayRegisterReconfigurationCallback` para detectar cambios de display.

## Créditos

Basado en [DisplayDisabler](https://github.com/oabdrabo/DisplayDisabler) por oabdrabo, simplificado a la función de deshabilitar y empaquetado como LaunchDaemon headless.

---

# MacOS Display Disabler

Disable your Mac's built-in display at boot using private CoreGraphics APIs. Designed for headless / clamshell Macs where macOS keeps reactivating the internal display.

## Usage

```sh
dd_disable         # disable built-in display
dd_disable watch   # persistent monitor mode
dd_disable list    # show connected displays
dd_disable enable  # re-enable built-in display
```

## Quick install (pre-built binary)

Download from the [latest release](https://github.com/m4rt0s/macos-display-disabler/releases/latest):

```sh
curl -L -o dd_disable https://github.com/m4rt0s/macos-display-disabler/releases/latest/download/dd_disable
chmod +x dd_disable
sudo mv dd_disable /usr/local/bin/
```

Then install the LaunchDaemon:

```sh
sudo curl -L -o /Library/LaunchDaemons/com.local.dd_disable.plist \
  https://github.com/m4rt0s/macos-display-disabler/releases/latest/download/com.local.dd_disable.plist
sudo launchctl load /Library/LaunchDaemons/com.local.dd_disable.plist
```

## Install from source

```sh
make install
```

Builds the binary, copies it to `/usr/local/bin/dd_disable`, installs the LaunchDaemon at `/Library/LaunchDaemons/com.local.dd_disable.plist`, and loads it.

The LaunchDaemon runs `dd_disable watch` at boot (before login) and stays alive. Whenever macOS activates a built-in display, it gets disabled immediately.

## Build

Requires Xcode Command Line Tools (`xcode-select --install`).

```sh
make
```

## Uninstall

```sh
sudo launchctl unload /Library/LaunchDaemons/com.local.dd_disable.plist 2>/dev/null || true
sudo rm -f /usr/local/bin/dd_disable /Library/LaunchDaemons/com.local.dd_disable.plist
```

Or if installed from source:

```sh
make uninstall
```

## How it works

Uses the private `CGSConfigureDisplayEnabled` function from CoreGraphics to toggle the enabled state of the built-in display (identified via `CGDisplayIsBuiltin`). In watch mode it registers a `CGDisplayRegisterReconfigurationCallback` to detect new displays.

## Credits

Based on [DisplayDisabler](https://github.com/oabdrabo/DisplayDisabler) by oabdrabo, stripped to the single disable function and packaged as a headless LaunchDaemon.
