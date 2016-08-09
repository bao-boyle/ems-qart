import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.2
import QtQuick.Layouts 1.2
import QtQuick.Dialogs 1.2
import EmsQart 1.0

ApplicationWindow {
    id: mainView;

    title: "ems-qart";

    visible: true;

    width: 800;
    height: 600;
    CartController {
        id: cartController;
    }

    FileDialog {
        id: fileDialog;

        property string selectedNameFilterExtension: selectedNameFilter.split("*")[1].replace(")","");

        title: fileDialogTitle(readButton.checked, romButton.checked);

        nameFilters: romButton.checked ? ["GB Roms (*.gb)", "GBC Roms (*.gbc)"] : ["GB/GBC Save files (*.sav)"];
        selectExisting: writeButton.checked;

        onAccepted: {
            cartController.setLocalFilePath(fileDialog.fileUrl, selectedNameFilterExtension);
        }
    }

    function fileDialogTitle(read, rom) {
        if (read) {
            if (rom) {
                return "choose where the ROM will be saved";
            } else {
                return "choose where the SAV will be saved";
            }
        } else {
            if (rom) {
                return "choose the ROM to be written to the cart";
            } else {
                return "choose the SAV to be written to the cart";
            }
        }
    }

    Column {
        id: mainColumn;

        spacing: (parent.height - (anchors.topMargin + anchors.bottomMargin) - (radioButtonsRow.height + cartIconsRow.height + theButton.height)) / 2;

        anchors {
            topMargin: 20;
            bottomMargin: 20;
            fill: parent;
        }

        RowLayout {
            id: radioButtonsRow;

            anchors {
                left: parent.left;
                right: parent.right;
            }

            GroupBox {
                id: readWriteGroupbox;

                title: "I/O direction";

                Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter;

                property bool readCart: readButton.checked;

                onReadCartChanged: {
                    cartController.clearLocalFilePath();
                }

                RowLayout {
                    id: readWriteRow;

                    spacing: 20;

                    ExclusiveGroup {
                        id: readWriteExclusiveGroup;
                    }
                    RadioButton {
                        id: readButton;

                        text: "Read from cart";
                        checked: true;
                        exclusiveGroup: readWriteExclusiveGroup;
                    }
                    RadioButton {
                        id: writeButton;

                        text: "Write to cart";
                        exclusiveGroup: readWriteExclusiveGroup;
                    }
                }
            }

            GroupBox {
                title: "Memory"

                Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter;

                RowLayout {
                    spacing: 20;

                    ExclusiveGroup {
                        id: sourceGroup;
                    }
                    RadioButton {
                        id: romButton;

                        text: "ROM (.gb/.gbc files)";
                        checked: true;
                        exclusiveGroup: sourceGroup;
                    }
                    RadioButton {
                        id: ramButton;

                        text: "SRAM (.sav files)";
                        exclusiveGroup: sourceGroup;
                    }
                }
            }

            GroupBox {
                title: "Bank"

                enabled: romButton.checked;

                Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter;

                RowLayout {
                    spacing: 20;

                    ExclusiveGroup {
                        id: bankGroup;
                    }
                    RadioButton {
                        id: bankOneButton;

                        text: "Bank 1";
                        checked: true;
                        exclusiveGroup: bankGroup;
                    }
                    RadioButton {
                        id: bankTwoButton;

                        text: "Bank 2";
                        exclusiveGroup: bankGroup;
                    }
                }
            }
        }

        RowLayout {
            id: cartIconsRow;

            anchors {
                left: parent.left;
                right: parent.right;
            }

            Item {
                id: localFileItem;

                implicitHeight: localFileIcon.height;
                implicitWidth: localFileIcon.width;

                Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter;

                Image {
                    id: localFileIcon;

                    opacity: cartController.localFilePath != "" ? 1 : 0.08;

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 100;
                        }
                    }

                    source: romButton.checked ? "qrc:///images/gb_cart.svg" : "qrc:///images/save_icon.svg";
                    sourceSize.height: mainView.height / 2.3;

                    MouseArea {
                        id: localFileSelectionMouseArea;

                        enabled: cartController.localFilePath == "";

                        anchors {
                            fill: parent;
                        }

                        onClicked: {
                            fileDialog.open();
                        }
                    }
                }

                Text {
                    id: chooseFileText;

                    text: "Click to " + fileDialogTitle(readButton.checked, romButton.checked);

                    visible: cartController.localFilePath == "";

                    anchors {
                        fill: localFileIcon;
                        topMargin: localFileIcon.height * 0.28;
                        bottomMargin: localFileIcon.height * 0.135;
                        leftMargin: localFileIcon.height * 0.120;
                        rightMargin: localFileIcon.height * 0.120;
                    }

                    font {
                        italic: true;
                        pointSize: 12;
                    }

                    wrapMode: Text.WordWrap;

                    horizontalAlignment: Text.AlignHCenter;
                    verticalAlignment: Text.AlignVCenter;
                }

                Image {
                    id: cancelFileIcon;

                    source: "qrc:///images/cancel_icon.svg";

                    visible: opacity > 0;
                    opacity: chosenFilePath.text != "" ? 1 : 0;

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 100;
                        }
                    }

                    anchors {
                        left: localFileIcon.left;
                        verticalCenter: chosenFilePath.verticalCenter;
                    }

                    sourceSize.width: 16;
                    sourceSize.height: 16;

                    MouseArea {
                        id: cancelFileMouseArea;

                        anchors {
                            fill: parent;
                        }

                        onClicked: {
                            cartController.clearLocalFilePath();
                        }
                    }
                }

                Label {
                    id: chosenFilePath;

                    text: cartController.localFilePath;

                    visible: opacity > 0;
                    opacity: text != "" ? 1 : 0;

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 100;
                        }
                    }

                    anchors {
                        left: cancelFileIcon.right;
                        leftMargin: 5;
                        right: localFileIcon.right;
                        top: localFileIcon. bottom;
                        topMargin: 10;
                    }

                    font {
                        pointSize: 10;
                    }

                    elide: Text.ElideMiddle;
                }
            }

            Image {
                id: arrowIcon;

                source: "qrc:///images/arrow.svg";
                sourceSize.height: 70;

                rotation: writeButton.checked ? 0 : 180;

                Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter;
            }

            Item {
                id: emsCartItem;

                implicitWidth: emsCartIcon.width;
                implicitHeight: emsCartIcon.height;

                Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter;

                Image {
                    id: emsCartIcon;

                    source: "qrc:///images/gb_cart_usb.svg";
                    sourceSize.height: mainView.height / 2.3;

                    opacity: cartController.ready ? 1 : 0.08;

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 100;
                        }
                    }
                }

                GroupBox {
                    id: bankOneInfo;

                    title: "Bank 1";

                    visible: opacity > 0;
                    opacity: cartController.ready ? 1 : 0;

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 100;
                        }
                    }

                    anchors {
                        left: emsCartIcon.left;
                        right: emsCartIcon.right;
                        top: emsCartIcon.bottom;
                        topMargin: 15;
                    }

                    Column {
                        Label {
                            id: bankOneTitleLabel;

                            text: "Title: " + cartController.bankOne.title;
                        }

                        Label {
                            id: bankOneChecksumLabel;

                            text: "Checksum: " + (cartController.bankOne.checksumValid ? "valid" : "not valid");
                        }
                    }
                }


                GroupBox {
                    id: bankTwoInfo;

                    title: "Bank 2";

                    visible: opacity > 0;
                    opacity: cartController.ready ? 1 : 0;

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 100;
                        }
                    }

                    anchors {
                        left: bankOneInfo.left;
                        right: bankOneInfo.right;
                        top: bankOneInfo.bottom;
                        topMargin: 5;
                    }

                    Column {
                        Label {
                            id: bankTwoTitleLabel;

                            text: "Title: " + cartController.bankTwo.title;
                        }

                        Label {
                            id: bankTwoChecksumLabel;

                            text: "Checksum: " + (cartController.bankTwo.checksumValid ? "valid" : "not valid");
                        }
                    }
                }

                Text {
                    id: refreshText;

                    visible: !cartController.ready;

                    text: "Click to refresh EMS cart status";

                    anchors {
                        fill: emsCartIcon;
                        topMargin: emsCartIcon.height * 0.28;
                        bottomMargin: emsCartIcon.height * 0.135;
                        leftMargin: emsCartIcon.height * 0.120;
                        rightMargin: emsCartIcon.height * 0.120;
                    }

                    font {
                        italic: true;
                        pointSize: 12;
                    }

                    wrapMode: Text.WordWrap;

                    horizontalAlignment: Text.AlignHCenter;
                    verticalAlignment: Text.AlignVCenter;
                }

                Item {
                    id: cartStatus;

                    anchors {
                        left: emsCartIcon.left;
                        right: emsCartIcon.right;
                        bottom: emsCartIcon.top;
                        bottomMargin: 5;
                    }

                    Image {
                        id: cartLed;

                        source: cartController.ready ? "qrc:///images/green_led.svg" : "qrc:///images/red_led.svg";

                        sourceSize.width: 16;
                        sourceSize.height: 16;

                        anchors {
                            bottom: parent.bottom;
                        }
                    }

                    Label {
                        id: cartStatusLabel;

                        text: cartController.ready ? "Cart connected" : "Cart not connected";

                        width: 135;
                        anchors {
                            top: cartLed.top;
                            bottom: cartLed.bottom;
                            left: cartLed.right;
                            leftMargin: 5;
                        }

                        verticalAlignment: Text.AlignBottom;
                    }
                }

                MouseArea {
                    id: refreshCartMouseArea;

                    anchors {
                        fill: parent;
                    }

                    onClicked: {
                        cartController.refresh();
                    }
                }
            }
        }

        Button {
            id: theButton;

            text: "Start";

            height: parent.height / 8;
            width: height * 2;

            style: ButtonStyle {
				label: Text {
					renderType: Text.NativeRendering;
					verticalAlignment: Text.AlignVCenter;
					horizontalAlignment: Text.AlignHCenter;
					font.pointSize: 18;
					text: control.text;
				}
			}

            anchors {
                horizontalCenter: parent.horizontalCenter;
            }
        }
    }
}


