# Wortuhr — Operation

**Another word clock**

This clock shows the time in words.

| ![Wortuhr Plate Model INES](img/Plate-INES-de.svg) _Image: Wortuhr Plate Model INES_ | ![Wortuhr Plate Model NINA](img/Plate-NINA-de.svg) _Image: Wortuhr Plate Model NINA_ | ![Wortuhr Plate Model MARIA](img/Plate-MARIA-de.svg) _Image: Wortuhr Plate Model MARIA_ |
|:---:|:---:|:---:|

For the hardware see [BUILD.md](BUILD.md); for how the firmware works see the
[project README](../README.md).

## Table of contents

- [Establish network connection](#establish-network-connection)
- [Operating the clock](#operating-the-clock)
    - [Colour and brightness](#colour-and-brightness)
    - [Effects](#effects)
    - [Dialects](#dialects)
    - [Home Assistant and MQTT](#home-assistant-and-mqtt)
- [Settings](#settings)
    - [Time zone and daylight saving](#time-zone-and-daylight-saving)
    - [Switching off at night](#switching-off-at-night)
    - [Buttons](#buttons)
- [What the panel tells you while booting](#what-the-panel-tells-you-while-booting)

## <a name="establish-network-connection"></a>Establish network connection

The WLAN credentials are compiled into the firmware from `secrets.yaml`, so a
clock flashed for your network joins it by itself on first power-up. There is
nothing to configure by hand in the normal case.

The fallback access point is for the case where it cannot:

- Connect the clock to the power supply.
- If no known WLAN is in range, the clock opens an access point named
  **`wortuhr`**.
- Join it from a phone, tablet or PC. The password is the one set as
  `wifi_ap_password` in `secrets.yaml` — **not** a fixed default.
- A captive portal opens by itself. Enter the local WLAN and its password
  there.

_The access point comes up whenever the station side cannot connect, and goes
away again once it can._

## <a name="operating-the-clock"></a>Operating the clock

Everything is reachable three ways: the built-in web interface, Home Assistant,
and MQTT.

For the web interface, connect to **[wortuhr.local](http://wortuhr.local)**. Over
the fallback access point the address is `http://192.168.4.1` instead.

The page asks for a username and password — the `web_username` and
`web_password` set in `secrets.yaml`. Without them the Factory Reset button
would be one click away for anyone on the network.

### <a name="colour-and-brightness"></a>Colour and brightness

The entity is called **LED Color**. A colour picker sets the colour of the lit
words and a slider sets brightness from 0 % to 100 %.

Two things differ from what you might expect:

- **There is no background colour.** Words that are not part of the current
  time are off, not painted in a second colour.
- **Every boot resets colour and brightness** to white at 70 %. Switching the
  panel off and on again keeps your setting; a restart or a power cut does not.

There is no ambient light sensor, so brightness never adjusts itself.

Note that 70 % here drives the LEDs at 70 %, not at the roughly 37 % a
perceptual dimming curve would give. The curve is switched off so the fading
effects do not lose their dark end, which makes every setting read brighter
than it would on an ordinary lamp.

### <a name="effects"></a>Effects

The light offers six effects:

| Effect | What it is |
|---|---|
| **Time** | The clock. This is the one it runs on |
| Rainbow | The boot indicator: shown until the clock joins the WLAN |
| Color Wipe | Walks the chain one LED at a time — how you find a dead one |
| Fireworks | Decoration |
| Twinkle | Decoration |
| Random Twinkle | Decoration, each spark in its own colour |

Switching the panel off and on again always puts `Time` back on it, so a test
pattern or a decoration cannot be left running by accident.

Turning the panel on **and naming an effect in the same command** keeps that
effect — Home Assistant's "turn on with effect Fireworks" works. Only a plain
switch-on gets normalised back to `Time`.

### <a name="dialects"></a>Dialects

The front plate is German. The **Mode** entity picks which German:

| Mode | 14:15 | 14:45 |
|---|---|---|
| Hochdeutsch | `VIERTEL NACH ZWEI` | `VIERTEL VOR DREI` |
| Bayrisch | `VIERTEL NACH ZWEI` | `DREIVIERTEL DREI` |
| Schwäbisch | `VIERTEL DREI` | `DREIVIERTEL DREI` |
| Sächsisch | `VIERTEL DREI` | `DREIVIERTEL DREI` |

Sächsisch also counts twenty past and twenty to around the half hour:
`ZEHN VOR HALB` and `ZEHN NACH HALB` where the others say `ZWANZIG NACH` and
`ZWANZIG VOR`.

The choice survives a restart.

### <a name="home-assistant-and-mqtt"></a>Home Assistant and MQTT

The clock talks to Home Assistant over the native ESPHome API, encrypted, and
to an MQTT broker at the same time.

MQTT discovery is switched off on purpose: every entity is already adopted
through the API, and leaving discovery on would create a second, duplicate set
of entities in Home Assistant.

## <a name="settings"></a>Settings

### <a name="time-zone-and-daylight-saving"></a>Time zone and daylight saving

The clock gets its time from NTP and keeps it in a battery-backed DS1307, so it
is right again immediately after a power cut even with no network.

The time zone is fixed to `Europe/Berlin` in the firmware, and the daylight
saving changeover is handled automatically. **There is no time zone or DST
setting to change** — a different zone means editing `timezone:` in
`wortuhr.yaml` and reflashing.

### <a name="switching-off-at-night"></a>Switching off at night

There is no on/off schedule on the device. Turn the **LED Color** entity off
with a Home Assistant automation, or from the web interface by hand.

The clock keeps running while the panel is dark — it is the LEDs that are off,
not the timekeeping.

### <a name="buttons"></a>Buttons

| Button | Does |
|---|---|
| **Restart** | Ordinary reboot |
| **Restart (Safe Mode)** | Reboots into a firmware with WiFi and OTA only. The way back in if an update leaves the clock crashing |
| **Factory Reset** | Wipes the stored WLAN credentials **and** the selected dialect, and comes back on the fallback access point. This is the "give it away" button, not the "it is behaving oddly" one |

## <a name="what-the-panel-tells-you-while-booting"></a>What the panel tells you while booting

The panel is the only thing this clock can say anything with, so it reports its
own start-up:

1. A **rainbow** means the firmware is running and it has not joined the WLAN
   yet.
2. The **time appearing** means it is on the network — or that ten seconds have
   passed and the clock took over anyway.

So a rainbow that clears in a second or two is a normal start-up. A rainbow
that runs the full ten seconds every time means the clock is not reaching the
WLAN, and it will then show the time regardless — from the DS1307, which is
right whether or not there is a network. Check `Connection Status` and `SSID`
to tell the two apart.

A panel that stays dark from the start is a power or wiring problem — see
[BUILD.md](BUILD.md).
