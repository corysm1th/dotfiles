#!/usr/bin/env bash
#
# Display 256 xterm colors in structured columns:
#   - 16 system colors
#   - 216 color cube (6x6x6)
#   - 24 grayscale colors

# 1) System colors (0..15)
echo "System colors (0–15):"
for i in {0..15}; do
  printf "\e[48;5;%sm %3d \e[0m" "$i" "$i"
  # After printing 8 colors, break line
  if (( (i + 1) % 8 == 0 )); then
    echo
  fi
done
echo

# 2) Color cube (16..231)
#    The color cube is arranged as 6×6×6 for (Red,Green,Blue),
#    each ranging from 0..5. This gives 216 colors total.
echo "Color cube (16–231) in 6×6 blocks:"
for r in {0..5}; do
  echo "  Red = $r"
  for g in {0..5}; do
    for b in {0..5}; do
      i=$((16 + (r * 36) + (g * 6) + b))
      printf "\e[48;5;%sm %3d \e[0m" "$i" "$i"
    done
    echo  # new line after each row of 6
  done
  echo    # extra blank line after each red level block
done

# 3) Grayscale ramp (232..255)
echo "Grayscale ramp (232–255):"
for i in {232..255}; do
  printf "\e[48;5;%sm %3d \e[0m" "$i" "$i"
  # 24 grayscale colors -> print 6 per line
  if (( ((i - 232) + 1) % 6 == 0 )); then
    echo
  fi
done
echo

