# rieux_data_upload 🚀

[![DOI](https://zenodo.org/badge/1187474279.svg)](https://doi.org/10.5281/zenodo.19139228)


Função Bash para transferência segura de grandes volumes de dados (p.ex. de sequenciamento NGS) para o cluster **Rieux**.

## ✨ Funcionalidades
- **Autodetecção de OS:** Identifica se você está no macOS ou Linux/WSL e ajusta os comandos de integridade.
- **Prevenção de Suspensão:** Usa `caffeinate` no macOS para evitar interrupções.
- **Validação SHA-256:** Confere a integridade dos arquivos antes e depois do envio.
- **Retomada Inteligente:** Se a conexão cair, o `rsync` continua de onde parou.

## 🛠️ Instalação Rápida
Abra seu terminal e rode:
### 1. Organize seu ambiente (Recomendado)
Para manter seus códigos organizados, recomendamos criar uma pasta centralizada no seu computador (como `~/github`), mas o programa funcionará em qualquer diretório.

```bash
mkdir -p ~/github
cd ~/github
git clone https://github.com/thiagoparentefiocruz/rieux_data_upload.git
cd rieux_data_upload
bash install.sh
```

Ative a função
Para começar a usar imediatamente no terminal atual:
No macOS: 
```bash
source ~/.zshrc
```

No Linux/WSL: 
```bash
source ~/.bashrc
```

📖 Como Usar
```bash
rieux_data_upload /pasta/local/ usuario@rieux.fiocruz.br:/caminho/remoto/
```
