import QtQuick
import QtMultimedia

// Volume-controlled MediaPlayer with seam-free looping for ambience tracks.
//
// One AudioOutput whose volume is driven by a single NumberAnimation, so
// every transition — crossfades, loop-seam fades, master-volume changes —
// routes through fadeTo() and nothing fights over the same property.
//
// Loop seam: `loops: Infinite` keeps playback gapless, and since QML
// MediaPlayer exposes no `ended` signal, the seam is detected by position
// wrap. A tick timer starts a fade-out when the track enters its last
// `fadeMs`, re-armed on every tick against the remaining time (minus a
// safety margin) so the volume converges to ~0 *before* the seam and holds
// silently; once the position wraps, the track fades back in over the first
// `fadeMs`. `loopFadesEnabled` lets the owner (Panel crossfade-out) take
// over volume control while a player is being retired — without it, a
// retiring player would fade back up at its own seam mid-crossfade.
Item {
  id: root

  property url source: ""
  property real masterVolume: 0.8
  property bool loopFadesEnabled: true
  property real fadeMs: 3000        // loop fade window ("last few seconds")
  property int tickMs: 100

  readonly property bool playing: player.playing
  readonly property real position: player.position
  readonly property real duration: player.duration
  readonly property real volume: audio.volume
  readonly property bool animating: fadeAnim.running

  signal fadeFinished()

  // Effective loop-fade window: `fadeMs`, shrunk for short tracks so the
  // seam fade never dominates the loop.
  readonly property real effectiveFadeMs: {
    var d = player.duration
    if (d <= 0) return root.fadeMs
    return Math.min(root.fadeMs, Math.max(500, d * 0.15))
  }
  property bool fadingOut: false

  function fadeTo(v, ms) {
    fadeAnim.duration = Math.max(1, ms)
    fadeAnim.to = v
    fadeAnim.restart()
  }

  function play() { player.play() }
  function pause() { player.pause() }
  function stop() { player.stop() }

  onSourceChanged: {
    root.fadingOut = false
    player.stop()
  }

  onPlayingChanged: {
    if (root.playing) root.tick()   // re-sync loop state on resume
  }

  MediaPlayer {
    id: player
    source: root.source
    loops: MediaPlayer.Infinite
    audioOutput: AudioOutput {
      id: audio
      volume: 0
    }
    onErrorOccurred: function(error, message) {
      console.warn("nature-mood playback error", error, message)
    }
  }

  NumberAnimation {
    id: fadeAnim
    target: audio
    property: "volume"
    duration: 250
    easing.type: Easing.InOutQuad
    onFinished: root.fadeFinished()
  }

  Timer {
    id: fadeTimer
    interval: root.tickMs
    repeat: true
    running: root.playing
    onTriggered: root.tick()
  }

  function tick() {
    var d = player.duration
    if (d <= 0 || !root.loopFadesEnabled) return
    var p = player.position
    var f = root.effectiveFadeMs

    if (root.fadingOut) {
      if (p < f) {
        // Wrapped past the seam: fade back in over the first f seconds.
        root.fadingOut = false
        root.fadeTo(root.masterVolume, f)
      } else if (audio.volume >= root.masterVolume - 0.02) {
        // Self-heal: already at full volume with the flag stale (e.g. the
        // player was repurposed as an incoming crossfade).
        root.fadingOut = false
      }
      return
    }

    // Entering the last f seconds: fade out, sized to the remaining time
    // minus a safety margin so volume hits ~0 before the seam.
    if (d - p <= f) {
      root.fadingOut = true
      root.fadeTo(0, Math.max(50, d - p - 250))
      return
    }

    // Reconcile: stuck below master (pause/resume mid-fade, master change).
    if (!fadeAnim.running && Math.abs(audio.volume - root.masterVolume) > 0.02) {
      root.fadeTo(root.masterVolume, 250)
    }
  }
}
