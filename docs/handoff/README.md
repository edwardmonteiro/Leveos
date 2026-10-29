# Piloto: shira -> Claude -> Edward

Este piloto usa somente arquivos Git e troca manual entre aplicativos. Não chama modelos por API nem instala um orquestrador. Edward abre cada aplicativo e entrega o comando. O repositório é o registro do trabalho, não uma autorização automática para executar ações.

## Comece aqui

- Tarefa: [001-lite-iso/spec.md](001-lite-iso/spec.md).
- Etapa atual e próximo responsável: [001-lite-iso/state.json](001-lite-iso/state.json).
- Saída reservada ao Claude: [001-lite-iso/claude-review.md](001-lite-iso/claude-review.md).

## Papéis e passagem de bastão

1. **shira / autora:** registra intenção, proposta, critérios e fontes. Esta etapa foi preparada.
2. **Claude / revisor independente:** em uma conversa nova, lê este guia, a especificação e apenas os fontes relevantes nela indicados; questiona premissas, riscos e critérios. Não recebe a conversa que originou o plano nem parecer de outro revisor. Registra seu próprio parecer, com evidências.
3. **shira / síntese:** após Edward retornar com o commit do parecer, verifica o diff e resume convergências, divergências e decisões pendentes.
4. **Edward / decisão:** aprova, pede revisão ou interrompe, referindo o commit exato que examinou. Implementação, build, merge e teste físico são etapas posteriores, fora deste piloto.

Separação de contexto é uma disciplina, não isolamento técnico: o revisor pode acessar o restante do repositório. Não alegue independência perfeita nem que dois modelos concordando demonstram correção.

## Contrato desta rodada

- Somente documentação na pasta desta tarefa. Não editar código, workflow, configurações do SO ou arquivos de outros trabalhos.
- Não executar build, workflow, instalação, VM, deploy, merge, chamadas pagas ou alterações no Mac.
- Não declarar testes executados sem logs. Inspeção estática, build, boot em VM e compatibilidade física são evidências distintas.
- Não escrever em nome de outro modelo. O template não é um parecer concluído.
- Claude deve registrar o SHA completo de entrada (`git rev-parse HEAD`) antes de escrever. Se os fontes-base mudarem ou o pacote de entrada for alterado, interromper para nova revisão.
- O campo de aprovação humana começa vazio. Um agente nunca o preenche por inferência.
- Para publicar o parecer, alterar apenas `claude-review.md` e `state.json` nesta branch. Sem merge. Se o aplicativo só permite leitura, devolver o parecer e os SHAs a Edward; não simular commit.

## Como Claude encerra

Preencher seu parecer, definir `phase = "awaiting_shira_synthesis"`, `owner = "shira"` e `next_action = "Verificar o parecer e apresentar decisões a Edward; não implementar."` em state.json. Registrar o SHA de entrada em `reviewed_input_commit`. Após o commit, devolver URL e SHA do novo commit. O próprio commit do parecer não precisa estar escrito dentro de si.

shira verifica o commit publicado antes de considerar o bastão recebido. Uma aprovação deve identificar o pacote/commit analisado e escopo; qualquer mudança material exige nova decisão. A aprovação do plano não equivale a aprovação de PR, merge, instalação ou execução privilegiada.
