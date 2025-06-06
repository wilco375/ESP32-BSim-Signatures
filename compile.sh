#!/bin/bash

# First run source ~/.platformio/penv/bin/activate
versions="3.0.0 3.2.1 3.3.0 5.0.0 6.3.1 6.4.0 6.6.0 6.8.0 6.11.0"
ghidra_dir="/opt/ghidra"
rebuild=0
if [ "$1" == "--rebuild" ]; then
  rebuild=1
fi
if [ ! -f platformio.ini ]; then
  echo "No platformio.ini found in current directory. Run this script in the root of the project."
  exit 1
fi

mkdir -p dist/firmware 2>/dev/null
for version in $versions; do
  if [ -f dist/firmware-$version.elf ] && [ $rebuild -eq 0 ]; then
    continue
  fi

  sed -Ei "s/platform = espressif32(@[0-9]+\.[0-9]+\.[0-9]+)?/platform = espressif32@$version/" platformio.ini
  platformio run --environment esp-wrover-kit

  attempts=0
  while [ $attempts -lt 3 ]; do
    platformio run --environment esp-wrover-kit
    if [ -f .pio/build/esp-wrover-kit/firmware.elf ]; then
      break
    fi
    attempts=$((attempts + 1))
  done

  mv .pio/build/esp-wrover-kit/firmware.elf dist/firmware/firmware-$version.elf 2>/dev/null
done

$ghidra_dir/support/bsim createdatabase file://$(pwd)/dist/esp32-signatures medium_nosize

mkdir -p dist/ghidra 2>/dev/null
$ghidra_dir/support/analyzeHeadless $(pwd)/dist/ghidra esp32_libs -import $(pwd)/dist/firmware/*

$ghidra_dir/support/bsim generatesigs ghidra://$(pwd)/dist/ghidra/esp32_libs $(pwd)/dist/signatures --bsim file://$(pwd)/dist/esp32-signatures
$ghidra_dir/support/bsim commitsigs file://$(pwd)/dist/esp32-signatures $(pwd)/dist/signatures