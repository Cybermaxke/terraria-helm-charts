#!/bin/bash

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

cmd="mono --server --gc=sgen -O=all /tshock/TerrariaServer.exe"

_term() {
  echo "SIGTERM received, shutting down server..."
  # Shutdown the stdin copy process first
  kill $stdin_pid 2>/dev/null || true
  wait $stdin_pid 2>/dev/null || true
  # Send 'exit' command to server stdin if available, this will save and exit
  echo "exit" >&4 2>/dev/null || true
  # Wait for the server to exit
  wait $server_pid
  exit 0
}

trap _term SIGTERM
# Prevent Ctrl-C in the interactive shell from stopping the server
trap '' SIGINT

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

# Copy from stdin to the server stdin
cat <&0 >&4 &
stdin_pid=$!

wait $server_pid
