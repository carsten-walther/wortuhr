# Wortuhr — Build

**Another word clock**

This clock shows the time in words.

| ![Wortuhr Plate Model INES](img/Plate-INES-de.svg) _Image: Wortuhr Plate Model INES_ | ![Wortuhr Plate Model NINA](img/Plate-NINA-de.svg) _Image: Wortuhr Plate Model NINA_ | ![Wortuhr Plate Model MARIA](img/Plate-MARIA-de.svg) _Image: Wortuhr Plate Model MARIA_ |
|:---:|:---:|:---:|

For operating the finished clock see [README.md](README.md).

## Table of contents

- [Pick a front plate first](#pick-a-plate)
- [List of materials](#bom)
- [Wiring](#wiring)
- [Front plates and grids](#faces)
- [Flashing](#flashing)

## <a name="pick-a-plate"></a>Pick a front plate first

The plate decides the LED count, and the firmware is written for one of them:

| Plate | Words | LEDs | Has `GENAU` | Works with `wortuhr.yaml` as-is |
|---|--:|--:|:---:|:---:|
| INES | 21 | **25** | yes | **yes** |
| NINA | 20 | 24 | no | no |
| MARIA | 20 | 24 | no | no |

Building NINA or MARIA means editing `wortuhr.yaml`: `NUMBER_OF_LEDS`, and the
constant block at the top of the `Time` effect that maps each word to its
position in the chain. Those two have to agree with how you actually wire the
chain — the map is the wiring order, not a preference.

The rest of this page assumes **INES**.

## <a name="bom"></a>List of materials

| Amount | Item | Notes |
|--:|---|---|
| 1 | ESP32-C3 DevKitM-1 | Any C3 board works; `board:` in the config may need changing |
| 25 | WS2811 addressable LEDs | One per word and minute dot |
| 1 | DS1307 RTC module | I²C, address `0x68`, with a coin cell fitted |
| 1 | 5 V power supply | Sized for the strip |
| 1 | Image frame 20×20 cm | e.g. IKEA Ribba |
| — | Diffuser sheet | Between grid and plate |

The strip is the whole power budget worth thinking about: 25 WS2811 at full
white draw on the order of an amp between them. At the default 70 % brightness
with only a few words lit at a time the real figure is far lower, but the
supply should cover the worst case rather than the average.

## <a name="wiring"></a>Wiring

```
ESP32-C3 DevKitM-1        WS2811 chain          DS1307 module
──────────────────        ────────────          ─────────────
GPIO10 ────────────────── DIN
GPIO8  ─────────────────────────────────────────  SDA
GPIO9  ─────────────────────────────────────────  SCL
3V3    ─────────────────────────────────────────  VCC
GND    ────────────────── GND ──────────────────  GND
5V ────────────────────── +5V
```

Three things that will cost you an evening if you skip them:

**`GPIO8` and `GPIO9` are strapping pins.** ESPHome prints a warning about them
on every build, and it is right to. They are usable here only because the
DS1307 breakout carries its own I²C pull-ups, which hold both high while the
chip comes out of reset. Put a pull-down on either one — or use a breakout
without pull-ups — and the board comes up in the ROM bootloader instead of in
the firmware.

**The data line is marginally out of spec.** The strip runs on 5 V, the ESP32-C3
drives 3.3 V, and a WS2811 wants a logic high above 0.7 × VDD = 3.5 V. It works
on most batches. When it does not, the symptom is specific: the **first** LED
flickers or shows a wrong colour while the rest of the chain is fine. A level
shifter on the data line fixes it.

**Fit the DS1307's coin cell.** Without it the RTC is pointless — the clock
would come up blank after every power cut until the network is available.

## <a name="faces"></a>Front plates and grids

Per face, under [`../builds/faces`](../builds/faces):

| File | What |
|---|---|
| `<face>/plate/DE/Plate <FACE> (de).svg` | Front plate, for laser cutting |
| `<face>/plate/DE/Plate <FACE> (de).eps` | Same, EPS |
| `<face>/plate/DE/Plate <FACE> (de).pdf` | Same, PDF — the one to print for a check |
| `<face>/grid/DE/Grid.scad` | Light grid, OpenSCAD |

So for INES: [`../builds/faces/ines/plate/DE`](../builds/faces/ines/plate/DE)
and [`../builds/faces/ines/grid/DE`](../builds/faces/ines/grid/DE).

The grid is what keeps one lit word from bleeding into its neighbours. Without
it — or without a diffuser between grid and plate — individual LEDs show as
bright dots through the letters instead of an evenly lit word.

> **`Grid.scad` does not render as it stands.** It is a six-line wrapper that
> extrudes `Grid.svg` from the same directory, and that SVG is not in this
> repository for any of the three faces. Either supply a `Grid.svg` matching
> your plate, or build the grid another way.

The SVGs under [`img/`](img) are preview copies for these pages. Cut from the
files under `builds/faces`, not from those.

## <a name="flashing"></a>Flashing

Needs a `secrets.yaml` next to `wortuhr.yaml`; the keys are listed in the
[project README](../README.md#installation).

```sh
esphome run wortuhr.yaml
```

First flash over USB, everything after that over the air. Bump `version:` in
`substitutions:` when you change something — the `Firmware Version` entity is
what tells you whether an update actually took.

Wire and test the electronics **before** the panel goes into the frame. Once
the plate is glued in, the boot rainbow is the only diagnostic left.
