# LeveOS 0.3 — Lite / Web / Claw

Distribuição Debian 13 amd64 **CLI-first** para Macs Intel antigos sem T2. Não é um kernel desenvolvido do zero.

## Perfis

- **lite**: terminal, rede, W3M, NetSurf, JWM/X11 sob demanda.
- **web**: lite + Firefox ESR para sites com JavaScript moderno.
- **claw**: web + OpenClaw 2026.10.5 com Node privado. O agente fica desligado no boot.

Sem dependência de conta Google. O OpenClaw não inclui pesos de modelos. Para inferência, configure uma API remota ou outro backend compatível.

## Comandos

    leveos help
    leveos status
    leveos wifi
    leveos text https://example.org
    leveos web https://example.org
    leveos full https://chatgpt.com
    leveos gui
    leveos claw setup
    leveos claw audit
    leveos claw start

OpenClaw **nunca deve ser executado com sudo**. Mantenha o Gateway restrito ao localhost, autenticado e com permissões mínimas.

## Build em Debian 13 amd64

    sudo apt update
    sudo apt install -y live-build debootstrap squashfs-tools xorriso
    ./validate.sh
    sudo ./build.sh --profile lite
    sudo ./build.sh --profile web --installer
    sudo ./build.sh --profile claw --installer

O script produz ISO + SHA256 em output/. Com --installer inclui instalador Debian Live. Use Actions > LeveOS ISO > Run workflow para compilar pelo GitHub, inclusive a partir do celular.

## Hardware e estado

Somente **Mac Intel amd64 sem T2** como alvo inicial. T2, Apple Silicon e PowerPC exigem outro projeto. Suporte Wi-Fi Broadcom, vídeo, trackpad e boot dependem do modelo. Faça backup e teste com pendrive Live antes de gravar SSD.

**Importante:** código e validação estática prontos; ISO não foi compilada ou testada no Mac real. O hook OpenClaw requer validação em build completo.

## Referências

- https://docs.openclaw.ai/install/installer
- https://docs.openclaw.ai/gateway/security
- https://live-team.pages.debian.net/live-manual/html/live-manual.en.html
- https://t2linux.org/
