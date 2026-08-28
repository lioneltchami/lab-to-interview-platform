# Talos Configuration Boundary

This directory contains **reviewable templates and non-secret patches only**. It is not a backup location and must never contain a generated Talos secrets bundle, `talosconfig`, kubeconfig, machine configuration with real endpoint data, private keys, actual node addresses, router details, or configuration copied from another lab.

## Repository contract

| May be committed | Must remain outside Git |
|---|---|
| Version-pinned, reviewed configuration templates with placeholders | `secrets.yaml`, `talosconfig`, kubeconfig, Age keys, and any generated credentials |
| Generic CNI bootstrap patches and explanatory documentation | Actual management addresses, machine interface names, installation disk names, and cluster endpoint values |
| Sanitized topology diagrams and documented decision criteria | Device identifiers, serial numbers, MAC addresses, Wi-Fi data, router exports, and physical-site details |
| Test manifests that contain no credential material | Bootstrap artifacts or recovery media containing cluster state |

## Workflow

1. Complete a private hardware and network inventory from `docs/hardware-inventory-template.md`.
2. Select either the D1 single-control-plane profile or the D2 three-control-plane profile through an approved pull request.
3. Pin the Talos, Kubernetes, Cilium, and Flux versions in a reviewed design update.
4. Create an operator-local private configuration workspace outside this repository and restrict its filesystem permissions.
5. Generate Talos secrets and machine configuration only in that private workspace.
6. Review generated configuration for unintended values before applying it to a reimageable node.
7. Commit only sanitized evidence: command versions, redacted health output, manifest references, and a dated bootstrap record.

## Cilium dependency

The durable Talos cluster will use Cilium only after a user-approved version and installation method exist. Talos documents that a custom CNI choice must be reflected before bootstrap. The example patch in `patches/cni-none.example.yaml` expresses this pre-bootstrap dependency; it is not a complete machine configuration and it cannot be applied by itself. [1]

## Verification before use

Before any durable bootstrap, run the repository credential checks, review `git status`, and confirm that the intended generated files remain ignored. Do not bypass a failed secret check. Stop and investigate rather than editing policy checks to allow a sensitive file.

## Reference

[1]: https://docs.siderolabs.com/kubernetes-guides/cni/deploying-cilium "Talos Linux — Deploy Cilium CNI"
