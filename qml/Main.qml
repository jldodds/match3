import VPlay 2.0
import QtQuick 2.0

GameWindow {
    id: gameWindow

    activeScene: scene

    // the size of the Window can be changed at runtime by pressing Ctrl (or Cmd on Mac) + the number keys 1-8
    // the content of the logical scene size (480x320 for landscape mode by default) gets scaled to the window size based on the scaleMode
    // you can set this size to any resolution you would like your project to start with, most of the times the one of your main target device
    // this resolution is for iPhone 4 & iPhone 4S
    screenWidth: 640
    screenHeight: 960

    // initialiaze game when window is fully loaded
    onSplashScreenFinished: gameOverWindow.show()

    // for dynamic creation of entities
    EntityManager {
        id: entityManager
        entityContainer: gameArea
    }


    // custom font loading of ttf fonts
    FontLoader {
        id: gameFont
        source: "../assets/fonts/akaDylan Plain.ttf"
    }

    Scene {
        id: scene

        // the "logical size" - the scene content is auto-scaled to match the GameWindow size
        width: 320
        height: 480

        // property to hold game score
        property int score

        // background image
        BackgroundImage {
            source: "../assets/JuicyBackground.png"
            anchors.centerIn: scene.gameWindowAnchorItem
        }

        // display score
        Text {
            // set font
            font.family: gameFont.name
            font.pixelSize: 12
            color: "red"
            text: scene.score

            // set position
            anchors.horizontalCenter: parent.horizontalCenter
            y: 446
        }

        // game area holds game field with blocks
        GameArea {
            id: gameArea
            anchors.horizontalCenter: scene.horizontalCenter
            blockSize: 30
            y: 20
            onGameOver: gameOverWindow.show()
        }

        // configure gameover window
        GameOverWindow {
          id: gameOverWindow
          y: 90
          opacity: 0 // by default the window is hidden
          anchors.horizontalCenter: scene.horizontalCenter
          onNewGameClicked: scene.startGame()
        }

        // initialize game
        function startGame() {
            gameOverWindow.hide()
            gameArea.initializeField()
            scene.score = 0
        }
    }
}
