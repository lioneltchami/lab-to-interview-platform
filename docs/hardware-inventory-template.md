# Durable Lab Hardware Inventory Template

**Status:** Template — do not treat as completed inventory
**Purpose:** Capture only the equipment facts needed to choose the Phase 3 durable-cluster profile.
**Public repository rule:** Do not add serial numbers, exact private addresses, Wi-Fi credentials, router administration screenshots, warranty codes, MAC addresses, or physical-address details.

## How to use this template

Create a private operator copy of this document and complete it from the actual equipment. Commit only a sanitized summary if it is sufficient for a reader to understand the topology. The Phase 3 durable bootstrap is blocked until every required item is known or explicitly marked unavailable.

## Inventory summary

| Item | Value | Required before bootstrap? | Notes |
|---|---|---:|---|
| Selected profile | `D1` single control plane / `D2` three-control-plane HA / other | Yes | State the claim the lab will make and the claims it will not make. |
| Operator and recovery contact | Private operator record reference only | Yes | Do not publish names or contact details. |
| Private management network available | Yes / No | Yes | State only whether a private path exists, not its addressing. |
| Dedicated wired network path available | Yes / No | Yes | Record if links are shared with general client traffic. |
| Stable power / recovery procedure | Yes / No | Yes | State whether a safe shutdown and restart path exists. |
| Hardware reimage authorization | Yes / No | Yes | The system disk will be erased during Talos installation. |
| Public exposure required | No by default | Yes | Any `Yes` requires a separate approved ADR and threat-model update. |

## Node worksheet

Repeat this table once for each candidate node. Use the internal asset label rather than identifying device information.

| Field | Required value | Example format |
|---|---|---|
| Internal node label | A non-sensitive short label | `cp-01` or `worker-01` |
| Intended role | Control plane, worker, or undecided | `control-plane` |
| CPU architecture | Hardware architecture | `amd64` or `arm64` |
| CPU capacity | Core count and model class | `4 cores` |
| Memory | Installed RAM | `16 GiB` |
| System disk | Capacity, medium, and reimage status | `512 GiB NVMe; reimage approved` |
| Additional storage | Capacity and purpose, if any | `none` or `2 TiB SSD; future Phase 4 only` |
| Network | Wired link capability and interface discovery status | `wired; interface verified privately` |
| Firmware and boot mode | Verified and any required change | `UEFI verified` |
| Power and physical recovery | High-level recovery method | `local console available` |
| Existing use | Whether migration is authorized | `dedicated to lab` |
| Talos compatibility check | Result and source of check | `pending` |
| Risks or exceptions | Facts that affect selection | `shared power circuit` |

## Network and endpoint worksheet

Keep actual values in a private operator record. Commit a sanitized topology description only.

| Design item | Private operator record | Public repository statement |
|---|---|---|
| Management segment | Exact address range, gateway, and DNS | A private management path exists. |
| Node addresses | Exact DHCP reservations or static addresses | Nodes have stable private addressing. |
| Control-plane endpoint | Exact DNS name or load-balancer address | D1 uses one private endpoint; D2 must document an endpoint that reaches each control-plane node. |
| Pod and Service CIDRs | Actual selected ranges | Ranges were chosen to avoid overlap with the local network. |
| External exposure | Firewall, NAT, and domain facts | No public exposure unless an explicit ADR states otherwise. |
| Break-glass path | Local console and authorized recovery procedure | A documented non-public recovery path exists. |

## Phase 3 selection gate

| Gate | D1 single-control-plane durable learning environment | D2 three-member HA control plane |
|---|---|---|
| Node count | One Talos-capable, reimageable durable node | Three equivalent, independently recoverable control-plane nodes |
| API endpoint | One private endpoint is acceptable | An endpoint that can reach all control-plane nodes is required |
| Availability claim | No HA claim | One control-plane member failure tolerance is tested |
| Storage claim | No durability claim for application state | Separate storage design and tests still required before stateful durability claims |
| Required evidence | Inventory, bootstrap record, node health, private access verification | D1 evidence plus endpoint test, etcd member health, and one-node failure exercise |

## Sign-off

| Decision | Owner statement | Date |
|---|---|---|
| Profile selected |  |  |
| Reimage authorization verified |  |  |
| Private network plan reviewed |  |  |
| Public-exposure boundary reaffirmed |  |  |
| Ready to create private Talos credentials |  |  |
