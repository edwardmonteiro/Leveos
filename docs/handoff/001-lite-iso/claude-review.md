# Parecer independente do Claude

**Status: parecer concluído pelo Claude (revisão documental).** Nada foi executado: nenhum build, workflow, VM ou instalação.

## Identificação

- Revisor / aplicativo: Claude, via Claude Code em sessão remota iniciada por Edward. O identificador exato do modelo não é gravado no repositório por política do ambiente; Edward o tem na conversa.
- Data UTC: 2026-10-29T03:54Z
- SHA completo do pacote de entrada, antes de escrever: `ba37a338c7d41635060e298099ef327267fecbbd` (`pilot/shira-claude-lite-review`, conferido igual a `origin` antes de escrever)
- SHA dos fontes-base: `fbeb7ac5aaf9ae269d57864a1526ae45405b9666`. `git diff fbeb7ac ba37a33` altera apenas `docs/handoff/`; `main` (`a623705`) altera apenas o README. O código-base não mudou.
- Arquivos lidos: `docs/handoff/README.md`, `spec.md`, `state.json`, este template; no SHA-base: `README.md`, `build.sh`, `validate.sh`, `.github/workflows/build.yml`, `packages/lite.list`, `overlay/etc/skel/.xinitrc`, `overlay/etc/skel/.jwmrc` e `overlay/usr/local/bin/{leveos,leveos-browser,leveos-claw,leveos-open-gui}`.
- Arquivos adicionais consultados: nenhum. O PR #1 e a conversa de origem não foram lidos.
- Limitações: este ambiente não acessa `deb.debian.org`, `packages.debian.org` nem `salsa.debian.org` (proxy 403). Por isso, tudo o que digo sobre dependências de pacotes Debian e padrões do live-build vem do meu conhecimento prévio e está marcado como **hipótese**. Essas afirmações devem ser verificadas no build ou numa consulta ao arquivo Debian.

## Conclusão

**O plano requer revisão.** A direção está correta: separar evidências, fazer o build só do perfil lite, não fazer alegações sobre o Mac e tratar BIOS e UEFI separadamente. Mas falta definir quatro coisas. Sem elas, a próxima etapa não é executável sem decisões improvisadas e pode passar com falso positivo:

1. como o sistema é acessado (usuário/login);
2. como a evidência de "sessão CLI utilizável" é capturada;
3. onde o build roda e qual ref exata é usada;
4. como o manifesto de pacotes é obtido, já que o código atual não o produz.

Todas as correções são documentais e cabem no `spec.md`. Esta conclusão técnica não é aprovação humana nem permissão para executar.

## Achados

Legenda: **O** = observado no fonte; **H** = hipótese não testada.

