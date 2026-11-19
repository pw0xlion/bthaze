#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

SAVEFILE="$HOME/.bthaze_orig"

# --- REVERT ---
if [[ "$1" == "--revert" ]]; then
    if [[ ! -f "$SAVEFILE" ]]; then
        echo -e "${RED}No saved state to revert.${RESET}"
        exit 1
    fi
    source "$SAVEFILE"
    echo -e "${YELLOW}Reverting to original...${RESET}"
    sudo bdaddr -i "$ORIG_HCI" -r "$ORIG_ADDR"
    sleep 4
    sudo hciconfig "$ORIG_HCI" up
    sudo hciconfig "$ORIG_HCI" name "$ORIG_NAME"
    sudo hciconfig "$ORIG_HCI" class "$ORIG_CLASS"
    rm -f "$SAVEFILE"
    echo -e "${GREEN}Reverted. Address: $ORIG_ADDR | Name: $ORIG_NAME${RESET}"
    exit 0
fi

# --- DETECT ACTIVE ADAPTER ---
ACTIVE=""
for hci in $(hciconfig -a 2>/dev/null | grep -oP '^hci\d+'); do
    if hciconfig "$hci" 2>/dev/null | grep -q "UP"; then
        ACTIVE="$hci"
        break
    fi
done

if [[ -z "$ACTIVE" ]]; then
    echo -e "${RED}No active Bluetooth adapter found.${RESET}"
    exit 1
fi

# Save original state
ORIG_ADDR=$(hciconfig "$ACTIVE" | grep 'BD Address' | awk '{print $3}')
ORIG_NAME=$(hciconfig "$ACTIVE" | grep "Name:" | sed "s/.*'\(.*\)'.*/\1/")
ORIG_CLASS=$(hciconfig "$ACTIVE" | grep 'Class:' | awk '{print $2}')
ORIG_HCI="$ACTIVE"

echo -e "${CYAN}==========================================${RESET}"
echo -e "${CYAN}  bthaze — BD Address Spoofing${RESET}"
echo -e "${CYAN}==========================================${RESET}"
echo -e "${BOLD}Target adapter :${RESET} $ACTIVE"
echo -e "${BOLD}Current address:${RESET} $ORIG_ADDR"
echo -e "${BOLD}Current name   :${RESET} $ORIG_NAME"
echo -e "${BOLD}Current class  :${RESET} $ORIG_CLASS"
echo ""
echo -e "${YELLOW}What device do you want to spoof as?${RESET}"
echo -e "  ${GREEN}1)${RESET} AirPods / Headphones   (0x5a020c)  → \"AirPods\""
echo -e "  ${GREEN}2)${RESET} Bluetooth Speaker      (0x5a040c)  → \"JBL Flip 6\""
echo -e "  ${GREEN}3)${RESET} Keyboard               (0x0c0420)  → \"Logitech K380\""
echo -e "  ${GREEN}4)${RESET} Mouse                  (0x0c0418)  → \"Logitech M185\""
echo -e "  ${GREEN}5)${RESET} Cell Phone             (0x271204)  → \"iPhone 15 Pro\""
echo -e "  ${GREEN}6)${RESET} Laptop                 (0x7c0100)  → \"MacBook Pro\""
read -p "Choice: " profile

case "$profile" in
  1) COD="0x5a020c"; DEV="AirPods / Headphones"; BTNAME="AirPods" ;;
  2) COD="0x5a040c"; DEV="Bluetooth Speaker";    BTNAME="JBL Flip 6" ;;
  3) COD="0x0c0420"; DEV="Keyboard";             BTNAME="Logitech K380" ;;
  4) COD="0x0c0418"; DEV="Mouse";                BTNAME="Logitech M185" ;;
  5) COD="0x271204"; DEV="Cell Phone";           BTNAME="iPhone 15 Pro" ;;
  6) COD="0x7c0100"; DEV="Laptop";              BTNAME="MacBook Pro" ;;
  *)  COD="0x7c0100"; DEV="Laptop";              BTNAME="MacBook Pro" ;;
esac

NEW=$(openssl rand -hex 6 | fold -w2 | paste -sd: - | tr 'a-z' 'A-Z')

echo ""
echo -e "${BOLD}Will apply:${RESET}"
echo -e "  ${GREEN}New address :${RESET} $NEW"
echo -e "  ${GREEN}New name    :${RESET} $BTNAME"
echo -e "  ${GREEN}New class   :${RESET} $COD ($DEV)"
echo ""
echo -e "${RED}WARNING: This is address spoofing. Use for legal${RESET}"
echo -e "${RED}and educational purposes only.${RESET}"
echo -e "${CYAN}==========================================${RESET}"
read -p "Proceed? (y/n) " confirm
[[ "$confirm" == "y" ]] || { echo -e "${RED}Aborted.${RESET}"; exit 1; }

# Save original for revert
echo "ORIG_HCI='$ORIG_HCI'" > "$SAVEFILE"
echo "ORIG_ADDR='$ORIG_ADDR'" >> "$SAVEFILE"
echo "ORIG_NAME='$ORIG_NAME'" >> "$SAVEFILE"
echo "ORIG_CLASS='$ORIG_CLASS'" >> "$SAVEFILE"

# Apply address (bdaddr needs bluetoothd running)
sudo bdaddr -i "$ACTIVE" -r "$NEW"

# Wait for chip reset + bluetoothd to re-initialize the adapter
sleep 4
sudo hciconfig "$ACTIVE" up

# Apply name and class (after bluetoothd has finished init)
sudo hciconfig "$ACTIVE" name "$BTNAME"
sudo hciconfig "$ACTIVE" class "$COD"

echo -e "${GREEN}Done.${RESET}"
echo -e "  ${GREEN}Address: $NEW${RESET}"
echo -e "  ${GREEN}Name   : $BTNAME${RESET}"
echo -e "  ${GREEN}Class  : $COD ($DEV)${RESET}"
echo ""
echo -e "${YELLOW}Revert anytime with: $0 --revert${RESET}"   
