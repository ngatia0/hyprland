# 1. KILL & WIPE TELEGRAM (Official and X versions)
adb shell am force-stop org.telegram.messenger
adb shell am force-stop com.telegram.messenger
adb shell pm clear org.telegram.messenger

# 2. ROTATE HARDWARE IDENTIFIERS
# Generates a new random 16-char Hex Android ID
NEW_ID=$(openssl rand -hex 8)
adb shell settings put secure android_id $NEW_ID
echo "New Scoped Android ID set to: $NEW_ID"

# 3. DELETE GOOGLE ADS ID (Crucial for 2026 linking)
adb shell pm clear com.google.android.gms

# 4. REVOKE "FINGERPRINTING" PERMISSIONS
# These are the ones I saw in your list that "leak" your identity/location
adb shell pm revoke org.telegram.messenger android.permission.ACCESS_FINE_LOCATION
adb shell pm revoke org.telegram.messenger android.permission.ACCESS_COARSE_LOCATION
adb shell pm revoke org.telegram.messenger android.permission.NEARBY_WIFI_DEVICES
adb shell pm revoke org.telegram.messenger android.permission.BLUETOOTH_SCAN
adb shell pm revoke org.telegram.messenger android.permission.READ_PHONE_NUMBERS
adb shell pm revoke org.telegram.messenger android.permission.READ_PHONE_STATE

# 5. BLOCK RE-VANCED/MICROG LEAKS
# Telegram 2026 checks for these specific package signatures
adb shell pm revoke org.telegram.messenger app.revanced.org.microg.gms.EXTENDED_ACCESS

echo "Identity reset complete. Switch to Mobile Data now."