| ID | Sev. | Evidência | Problema | Impacto | Recomendação |
| --- | --- | --- | --- | --- | --- |
| C1 | Alta | `spec.md` (Critérios: Inicialização/Interação); `build.sh:27-32` (**O**) | O plano não diz como se entra no sistema: qual usuário, senha, autologin ou TTY. O build usa `--apt-recommends false` com `minbase`. **H:** no Debian, `live-config` *recomenda* (não exige) `user-setup` e `sudo`. Sem `user-setup`, o usuário live padrão (`user`) e o autologin podem não ser criados. `sudo` está em `lite.list`, `user-setup` não. | O critério "sessão CLI utilizável" fica indefinido e pode falhar por um motivo que o plano não previu. Também pode "passar" com login de root improvisado. | Definir no spec o caminho de acesso esperado (ex.: autologin do usuário live em tty1) e registrar como falha qualquer desvio. Antes do boot, verificar no manifesto se `live-boot`, `live-config`, `live-config-systemd` e `user-setup` estão presentes. Não corrigir a lista antes de um build-base sem decisão (ver D5). |
| C2 | Alta | `spec.md` Critérios; `build.sh:32` (**O**: `--bootappend-live` sem `console=ttyS0`) | O plano não diz *como* a evidência de boot e de interação é capturada. Sem console serial, uma VM headless não produz um log de texto da sessão. Screenshots são exatamente o que o spec quer evitar. | Risco de falso positivo ("chegou a um prompt", visto numa imagem) e de evidência não auditável. | Escolher um de dois caminhos. (a) Teste manual por VNC/janela, com transcrição dos comandos e saídas (via `script` gravado em mídia/9p ou digitados) e screenshots só como complemento. (b) Teste automatizado com console serial, que exige mudar o código (`console=ttyS0`) ou editar a linha do kernel no menu de boot. Isso é decisão D3. |
| C3 | Média | `spec.md` Proposta passo 3; `build.sh:53-57`; `build.yml:48-51` (**O**) | O plano exige "manifesto de pacotes", mas `build.sh` só copia ISO, `.sha256` e o log do `lb build`. O manifesto que o live-build gera (**H:** `live-image-amd64.packages`) fica em `_build/` e não é enviado pelo workflow. O log também não inclui `lb config` nem as versões das ferramentas do host. | Requisito do plano impossível de cumprir sem mudar código, ou cumprido de forma ad hoc. | Sem mudar código: depois do build, extrair o manifesto da própria ISO (`xorriso -osirrox` + `unsquashfs` de `live/filesystem.squashfs` + `dpkg-query --admindir`) e registrar `lb --version`, `debootstrap --version` e a imagem/digest do contêiner. Ou autorizar uma mudança mínima no workflow (D5). |
| C4 | Média | `build.yml:2-3,25,35,45` (**O**) | `workflow_dispatch` constrói a *ponta de uma branch/tag*, não um SHA arbitrário. `actions/checkout@v4`, `upload-artifact@v4` e `debian:trixie` são tags mutáveis, e o build baixa do `deb.debian.org` vivo. | "Fixar o commit de entrada" não é garantido pelo processo, e duas execuções podem diferir sem registro. | Criar uma tag ou branch que aponte exatamente para o SHA aprovado, ou aceitar `main@a623705` (difere de `fbeb7ac` só no README) e registrar isso. Registrar `GITHUB_SHA`, o digest da imagem `debian:trixie` usada e o horário do build (para correlacionar com snapshot.debian.org). |
| C5 | Média | `spec.md` seção "Reproduzível" (**O**) | O spec delega a escolha a mim. | — | **Recomendo limitar o primeiro marco a "repetível com entradas registradas"** e chamá-lo assim. Reprodutibilidade binária (snapshot.debian.org fixado, `SOURCE_DATE_EPOCH`, action/imagem por digest e dois builds independentes comparados com `diffoscope`) vira um marco posterior. Exigir isso agora multiplica o custo antes de saber se a ISO sequer dá boot. A aceitação deve dizer explicitamente: "não reproduzível bit a bit". |
| C6 | Média | `lite.list:17-21`; `leveos:20` (`exec startx`) (**O**) | **H:** com `--apt-recommends false`, o Xorg sem root depende de uma sessão logind ativa (`libpam-systemd`) ou de `xserver-xorg-legacy`. Nenhum dos dois está listado, e `libpam-systemd` pode não entrar só por recomendação. Só há driver `fbdev` (o `modesetting` vem embutido no `xserver-xorg-core`). | `leveos gui` pode falhar na VM por causa do empacotamento, e não do conceito. | Manter o critério e, se falhar, exigir o log do Xorg (`~/.local/share/xorg/Xorg.0.log`) e o `loginctl session-status` como evidência. Registrar o driver de vídeo efetivamente carregado em cada modo de firmware. |
| C7 | Média | `spec.md` Critérios "Inicialização" (**O**) | 2 vCPU / 4 GiB está acima da classe de hardware-alvo (Macs Intel antigos têm 1 a 4 GiB) e diz pouco sobre "Lite". O limite de 5 min não fixa a aceleração: KVM leva segundos, TCG pode levar dezenas de minutos. | Aprovação com margem irreal, ou reprovação por causa do hipervisor. | Configuração de aceitação: QEMU/KVM, 2 vCPU, **2 GiB**, `-cdrom` somente leitura, sem disco. Medida informativa adicional com 1 GiB. Os 5 min valem só com KVM, registrando o tempo até o prompt. Sem KVM, o tempo é informativo. |
| C8 | Média | `spec.md` "BIOS legado e UEFI"; `build.sh:28` (**O**: `iso-hybrid`, sem `--bootloaders`) | **H:** o live-build do trixie usa por padrão syslinux (BIOS) e GRUB EFI x64. Não há garantia de Secure Boot. | Uma modalidade não cobre a outra (o spec já reconhece isso). | Matriz mínima: **(1) q35 + SeaBIOS**, **(2) q35 + OVMF x64 com Secure Boot desligado**, ambas obrigatórias e com resultados separados. Antes do boot, rodar `xorriso -indev ISO -report_el_torito plain` para confirmar as entradas BIOS e EFI. Secure Boot ligado: só informativo. **Fora do piloto, mas relevante para o produto:** Macs Intel de 2006–2008 usam EFI de 32 bits e muitos só dão boot legado por CD. Uma VM OVMF x64 não representa esse caso. |
| C9 | Média | `spec.md` Critérios "Interação" (**O**) | `leveos help` é um `cat` de texto e passa mesmo com o sistema degradado. `leveos status` só agrega `free`, `uptime`, `df` e `ps`. | Falso positivo de "sistema funcional". | Acrescentar: `systemctl is-system-running` (registrar as unidades com falha), `systemctl get-default` = `multi-user.target`, `locale` mostrando `pt_BR.UTF-8`, teclado ABNT2 verificado digitando `ç`, `/`, `?` e conferindo o eco, `nmcli general status` e `leveos text file:///usr/local/share/leveos/home.html`. |
| C10 | Baixa | `spec.md` "Isolamento do perfil" (**O**) | Critério verificável só por observação. | — | Tornar mensurável: no manifesto, `firefox-esr`, `nodejs` e `openclaw` ausentes. Na VM, `pgrep -a Xorg` vazio após o boot, nenhum display manager e nenhuma unidade `openclaw*`. |
| C11 | Baixa | `spec.md` Critério "Build" (**O**); `build.sh:57` | "Checksum recalculado corresponde" só prova integridade no transporte, já que o `.sha256` nasce no mesmo processo. Não prova a origem. | Expectativa indevida sobre a autenticidade. | Registrar o SHA256 no relatório, ligado ao `GITHUB_SHA` ou ao commit e ao log. Assinatura fica fora do escopo e deve ser dita assim. |
| C12 | Baixa | `README.md` (Build); `validate.sh:8` (**O**) | A receita local não instala `python3`, que o `validate.sh` exige. O workflow instala (`build.yml:38`). | Receita local incompleta: o critério "sem passos ocultos" falha. | Registrar no relatório e acrescentar `python3` à receita na etapa de implementação. |
| C13 | Baixa | `.jwmrc:6-7`; `leveos-browser:19-20` (**O**) | No lite, o menu JWM oferece "Firefox ESR" e "OpenClaw", que só imprimem erro ou ajuda. | Ruído no teste de GUI. Não bloqueia. | Registrar como comportamento esperado no lite, não como falha. |
| C14 | Info | `lite.list:31`; `build.sh:30` (**O**) | Muitos Macs antigos usam Broadcom BCM43xx que exigem `b43`/`broadcom-sta` (contrib/non-free, DKMS), não só `firmware-brcm80211`. | Fora do piloto: VM não testa Wi-Fi. | Não alegar suporte Broadcom com base neste marco. |

