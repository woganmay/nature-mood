pragma ComponentBehavior: Bound
import QtQuick
import qs.Commons

// Cover-flow carousel for the nature-mood sound picker. Pure presentation:
// Panel owns the selection + playback state; this renders covers as a fan
// around `selectedIndex` and reports clicks via `activated(id)`.
//
// Geometry per cover derives from its distance to the selection: x offset
// (stride), scale, Y-axis rotation (the fan), z-order, opacity. All are
// animated through Behaviors, so arrow-key browsing glides. Covers past the
// flow bounds are clipped so nothing paints outside the panel card.
Item {
  id: root

  property var items: []
  property int selectedIndex: 0
  property string playingId: ""

  signal activated(string id)

  property real coverWidth: Style.space(170)
  property real coverHeight: Style.space(100)
  property real stride: Style.space(100)
  property int maxDist: 2

  clip: true

  Repeater {
    model: root.items

    delegate: Item {
      required property var modelData
      required property int index
      readonly property int dist: index - root.selectedIndex
      readonly property int absDist: Math.abs(dist)
      readonly property bool isSelected: dist === 0
      readonly property bool isPlaying: root.playingId === modelData.id

      width: root.coverWidth
      height: root.coverHeight
      visible: absDist <= root.maxDist + 1   // allow slide-in from just offscreen
      z: 100 - absDist                       // nearest on top (discrete — not animated)
      transformOrigin: Item.Center
      x: parent.width / 2 - root.coverWidth / 2 + dist * root.stride
      y: (parent.height - root.coverHeight) / 2
      scale: absDist === 0 ? 1 : (absDist === 1 ? 0.78 : 0.58)
      opacity: absDist <= 1 ? 1 : 0.4

      Behavior on x { NumberAnimation { duration: 320; easing.type: Easing.OutCubic } }
      Behavior on scale { NumberAnimation { duration: 320; easing.type: Easing.OutCubic } }
      Behavior on opacity { NumberAnimation { duration: 320; easing.type: Easing.OutCubic } }

      // The fan: neighbors rotate toward the center around the Y axis.
      transform: Rotation {
        axis { x: 0; y: 1; z: 0 }
        origin.x: width / 2
        origin.y: height / 2
        angle: dist * -14
        Behavior on angle { NumberAnimation { duration: 320; easing.type: Easing.OutCubic } }
      }

      Image {
        id: art
        anchors.fill: parent
        source: Qt.resolvedUrl("images/" + modelData.image)
        fillMode: Image.PreserveAspectCrop
        smooth: true
      }

      // Selection / playback chrome. Radius matches the rx baked into the
      // SVG covers (14 / 190 of the cover width).
      Rectangle {
        anchors.fill: parent
        radius: root.coverWidth * 14 / 190
        color: "transparent"
        border.width: isSelected || isPlaying ? Math.max(1, Style.space(2)) : 0
        border.color: isSelected
          ? Color.accent
          : (isPlaying ? Qt.alpha(Color.accent, 0.55) : "transparent")
      }

      Rectangle {
        visible: isPlaying
        width: Style.space(7)
        height: Style.space(7)
        radius: width / 2
        color: Color.accent
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: Style.space(5)
        anchors.rightMargin: Style.space(5)
      }

      MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.activated(modelData.id)
      }
    }
  }
}
