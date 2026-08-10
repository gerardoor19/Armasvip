<div align="center">

# 👑 ArmasVIP

### Persistent VIP Weapon Ownership for FiveM

**A server-authoritative system for assigning, protecting and managing premium weapon ownership.**

![Version](https://img.shields.io/badge/version-2.2.0-orange)
![FiveM](https://img.shields.io/badge/platform-FiveM-blue)
![Price](https://img.shields.io/badge/price-Free-brightgreen)
![Inventory](https://img.shields.io/badge/inventory-ox__inventory-lightgrey)
![Database](https://img.shields.io/badge/database-oxmysql-lightgrey)
![Distribution](https://img.shields.io/badge/code-Cfx%20Asset%20Escrow-red)

**Qbox · QBCore · ESX · Standalone**

</div>

> [!IMPORTANT]
> **This repository contains documentation only.**  
> **The protected runtime resource is distributed through Cfx Asset Escrow.**

---

## Showcase

### Player VIP Arsenal

A dedicated premium interface where players manage only the VIP weapons they actually own. Ownership, availability, installed accessories and unlocked finishes are represented per persistent grant.

<img width="100%" alt="ArmasVIP player arsenal - Combat Pistol" src="https://github.com/user-attachments/assets/7832c509-7bc8-4b1b-9c66-8e3a4541e611" />

### Administrative Weapon Assignment

The administrative catalog is completely separate from the player Arsenal. Authorized staff can select a weapon and its initial configuration before creating the persistent VIP grant.

<img width="100%" alt="ArmasVIP administrative weapon assignment panel" src="https://github.com/user-attachments/assets/06b94175-d97b-4f74-8f1f-fe27796cb70c" />

### Premium Customization

Persistent camo/tint unlocks can be displayed and selected from the player's Arsenal. Cosmetic changes remain subject to server-side ownership and unlock validation.

<img width="100%" alt="ArmasVIP player arsenal - Combat PDW customization" src="https://github.com/user-attachments/assets/b92798b8-cfb7-4e08-97b7-2d749fdbb420" />

---

## What is ArmasVIP?

ArmasVIP is a FiveM resource built around **persistent VIP weapon ownership**.

It is not a menu that gives every VIP player access to every weapon. Instead, an authorized administrator assigns a **specific weapon to a specific player**, creating a persistent grant that represents ownership independently from the temporary physical item inside `ox_inventory`.

```text
OWNER / AUTHORIZED STAFF
          │
          ▼
   Selects a player
          │
          ▼
   Selects a VIP weapon
          │
          ▼
 Creates persistent grant
          │
          ▼
 PLAYER OWNS THAT VIP WEAPON
          │
          ▼
 Manages it from /misarmasvip
```

If the physical weapon disappears because of death, loss, restart or inventory state, the ownership grant remains. Recovery is possible only after the server validates the player's identity, grant and current weapon-instance state.

---

## Core Features

| Feature | Implementation |
|---|---|
| **Persistent ownership** | SQL-backed weapon grants survive loss of the physical item |
| **Admin panel** | `/armasvip`, protected by `armasvip.admin` ACE |
| **Player Arsenal** | `/misarmasvip`, showing only grants owned by that player |
| **Anti-duplication** | Recovery checks for an existing VIP instance before delivery |
| **Per-instance VIP behavior** | Normal copies of the same weapon remain normal |
| **Transfer protection** | VIP instances are protected through `ox_inventory` integration |
| **VIP durability** | VIP instances do not degrade normally |
| **Physical accessories** | Initial components are not regenerated during recovery |
| **Persistent camos/tints** | Unlocks belong to the grant and are validated server-side |
| **Framework support** | Qbox, QBCore, ESX and Standalone fallback |
| **Protected distribution** | Runtime delivered through Cfx Asset Escrow |

---

## Architecture

ArmasVIP separates **ownership** from the **physical inventory instance**.

```text
Persistent SQL Grant
├── Owner identity
├── VIP weapon
├── Grant state
├── Persistent cosmetic unlocks
└── Ownership data
        │
        ▼
Server-side validation
        │
        ▼
VIP weapon instance in ox_inventory
├── vip = true
├── vipGrantId = unique grant
└── vipOwner = validated owner
```

The grant is the authoritative ownership record. The inventory item is the physical representation of that ownership.

---

## VIP Weapon vs Normal Weapon

This distinction is fundamental to the design.

A VIP AP Pistol and a normal AP Pistol can both use the same base weapon name:

```text
weapon_appistol
```

VIP behavior is **not applied globally to the weapon type**. Only an instance carrying valid VIP metadata and backed by a valid grant receives VIP protections.

| Normal instance | VIP instance |
|---|---|
| Standard inventory behavior | Bound to a persistent grant |
| Standard durability | VIP non-degrading behavior |
| Normal transfer rules | VIP transfer protection |
| No VIP ownership | Server-validated owner |
| No grant association | Unique `vipGrantId` |

---

## Administration

Authorized staff open the administrative interface with:

```text
/armasvip
```

Required ACE permission:

```text
armasvip.admin
```

Example `server.cfg`:

```cfg
add_ace group.armasvip armasvip.admin allow
add_principal identifier.license:YOUR_LICENSE group.armasvip
```

The NUI is not a security boundary. Administrative operations must pass server-side ACE and data validation even if a malicious client manually invokes discovered events or callbacks.

---

## Player Arsenal

Players access their personal collection with:

```text
/misarmasvip
```

The Arsenal is intentionally isolated from the administrative catalog. It displays the player's actual persistent grants rather than accepting arbitrary weapon requests from the client.

Depending on grant and inventory state, the interface can represent:

- owned VIP weapon;
- current availability/state;
- installed accessories;
- unlocked camos/tints;
- selected finish;
- recovery/equip availability.

A player without a valid grant cannot create ownership by manipulating NUI data, weapon names or grant IDs.

---

## Recovery & Anti-Duplication

The persistent grant survives independently from the physical item. Before a VIP weapon is delivered or recovered, the server verifies the relevant ownership and instance state.

Conceptually:

```text
Recovery request
      │
      ▼
Validate player identity
      │
      ▼
Validate active grant + owner
      │
      ▼
Validate weapon/grant association
      │
      ▼
Check for existing VIP instance
      │
      ├── Exists ──► Reject duplicate delivery
      │
      └── Missing ─► Allow valid recovery
```

This prevents repeated Arsenal requests from becoming a weapon duplication mechanism.

---

## Accessories

VIP weapon ownership and accessories intentionally use different persistence rules.

**Weapon grant = persistent ownership.**  
**Accessories = physical components.**

An administrator can include compatible accessories with the initial assignment. After delivery, those components may be removed, changed or lost according to the server's normal inventory/game behavior.

Recovery does **not** regenerate removed accessories. This prevents a cycle such as:

```text
Remove accessory → Recover weapon → Receive accessory again → Duplicate
```

---

## Camos & Tints

Cosmetic unlocks are persistent premium data associated with the VIP grant. The Arsenal can display unlocked and locked finishes and allow the player to select an available finish.

The client cannot authorize an unlock by itself. The server validates the grant, owner and cosmetic entitlement before accepting a change.

---

## Security Model

ArmasVIP follows a **server-authoritative** security model. Hiding a UI button is never considered authorization.

Sensitive operations are designed to validate, when applicable:

- player/framework identity;
- `armasvip.admin` ACE permission;
- grant existence and state;
- grant owner;
- weapon associated with the grant;
- VIP metadata and `vipGrantId`;
- current physical instance state;
- camo/tint unlock entitlement;
- client/NUI supplied values;
- duplicate recovery attempts.

The objective is to prevent a normal player from acquiring unauthorized VIP weapons through manual `TriggerServerEvent` calls, executors, manipulated NUI requests, dumped event names, fabricated weapon names or another player's grant ID.

For the detailed threat model and operational notes, see **[Security](docs/SECURITY.md)**.

---

## Requirements

### Dependencies

- `oxmysql`
- `ox_lib`
- `ox_inventory`

### Supported identity environments

- Qbox
- QBCore
- ESX
- Standalone fallback

### Recommended startup order

```cfg
ensure oxmysql
ensure ox_lib
ensure ox_inventory
ensure armasvip
```

---

## Installation

The protected runtime package is distributed separately through the intended Cfx Asset Escrow delivery flow. This repository does not contain the private runtime source.

For server installation, database preparation, ACE configuration and validation steps, see:

**[Installation Guide →](docs/INSTALLATION.md)**

---

## Documentation

| Guide | Purpose |
|---|---|
| **[Installation](docs/INSTALLATION.md)** | Dependencies, setup, SQL and ACE configuration |
| **[Configuration](docs/CONFIGURATION.md)** | Framework/identity and resource behavior |
| **[Usage](docs/USAGE.md)** | Admin and player workflows |
| **[Security](docs/SECURITY.md)** | Server-authoritative security model |
| **[Troubleshooting](docs/TROUBLESHOOTING.md)** | Common installation and runtime checks |
| **[Publishing](docs/PUBLISHING.md)** | Protected distribution workflow |
| **[Changelog](CHANGELOG.md)** | Version history |

---

## Distribution

| | |
|---|---|
| **Price** | Free |
| **Version** | 2.2.0 |
| **Code access** | Cfx Asset Escrow |
| **Runtime source in this repository** | No |

ArmasVIP is currently intended to be **free to use**, while its protected runtime is distributed through **Cfx Asset Escrow** and the intended FiveM/Tebex distribution flow.

This project is **not published as open-source software**. This documentation repository does not grant permission to resell, re-upload or redistribute the protected runtime package outside its intended distribution channel.

Official Tebex, Cfx Forum and support links are intentionally omitted until they are supplied by the project owner.

---

## Project Status

**Current version:** `2.2.0`

ArmasVIP is an independently developed FiveM resource with its own project identity, documentation and distribution model.

<div align="center">

### ArmasVIP
**Persistent ownership. Server authority. Premium presentation.**

</div>
