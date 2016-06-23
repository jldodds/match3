import VPlay 2.0
 import QtQuick 2.0


 EntityBase {
   id: block
   entityType: "block"

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
 }
