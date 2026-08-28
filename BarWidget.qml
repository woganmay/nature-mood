import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

// Stormcloud bar button for nature-mood: left-click toggles the sound
// picker panel. All audio is bundled mp3 played through the shell's own
// QtMultimedia stack — no streaming at runtime.
BarWidget {
  id: root
  moduleName: "woganmay.nature-mood"

  // ---- Panel lifecycle contract for shell.summon/hide/toggle routing
  //      (Bar.findPanelWidget requires open/close/opened on the widget
  //      root).
  readonly property bool opened: panelLoader.item
    ? panelLoader.item.opened === true
    : false

  function open() {
    if (panelLoader.item) panelLoader.item.open()
  }

  function close() {
    if (panelLoader.item) panelLoader.item.close()
  }

  function toggle() {
    if (panelLoader.item) panelLoader.item.toggle()
  }

  // Forwarded so this widget can stand in for the panel as the bar's
  // popout identity.
  readonly property bool popoutSwitchClosing: panelLoader.item
    ? panelLoader.item.popoutSwitchClosing === true
    : false

  function closeForPopoutSwitch() {
    if (panelLoader.item) panelLoader.item.closeForPopoutSwitch()
  }

  function injectPanel() {
    var target = panelLoader.item
    if (!target) return
    if ("bar" in target) target.bar = root.bar
    if ("settings" in target) target.settings = root.settings
    if ("anchorItem" in target) target.anchorItem = button
    if ("hostWidget" in target) target.hostWidget = root
  }

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  onBarChanged: injectPanel()
  onSettingsChanged: injectPanel()

  Loader {
    id: panelLoader
    active: true
    source: Qt.resolvedUrl("Panel.qml")
    visible: false
    onLoaded: {
      root.injectPanel()
      Qt.callLater(root.injectPanel)
    }
  }

  IpcHandler {
    target: "woganmay.nature-mood"

    function open(): void { root.open() }
    function close(): void { root.close() }
    function show(): void { root.open() }
    function hide(): void { root.close() }
    function toggle(): void { root.toggle() }
  }

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    // nf-weather-thunderstorm — the stormcloud, same glyph the weather
    // panel uses, rendered in the bar's Nerd Font.
    text: "\uE31D"
    tooltipText: "Nature Mood — nature sounds"
    onPressed: function(b) {
      if (b === Qt.LeftButton) root.toggle()
    }
  }
}
