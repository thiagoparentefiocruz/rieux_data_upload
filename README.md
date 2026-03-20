# rieux_data_upload

[![DOI](https://zenodo.org/badge/1187474279.svg)](https://doi.org/10.5281/zenodo.19139228)


Função em Bash (OS-agnostic) para transferência segura de grandes volumes de dados de sequenciamento para o cluster HPC Rieux.

## Funcionalidades
- **Autodetecção OS:** Identifica macOS ou Linux/WSL e adapta comandos (`shasum` vs `sha256sum`).
- **Prevenção de Suspensão:** Usa `caffeinate` no macOS para evitar que a máquina durma durante uploads.
- **Validação End-to-End:** Gera hashes SHA-256 antes do envio e confere automaticamente no destino.
- **Retomada Segura:** Retoma transferências interrompidas de onde pararam.

## Como Usar
```bash
rieux_data_upload /caminho/pasta_local/ usuario@rieux.fiocruz.br:/caminho/remoto/destino/
