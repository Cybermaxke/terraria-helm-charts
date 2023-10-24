#!/bin/sh

# Copy the plugins to where tshock loads them from
if [ "$(ls -A /home/terraria/server/plugins)" ]; then
  cp /home/terraria/server/plugins/* /tshock/ServerPlugins/
fi

# Capture the args first and then pass them to the command, directly using "$@" ignores them
# shellcheck disable=SC2116
args=$(echo "$@")
echo "Running server with command flags: $args"

# Workaround worldpath being ignored and not defaulting to /home/terraria/server/worlds

config=$(echo "$args" | pcregrep -o2 '(^|\s)(-config\s+[^\s]+)')
# Copy the config so we can modify it
if [ -n "$config" ]; then
  args=$(echo "$args" | sed "s@$config@@g")
  config=$(echo "$config" | pcregrep -o1 '\s+([^\s]+)$')
  cp "$config" "/tshock/tmp/serverconfig.txt"
  config="/tshock/tmp/serverconfig.txt"
fi

# Extract world arg
world=$(echo "$args" | pcregrep -o2 '(^|\s)(-world\s+[^\s]+)')
if [ -n "$world" ]; then
  args=$(echo "$args" | sed "s@$world@@g")
  world=$(echo "$world" | pcregrep -o1 '\s+([^\s]+)$')
fi

# No world is set through args, check the config
if [ -z "$world" ] && [ -n "$config" ]; then
  echo "Check config world"
  world=$(cat "$config" | pcregrep -o1 '^(\s*world\s*=\s*[^\s]+)')
  if [ -n "$world" ]; then
	  sed -i "s@$world@@g" "$config"
    world=$(echo "$world" | pcregrep -o1 '=\s*([^\s]+)')
  fi
fi

worldpath=$(echo "$args" | pcregrep -o2 '(^|\s)-worldpath\s+([^\s]+)')
# No world directory is set through args, check the config
if [ -z "$worldpath" ] && [ -n "$config" ]; then
  echo "Check config worldpath"
  worldpath=$(cat "$config" | pcregrep -o1 '^(\s*worldpath\s*=\s*[^\s]+)')
  if [ -n "$worldpath" ]; then
    sed -i "s@$worldpath@@g" "$config"
    worldpath=$(echo "$worldpath" | pcregrep -o1 '=\s*([^\s]+)')
  fi
fi

# Default world directory
if [ -z "$worldpath" ]; then
  echo "Fallback to default worldpath"
  worldpath="/home/terraria/server/worlds"
fi

# World directory doesn't end with / so add it
if [ -z "$(echo "$worldpath" | pcregrep '/$')" ]; then
  worldpath="$worldpath/"
fi

if [ -n "$world" ]; then
  # Check if the path is absolute, if not, set it relative to the world directory
  if [ -z "$(echo "$world" | pcregrep '^/')" ]; then
    args="$args -world $worldpath$world"
  else
    args="$args -world $world"
  fi
fi

# Add new config
if [ -n "$config" ]; then
  args="$args -config $config"
fi

# Default configpath
if [ -z "$(echo "$args" | pcregrep -o2 '(^|\s)-configpath\s+([^\s]+)')" ]; then
  args="$args -configpath /home/terraria/server/config"
fi

# Default logpath
if [ -z "$(echo "$args" | pcregrep -o2 '(^|\s)-logpath\s+([^\s]+)')" ]; then
  args="$args -logpath /home/terraria/server/logs"
fi

echo "ARGS: $args"
if [ -e "$config" ]; then
  cat "$config"
fi
ls -al /home/terraria/server

# shellcheck disable=SC2086
mono --server --gc=sgen -O=all /tshock/TerrariaServer.exe $args | \
while read line; do \
  echo $line | \
  grep -v "127\.0\.0\.1:[0-9]* is connecting\.\.\." | \
  grep -v "127\.0\.0\.1:[0-9]* was booted: You are not using the same version as this server\."; \
done
