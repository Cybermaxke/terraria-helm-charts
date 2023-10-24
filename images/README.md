# Images

The docker images as based on [ryshe/terraria](https://github.com/ryansheehan/terraria) but come 
with a few improvements.
- A `terraria` user and group (`1000:1000`), which must be used to run the server instead of root
- Consistent mounting points, all necessary files and directories should now be located in 
  `/home/terraria/server`. The following subdirectories are available:
  - `worlds` - where worlds are stored by default, unless a different `-worldpath`
  - `logs` - where tshock logs are stored by default, unless a different `-logpath`
  - `plugins` - where tshock plugins are stored
  - `config` - where tshock config files are stored
  - `tshock` - where tshock plugins store things?
- The `-worldpath` and `-world` options now work consistently for vanilla and tshock images

## Notes

The helm charts expect images with these modifications and will not work properly otherwise.

## Examples
```
docker build images/tshock-4 --tag ghcr.io/cybermaxke/terraria:tshock-1.4.3.6  --build-arg TERRARIA_VERSION=1.4.3.6 --build-arg TSHOCK_VERSION=4.5.18
docker build images/tshock-5 --tag ghcr.io/cybermaxke/terraria:tshock-1.4.4.9  --build-arg TERRARIA_VERSION=1.4.4.9 --build-arg TSHOCK_VERSION=5.2.0
docker build images/vanilla  --tag ghcr.io/cybermaxke/terraria:vanilla-1.4.4.9 --build-arg TERRARIA_VERSION=1.4.4.9
docker build images/tools    --tag ghcr.io/cybermaxke/tools:latest
```
