
import VPlay 2.0
import QtQuick 2.0

Item {

    id: gameArea

    // shall be a multiple of the blockSize
    // the game field is 8 columns by 12 rows big
    width: blockSize * 8
    height: blockSize * 12

    // properties for game area configuration
    property double blockSize
    property int rows: Math.floor(height / blockSize)
    property int columns: Math.floor(width / blockSize)

    // array for handling game field
    property var field: []

    // game over signal
    signal gameOver()

    // calculate field index
    function index(row, column) {
        return row * columns + column
    }

    // fill game field with blocks
    function initializeField() {
        // clear field
        clearField()

        // fill field
        for(var i = 0; i < rows; i++) {
            for(var j = 0; j < columns; j++) {
                gameArea.field[index(i, j)] = createBlock(i, j)
            }
        }
    }

    // clear game field
    function clearField() {
        // remove entities
        for(var i = 0; i < gameArea.field.length; i++) {
            var block = gameArea.field[i]
            if(block !== null)  {
                entityManager.removeEntityById(block.entityId)
            }
        }
        gameArea.field = []
    }

    // create a new block at specific position
    function createBlock(row, column) {
        // configure block
        var entityProperties = {
            width: blockSize,
            height: blockSize,
            x: column * blockSize,
            y: row * blockSize,

            type: Math.floor(Math.random() * 5), // random type
            row: row,
            column: column
        }

        // add block to game area
        var id = entityManager.createEntityFromUrlWithProperties(
                    Qt.resolvedUrl("Block.qml"), entityProperties)

        // link click signal from block to handler function
        var entity = entityManager.getEntityById(id)
        entity.clicked.connect(handleClick)

        return entity
    }

    function handleClick(row, column, type) {
        // copy current field, allows us to change the array without modifying the real game field
        // this simplifies the algorithms to search for connected blocks and their removal
        var fieldCopy = field.slice()

        // count and delete connected blocks
        var blockCount = getNumberOfConnectedBlocks(fieldCopy, row, column, type)
        if(blockCount >= 3) {
            removeConnectedBlocks(fieldCopy)
            moveBlocksToBottom()

            var score = blockCount * (blockCount + 1) / 2
            scene.score += score

            if(isGameOver())
                gameOver()

        }

    }

    // recursively check a block and its neighbours
    // returns number of connected blocks
    function getNumberOfConnectedBlocks(fieldCopy, row, column, type) {
        // stop recursion if out of bounds
        if(row >= rows || column >= columns || row < 0 || column < 0)
            return 0

        // get block
        var block = fieldCopy[index(row, column)]

        // stop if block was already checked
        if(block === null)
            return 0

        // stop if block has different type
        if(block.type !== type)
            return 0

        // block has the required type and was not checked before
        var count = 1

        // remove block from field copy so we can't check it again
        // also after we finished searching, every correct block we found will leave a null value at its
        // position in the field copy, which we then use to remove the blocks in the real field array
        fieldCopy[index(row, column)] = null

        // check all neighbours of current block and accumulate number of connected blocks
        // at this point the function calls itself with different parameters
        // this principle is called "recursion" in programming
        // each call will result in the function calling itself again until one of the
        // checks above immediately returns 0 (e.g. out of bounds, different block type, ...)
        count += getNumberOfConnectedBlocks(fieldCopy, row + 1, column, type) // add number of blocks to the right
        count += getNumberOfConnectedBlocks(fieldCopy, row, column + 1, type) // add number of blocks below
        count += getNumberOfConnectedBlocks(fieldCopy, row - 1, column, type) // add number of blocks to the left
        count += getNumberOfConnectedBlocks(fieldCopy, row, column - 1, type) // add number of bocks above

        // return number of connected blocks
        return count
    }
    // remove previously marked blocks
    function removeConnectedBlocks(fieldCopy) {
        // search for blocks to remove
        for(var i = 0; i < fieldCopy.length; i++) {
            if(fieldCopy[i] === null) {
                // remove block from field
                var block = gameArea.field[i]
                if(block !== null) {
                    gameArea.field[i] = null
                    entityManager.removeEntityById(block.entityId)
                }
            }
        }
    }

    // move remaining blocks to the bottom and fill up columns with new blocks
    function moveBlocksToBottom() {
        // check all columns for empty fields
        for(var col = 0; col < columns; col++) {

            // start at the bottom of the field
            for(var row = rows - 1; row >= 0; row--) {

                // find empty spot in grid
                if(gameArea.field[index(row, col)] === null) {

                    // find block to move down
                    var moveBlock = null
                    for(var moveRow = row - 1; moveRow >= 0; moveRow--) {
                        moveBlock = gameArea.field[index(moveRow,col)]

                        if(moveBlock !== null) {
                            gameArea.field[index(moveRow,col)] = null
                            gameArea.field[index(row, col)] = moveBlock
                            moveBlock.row = row
                            moveBlock.y = row * gameArea.blockSize
                            break
                        }
                    }

                    // if no block found, fill whole column up with new blocks
                    if(moveBlock === null) {
                        for(var newRow = row; newRow >= 0; newRow--) {
                            var newBlock = createBlock(newRow, col)
                            gameArea.field[index(newRow, col)] = newBlock
                            newBlock.row = newRow
                            newBlock.y = newRow * gameArea.blockSize
                        }

                        // column already filled up, no need to check higher rows again
                        break
                    }
                }

            } // end check rows starting from the bottom
        } // end
    }

    // check if game is over
    function isGameOver() {
      var gameOver = true

      // copy field to search for connected blocks without modifying the actual field
      var fieldCopy = field.slice()

      // search for connected blocks in field
      for(var row = 0; row < rows; row++) {
        for(var col = 0; col < columns; col++) {

          // test all blocks
          var block = fieldCopy[index(row, col)]
          if(block !== null) {
            var blockCount = getNumberOfConnectedBlocks(fieldCopy, row, col, block.type)

            if(blockCount >= 3) {
              gameOver = false
              break
            }
          }

        }
      }

      return gameOver
    }
}
