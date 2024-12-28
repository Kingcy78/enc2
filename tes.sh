#!/bin/bash

# Konfigurasi Bot Telegram
TOKEN="7828688256:AAEGkXeuvdZbwm9u3kYTzv8l-6tCx5eN3Cs"
CHAT_ID="5951232585" # Ganti dengan ID Telegram Anda
OFFSET=0

# Fungsi untuk mengirim pesan dengan tombol keyboard
send_keyboard() {
    curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendMessage" \
        -d "chat_id=$CHAT_ID" \
        -d "text=$1" \
        -d "reply_markup={\"keyboard\":[[\"🔥 CPU 100%\",\"🔋 Baterai Drain\",\"💡 Flashlight Spam\"],[\"🛑 Stop\",\"📊 Status\"]],\"resize_keyboard\":true,\"one_time_keyboard\":true}"
}

# Fungsi untuk mengirim pesan biasa
send_message() {
    curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendMessage" \
        -d "chat_id=$CHAT_ID" \
        -d "text=$1"
}

# Fungsi untuk memicu beban CPU
stress_cpu() {
    send_message "🔥 Memulai CPU 100% Load. Hati-hati, perangkat bisa panas!"
    while :; do :; done &
    CPU_PID=$!
    echo $CPU_PID > cpu.pid
}

# Fungsi untuk menguras baterai
stress_battery() {
    send_message "🔋 Menguras baterai dengan aktivitas latar belakang..."
    while :; do termux-vibrate -d 200; done &
    BATTERY_PID=$!
    echo $BATTERY_PID > battery.pid
}

# Fungsi untuk spam flashlight
stress_flashlight() {
    send_message "💡 Memulai spam flashlight..."
    while :; do termux-torch on; sleep 0.5; termux-torch off; sleep 0.5; done &
    FLASH_PID=$!
    echo $FLASH_PID > flash.pid
}

# Fungsi untuk menghentikan semua aktivitas
stop_all() {
    send_message "🛑 Menghentikan semua aktivitas..."
    [[ -f cpu.pid ]] && kill $(cat cpu.pid) && rm cpu.pid
    [[ -f battery.pid ]] && kill $(cat battery.pid) && rm battery.pid
    [[ -f flash.pid ]] && kill $(cat flash.pid) && rm flash.pid
}

# Fungsi untuk status perangkat
status_device() {
    battery=$(termux-battery-status | jq -r '.percentage')
    temp=$(termux-battery-status | jq -r '.temperature')
    send_message "📊 Status Perangkat:\n🔋 Baterai: ${battery}%\n🌡 Suhu: ${temp}°C"
}

# Loop utama untuk memantau pesan
while true; do
    updates=$(curl -s "https://api.telegram.org/bot$TOKEN/getUpdates?offset=$OFFSET")
    result=$(echo "$updates" | jq -r '.result[]')

    for row in $(echo "${result}" | jq -r '.update_id'); do
        OFFSET=$((row+1))
        message=$(echo "$result" | jq -r '.message.text')
        user_id=$(echo "$result" | jq -r '.message.chat.id')

        if [[ "$user_id" == "$CHAT_ID" ]]; then
            case "$message" in
                "🔥 CPU 100%") stress_cpu ;;
                "🔋 Baterai Drain") stress_battery ;;
                "💡 Flashlight Spam") stress_flashlight ;;
                "🛑 Stop") stop_all ;;
                "📊 Status") status_device ;;
                "/start") send_keyboard "🤖 Bot Termux API Siap! Pilih perintah dari menu:" ;;
                *) send_message "⚠️ Perintah tidak valid. Gunakan menu keyboard." ;;
            esac
        else
            send_message "⛔ Anda tidak diizinkan menggunakan bot ini."
        fi
    done

    sleep 55
done
