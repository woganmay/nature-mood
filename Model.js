// Nature-mood sound catalog.
//
// Every track is CC0 (public domain) from BigSoundBank, re-encoded to
// 128 kbps 48 kHz for a lean plugin repo. Per-file sources and licenses
// are recorded in sounds/README.md, including the Flaticon cover icons in
// images/. All playback is local — no streaming.
var SOUNDS = [
  { id: "rain",         name: "Rain",            file: "rain.mp3",         image: "rain.svg" },
  { id: "storm",        name: "Storm",           file: "storm.mp3",        image: "storm.svg" },
  { id: "thunderstorm", name: "Thunderstorm",    file: "thunderstorm.mp3", image: "thunderstorm.svg" },
  { id: "forest",       name: "Forest",          file: "forest.mp3",       image: "forest.svg" },
  { id: "birds",        name: "Birds",           file: "birds.mp3",        image: "birds.svg" },
  { id: "shoreline",    name: "Shoreline",       file: "shoreline.mp3",    image: "shoreline.svg" },
  { id: "beach",        name: "Beach",           file: "beach.mp3",        image: "beach.svg" },
  { id: "river",        name: "River",           file: "river.mp3",        image: "river.svg" },
  { id: "city",         name: "City",            file: "city.mp3",         image: "city.svg" },
  { id: "village",      name: "Village",         file: "village.mp3",      image: "village.svg" },
  { id: "coffee-shop",  name: "Coffee Shop",     file: "coffee-shop.mp3",  image: "coffee-shop.svg" },
  { id: "restaurant",   name: "Restaurant",      file: "restaurant.mp3",   image: "restaurant.svg" }
]

function soundById(id) {
  for (var i = 0; i < SOUNDS.length; i++) {
    if (SOUNDS[i].id === id) return SOUNDS[i]
  }
  return null
}

if (typeof module !== "undefined") {
  module.exports = {
    SOUNDS: SOUNDS,
    soundById: soundById
  }
}
