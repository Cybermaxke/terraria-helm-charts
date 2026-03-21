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

## Versions
It is possible to override the Terraria or tShock version that needs to be installed by the chart,
overriding the version can be done using the following value:
```yaml
image:
  terraria:
    tag: tshock-1.4.5.6
```
By default, are tShock images used, using the vanilla image will restrict the usage of values 
that are tShock only. Some values may also not work with older/newer versions.

Image tags are formatted like:
```
vanilla-<terraria-version>
# tShock image with the latest supported version for the Terraria version
tshock-<terraria-version>
# tShock image with a specific version
tshock-<terraria-version>-<tshock-version>
```

The following table contains image tags that are compatible with the latest chart version:

| Terraria version | tShock version | Tags                                      |
|------------------|----------------|-------------------------------------------|
| 1.4.5.6          |                | `vanilla-1.4.5.6`                         |
| 1.4.5.6          | 6.1.0          | `tshock-1.4.5.6`, `tshock-1.4.5.6-6.1.0`  |
| 1.4.4.9          |                | `vanilla-1.4.4.9`                         |
| 1.4.4.9          | 5.2.4          | `tshock-1.4.4.9`, `tshock-1.4.4.9-5.2.4`  |
| 1.4.3.6          |                | `vanilla-1.4.3.6`                         |
| 1.4.3.6          | 4.5.16         | `tshock-1.4.3.6`, `tshock-1.4.3.6-4.5.16` |
| 1.4.2.3          |                | `vanilla-1.4.2.3`                         |
| 1.4.2.3          | 4.5.3          | `tshock-1.4.2.3`, `tshock-1.4.2.3-4.5.3`  |
