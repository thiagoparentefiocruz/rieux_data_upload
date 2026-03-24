# rieux_data_upload 🚀

[![DOI](https://zenodo.org/badge/1187474279.svg)](https://doi.org/10.5281/zenodo.19139228)


Função Bash para transferência segura de dados de sequenciamento para o cluster **Rieux**.

## ✨ Funcionalidades
- **Prevenção de Suspensão:** Usa `caffeinate` no macOS para evitar interrupções.
- **Validação SHA-256:** Confere a integridade dos arquivos antes e depois do envio.
- **Retomada Inteligente:** Se a conexão cair, o `rsync` continua de onde parou.

## 🛠️ Instalação Rápida
Abra seu terminal e rode:

```bash
git clone https://github.com/thiagoparentefiocruz/rieux_data_upload.git
cd rieux_data_upload
bash install.sh
source ~/.zshrc  # Se estiver no Mac
```

📖 Como Usar
```bash
rieux_data_upload /pasta/local/ usuario@rieux.fiocruz.br:/caminho/remoto/
```