## Critérios de aceitação: ajustes propostos

| Critério | Avaliação | Ajuste mensurável |
| --- | --- | --- |
| Receita repetível | Bom, mas incompleto | Ref exata (C4), `lb`/`debootstrap`/digest da imagem, horário do build, manifesto extraído (C3), `python3` (C12). Nome: "repetível", não "reproduzível" (C5). |
| Build | Bom | `validate.sh` e `build.sh` com saída 0, ISO > 0 bytes, `xorriso -report_el_torito` com entradas BIOS e EFI (C8), SHA256 no relatório (C11). |
| Inicialização | Insuficiente | Por modo de firmware: chegar ao caminho de login definido (C1) em ≤ 5 min com KVM, com 2 GiB. Medida informativa com 1 GiB (C7). Evidência de texto (C2). |
| Interação | Fraco (falso positivo) | Acrescentar as verificações de C9. |
| Interface sob demanda | Adequado | `leveos gui` como usuário não-root abre JWM + xterm. Sair pelo menu volta ao TTY. Em caso de falha, o log do Xorg e o `loginctl` são obrigatórios (C6). |
| Isolamento do perfil | Vago | Manifesto + processos/unidades (C10). |
| Conclusão honesta | Bom | Manter. Acrescentar: "não reproduzível bit a bit; sem teste de Wi-Fi, Secure Boot, EFI32 ou Mac". |

