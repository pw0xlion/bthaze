# bthaze

Bluetooth BD address & identity spoofing tool for Linux.

## What it does
- Randomizes your Bluetooth MAC address
- Spoofs device name (e.g. "AirPods", "JBL Flip 6")
- Sets Class of Device to match the profile
- One command revert to original

## Requirements
- Linux with BlueZ (`bluetooth` package)
- `bdaddr` (from BlueZ tools or `bluez-hciutils`)
- `openssl`

## Usage
```
sudo ./bthaze.sh          # Spoof
sudo ./bthaze.sh --revert # Restore original
```

# ⚠️ WARNING

> **THIS TOOL IS FOR LEGAL AND EDUCATIONAL PURPOSES ONLY.**
>
> **The author is NOT responsible for any misuse, unauthorized access,
> or unethical behavior resulting from the use of this tool.**
>
> Device names referenced (AirPods, JBL, Logitech, etc.) are trademarks
> of their respective owners and are used for identification purposes only.
>
> **Unauthorized use may violate local laws.**
> You are solely responsible for your own actions.   
