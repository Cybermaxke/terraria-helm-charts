# Terraria

This project provides helm charts that can be used to deploy your Terraria server to a kubernetes
cluster. TShock and vanilla servers are supported.

The charts are very WIP and are subject to change. As long as versions are `0.1.x`, breaking 
changes are possible, once the charts are stable proper releases will start from `1.x.x` where only
breakages are allowed in major versions.

## Usage

[Helm](https://helm.sh) must be installed to use the charts.
Please refer to Helm's [documentation](https://helm.sh/docs/) to get started.

Once Helm is set up properly, add the repo as follows:

```
helm repo add terraria https://www.seppevolkaerts.be/terraria-helm-charts/
```

You can then run `helm search repo terraria` to see the charts.