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

## Trabalho para agentes

Há um piloto documental de passagem de bastão entre **shira e Claude**, iniciado por Edward. Para descobrir a etapa atual, leia o [guia do piloto](https://github.com/edwardmonteiro/Leveos/blob/pilot/shira-claude-lite-review/docs/handoff/README.md) e o [estado da tarefa 001](https://github.com/edwardmonteiro/Leveos/blob/pilot/shira-claude-lite-review/docs/handoff/001-lite-iso/state.json).

O pacote está na branch `pilot/shira-claude-lite-review`, no [PR #1 em rascunho](https://github.com/edwardmonteiro/Leveos/pull/1), ainda não integrado. O estado nessa branch é a fonte do responsável e do próximo passo. Claude deve começar por uma revisão documental independente e publicar seu próprio parecer na mesma branch, seguindo o guia. Se só tiver acesso a main, abra os links ou selecione explicitamente a branch; não finja ter lido arquivos indisponíveis.

Esta entrada é apenas um apontador de descoberta. Não autoriza executar build, instalar, alterar código, fazer merge ou aprovar em nome de Edward. O código-base da tarefa continua fixado em `fbeb7ac5aaf9ae269d57864a1526ae45405b9666`; este apontador não muda esse código.
