# Publicación y protección del código

## Objetivo

ArmasVIP se distribuye gratuitamente sin publicar el source privado del runtime en este repositorio.

## Flujo de distribución

El flujo previsto es:

```text
Cfx Forum
    ↓
Tebex FREE
    ↓
Cfx Asset Escrow
    ↓
ArmasVIP protegido
```

No se incluyen URLs hasta que el propietario del proyecto proporcione las oficiales.

## Cfx Asset Escrow

El paquete 2.2.0 revisado está preparado para Cfx Asset Escrow. Su `fxmanifest.lua` mantiene `config/config.lua` editable mediante `escrow_ignore`, mientras los Lua protegibles se distribuyen mediante el sistema de Asset Escrow.

Flujo general:

1. Conserva el paquete escrow-ready de forma privada.
2. Gestiona el asset mediante las herramientas oficiales de Cfx.re.
3. Procesa el recurso mediante Asset Escrow.
4. Asocia el asset al paquete de Tebex correspondiente.
5. Configura el producto como gratuito cuando corresponda.
6. Publica en Cfx Forum únicamente cuando la ficha, enlaces y paquete estén verificados.

## NUI

El paquete revisado distribuye la interfaz como `web/dist` compilado. El frontend no debe contener secretos, credenciales, webhooks privados ni decisiones de seguridad; la autoridad permanece en servidor.

## Repositorio GitHub

Este repositorio se mantiene como documentación del proyecto. No debe utilizarse para publicar accidentalmente el runtime privado/protegido.

> **This repository contains documentation only.**  
> **The protected runtime resource is distributed through Cfx Asset Escrow.**

## Distribución y uso

ArmasVIP es actualmente gratuito, pero no se publica como proyecto open source. La intención de distribución no permite reventa, redistribución no autorizada ni re-upload del paquete protegido.

Asset Escrow y las condiciones de las plataformas utilizadas para distribuir el recurso también son aplicables al paquete entregado por esas plataformas.
