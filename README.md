# Nature Mood

A simple bar widget for Omarchy that plays soothing background sounds.

Everything is bundled into the plugin itself to avoid needing to stream anything
<p align="center">
  <img src="preview.png" alt="Nature Mood preview" width="480">
</p>

## Features

- **12 bundled tracks** — CC0 nature recordings, re-encoded to 128 kbps / 48 kHz:
  rain, storm, thunderstorm, forest, birds, shoreline, beach, river, city,
  village, coffee-shop, restaurant
- **Cover-flow picker** — per-track icon art; ← / → browse, Space (or click)
  plays, clicking the playing track pauses
- **Smooth playback** — crossfade when switching tracks; fade out/in at the
  loop seam makes looping inaudible
- **Volume** — ↑ / ↓ adjusts, persisted across shell restarts
- **Keeps playing** — closing the picker leaves the mood running

## Install

```bash
omarchy plugin add https://github.com/woganmay/nature-mood.git --enable
```

## Usage

Click the stormcloud button in the bar to open the picker:

| Key | Action |
|---|---|
| ← / → | browse tracks (clamps at the ends) |
| Space | play / pause the selected track |
| ↑ / ↓ | volume |
| Esc | close the picker (playback continues) |

Clicking a cover selects *and* plays it; Space or a click on the playing
track pauses it (position kept).

## Configure

Move the widget to another bar section:

```bash
omarchy bar move woganmay.nature-mood --section right
```

`--section` accepts `left`, `center`, or `right`; add `--index <n>` to pin
an exact position.

## Remove

```bash
omarchy plugin remove woganmay.nature-mood
```

## Requirements

MP3 playback uses the shell's QtMultimedia stack with its ffmpeg backend —
bundled with Omarchy, nothing extra to install assuming you're running a recent
version of Omarchy.

## Attribution

Every track pairs a CC0 sound from [BigSoundBank](https://bigsoundbank.com)
with an icon from [Flaticon](https://www.flaticon.com). Full per-track
sources and licenses:

### Sounds

All sounds are CC0 (public domain) from
[BigSoundBank](https://bigsoundbank.com), downloaded from the direct MP3
pattern `https://bigsoundbank.com/UPLOAD/mp3/<id>.mp3` and re-encoded to
128 kbps / 48 kHz stereo. CC0 permits redistribution without attribution;
courtesy credit: *Additional sounds: Joseph SARDIN — BigSoundBank.com*

| Track | File | Sound | ID | Direct URL |
|---|---|---|---|---|
| rain | rain.mp3 | Summer Rain on Terrace | s1019 | https://bigsoundbank.com/UPLOAD/mp3/1019.mp3 |
| storm | storm.mp3 | Rain and Thunder #2 | s0740 | https://bigsoundbank.com/UPLOAD/mp3/0740.mp3 |
| thunderstorm | thunderstorm.mp3 | Rain and Thunder #4 | s2719 | https://bigsoundbank.com/UPLOAD/mp3/2719.mp3 |
| forest | forest.mp3 | Forest #2 | s1348 | https://bigsoundbank.com/UPLOAD/mp3/1348.mp3 |
| birds | birds.mp3 | Birds Waking #4 | s1906 | https://bigsoundbank.com/UPLOAD/mp3/1906.mp3 |
| shoreline | shoreline.mp3 | Small Waves and Beach #1 | s1446 | https://bigsoundbank.com/UPLOAD/mp3/1446.mp3 |
| beach | beach.mp3 | Small Waves Facing the Ocean | s1046 | https://bigsoundbank.com/UPLOAD/mp3/1046.mp3 |
| river | river.mp3 | Small Stream | s0823 | https://bigsoundbank.com/UPLOAD/mp3/0823.mp3 |
| city | city.mp3 | Aubervilliers Street | s2722 | https://bigsoundbank.com/UPLOAD/mp3/2722.mp3 |
| village | village.mp3 | Village, City Center #1 | s1346 | https://bigsoundbank.com/UPLOAD/mp3/1346.mp3 |
| coffee-shop | coffee-shop.mp3 | Coffee Shop at the Capucins | s2561 | https://bigsoundbank.com/UPLOAD/mp3/2561.mp3 |
| restaurant | restaurant.mp3 | Small Restaurant Conversations | s3542 | https://bigsoundbank.com/UPLOAD/mp3/3542.mp3 |

### Icons

Each track's cover (`images/<id>.svg`, 190×110, rounded corners) frames a
white glyph from [Flaticon](https://www.flaticon.com) on a light-to-dark
gradient of the track's primary color. Icons are used under the Flaticon
Free License (User License) — icon IDs 3238823, 3238822, 3238818, 1182902,
3421655, 5832939, 2383947, 2803248, 8207111, 78846, 701965, 14068466:
<https://www.flaticon.com/license/icons/3238823%2C3238822%2C3238818%2C1182902%2C3421655%2C5832939%2C2383947%2C2803248%2C8207111%2C78846%2C701965%2C14068466>.

| Track | File | Source | License |
|---|---|---|---|
| rain | rain.svg | [Flaticon](https://www.flaticon.com) | Flaticon Free (User License) |
| storm | storm.svg | [Flaticon](https://www.flaticon.com) | Flaticon Free (User License) |
| thunderstorm | thunderstorm.svg | [Flaticon](https://www.flaticon.com) | Flaticon Free (User License) |
| forest | forest.svg | [Flaticon](https://www.flaticon.com) | Flaticon Free (User License) |
| birds | birds.svg | [Flaticon](https://www.flaticon.com) | Flaticon Free (User License) |
| shoreline | shoreline.svg | [Flaticon](https://www.flaticon.com) | Flaticon Free (User License) |
| beach | beach.svg | [Flaticon](https://www.flaticon.com) | Flaticon Free (User License) |
| river | river.svg | [Flaticon](https://www.flaticon.com) | Flaticon Free (User License) |
| city | city.svg | [Flaticon](https://www.flaticon.com) | Flaticon Free (User License) |
| village | village.svg | [Flaticon](https://www.flaticon.com) | Flaticon Free (User License) |
| coffee-shop | coffee-shop.svg | [Flaticon](https://www.flaticon.com) | Flaticon Free (User License) |
| restaurant | restaurant.svg | [Flaticon](https://www.flaticon.com) | Flaticon Free (User License) |

## License

- **Audio:** CC0 (public domain) — see the sound table above
- **Icons:** Flaticon Free License (User License) — see the icon table above
- **Code:** MIT — see [LICENSE](LICENSE)
