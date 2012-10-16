import Qt 4.7

Grid {
    property string keys: ""
    property string enteredText: ""
    property int gridRows: 0
    property int gridColumns: 0
    property int buttonWidth: 70
    property int buttonHeight: 70

    property bool shift: false

    signal letterBackspace()
    signal letterEntered(string letter)

    rows: gridRows
    columns: gridColumns
    spacing: 1

    Repeater {
        model: keys.length
        BarButton {
	    width: buttonWidth; height: buttonHeight
	    property string key: shift ? keys.charAt(index).toUpperCase() : keys.charAt(index)
	    property bool special: key == "^" || key == "<"

            text: key == "^" ? "shift" : key == "<" ? "bksp" : key
            fontSize: 0.768 * (special ? 27 : 60)

            onButtonClick: {
		if (key == "^")
		    shift = !shift
		else if (key == "<")
		    letterBackspace()
		else {
		    letterEntered(key)
		    shift = false
		}
            }
        }
    }

    onLetterEntered: { enteredText = enteredText.toString() + letter; }
    onLetterBackspace: { enteredText = enteredText.toString().replace(/.$/, ''); }
    Keys.onPressed: {
	if (event.key == Qt.Key_Backspace) {
	    enteredText = enteredText.toString().replace(/.$/, '');
	} else {
	    enteredText = enteredText.toString() + event.text;
	}
    }
}
