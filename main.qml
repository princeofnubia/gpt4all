import QtCore
import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Basic
import QtQuick.Layouts
import llm
import network

Window {
    id: window
    width: 1280
    height: 720
    visible: true
    title: qsTr("GPT4All v") + Qt.application.version
    color: "#d1d5db"

    Item {
        Accessible.role: Accessible.Window
        Accessible.name: title
    }

    Rectangle {
        id: header
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: 100
        color: "#202123"

        Item {
            anchors.centerIn: parent
            height: childrenRect.height
            visible: LLM.isModelLoaded

            Label {
                id: modelLabel
                color: "#d1d5db"
                padding: 20
                font.pixelSize: 24
                text: ""
                background: Rectangle {
                    color: "#202123"
                }
                horizontalAlignment: TextInput.AlignRight
            }

            ComboBox {
                id: comboBox
                width: 400
                anchors.top: modelLabel.top
                anchors.bottom: modelLabel.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                font.pixelSize: 24
                spacing: 0
                model: LLM.modelList
                Accessible.role: Accessible.ComboBox
                Accessible.name: qsTr("ComboBox for displaying/picking the current model")
                Accessible.description: qsTr("Use this for picking the current model to use; the first item is the current model")
                contentItem: Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    leftPadding: 10
                    rightPadding: 10
                    text: comboBox.displayText
                    font: comboBox.font
                    color: "#d1d5db"
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    elide: Text.ElideRight
                }
                background: Rectangle {
                    color: "#242528"
                }

                onActivated: {
                    LLM.stopGenerating()
                    LLM.modelName = comboBox.currentText
                    chatModel.clear()
                }
            }
        }

        BusyIndicator {
            anchors.centerIn: parent
            visible: !LLM.isModelLoaded
            running: !LLM.isModelLoaded
            Accessible.role: Accessible.Animation
            Accessible.name: qsTr("Busy indicator")
            Accessible.description: qsTr("Displayed when the model is loading")
        }
    }

    SettingsDialog {
        id: settingsDialog
        anchors.centerIn: parent
    }

    Button {
        id: drawerButton
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.topMargin: 30
        anchors.leftMargin: 30
        width: 60
        height: 40
        z: 200
        padding: 15

        Accessible.role: Accessible.ButtonMenu
        Accessible.name: qsTr("Hamburger button")
        Accessible.description: qsTr("Hamburger button that reveals a drawer on the left of the application")

        background: Item {
            anchors.fill: parent

            Rectangle {
                id: bar1
                color: "#7d7d8e"
                width: parent.width
                height: 8
                radius: 2
                antialiasing: true
            }

            Rectangle {
                id: bar2
                anchors.centerIn: parent
                color: "#7d7d8e"
                width: parent.width
                height: 8
                radius: 2
                antialiasing: true
            }

            Rectangle {
                id: bar3
                anchors.bottom: parent.bottom
                color: "#7d7d8e"
                width: parent.width
                height: 8
                radius: 2
                antialiasing: true
            }


        }
        onClicked: {
            drawer.visible = !drawer.visible
        }
    }

    NetworkDialog {
        id: networkDialog
        anchors.centerIn: parent
        Item {
            Accessible.role: Accessible.Dialog
            Accessible.name: qsTr("Network dialog")
            Accessible.description: qsTr("Dialog for opt-in to sharing feedback/conversations")
        }
    }

    Button {
        id: networkButton
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.topMargin: 20
        anchors.rightMargin: 30
        width: 60
        height: 60
        z: 200
        padding: 15

        Accessible.role: Accessible.Button
        Accessible.name: qsTr("Network button")
        Accessible.description: qsTr("Reveals a dialogue where you can opt-in for sharing data over network")

        background: Item {
            anchors.fill: parent
            Rectangle {
                anchors.fill: parent
                color: "transparent"
                visible: Network.isActive
                border.color: "#7d7d8e"
                border.width: 1
                radius: 10
            }
            Image {
                anchors.centerIn: parent
                width: 50
                height: 50
                source: "qrc:/gpt4all-chat/icons/network.svg"
            }
        }

        onClicked: {
            if (Network.isActive)
                Network.isActive = false
            else
                networkDialog.open();
        }
    }

    Button {
        id: settingsButton
        anchors.right: networkButton.left
        anchors.top: parent.top
        anchors.topMargin: 30
        anchors.rightMargin: 30
        width: 60
        height: 40
        z: 200
        padding: 15

        background: Item {
            anchors.fill: parent
            Image {
                anchors.centerIn: parent
                width: 40
                height: 40
                source: "qrc:/gpt4all-chat/icons/settings.svg"
            }
        }

        Accessible.role: Accessible.Button
        Accessible.name: qsTr("Settings button")
        Accessible.description: qsTr("Reveals a dialogue where you can change various settings")

        onClicked: {
            settingsDialog.open()
        }
    }

    Dialog {
        id: copyMessage
        anchors.centerIn: parent
        modal: false
        opacity: 0.9
        Text {
            horizontalAlignment: Text.AlignJustify
            text: qsTr("Conversation copied to clipboard.")
            color: "#d1d5db"
            Accessible.role: Accessible.HelpBalloon
            Accessible.name: text
            Accessible.description: qsTr("Reveals a shortlived help balloon")
        }
        background: Rectangle {
            anchors.fill: parent
            color: "#202123"
            border.width: 1
            border.color: "white"
            radius: 10
        }

        exit: Transition {
            NumberAnimation { duration: 500; property: "opacity"; from: 1.0; to: 0.0 }
        }
    }

    Button {
        id: copyButton
        anchors.right: settingsButton.left
        anchors.top: parent.top
        anchors.topMargin: 30
        anchors.rightMargin: 30
        width: 60
        height: 40
        z: 200
        padding: 15

        Accessible.role: Accessible.Button
        Accessible.name: qsTr("Copy button")
        Accessible.description: qsTr("Copy the conversation to the clipboard")

        background: Item {
            anchors.fill: parent
            Image {
                anchors.centerIn: parent
                width: 40
                height: 40
                source: "qrc:/gpt4all-chat/icons/copy.svg"
            }
        }

        TextEdit{
            id: copyEdit
            visible: false
        }

        onClicked: {
            var conversation = getConversation()
            copyEdit.text = conversation
            copyEdit.selectAll()
            copyEdit.copy()
            copyMessage.open()
            timer.start()
        }
        Timer {
            id: timer
            interval: 500; running: false; repeat: false
            onTriggered: copyMessage.close()
        }
    }

    function getConversation() {
        var conversation = "";
        for (var i = 0; i < chatModel.count; i++) {
            var item = chatModel.get(i)
            var string = item.name;
            var isResponse = item.name === qsTr("Response: ")
            if (item.currentResponse)
                string += LLM.response
            else
                string += chatModel.get(i).value
            if (isResponse && item.stopped)
                string += " <stopped>"
            string += "\n"
            conversation += string
        }
        return conversation
    }

    function getConversationJson() {
        var str = "{\"conversation\": [";
        for (var i = 0; i < chatModel.count; i++) {
            var item = chatModel.get(i)
            var isResponse = item.name === qsTr("Response: ")
            str += "{\"content\": \"";
            if (item.currentResponse)
                str += LLM.response + "\""
            else
                str += item.value + "\""
            str += ", \"role\": \"" + (isResponse ? "assistant" : "user") + "\"";
            if (isResponse && item.thumbsUpState !== item.thumbsDownState)
                str += ", \"rating\": \"" + (item.thumbsUpState ? "positive" : "negative") + "\"";
            if (isResponse && item.newResponse !== "")
                str += ", \"edited_content\": \"" + item.newResponse + "\"";
            if (isResponse && item.stopped)
                str += ", \"stopped\": \"true\""
            if (!isResponse)
                str += "},"
            else
                str += ((i < chatModel.count - 1) ? "}," : "}")
        }
        return str + "]}"
    }

    Button {
        id: resetContextButton
        anchors.right: copyButton.left
        anchors.top: parent.top
        anchors.topMargin: 30
        anchors.rightMargin: 30
        width: 60
        height: 40
        z: 200
        padding: 15

        Accessible.role: Accessible.Button
        Accessible.name: text
        Accessible.description: qsTr("Reset the context which erases current conversation")

        background: Item {
            anchors.fill: parent
            Image {
                anchors.centerIn: parent
                width: 40
                height: 40
                source: "qrc:/gpt4all-chat/icons/regenerate.svg"
            }
        }

        onClicked: {
            LLM.stopGenerating()
            LLM.resetContext()
            chatModel.clear()
        }
    }

    Dialog {
        id: checkForUpdatesError
        anchors.centerIn: parent
        modal: false
        opacity: 0.9
        padding: 20
        Text {
            horizontalAlignment: Text.AlignJustify
            text: qsTr("ERROR: Update system could not find the MaintenanceTool used<br>
                   to check for updates!<br><br>
                   Did you install this application using the online installer? If so,<br>
                   the MaintenanceTool executable should be located one directory<br>
                   above where this application resides on your filesystem.<br><br>
                   If you can't start it manually, then I'm afraid you'll have to<br>
                   reinstall.")
            color: "#d1d5db"
            Accessible.role: Accessible.Dialog
            Accessible.name: text
            Accessible.description: qsTr("Dialog indicating an error")
        }
        background: Rectangle {
            anchors.fill: parent
            color: "#202123"
            border.width: 1
            border.color: "white"
            radius: 10
        }
    }

    ModelDownloaderDialog {
        id: downloadNewModels
        anchors.centerIn: parent
        Item {
            Accessible.role: Accessible.Dialog
            Accessible.name: qsTr("Download new models dialog")
            Accessible.description: qsTr("Dialog for downloading new models")
        }
    }

    Drawer {
        id: drawer
        y: header.height
        width: 0.3 * window.width
        height: window.height - y
        modal: false
        opacity: 0.9

        background: Rectangle {
            height: parent.height
            color: "#202123"
        }

        Item {
            anchors.fill: parent
            anchors.margins: 30

            Accessible.role: Accessible.Pane
            Accessible.name: qsTr("Drawer on the left of the application")
            Accessible.description: qsTr("Drawer that is revealed by pressing the hamburger button")

            Label {
                id: conversationList
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                wrapMode: Text.WordWrap
                text: qsTr("Chat lists of specific conversations coming soon! Check back often for new features :)")
                color: "#d1d5db"

                Accessible.role: Accessible.Paragraph
                Accessible.name: qsTr("Coming soon")
                Accessible.description: text
            }

            Label {
                id: discordLink
                textFormat: Text.RichText
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: conversationList.bottom
                anchors.topMargin: 20
                wrapMode: Text.WordWrap
                text: qsTr("Check out our discord channel <a href=\"https://discord.gg/4M2QFmTt2k\">https://discord.gg/4M2QFmTt2k</a>")
                onLinkActivated: { Qt.openUrlExternally("https://discord.gg/4M2QFmTt2k") }
                color: "#d1d5db"
                linkColor: "#1e8cda"

                Accessible.role: Accessible.Link
                Accessible.name: qsTr("Discord link")
            }

            Label {
                id: nomicProps
                textFormat: Text.RichText
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: discordLink.bottom
                anchors.topMargin: 20
                wrapMode: Text.WordWrap
                text: qsTr("Thanks to <a href=\"https://home.nomic.ai\">nomic.ai</a> and the community for contributing so much great data and energy!")
                onLinkActivated: { Qt.openUrlExternally("https://home.nomic.ai") }
                color: "#d1d5db"
                linkColor: "#1e8cda"

                Accessible.role: Accessible.Paragraph
                Accessible.name: qsTr("Thank you blurb")
                Accessible.description: qsTr("Contains embedded link to https://home.nomic.ai")
            }

            Button {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: downloadButton.top
                anchors.bottomMargin: 20
                padding: 15
                contentItem: Text {
                    text: qsTr("Check for updates...")
                    horizontalAlignment: Text.AlignHCenter
                    color: "#d1d5db"

                    Accessible.role: Accessible.Button
                    Accessible.name: text
                    Accessible.description: qsTr("Use this to launch an external application that will check for updates to the installer")
                }

                background: Rectangle {
                    opacity: .5
                    border.color: "#7d7d8e"
                    border.width: 1
                    radius: 10
                    color: "#343541"
                }

                onClicked: {
                    if (!LLM.checkForUpdates())
                        checkForUpdatesError.open()
                }
            }

            Button {
                id: downloadButton
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                padding: 15
                contentItem: Text {
                    text: qsTr("Download new models...")
                    horizontalAlignment: Text.AlignHCenter
                    color: "#d1d5db"

                    Accessible.role: Accessible.Button
                    Accessible.name: text
                    Accessible.description: qsTr("Use this to launch a dialog to download new models")
                }

                background: Rectangle {
                    opacity: .5
                    border.color: "#7d7d8e"
                    border.width: 1
                    radius: 10
                    color: "#343541"
                }

                onClicked: {
                    downloadNewModels.open()
                }
            }

        }
    }

    Rectangle {
        id: conversation
        color: "#343541"
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.top: header.bottom

        ScrollView {
            id: scrollView
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: textInputView.top
            anchors.bottomMargin: 30
            ScrollBar.vertical.policy: ScrollBar.AlwaysOn

            ListModel {
                id: chatModel
            }

            Rectangle {
                anchors.fill: parent
                color: "#444654"

                ListView {
                    id: listView
                    anchors.fill: parent
                    model: chatModel

                    Accessible.role: Accessible.List
                    Accessible.name: qsTr("List of prompt/response pairs")
                    Accessible.description: qsTr("This is the list of prompt/response pairs comprising the actual conversation with the model")

                    delegate: TextArea {
                        text: currentResponse ? LLM.response : (value ? value : "")
                        width: listView.width
                        color: "#d1d5db"
                        wrapMode: Text.WordWrap
                        focus: false
                        readOnly: true
                        font.pixelSize: 24
                        cursorVisible: currentResponse ? (LLM.response !== "" ? LLM.responseInProgress : false) : false
                        cursorPosition: text.length
                        background: Rectangle {
                            color: name === qsTr("Response: ") ? "#444654" : "#343541"
                        }

                        Accessible.role: Accessible.Paragraph
                        Accessible.name: name
                        Accessible.description: name === qsTr("Response: ") ? "The response by the model" : "The prompt by the user"

                        topPadding: 20
                        bottomPadding: 20
                        leftPadding: 100
                        rightPadding: 100

                        BusyIndicator {
                            anchors.left: parent.left
                            anchors.leftMargin: 90
                            anchors.top: parent.top
                            anchors.topMargin: 5
                            visible: (currentResponse ? true : false) && LLM.response === "" && LLM.responseInProgress
                            running: (currentResponse ? true : false) && LLM.response === "" && LLM.responseInProgress

                            Accessible.role: Accessible.Animation
                            Accessible.name: qsTr("Busy indicator")
                            Accessible.description: qsTr("Displayed when the model is thinking")
                        }

                        Rectangle {
                            anchors.left: parent.left
                            anchors.top: parent.top
                            anchors.leftMargin: 20
                            anchors.topMargin: 20
                            width: 30
                            height: 30
                            radius: 5
                            color: name === qsTr("Response: ") ? "#10a37f" : "#ec86bf"

                            Text {
                                anchors.centerIn: parent
                                text: name === qsTr("Response: ") ? "R" : "P"
                                color: "white"
                            }
                        }

                        ThumbsDownDialog {
                            id: thumbsDownDialog
                            property point globalPoint: mapFromItem(window,
                                window.width / 2 - width / 2,
                                window.height / 2 - height / 2)
                            x: globalPoint.x
                            y: globalPoint.y
                            property string text: currentResponse ? LLM.response : (value ? value : "")
                            response: newResponse === "" ? text : newResponse
                            onAccepted: {
                                var responseHasChanged = response !== text && response !== newResponse
                                if (thumbsDownState && !thumbsUpState && !responseHasChanged)
                                    return

                                newResponse = response
                                thumbsDownState = true
                                thumbsUpState = false
                                Network.sendConversation(getConversationJson());
                            }
                        }

                        Column {
                            visible: name === qsTr("Response: ") &&
                                (!currentResponse || !LLM.responseInProgress) && Network.isActive
                            anchors.right: parent.right
                            anchors.rightMargin: 20
                            anchors.top: parent.top
                            anchors.topMargin: 20
                            spacing: 10

                            Item {
                                width: childrenRect.width
                                height: childrenRect.height
                                Button {
                                    id: thumbsUp
                                    width: 30
                                    height: 30
                                    opacity: thumbsUpState || thumbsUpState == thumbsDownState ? 1.0 : 0.2
                                    background: Image {
                                        anchors.fill: parent
                                        source: "qrc:/gpt4all-chat/icons/thumbs_up.svg"
                                    }
                                    onClicked: {
                                        if (thumbsUpState && !thumbsDownState)
                                            return

                                        newResponse = ""
                                        thumbsUpState = true
                                        thumbsDownState = false
                                        Network.sendConversation(getConversationJson());
                                    }
                                }

                                Button {
                                    id: thumbsDown
                                    anchors.top: thumbsUp.top
                                    anchors.topMargin: 10
                                    anchors.left: thumbsUp.right
                                    anchors.leftMargin: 2
                                    width: 30
                                    height: 30
                                    checked: thumbsDownState
                                    opacity: thumbsDownState || thumbsUpState == thumbsDownState ? 1.0 : 0.2
                                    transform: [
                                      Matrix4x4 {
                                        matrix: Qt.matrix4x4(-1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1)
                                      },
                                      Translate {
                                        x: thumbsDown.width
                                      }
                                    ]
                                    background: Image {
                                        anchors.fill: parent
                                        source: "qrc:/gpt4all-chat/icons/thumbs_down.svg"
                                    }
                                    onClicked: {
                                        thumbsDownDialog.open()
                                    }
                                }
                            }
                        }
                    }

                    property bool shouldAutoScroll: true
                    property bool isAutoScrolling: false

                    Connections {
                        target: LLM
                        function onResponseChanged() {
                            if (listView.shouldAutoScroll) {
                                listView.isAutoScrolling = true
                                listView.positionViewAtEnd()
                                listView.isAutoScrolling = false
                            }
                        }
                    }

                    onContentYChanged: {
                        if (!isAutoScrolling)
                            shouldAutoScroll = atYEnd
                    }

                    Component.onCompleted: {
                        shouldAutoScroll = true
                        positionViewAtEnd()
                    }

                    footer: Item {
                        id: bottomPadding
                        width: parent.width
                        height: 60
                    }
                }
            }
        }

        Button {
            Image {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 15
                source: LLM.responseInProgress ? "qrc:/gpt4all-chat/icons/stop_generating.svg" : "qrc:/gpt4all-chat/icons/regenerate.svg"
            }
            leftPadding: 50
            onClicked: {
                if (chatModel.count)
                    var listElement = chatModel.get(chatModel.count - 1)

                if (LLM.responseInProgress) {
                    listElement.stopped = true
                    LLM.stopGenerating()
                } else {
                    LLM.regenerateResponse()
                    if (chatModel.count) {
                        if (listElement.name === qsTr("Response: ")) {
                            listElement.currentResponse = true
                            listElement.stopped = false
                            listElement.value = LLM.response
                            listElement.thumbsUpState = false
                            listElement.thumbsDownState = false
                            listElement.newResponse = ""
                            LLM.prompt(listElement.prompt, settingsDialog.promptTemplate,
                                       settingsDialog.maxLength,
                                       settingsDialog.topK, settings.topP,
                                       settingsDialog.temperature,
                                       settingsDialog.promptBatchSize)
                        }
                    }
                }
            }
            anchors.bottom: textInputView.top
            anchors.horizontalCenter: textInputView.horizontalCenter
            anchors.bottomMargin: 40
            padding: 15
            contentItem: Text {
                text: LLM.responseInProgress ? qsTr("Stop generating") : qsTr("Regenerate response")
                color: "#d1d5db"
                Accessible.role: Accessible.Button
                Accessible.name: text
                Accessible.description: qsTr("Controls generation of the response")
            }
            background: Rectangle {
                opacity: .5
                border.color: "#7d7d8e"
                border.width: 1
                radius: 10
                color: "#343541"
            }
        }

        ScrollView {
            id: textInputView
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: 30
            height: Math.min(contentHeight, 200)

            TextArea {
                id: textInput
                color: "#dadadc"
                padding: 20
                enabled: LLM.isModelLoaded
                font.pixelSize: 24
                placeholderText: qsTr("Send a message...")
                placeholderTextColor: "#7d7d8e"
                background: Rectangle {
                    color: "#40414f"
                    radius: 10
                }
                Accessible.role: Accessible.EditableText
                Accessible.name: placeholderText
                Accessible.description: qsTr("Textfield for sending messages/prompts to the model")
                Keys.onReturnPressed: (event)=> {
                    if (event.modifiers & Qt.ControlModifier || event.modifiers & Qt.ShiftModifier)
                        event.accepted = false;
                    else
                        editingFinished();
                }
                onEditingFinished: {
                    if (textInput.text === "")
                        return

                    LLM.stopGenerating()

                    if (chatModel.count) {
                        var listElement = chatModel.get(chatModel.count - 1)
                        listElement.currentResponse = false
                        listElement.value = LLM.response
                    }
                    var prompt = textInput.text + "\n"
                    chatModel.append({"name": qsTr("Prompt: "), "currentResponse": false,
                        "value": textInput.text})
                    chatModel.append({"id": chatModel.count, "name": qsTr("Response: "),
                        "currentResponse": true, "value": "", "stopped": false,
                        "thumbsUpState": false, "thumbsDownState": false,
                        "newResponse": "",
                        "prompt": prompt})
                    LLM.resetResponse()
                    LLM.prompt(prompt, settingsDialog.promptTemplate,
                               settingsDialog.maxLength,
                               settingsDialog.topK,
                               settingsDialog.topP,
                               settingsDialog.temperature,
                               settingsDialog.promptBatchSize)
                    textInput.text = ""
                }
            }
        }

        Button {
            anchors.right: textInputView.right
            anchors.verticalCenter: textInputView.verticalCenter
            anchors.rightMargin: 15
            width: 30
            height: 30

            background: Image {
                anchors.centerIn: parent
                source: "qrc:/gpt4all-chat/icons/send_message.svg"
            }

            Accessible.role: Accessible.Button
            Accessible.name: qsTr("Send the message button")
            Accessible.description: qsTr("Sends the message/prompt contained in textfield to the model")

            onClicked: {
                textInput.accepted()
            }
        }
    }
}
