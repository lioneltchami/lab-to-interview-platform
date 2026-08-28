# D1 Pre-Bootstrap Configuration Guide

**Profile:** Single-control-plane durable learning environment
**Status:** Prepared; blocked on actual hardware facts
**This is not an active cluster configuration.**

## Purpose

The D1 profile translates the approved platform decision into a small set of reviewable inputs before any device is erased or any private credential is created. It deliberately avoids a complete Talos machine configuration because that configuration must contain real hardware and network facts that do not belong in the public repository.

The file `bootstrap-input.example.yaml` is a project planning contract. It records the required design choices and placeholders. It must never be passed directly to Talos tooling.

## Required private inputs

| Input | Where it belongs | Why it is not public |
|---|---|---|
| Node address, gateway, resolver, and endpoint | Local private operator worksheet | These values map the private management plane. |
| Interface and installation-disk name | Local console discovery record | Incorrect guesses can interrupt network access or erase the wrong device. |
| Talos `secrets.yaml`, `talosconfig`, kubeconfig, and generated machine configuration | Restricted private workspace | They contain credentials and cluster-specific control-plane data. |
| Stable DHCP reservation details | Router and private operator record | They identify the local network and are configuration authority data. |
| Recovery-media or secure-storage location | Private recovery record | It must be accessible to the operator but not exposed publicly. |

## Review sequence

1. Complete the local `D1_OPERATOR_WORKSHEET.md` outside the repository.
2. Confirm that the device is wired, reimageable, and has enough capacity for the D1 profile.
3. Verify the hardware’s boot mode, detected network interface, and target installation disk directly from local console output.
4. Select exact compatible Talos, Kubernetes, Cilium, and Flux releases and add a version-pinned decision update for review.
5. Review the selected Cilium install method before generating any machine configuration; its CNI dependency must be reflected before bootstrap. [1]
6. Create the private workspace and generate configuration only after explicit reimage and credential-custody approval.
7. Apply configuration only to the verified target disk, bootstrap once, then verify the private API, CNI, Flux, Signalboard, Pod Security, and policy behavior in that order.

## Things this profile does not do

D1 does not claim high availability, add a second control plane, provide a public route, implement a VPN, create an identity system, run persistent application data, install Cilium yet, generate a SOPS key, or publish a container image. Each of those has a separate user-approval and evidence gate.

## Reference

[1]: https://docs.siderolabs.com/kubernetes-guides/cni/deploying-cilium "Talos Linux — Deploy Cilium CNI"
