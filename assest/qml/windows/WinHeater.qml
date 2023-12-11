import QtQuick
import QtQuick.Controls.Material
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

import "../modules"

Window {

    width: 1400
    height: 600
    visible: true

    Connections {
        target: dsContext

        function onQml_send_text(string){
            var currentTime = new Date();
            var formattedTime = currentTime.toLocaleTimeString(); // Форматируйте время, как вам нужно
            var message = formattedTime + " : " + string;
            textAreaLog.append(message);
        }

    }

    Rectangle {
        id: bacground
        color: "#dbdcdc"
        anchors.fill: parent

        GridLayout {
            anchors.fill: parent
            anchors.margins: 20
            columns: 2
            columnSpacing: 20


            Rectangle {
                Layout.fillHeight: true
                Layout.preferredWidth: 400
                id: contentList
                color: "white"
                radius: 10
                layer.enabled: true
                layer.effect: DropShadow {
                    color: "#a0676767"
                    transparentBorder: true
                    horizontalOffset: 2
                    verticalOffset: 4
                    radius: 4
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 20

                    TextArea {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 50
                        id: tempListInput
                        placeholderText: qsTr("Внести список цілових температур")

                        Keys.onReturnPressed: {
                            var command = []

                            var inputText = tempListInput.text;
                            inputText = inputText.replace(",", ".");
                            var temperatureArray = inputText.split(/\s+|\//);

                            command = ["target_temp_list"].concat(temperatureArray);
                            dsContext.receive_data_from_QML(command)

                            tempList.model.clear();
                            for (var i = 0; i < temperatureArray.length; ++i) {
                                tempList.model.append({ temperature: temperatureArray[i] });
                            }

                            console.log(command);
                        }
                    }

                    ListView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        id: tempList

                        model: ListModel {
                            ListElement { temperature: "Список температур" }
                        }

                        delegate: Item {
                            width: tempList.width
                            height: 60

                            Menu {
                                id: actionMenu
                                x: actionBtn.x + actionBtn.width
                                y: actionBtn.y + actionBtn.height

                                font.pointSize: sm.sFont

                                MenuItem {
                                    text: qsTr("Видалити")
                                    onTriggered: { }
                                }

                            }

                            Rectangle {
                                id: background
                                radius: 10
                                anchors.fill: parent
                                color: index % 2 == 0 ? "#00000000" : "#e6e6e6"

                                GridLayout {
                                    anchors.fill: parent
                                    anchors.margins: 5
                                    columns: 2
                                    rows: 1

                                    Text {
                                        Layout.fillWidth: true
                                        id: tempItemText
                                        text: model.temperature
                                        verticalAlignment: Qt.AlignVCenter
                                        horizontalAlignment: Qt.AlignHCenter
                                        font.pixelSize: sm.mFont
                                    }

                                    Button {
                                        id: actionBtn
                                        display: AbstractButton.TextBesideIcon
                                        icon.source: "qrc:/icons/dash.svg"
                                        onClicked: actionMenu.open()
                                        flat: true
                                    }


                                }
                            }
                        }
                    }
                }


            }

            Rectangle {
                Layout.fillHeight: true
                Layout.fillWidth: true
                id: contentManual
                color: "white"
                radius: 10
                layer.enabled: true
                layer.effect: DropShadow {
                    color: "#a0676767"
                    transparentBorder: true
                    horizontalOffset: 2
                    verticalOffset: 4
                    radius: 4
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 20

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 120
                        id: rectangleControl
                        color: "#00000000"

                        GridLayout {
                            anchors.fill: parent
                            anchors.margins: 20

                            columns: 2
                            rows: 2

                            Switch {
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                Layout.row: 0
                                Layout.column: 0
                                id: switchControllSystem
                                text: "Система контролю"
                                font.pointSize: sm.mFont
                                enabled: !switchFurnaceConncet.checked
                                onClicked: {
                                    var command = []
                                    switchControllSystem.checked ? command = ["connect_heater"] : command = ["disconnect_heater"]
                                    dsContext.receive_data_from_QML(command)
                                    console.log(command)
                                }
                            }

                            Switch {
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                Layout.row: 1
                                Layout.column: 0
                                id: switchFurnaceConncet
                                text: qsTr("Підключення до пічки")
                                font.pointSize: sm.mFont
                                enabled: switchControllSystem.checked
                                onClicked: {
                                    var command = []
                                    switchFurnaceConncet.checked ? command = ["on_control_heater"] : command = ["off_control_heater"]
                                    dsContext.receive_data_from_QML(command)
                                    console.log(command)
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                Layout.row: 0
                                Layout.column: 1
                                Layout.rowSpan: 2


                                RowLayout {

                                    Text {
                                        Layout.fillWidth: true
                                        text: "Поточна температура:"
                                        font.pointSize: sm.mFont
                                    }

                                    TextField {
                                        id: temperatureLable
                                        text: dsContext.temp
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                        font.pointSize: sm.mFont
                                    }
                                }


                                RowLayout {

                                    Text {
                                        Layout.fillWidth: true
                                        text: "Цільова температура:"
                                        font.pointSize: sm.mFont
                                    }

                                    TextField {
                                        id: tagetTempInput
                                        selectByMouse: true
                                        horizontalAlignment: TextEdit.AlignHCenter
                                        verticalAlignment: TextEdit.AlignVCenter
                                        font.pointSize: sm.mFont
                                        validator: DoubleValidator {
                                            top: 99.99;
                                            bottom: -99.99;
                                            decimals: 2;
                                            notation: DoubleValidator.StandardNotation }

                                        Keys.onReturnPressed: {
                                            var command = []
                                            tagetTempInput.text = tagetTempInput.text.replace(",", ".")
                                            command = ["target_temp", tagetTempInput.text.toString()]
                                            dsContext.receive_data_from_QML(command)
                                            console.log(command)
                                        }

                                    }

                                }

                            }
                        }
                    }


                    ScrollView {
                        Layout.fillHeight: true
                        Layout.fillWidth: true

                        TextArea {
                            id: textAreaLog
                            font.styleName: "Regular"
                            font.family: "JetBrains Mono" //monofont to equal distance
                            font.pointSize: sm.mFont

                        }
                    }
                }
            }
        }
    }
}
