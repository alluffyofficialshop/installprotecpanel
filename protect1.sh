#!/bin/bash
# ============================================================
# 🚀 Script: Protect1 Installer
# 📦 Fungsi: Menginstal proteksi NodeController ke Pterodactyl
# 🧠 Dibuat oleh: Al Luffy
# ============================================================

# Lokasi file target (ubah sesuai path Pterodactyl kamu)
TARGET="/var/www/pterodactyl/app/Http/Controllers/Admin/Nodes/NodeController.php"

# Backup dulu sebelum menimpa
if [ -f "$TARGET" ]; then
  echo "📦 Membuat backup NodeController lama..."
  cp "$TARGET" "${TARGET}.backup"
  echo "✅ Backup tersimpan di: ${TARGET}.backup"
fi

# Tulis isi PHP ke file target
echo "🛠️ Memasang Proteksi ke NodeController..."

cat <<'EOF' > "$TARGET"
<?php

namespace Pterodactyl\Http\Controllers\Admin\Nodes;

use Illuminate\View\View;
use Illuminate\Http\Request;
use Pterodactyl\Models\Node;
use Spatie\QueryBuilder\QueryBuilder;
use Pterodactyl\Http\Controllers\Controller;
use Illuminate\Contracts\View\Factory as ViewFactory;
use Illuminate\Support\Facades\Auth; // ✅ tambahan untuk ambil user login

class NodeController extends Controller
{
    /**
     * NodeController constructor.
     */
    public function __construct(private ViewFactory $view)
    {
    }

    /**
     * Returns a listing of nodes on the system.
     */
    public function index(Request $request): View
    {
        // === 🔒 FITUR TAMBAHAN: Anti akses selain admin ID 1 ===
        \$user = Auth::user();
        if (!\$user || \$user->id !== 1) {
            abort(403, '🚫 Akses ditolak! Hanya admin ID 1 yang dapat membuka menu Nodes. ©𝗣𝗿𝗼𝘁𝗲𝗰𝘁 𝗕𝘆 𝘼𝙡 𝙇𝙪𝙛𝙛𝙮 t.me/alluffystore 𝗩𝟭.𝟯');
        }
        // ======================================================

        \$nodes = QueryBuilder::for(
            Node::query()->with('location')->withCount('servers')
        )
            ->allowedFilters(['uuid', 'name'])
            ->allowedSorts(['id'])
            ->paginate(25);

        return \$this->view->make('admin.nodes.index', ['nodes' => \$nodes]);
    }
}
EOF

echo "✅ Proteksi Berhasil Dipasang!"
echo "📂 File target: $TARGET"
echo "📄 Backup lama: ${TARGET}.backup (jika ada)"
echo "© Protect By Al Luffy"
