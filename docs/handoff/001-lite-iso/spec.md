# 001 — Plano verificável de build Lite e boot em VM

**Autora:** shira. **Status:** proposta para revisão, não implementação.
**Fonte-base:** `fbeb7ac5aaf9ae269d57864a1526ae45405b9666` de `edwardmonteiro/Leveos`.
**Escopo desta rodada:** revisar este plano e seus critérios, sem executar scripts.

## Intenção

Demonstrar uma passagem de bastão útil: shira propõe como sair de “código inspecionado” para “ISO Lite gerada e comportamento verificado em VM”; Claude encontra lacunas antes de Edward decidir o próximo passo.

O produto atual se descreve como Debian 13 amd64, CLI-first, para Macs Intel antigos sem T2. Boot em VM não comprova funcionamento no Mac. Modelo/ano/firmware do Mac e teste físico ficam fora da aceitação deste piloto.

## Evidências existentes no repositório

- README.md descreve perfis lite/web/claw e informa que a ISO não foi compilada nem testada no Mac real.
- build.sh usa live-build/trixie/amd64, perfil lite por padrão, sem instalador por padrão. Gera ISO, .sha256 e .build.log em output/.
- validate.sh verifica sintaxe e estrutura; sua própria mensagem distingue isso de boot e hardware.
- .github/workflows/build.yml tem apenas workflow_dispatch; usa ubuntu-24.04 e contêiner debian:trixie com privilégio. Não há teste de boot nesse workflow.
- packages/lite.list e overlay/ determinam conteúdo e comandos do sistema.
- A árvore-base não contém AGENTS.md nem .agents/skills. Reavaliar se forem adicionados.

Estas afirmações resultam de leitura dos fontes, não de execução. Nenhum resultado de build/VM é reivindicado neste pacote.

## Proposta a criticar

Depois de aprovação específica, uma implementação futura deverá:

1. Fixar o commit de entrada e registrar receita, ambiente, versões das ferramentas, origem/versões dos pacotes, arquitetura, configuração e comandos.
2. Executar validação estática e construir somente lite, sem instalador, em ambiente descartável. Identificar previamente as permissões privilegiadas exigidas pelo build.
3. Preservar código de saída, log completo, manifesto de pacotes, tamanho e SHA256 da ISO e identidade do ambiente. Não considerar a mera presença de um arquivo como sucesso.
4. Usar a mesma ISO verificada em uma VM x86_64 descartável, sem disco físico/passthrough, sem credenciais pessoais e sem instalação no host.
5. Testar o comportamento CLI-first e GUI sob demanda; registrar observação e falhas, não apenas screenshots de tela inicial.
6. Entregar uma síntese com cada critério passado/falhou/não executado e limitações. Separar explicitamente “boot em VM” de “compatível com Mac”.

## Critérios propostos para a próxima etapa (ainda não autorizada)

| Critério | Evidência necessária |
| --- | --- |
| Receita repetível | Commit, comandos, versões e dependências registrados; reprodução em ambiente limpo descrita sem passos ocultos |
| Build | Validação e build com saída 0; artefatos esperados não vazios; log íntegro; checksum recalculado corresponde |
| Inicialização | ISO Lite chega a uma sessão CLI utilizável em até 5 minutos, em VM com 2 vCPU e 4 GiB; registrar hipervisor/versão/firmware/dispositivos exatos |
| Interação | `leveos help` e `leveos status` funcionam; entrada de teclado e locale observados; erros registrados |
| Interface sob demanda | Sem sessão gráfica automática; `leveos gui` abre JWM e terminal quando solicitado, sem instalar componentes no teste |
| Isolamento do perfil | Firefox/OpenClaw não exigidos para aceitar Lite; nenhum agente iniciado automaticamente |
| Conclusão honesta | Logs e evidências ligados ao SHA da ISO; falhas e itens não testados explicitados; nenhum claim sobre Mac real |

Os valores de tempo/recursos são uma proposta de critério para Claude contestar, não medição ou promessa de desempenho. BIOS legado e UEFI devem ter resultados separados; a revisão deve recomendar uma matriz mínima e justificar seu alcance. Não pressupor que uma modalidade cubra a outra.

## “Reproduzível” precisa ser definido

O script usa repositórios Debian vivos e o workflow usa tags mutáveis de contêiner/actions. A receita atual, sozinha, não garante imagens idênticas bit a bit. Nesta proposta, “repetível” significa repetir o processo com entradas registradas; reprodutibilidade binária exige uma etapa adicional de fixação de entradas, controle de timestamps e comparação de dois builds independentes. Claude deve decidir se o primeiro marco deve limitar a promessa ou exigir essa etapa; não classificar como reproduzível sem evidência.

## Pacote de leitura do Claude

Ler esta especificação primeiro. Depois, no SHA-base: README.md, build.sh, validate.sh, .github/workflows/build.yml, packages/lite.list, overlay/etc/skel/.xinitrc, overlay/etc/skel/.jwmrc e os scripts em overlay/usr/local/bin/. Inspecionar outros fontes somente se uma hipótese exigir; registrar quais. Não ler conversa anterior ou opiniões de outros revisores antes de formar o parecer.

## Perguntas que a revisão deve responder

- Esses critérios realmente provam o objetivo ou permitem falsos positivos?
- Quais dependências, etapas de login/boot, firmware, drivers ou privilégios faltam na receita?
- O que deve ser fixado para repetir o build? Qual limite de reprodutibilidade está sendo prometido?
- A matriz de VM e as verificações de GUI/CLI são suficientes e executáveis?
- Há riscos de host, rede, credenciais, disco ou execução privilegiada que exigem decisão explícita?
- Qual é a menor correção documental para tornar o plano implementável?

Saída: parecer independente em claude-review.md, com severidade, caminho/linha ou evidência, impacto, recomendação e decisões para Edward. Não corrigir código. Pare após publicar o parecer e atualizar o estado.
