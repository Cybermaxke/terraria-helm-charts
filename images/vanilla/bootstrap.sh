#!/bin/bash

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
  cp "$config" "/terraria-server/tmp/serverconfig.txt"
fi

config="/terraria-server/tmp/serverconfig.txt"
touch "$config"

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

# Since 1.4.5, the autocreate flag is required when generating a new world

# Extract autocreate arg
autocreate=$(echo "$args" | pcregrep -o2 '(^|\s)(-autocreate\s+[^\s]+)')
if [ -n "$autocreate" ]; then
  args=$(echo "$args" | sed "s@$autocreate@@g")
  autocreate=$(echo "$autocreate" | pcregrep -o1 '\s+([^\s]+)$')
fi

# No autocreate is set through args, check the config
if [ -z "$autocreate" ] && [ -n "$config" ]; then
  echo "Check config autocreate"
  autocreate=$(cat "$config" | pcregrep -o1 '^(\s*autocreate\s*=\s*[^\s]+)')
  if [ -n "$autocreate" ]; then
    autocreate=$(echo "$autocreate" | pcregrep -o1 '=\s*([^\s]+)')
  fi
fi

if [ -z "$autocreate" ]; then
  echo "Fallback to default autocreate (3: large)"
  autocreate="3"
fi

args="$args -autocreate $autocreate"

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

# World directory doesn't start with / so put it relative to the workdir
if [ -z "$(echo "$worldpath" | pcregrep '/$')" ]; then
  worldpath="/home/terraria/server/$worldpath"
fi

if [ -n "$world" ]; then
  # Check if the path is absolute, if not, set it relative to the world directory
  if [ -z "$(echo "$world" | pcregrep '^/')" ]; then
    args="$args -world $worldpath$world"
  else
    args="$args -world $world"
  fi
fi

echo "worldpath=$worldpath" >> "$config"
args="$args -config $config"

if command -v mono >/dev/null 2>&1; then
  cmd="mono --server --gc=sgen -O=all /terraria-server/TerrariaServer.exe"
else
  cmd="/terraria-server/TerrariaServer.bin.x86_64"
fi

_term() {
  echo "SIGTERM/SIGINT received, shutting down server..."
  # Send 'exit' command to stdin if available, this will save and exit
  echo "exit" >&4 2>/dev/null || true
  # Wait for the server to exit
  wait $server_pid
  exit 0
}

trap _term SIGTERM SIGINT

live=/home/terraria/server/live
# Create dedicated file descriptor for server stdin
exec 4<> <(:)
$cmd $args > >(while IFS= read -r line; do
  case "$line" in
    *"Listening on port "[0-9]*)
      [ -f $live ] || touch $live
      ;;
  esac
  printf '%s\n' "$line"
done) 2>&1 <&4 &
server_pid=$!

wait $server_pid
