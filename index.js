const fetch = require('node-fetch');
const express = require('express');
const app = express();

// Ganti dengan token bot Telegram Anda
const TOKEN = '7557410285:AAGkA9662osPXoRcNZWhjF73NPbG6O2U6QQ';
const CHAT_ID = '5951232585';  // Ganti dengan ID chat Telegram Anda
const URL_API = `https://api.telegram.org/bot${TOKEN}`;

// Fungsi untuk mengirim pesan
async function sendMessage(text) {
  const response = await fetch(`${URL_API}/sendMessage`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({
      chat_id: CHAT_ID,
      text: text
    })
  });
  return response.json();
}

// Fungsi untuk mengirim keyboard dengan tombol
async function sendKeyboard(text) {
  const response = await fetch(`${URL_API}/sendMessage`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({
      chat_id: CHAT_ID,
      text: text,
      reply_markup: JSON.stringify({
        inline_keyboard: [
          [{ text: 'Ubah Wallpaper', callback_data: 'change_wallpaper' }]
        ]
      })
    })
  });
  return response.json();
}

// Fungsi untuk menangani callback dari tombol
async function handleCallback(callbackData) {
  if (callbackData === 'change_wallpaper') {
    await sendMessage('Kirimkan URL gambar untuk mengubah wallpaper.');
  }
}

// Fungsi untuk mengganti wallpaper (dummy karena tidak bisa dilakukan di JS secara langsung)
async function changeWallpaper(imageUrl) {
  // Dalam implementasi asli, Anda akan menggunakan API seperti Termux atau sistem operasi yang mendukungnya
  console.log(`Mengubah wallpaper dengan gambar dari: ${imageUrl}`);

  // Kirim pesan konfirmasi ke Telegram
  await sendMessage('Wallpaper telah berhasil diubah!');
}

// Webhook untuk menangani update dari Telegram
app.use(express.json());
app.post('/webhook', async (req, res) => {
  const updates = req.body;

  // Menangani callback data (tombol yang ditekan)
  if (updates.callback_query) {
    const callbackData = updates.callback_query.data;
    await handleCallback(callbackData);
  }

  // Menangani pesan teks (URL gambar)
  if (updates.message && updates.message.text) {
    const messageText = updates.message.text;
    // Jika pesan adalah URL gambar, ganti wallpaper
    await changeWallpaper(messageText);
  }

  res.sendStatus(200);
});

// Fungsi untuk mengatur webhook di Telegram
async function setWebhook() {
  const webhookUrl = 'https://your-server.com/webhook'; // Ganti dengan URL server Anda
  const response = await fetch(`${URL_API}/setWebhook`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({
      url: webhookUrl
    })
  });
  return response.json();
}

// Mulai bot
(async () => {
  await sendMessage('Selamat datang! Tekan tombol di bawah untuk mengubah wallpaper.');
  await sendKeyboard('Pilih opsi untuk mengubah wallpaper:');

  // Set webhook agar bot bisa menerima update
  await setWebhook();
})();

// Menjalankan server Express untuk menerima webhook
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server berjalan di http://localhost:${PORT}`);
});
