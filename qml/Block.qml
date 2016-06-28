import VPlay 2.0
import QtQuick 2.0


EntityBase {
    id: block
    entityType: "block"

    visible: y >= 0
    transformOrigin: Item.Center
    // each block knows its type and its position on the field
    property int type
    property int row
    property int column

    property real cScale : 1.0

    // emit a signal when block is clicked
    signal clicked(int row, int column, int type)

    signal blockLanded()

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
        easing.type: Easing.InQuad
    }




    ParallelAnimation{
        id : moveToAnimation
        NumberAnimation {
            id : moveToYAnimation
            target: block
            property: "y"
            duration: 100
            easing.type: Easing.InOutQuad
        }
        NumberAnimation {
            id : moveToXAnimation
            target: block
            property: "x"
            duration: 100
            easing.type: Easing.InOutQuad
        }
    }

    SequentialAnimation {
        id: scalePulseAnimation
        alwaysRunToEnd: true
        loops: Animation.Infinite
        NumberAnimation {
            target: block
            property: "scale"
            duration: 200
            easing.type: Easing.InQuad
            to: 1.2
        }
        NumberAnimation {
            target: block
            property: "scale"
            duration: 200
            easing.type: Easing.OutQuad
            to: 1
        }
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

    function select(){
        scalePulseAnimation.start();
    }

    function deselect(){
        scalePulseAnimation.stop()
    }

    function moveTo(x, y){
        column = x
        row = y
        moveToYAnimation.to = y * block.height
        moveToXAnimation.to = x * block.width
        moveToAnimation.start()
    }

    Timer{
        id: checkTimer
        repeat: false
        running: false
        onTriggered:{
            blockLanded()
        }
    }

    // trigger fall down of block
    function fallDown(distance) {
        // complete previous fall before starting a new one
        fallDownAnimation.complete()

        var gravity = 9

        fallDownAnimation.duration = Math.sqrt(distance * 500000 / gravity)
        fallDownAnimation.to = block.y + distance * block.height

        checkTimer.interval = fallDownTimer.interval + fallDownAnimation.duration + 10

        // wait for removal of other blocks before falling down
        fallDownTimer.start()
        checkTimer.start()
    }
}
