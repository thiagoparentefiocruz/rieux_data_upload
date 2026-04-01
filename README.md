# rieux_data_upload 🚀

[![DOI](https://zenodo.org/badge/1187474279.svg)](https://doi.org/10.5281/zenodo.19139228)

Função Bash para transferência segura de grandes volumes de dados (p.ex. de sequenciamento NGS) para o cluster **Rieux** (ou qualquer ambiente HPC Linux).

## ✨ Funcionalidades
- **Autodetecção de OS:** Identifica se você está no macOS ou Linux/WSL e ajusta os comandos de integridade automaticamente.
- **Prevenção de Suspensão:** Usa `caffeinate` no macOS para evitar que a máquina durma durante uploads longos.
- **Validação SHA-256:** Calcula os hashes locais, confere a integridade dos arquivos após o envio no servidor remoto e garante auditoria ponta a ponta.
- **Retomada Inteligente:** Se a conexão cair ou for interrompida, o `rsync` continua exatamente de onde parou na próxima execução.

## 🛠️ Instalação

Para instalar a ferramenta como um comando nativo do seu sistema, basta clonar o repositório e rodar o nosso script de instalação automatizada. 

Você pode baixar em qualquer diretório da sua máquina (como a pasta `Downloads`), pois o instalador cuidará de tudo. Abra seu terminal e rode os comandos abaixo:

```bash
# 1. Clone o repositório
git clone https://github.com/thiagoparentefiocruz/rieux_data_upload.git

# 2. Entre na pasta clonada
cd rieux_data_upload

# 3. Execute o instalador
bash install.sh
```

*(O script `install.sh` copiará o executável de forma segura para `~/.local/bin` e configurará automaticamente o seu `PATH`, caso seja necessário).*

**Limpeza (Opcional):**
Como o instalador faz uma cópia real do arquivo, logo após a instalação você pode apagar a pasta que acabou de baixar para manter seu computador organizado:

```bash
cd ..
rm -rf rieux_data_upload
```

## 📖 Como Usar

Após a instalação, a ferramenta estará disponível globalmente em qualquer terminal. A sintaxe básica é:

```bash
rieux_data_upload /caminho/pasta_local/ usuario@rieux.fiocruz.br:/caminho/remoto/destino/
```
