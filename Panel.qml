import QtQuick
import qs.Commons
import qs.Ui
import "Model.js" as Model

// Nature-mood sound picker: a cover-flow panel anchored to the stormcloud
// bar button. Arrow keys browse the covers, Up/Down drive the volume,
// Space (or a click) plays/pauses the selected sound, Esc closes. Switching
// sounds crossfades — the outgoing track fades out while the incoming fades
// in — and every looped track fades out over its last few seconds and back
// in over its first few, so the seam is inaudible. No runtime display: the
// covers replaced the old duration list. All audio is bundled mp3 played
// through the shell's own QtMultimedia stack — no streaming, no external
// player.
//
// BarWidget.qml owns the bar button and hands this panel the anchor.
Panel {
  id: root
  moduleName: "woganmay.nature-mood"
  ipcTarget: "woganmay.nature-mood"
  manageIpc: false

  property var anchorItem: null
  property var hostWidget: null
  readonly property var barIdentity: hostWidget || root

  // ---- Playback state. Volume persists through the widget's shell.json
  //      entry so the mood survives shell restarts.
  property string currentSoundId: ""
  property int selectedIndex: 0
  property real volume: setting("volume", 0.8)

  readonly property bool hasSound: root.currentSoundId !== ""
  readonly property var currentSound: Model.soundById(root.currentSoundId)
  readonly property var selectedSound: Model.SOUNDS[root.selectedIndex]
  property Item activePlayer: playerA

  // The player faded out by the last switch; stopped when its fade finishes
  // (identity-guarded so rapid switching can't kill the new playback).
  property Item pendingStop: null

  readonly property int crossfadeMs: 800
  property real volumeStep: 0.05   // matches PanelSlider.step

  // Guarded so the panel renders before the bar is injected (the bar-widget
  // contract instantiates it bare).
  readonly property color contentForeground: bar ? bar.foreground : Color.foreground
  readonly property string contentFontFamily: bar ? bar.fontFamily : Style.font.family

  function open() {
    root.controller.show()
  }

  function close() {
    // Closing the picker keeps the mood playing; pause explicitly via
    // Space/click on the selected cover.
    root.controller.hide()
  }

  function toggle() {
    if (root.opened) root.close()
    else root.open()
  }

  function switchPanel(direction) {
    if (root.bar && typeof root.bar.switchPanelFrom === "function")
      return root.bar.switchPanelFrom(root.barIdentity, direction)
    return false
  }

  // Arrow keys browse only; Space/click plays. Navigation clamps at the ends.
  function navigate(dx) {
    var next = root.selectedIndex + dx
    root.selectedIndex = Math.max(0, Math.min(Model.SOUNDS.length - 1, next))
  }

  // Click/Space on the current sound toggles play/pause (position kept).
  // Any other sound crossfades in: the incoming player starts silent and
  // ramps up while the outgoing ramps down, then stops.
  function playSound(id) {
    if (root.currentSoundId === id) {
      if (root.activePlayer.playing) root.activePlayer.pause()
      else root.activePlayer.play()
      return
    }
    var sound = Model.soundById(id)
    if (!sound) return

    var incoming = root.activePlayer === playerA ? playerB : playerA
    incoming.loopFadesEnabled = true
    incoming.source = Qt.resolvedUrl("sounds/" + sound.file)
    incoming.fadeTo(0, 1)
    incoming.play()
    incoming.fadeTo(root.volume, root.crossfadeMs)

    root.activePlayer.loopFadesEnabled = false
    root.activePlayer.fadeTo(0, root.crossfadeMs)
    root.pendingStop = root.activePlayer
    root.activePlayer = incoming
    root.currentSoundId = id
    for (var i = 0; i < Model.SOUNDS.length; i++) {
      if (Model.SOUNDS[i].id === id) { root.selectedIndex = i; break }
    }
  }

  function togglePlay() {
    var sound = root.selectedSound
    if (!sound) return
    root.playSound(sound.id)
  }

  // Up/Down (moveRequested dy) drive the volume slider at the same step as
  // the slider itself, clamped to [0, 1]. Persisted after the presses
  // settle so holding a key doesn't hammer shell.json.
  function adjustVolume(delta) {
    var v = root.volume + delta * root.volumeStep
    v = Math.max(0, Math.min(1, v))
    if (v === root.volume) return
    root.volume = v
    root.volumePersistTimer.restart()
  }

  // Same persistence shape as the clock: applied locally first, then
  // written to shell.json through the bar, which round-trips it back.
  function persistSettings(values) {
    var entry = { id: root.moduleName }
    for (var existing in root.settings) if (existing !== "id") entry[existing] = root.settings[existing]
    for (var key in values) entry[key] = values[key]

    root.settings = entry
    if (root.hostWidget && "settings" in root.hostWidget) root.hostWidget.settings = entry
    if (root.bar && root.bar.shell && typeof root.bar.shell.updateEntryInline === "function")
      root.bar.shell.updateEntryInline(root.moduleName, entry)
  }

  FadePlayer {
    id: playerA
    masterVolume: root.volume
    onFadeFinished: {
      if (root.pendingStop === playerA) {
        playerA.stop()
        root.pendingStop = null
      }
    }
  }

  FadePlayer {
    id: playerB
    masterVolume: root.volume
    onFadeFinished: {
      if (root.pendingStop === playerB) {
        playerB.stop()
        root.pendingStop = null
      }
    }
  }

  // Debounced persistence so holding ↑/↓ doesn't hammer shell.json.
  Timer {
    id: volumePersistTimer
    interval: 500
    onTriggered: root.persistSettings({ volume: root.volume })
  }

  KeyboardPanel {
    id: panel
    anchorItem: root.anchorItem
    owner: root.barIdentity
    bar: root.bar
    open: root.opened
    centerOnBar: false
    focusTarget: keyCatcher
    contentWidth: panel.fittedContentWidth(Style.space(360))
    contentHeight: panel.fittedContentHeight(content.implicitHeight)

    PanelKeyCatcher {
      id: keyCatcher
      anchors.fill: parent
      onCloseRequested: root.close()
      onTabRequested: function(direction) { root.switchPanel(direction) }
      onMoveRequested: function(dx, dy) {
        if (dy === 0) root.navigate(dx)
        else root.adjustVolume(-dy)   // Up = +, Down = -
      }
      onActivateRequested: root.togglePlay()

      Column {
        id: content
        width: parent.width
        spacing: Style.space(8)

        Text {
          width: parent.width
          text: "NATURE MOOD"
          color: Qt.darker(root.contentForeground, 1.5)
          font.family: root.contentFontFamily
          font.pixelSize: Style.font.caption
          font.letterSpacing: 1
          font.bold: true
        }

        CoverFlow {
          id: flow
          width: parent.width
          height: Style.space(118)
          items: Model.SOUNDS
          selectedIndex: root.selectedIndex
          playingId: root.currentSoundId
          onActivated: function(id) { root.playSound(id) }
        }

        Text {
          width: parent.width
          visible: root.selectedSound
          text: {
            var s = root.selectedSound
            if (!s) return ""
            if (root.currentSoundId === s.id && root.hasSound)
              return s.name + (root.activePlayer.playing ? "  ·  playing" : "  ·  paused")
            return s.name
          }
          color: Color.accent
          font.family: root.contentFontFamily
          font.pixelSize: Style.font.body
          font.bold: root.currentSoundId === root.selectedSound.id
          elide: Text.ElideRight
        }

        Text {
          width: parent.width
          text: "← →  browse      ↑ ↓  volume      Space  play / pause      Esc  close"
          color: Qt.darker(root.contentForeground, 1.5)
          font.family: root.contentFontFamily
          font.pixelSize: Style.font.caption
        }

        Row {
          width: parent.width
          spacing: Style.space(12)

          Text {
            id: volumeLabel
            anchors.verticalCenter: parent.verticalCenter
            text: "Volume"
            color: Qt.darker(root.contentForeground, 1.5)
            font.family: root.contentFontFamily
            font.pixelSize: Style.font.caption
          }

          PanelSlider {
            id: volumeSlider
            bar: root.bar
            width: parent.width - volumeLabel.implicitWidth - parent.spacing
            value: root.volume
            onMoved: function(v) { root.volume = v }
            onReleased: function(v) {
              root.volume = v
              root.persistSettings({ volume: v })
            }
          }
        }
      }
    }
  }
}
