// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1

TextInput {
    id: barcode
    x: 433
    y: 65
    width: 80
    height: 100
    color: "#ff6464"
    text: ""
    transformOrigin: Item.Center
    visible: true
    opacity: 0
    font.pixelSize: 0.768 * 12
    focus: true
    validator: RegExpValidator { regExp: /..*/ } /* non-empty strings; barcode readers send empty lines, ignore these */
}
