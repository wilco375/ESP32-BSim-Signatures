# ESP32 Ghidra BSim Signatures
This repo contains a BSim signature database for ESP32 ESP-IDF libraries, and the source code to generate it.  
The signature database also contains commonly used functions such as WiFi, Bluetooth and MQTT-related functions. It can be used with BSim to find standard ESP32 functions within compiled firmware without symbols.

Signature database: `dist/signatures.mv.db`  
ELF files used for signature database: `dist/firmware/firmware-<pio-espressif-version>.elf`

## Generating signatures database
1. Install PlatformIO
2. Activate PlatformIO venv, e.g. `source ~/.platformio/penv/bin/activate`
3. Optionally, update downloaded espressif versions in `compile.sh`
4. Run `bash compile.sh`
5. The generated files can now be found in `dist/`

## Using the signature database
1. Start Ghidra
2. Open an ESP32 firmware image and analyze it
3. Go to File -> Configure, and enable BSim
4. Go to BSim -> Manage Servers and add the file `dist/esp32-signatures.mv.db`
5. Go to a suspected ESP-IDF function, and Right Click -> BSim -> Search Function(s)... (you can also select and search for multiple functions at once), select the esp32-signatures.mv.db database, optionally adjust the similarity threshold and search
6. If a matching function is found, apply it with Right Click -> Apply Signature and Data Types