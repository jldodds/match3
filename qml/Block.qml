import VPlay 2.0
import QtQuick 2.0


EntityBase {
    id: block
    entityType: "block"

    visible: y >= 0

    // each block knows its type and its position on the field
    property int type
    property int row
    property int column

    // emit a signal when block is clicked
    signal clicked(int row, int column, int type)

    // show different images for block types
    Image {
        anchors.fill: parent
        source: {
            if (type == 0)
                return "../assets/Apple.png"
            else if(type == 1)
                return "../assets/Banana.png"
            else if (type == 2)
                return "../assets/Orange.png"
            else if (type == 3)
                return "../assets/Pear.png"
            else
                return "../assets/BlueBerry.png"
        }
    }

    // handle click event on blocks (trigger clicked signal)
    MouseArea {
        anchors.fill: parent
        onClicked: parent.clicked(row, column, type)
    }

    // fade out block before removal
    NumberAnimation {
      id: fadeOutAnimation
      target: block
      property: "opacity"
      duration: 100
      from: 1.0
      to: 0

      // remove block after fade out is finished
      onStopped: {
        entityManager.removeEntityById(block.entityId)
      }
    }

    // animation to let blocks fall down
    NumberAnimation {
      id: fallDownAnimation
      target: block
      property: "y"
    }

    // timer to wait for other blocks to fade out
    Timer {
      id: fallDownTimer
      interval: fadeOutAnimation.duration
      repeat: false
      running: false
      onTriggered: {
        fallDownAnimation.start()
      }
    }

    // start fade out / removal of block
    function remove() {
      fadeOutAnimation.start()
    }

    // trigger fall down of block
    function fallDown(distance) {
      // complete previous fall before starting a new one
      fallDownAnimation.complete()

      // move with 100 ms per block
      // e.g. moving down 2 blocks takes 200 ms
      fallDownAnimation.duration = 100 * distance
      fallDownAnimation.to = block.y + distance * block.height

      // wait for removal of other blocks before falling down
      fallDownTimer.start()
    }
}
