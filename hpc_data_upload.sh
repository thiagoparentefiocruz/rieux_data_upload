#!/bin/bash

hpc_data_upload() {
    if [ "$#" -ne 2 ]; then
        echo "Uso: hpc_data_upload </caminho/local_arquivo_ou_pasta> <usuario@hpc:/caminho/remoto_destino>"
        return 1
    fi

    local LOCAL_SRC="$1"
    local REMOTE_DEST="$2"
    
    local REMOTE_HOST="${REMOTE_DEST%%:*}"
    local REMOTE_DIR="${REMOTE_DEST#*:}"

    echo "🚀 Iniciando pipeline inteligente de upload para o hpc..."

    local OS_TYPE=$(uname -s)
    local CMD_HASH_GEN=()
    local CMD_RSYNC=()

    case "$OS_TYPE" in
        Darwin*)
            echo "🍎 Sistema detectado: macOS. Configurando caffeinate e shasum..."
            CMD_HASH_GEN=(shasum -a 256)
            CMD_RSYNC=(caffeinate -i rsync -avP)
            ;;
        Linux*)
            echo "🐧 Sistema detectado: Linux/WSL. Configurando sha256sum..."
            CMD_HASH_GEN=(sha256sum)
            CMD_RSYNC=(rsync -avP)
            ;;
        *)
            echo "❌ Sistema Operacional '$OS_TYPE' não suportado."
            return 1
            ;;
    esac

    local ORIGINAL_DIR=$(pwd)
    
    echo "---------------------------------------------------"
    echo "Preparando o diretório de destino no hpc..."
    # Garante que a pasta de destino remota exista antes do rsync
    ssh "$REMOTE_HOST" "mkdir -p '$REMOTE_DIR'"

    echo "---------------------------------------------------"
    echo "Analisando o alvo local e calculando hashes em tempo real..."
    
    # Verifica se é diretório ou arquivo local
    local LOCAL_IS_DIR="NO"
    if [ -d "$LOCAL_SRC" ]; then
        LOCAL_IS_DIR="YES"
    elif [ ! -f "$LOCAL_SRC" ]; then
        echo "❌ Erro: O arquivo ou pasta local não foi encontrado."
        return 1
    fi

    local RSYNC_SRC=""

    if [ "$LOCAL_IS_DIR" = "YES" ]; then
        # É uma pasta: calcula a hash do conteúdo
        cd "$LOCAL_SRC" || return 1
        find . -type f ! -path '*/.*' ! -name "checksums_local.txt" -exec "${CMD_HASH_GEN[@]}" {} + > checksums_local.txt
        RSYNC_SRC="./"
    else
        # É um arquivo solto: calcula a hash apenas dele
        cd "$(dirname "$LOCAL_SRC")" || return 1
        "${CMD_HASH_GEN[@]}" "$(basename "$LOCAL_SRC")" > checksums_local.txt
        RSYNC_SRC="$(basename "$LOCAL_SRC")"
    fi

    # Verifica se o arquivo de checksum foi gerado com sucesso
    if [ ! -s checksums_local.txt ]; then
        echo "❌ Erro: Falha ao gerar as hashes locais ou pasta vazia."
        rm -f checksums_local.txt
        cd "$ORIGINAL_DIR"
        return 1
    fi
    echo "✅ Checksums locais mapeados e salvos."

    echo "---------------------------------------------------"
    echo "Iniciando transferência segura (rsync)..."

    if [ "$LOCAL_IS_DIR" = "YES" ]; then
        # Envia o conteúdo da pasta (o checksums_local.txt já está lá dentro e vai junto)
        "${CMD_RSYNC[@]}" "$RSYNC_SRC" "$REMOTE_DEST/"
    else
        # Envia o arquivo específico e o txt de checksums juntos
        "${CMD_RSYNC[@]}" "$RSYNC_SRC" checksums_local.txt "$REMOTE_DEST/"
    fi

    if [ $? -ne 0 ]; then
        echo "❌ Erro ou interrupção na transferência."
        echo "Basta rodar o comando novamente para retomar de onde parou."
        cd "$ORIGINAL_DIR"
        return 1
    fi
    echo "✅ Upload concluído."

    echo "---------------------------------------------------"
    echo "Verificando a integridade dos dados remotamente..."
    
    # O HPC lê o arquivo de texto enviado e confere se a transferência foi perfeita
    ssh "$REMOTE_HOST" "cd '$REMOTE_DIR' && sha256sum -c checksums_local.txt"

    if [ $? -eq 0 ]; then
        echo "---------------------------------------------------"
        echo "🎉 SUCESSO! Transferência validada criptograficamente no hpc."
    else
        echo "---------------------------------------------------"
        echo "⚠️ AVISO: A verificação falhou para um ou mais arquivos. Cheque o log acima."
    fi

    cd "$ORIGINAL_DIR"
}

hpc_data_upload "$@"
