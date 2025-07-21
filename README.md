# ph-storge
---
is an advanced and fully-featured storage management script for FiveM servers using the QBCore framework. It allows players to purchase, manage, and secure personal storage units (stashes) with advanced features such as police control, ownership transfer, lock repair, and more. The script is highly configurable and integrates seamlessly with QBCore and its ecosystem.

---

## ✨ Features
- **Buyable Storage Units:** Players can purchase storage units at configured locations.
- **Customizable Storage:** Each storage has configurable price, size, slots, and location.
- **Password Protection:** Storages are protected by a player-set password.
- **Ownership Transfer:** Players can transfer storage ownership to other players.
- **Police Control:** Police can lock, unlock, and seize storages for investigations.
- **Lock Repair:** Players can pay to repair broken storage locks.
- **Blip & Ped Integration:** Storage managers (Peds) and blips are shown on the map.
- **Full QBCore Integration:** Uses QBCore jobs, money, inventory, and notifications.
- **Admin Controls:** Admins (police) can manage and release seized storages.
- **Highly Configurable:** All locations, prices, jobs, and more are set in `config.lua`.
- **No database required:** Storage data is saved in `storges.json`.

---

## 📌 Dependencies
  - `qb-core`
  - `qb-target`
  - `qb-menu`
  - `qb-inventory`
  - `qb-input`

---

## 📩 Installation
1. Download or clone this repository into your server's `resources` folder.
2. Add the following line to your `server.cfg` (after all dependencies):
   ```
   ensure ph-storge
   ```
3. Edit `config.lua` to customize storage locations, prices, jobs, and other settings as needed.
4. Restart your server or use `refresh` and `ensure ph-storge` in the server console.

---

## 📞 Support & Contact
[PH Scripts Community](https://discord.gg/MyXQHPX9U8)
