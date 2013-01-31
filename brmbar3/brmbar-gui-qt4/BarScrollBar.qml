// Based on https://projects.forum.nokia.com/qmluiexamples/browser/qml/qmluiexamples/Scrollable/ScrollBar.qml
import Qt 4.7

Rectangle {
    // The flickable to which the scrollbar is attached to, must be set
    property variant flickableItem

    // True for vertical ScrollBar, false for horizontal
    property bool vertical: true

    property int scrollbarWidth: 20

    property string color: "white"
    property real baseOpacityOff: 0.4
    property real baseOpacityOn: 0.9

    radius: vertical ? width/2 : height/2

    function sbOpacity()
    {
	if (vertical ? (height >= parent.height) : (width >= parent.width)) {
	    return 0;
	} else {
	    return (flickableItem.flicking || flickableItem.moving) ? baseOpacityOn : baseOpacityOff;
	}
    }

    // Scrollbar appears automatically when content is bigger than the Flickable
    opacity: sbOpacity()

    // Calculate width/height and position based on the content size and position of
    // the Flickable
    width: vertical ? scrollbarWidth : flickableItem.visibleArea.widthRatio * parent.width
    height: vertical ? flickableItem.visibleArea.heightRatio * parent.height : scrollbarWidth
    x: vertical ? parent.width - width : flickableItem.visibleArea.xPosition * parent.width
    y: vertical ? flickableItem.visibleArea.yPosition * parent.height : parent.height - height

    // Animate scrollbar appearing/disappearing
    Behavior on opacity { NumberAnimation { duration: 200 }}
}
