#!/bin/bash

BACKUP_DIR="./backup_safe_update"
CORE_DIR="./core"
GIVE_ME_NAME="./give-me-name.sh"
URL_LATEST="https://raw.githubusercontent.com/Agr96/StackLyX/latest/give-me-name.sh"

mkdir -p "$BACKUP_DIR"

function backup_now() {
    timestamp=$(date +"%Y%m%d_%H%M%S")
    backup_path="$BACKUP_DIR/backup_$timestamp"
    echo "Membuat backup ke $backup_path ..."
    mkdir -p "$backup_path"
    # Backup core folder dan give-me-name.sh jika ada
    cp -r "$CORE_DIR" "$backup_path" 2>/dev/null
    cp "$GIVE_ME_NAME" "$backup_path" 2>/dev/null
    echo "Backup selesai."
}

function list_backups() {
    ls -1 "$BACKUP_DIR" | grep backup_ | sort -r
}

function rollback() {
    backups=($(list_backups))
    if [ ${#backups[@]} -eq 0 ]; then
        echo "Tidak ada backup untuk rollback."
        return
    fi

    echo "Pilih backup untuk rollback:"
    select choice in "${backups[@]}" "Cancel"; do
        if [[ "$choice" == "Cancel" ]]; then
            echo "Rollback dibatalkan."
            return
        elif [[ -n "$choice" ]]; then
            echo "Melakukan rollback ke backup: $choice ..."
            rm -rf "$CORE_DIR"
            cp -r "$BACKUP_DIR/$choice/core" . 2>/dev/null
            cp "$BACKUP_DIR/$choice/give-me-name.sh" . 2>/dev/null
            echo "Rollback selesai."
            return
        else
            echo "Pilihan tidak valid, coba lagi."
        fi
    done
}

function update_now() {
    backup_now
    echo "Mengunduh give-me-name.sh terbaru ..."
    curl -fsSL -o "$GIVE_ME_NAME" "$URL_LATEST"
    if [ $? -ne 0 ]; then
        echo "Gagal mengunduh update."
        return
    fi
    echo "Update give-me-name.sh selesai."

    echo "Menghapus isi folder core ..."
    rm -rf "$CORE_DIR"
    mkdir -p "$CORE_DIR"

    echo "Menjalankan give-me-name.sh untuk generate modul core ..."
    bash "$GIVE_ME_NAME"
    echo "Update selesai."
}

echo "Pilih aksi:"
options=("Update now (backup dulu)" "Rollback" "Cancel")
select opt in "${options[@]}"; do
    case $opt in
        "Update now (backup dulu)")
            update_now
            break
            ;;
        "Rollback")
            rollback
            break
            ;;
        "Cancel")
            echo "Dibatalkan."
            break
            ;;
        *)
            echo "Pilihan tidak valid."
            ;;
    esac
done