**Matriz mínima de VM:** QEMU/KVM, máquina q35, `-cdrom` da ISO, sem disco, rede NAT user-mode (ou nenhuma), 2 vCPU, 2 GiB. Duas linhas obrigatórias: SeaBIOS e OVMF x64 com Secure Boot desligado. Medida informativa: 1 GiB em uma das linhas.

## Riscos que exigem decisão

- **Privilégio:** `build.sh` exige root e o workflow usa `docker --privileged`. Em runner hospedado do GitHub o risco ao host de Edward é nulo. Localmente, só numa VM Debian 13 descartável, nunca no sistema de uso diário.
- **Rede:** o build baixa do arquivo Debian (inclui non-free-firmware). A VM de teste não precisa de credenciais nem de passthrough. Não anexar discos do host.
- **Custo:** um build no Actions consome minutos do repositório. A VM pode exigir runner com KVM. **H:** os runners Linux hospedados expõem `/dev/kvm`, mas a disponibilidade deve ser verificada antes de prometer automação.

## Decisões necessárias de Edward

- **D1 — Ambiente de build:** GitHub Actions (workflow existente, runner descartável) ou VM Debian 13 local descartável.
- **D2 — Promessa do marco 1:** "repetível com entradas registradas" (recomendação do revisor) ou exigir reprodutibilidade binária já.
- **D3 — Captura de evidência do boot:** teste manual com transcrição, sem mudar código, ou automação com console serial, o que exige mudar o código e aprovar à parte.
- **D4 — Ref a construir:** tag ou branch fixada em `fbeb7ac`, ou `main@a623705` (só o README difere).
- **D5 — Correções antes ou depois:** fazer primeiro um build-base sem alterar o código, para observar C1/C6 (recomendação), ou permitir antes ajustes mínimos (`user-setup`, `libpam-systemd`, envio do manifesto pelo workflow).
- **D6 — Matriz:** aceitar as duas linhas obrigatórias acima (SeaBIOS e OVMF) e 2 GiB como aceitação.

## Evidências e limites

- Feito: leitura estática dos arquivos listados no SHA-base e comparação de diffs entre `fbeb7ac`, `a623705` e `ba37a33`.
- Não executado: `validate.sh`, `build.sh`, workflow, VM, instalação, merge, chamadas pagas.
- Não verificado (rede bloqueada): dependências e recomendações dos pacotes Debian trixie e os padrões do live-build (C1, C3, C6, C8). Estão marcados como **H**.
- Separação de contexto: não li o PR #1 nem a conversa de origem. Isso é uma disciplina, não isolamento: eu tinha acesso ao repositório inteiro.

## Devolução do bastão

`state.json` foi atualizado para `awaiting_shira_synthesis` / `owner = shira`. Os SHAs e a URL do commit deste parecer vão para Edward na conversa.
