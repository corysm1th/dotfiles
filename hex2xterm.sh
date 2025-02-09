#!/usr/bin/env bash

# ------------------------------------------------------------------------------
# Converts a given #RRGGBB (hex) color into the closest xterm-256 color index.
#
# Usage:
#   ./hex2xterm.sh "#ff00ff"
#   ./hex2xterm.sh ff00ff
# ------------------------------------------------------------------------------

# 1. Parse input
if [ -z "$1" ]; then
  echo "Usage: $0 #RRGGBB or RRGGBB" >&2
  exit 1
fi

# Remove leading '#' if present
INPUT="${1#\#}"

# Ensure we have exactly 6 hex digits
if [[ ! "$INPUT" =~ ^[0-9A-Fa-f]{6}$ ]]; then
  echo "Error: Input must be 6 hex characters (e.g. ff00ff or #ff00ff)" >&2
  exit 1
fi

# Convert hex -> decimal R, G, B
R=$((16#${INPUT:0:2}))
G=$((16#${INPUT:2:2}))
B=$((16#${INPUT:4:2}))

# ------------------------------------------------------------------------------
# 2. Define a function to get the (R, G, B) for each xterm-256 color code (0-255).
# ------------------------------------------------------------------------------

xterm2rgb() {
  local c="$1"
  local r g b

  if [ "$c" -lt 16 ]; then
    # The 16 standard xterm colors
    case $c in
      0)  r=0   ; g=0   ; b=0   ;;  # black
      1)  r=128 ; g=0   ; b=0   ;;  # red
      2)  r=0   ; g=128 ; b=0   ;;  # green
      3)  r=128 ; g=128 ; b=0   ;;  # yellow
      4)  r=0   ; g=0   ; b=128 ;;  # blue
      5)  r=128 ; g=0   ; b=128 ;;  # magenta
      6)  r=0   ; g=128 ; b=128 ;;  # cyan
      7)  r=192 ; g=192 ; b=192 ;;  # white (light gray)
      8)  r=128 ; g=128 ; b=128 ;;  # bright black (gray)
      9)  r=255 ; g=0   ; b=0   ;;  # bright red
      10) r=0   ; g=255 ; b=0   ;;  # bright green
      11) r=255 ; g=255 ; b=0   ;;  # bright yellow
      12) r=0   ; g=0   ; b=255 ;;  # bright blue
      13) r=255 ; g=0   ; b=255 ;;  # bright magenta
      14) r=0   ; g=255 ; b=255 ;;  # bright cyan
      15) r=255 ; g=255 ; b=255 ;;  # bright white
    esac
  elif [ "$c" -lt 232 ]; then
    # The 6x6x6 color cube
    local c2=$((c - 16))  # 0 to 215
    r=$(( (c2 / 36) * 51 ))         # Each of the 6 steps is 0,1,2,3,4,5 => times 51 => 0..255
    g=$(( ((c2 % 36) / 6) * 51 ))
    b=$(( (c2 % 6) * 51 ))
  else
    # The grayscale ramp (232..255)
    # 232 -> 8; 255 -> 238 in steps of 10
    local c2=$((c - 232)) # 0..23
    local level=$((c2 * 10 + 8))
    r=$level
    g=$level
    b=$level
  fi

  echo "$r $g $b"
}

# ------------------------------------------------------------------------------
# 3. Find the closest color by Euclidean distance in RGB space
# ------------------------------------------------------------------------------

closest=-1
mindist=999999

for c in $(seq 0 255); do
  # Get this palette entry's R, G, B
  read -r rr gg bb <<< "$(xterm2rgb "$c")"

  # Compute distance^2 in RGB space
  dr=$((R - rr))
  dg=$((G - gg))
  db=$((B - bb))
  dist=$((dr * dr + dg * dg + db * db))

  # Update if this is closer
  if [ "$dist" -lt "$mindist" ]; then
    mindist="$dist"
    closest="$c"
  fi
done

# ------------------------------------------------------------------------------
# 4. Print the result
# ------------------------------------------------------------------------------

# Output the matched xterm index
echo "Input color: #$INPUT  => Closest xterm-256 color index: $closest"

# Show a small demonstration in the terminal
# Using ANSI escape sequences to color a text sample
echo -e "Preview: \033[48;5;${closest}m   \033[0m (background) or \033[38;5;${closest}mTEXT\033[0m (foreground)"

