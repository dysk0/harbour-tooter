import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.tooter.Uploader 1.0
import "../lib/API.js" as Logic
import "./components/"

Page {
	id: conversationPage
	property string type
	property alias title: header.title
	property alias description: header.description
	property alias avatar: header.image
	property string suggestedUser: ""
	property ListModel suggestedModel
	property string toot_id: ""
    property int tootMaxChar: 500;
	property ListModel mdl
	allowedOrientations: Orientation.All
	onSuggestedUserChanged: {
		console.log(suggestedUser)
		suggestedModel = Qt.createQmlObject(
			'import QtQuick 2.0; ListModel {   }',
			Qt.application, 'InternalQmlObject'
		)
		predictionList.visible = false
		if (suggestedUser.length > 0) {
			var msg = {
				"action": 'accounts/search',
				"method": 'GET',
				"model": suggestedModel,
				"mode": "append",
				"params": [{
						"name": "q",
						"data": suggestedUser
					}],
				"conf": Logic.conf
			}
			worker.sendMessage(msg)
			predictionList.visible = true
		}
	}

	ListModel {
		id: mediaModel
		onCountChanged: {
			btnAddImage.enabled = mediaModel.count < 4
		}
	}

	WorkerScript {
		id: worker
		source: "../lib/Worker.js"
		onMessage: {
			console.log(JSON.stringify(messageObject))
		}
	}

	ProfileHeader {
		id: header
		visible: false
	}
	SilicaListView {
		id: conversationList
		header: PageHeader {
			title: qsTr("Conversation")
		}
		clip: true
		anchors {
			top: parent.top
			bottom: panel.top
			left: parent.left
			right: parent.right
		}
		model: mdl
		section {
			property: 'section'
			delegate: SectionHeader {
				height: Theme.itemSizeExtraSmall
				text: Format.formatDate(section, Formatter.DateMedium)
			}
		}
		delegate: VisualContainer {
		}
		onCountChanged: {
			if (mdl)
				for (var i = 0; i < mdl.count; i++) {
					if (mdl.get(i).status_id === toot_id) {
						console.log(mdl.get(i).status_id)
						positionViewAtIndex(i, ListView.Center)
					}
				}
		}
	}
	Rectangle {
		id: predictionList
		visible: false
		anchors.bottom: panel.top
		anchors.left: parent.left
		anchors.right: panel.right
		height: suggestedModel.count > 6 ? Theme.itemSizeMedium * 6 : Theme.itemSizeMedium * suggestedModel.count
		color: Theme.highlightDimmerColor

		SilicaListView {
			anchors.fill: parent
			model: suggestedModel
			clip: true

			delegate: ItemUser {
				onClicked: {
					var start = toot.cursorPosition
					while (toot.text[start] !== "@" && start > 0) {
						start--
					}
					textOperations.text = toot.text
					textOperations.cursorPosition = toot.cursorPosition
					textOperations.moveCursorSelection(start - 1, TextInput.SelectWords)
					toot.text = textOperations.text.substring(0, textOperations.selectionStart)
						+ ' @'
						+ model.account_acct
						+ ' '
						+ textOperations.text.substring(textOperations.selectionEnd).trim()

					toot.cursorPosition = toot.text.indexOf('@' + model.account_acct)
				}
			}
			onCountChanged: {
				positionViewAtIndex(suggestedModel.count - 1, ListView.End)
			}
		}
	}

	DockedPanel {
		id: panel
		open: true
		onExpandedChanged: {
			if (!expanded) {
				show()
			}
		}

		width: parent.width
		height: progressBar.height + toot.height + (mediaModel.count ? uploadedImages.height : 0)
			+ btnContentWarning.height + Theme.paddingMedium
			+ (warningContent.visible ? warningContent.height : 0)
		dock: Dock.Bottom
		Rectangle {
			width: parent.width
			height: progressBar.height
			color: Theme.highlightBackgroundColor
			opacity: 0.2
			anchors {
				left: parent.left
				right: parent.right
				top: parent.top
			}
		}
		Rectangle {
			id: progressBar
			width: toot.text.length ? panel.width * (toot.text.length / tootMaxChar) : 0

			height: Theme.itemSizeSmall * 0.05
			color: Theme.highlightBackgroundColor
			opacity: 0.7
			anchors {
				left: parent.left
				top: parent.top
			}
		}

		TextField {
			id: warningContent
			visible: false
			height: visible ? implicitHeight : 0
			anchors {
				top: parent.top
				topMargin: Theme.paddingMedium
				left: parent.left
				right: parent.right
			}
			autoScrollEnabled: true
			labelVisible: false
            placeholderText: qsTr("Write your warning here")
            placeholderColor: palette.highlightColor
            color: palette.highlightColor
			horizontalAlignment: Text.AlignLeft
			EnterKey.onClicked: {
				//tweet()
			}
		}
		TextInput {
			id: textOperations
			visible: false
		}

		TextArea {
			id: toot
			anchors {
				top: warningContent.bottom
				topMargin: Theme.paddingMedium
				left: parent.left
				right: parent.right
				rightMargin: Theme.paddingMedium
			}
			autoScrollEnabled: true
			labelVisible: false
			//focus: true
			text: description !== "" && (description.charAt(0) == '@'
																	 || description.charAt(
																		 0) == '#') ? description + ' ' : ''
            height: Math.max(270, Math.min(900, implicitHeight))
            //height: implicitHeight
	    horizontalAlignment: Text.AlignLeft
            placeholderText: qsTr("What's on your mind?")
	    font.pixelSize: Theme.fontSizeSmall
			EnterKey.onClicked: {
				//tweet()
			}
			onTextChanged: {
				textOperations.text = toot.text
				textOperations.cursorPosition = toot.cursorPosition
				textOperations.selectWord()
				textOperations.select(
							textOperations.selectionStart ? textOperations.selectionStart - 1 : 0,
							textOperations.selectionEnd)
				//console.log(textOperations.text.substr(textOperations.selectionStart, textOperations.selectionEnd))
				console.log(toot.text.length)
				suggestedUser = ""
				if (textOperations.selectedText.charAt(0) === "@") {
					suggestedUser = textOperations.selectedText.trim().substring(1)
				}
			}
		}
		IconButton {
			id: btnSmileys
			property string selection
			onSelectionChanged: {
				console.log(selection)
			}

			anchors {
                top: warningContent.bottom
				bottom: bottom.top
				right: parent.right
				rightMargin: Theme.paddingSmall
			}
            icon.source: "../../qml/images/emojiselect.svg" + (pressed ? Theme.highlightColor : (warningContent.visible ? Theme.secondaryHighlightColor : Theme.primaryColor))
			onClicked: pageStack.push(firstWizardPage)
		}
		SilicaGridView {
			id: uploadedImages
			width: parent.width
            anchors.top: bottom.toot
			anchors.bottom: parent.bottom
            height: mediaModel.count ? Theme.itemSizeSmall : 0
			model: mediaModel
			cellWidth: uploadedImages.width / 4
            cellHeight: Theme.itemSizeSmall
			delegate: BackgroundItem {
				id: myDelegate
				width: uploadedImages.cellWidth
				height: uploadedImages.cellHeight
				RemorseItem {
					id: remorse
				}
				Image {
					anchors.fill: parent
					fillMode: Image.PreserveAspectCrop
					source: model.preview_url
				}

				onClicked: {
					var idx = index
					console.log(idx)
					//mediaModel.remove(idx)
					remorse.execute(myDelegate, qsTr("Delete"), function () {
						mediaModel.remove(idx)
					})
				}
			}
			add: Transition {
				NumberAnimation {
					property: "opacity"
					from: 0
					to: 1.0
					duration: 800
				}
			}

			remove: Transition {
				NumberAnimation {
					property: "opacity"
					from: 1.0
					to: 0
					duration: 800
				}
			}
			displaced: Transition {
				NumberAnimation {
					properties: "x,y"
					duration: 800
					easing.type: Easing.InOutBack
				}
			}
		}
		IconButton {

			id: btnContentWarning
			anchors {
				verticalCenter: privacy.verticalCenter
				left: parent.left
				leftMargin: Theme.paddingMedium
			}
			icon.source: "image://theme/icon-s-warning?"
				+ (pressed ? Theme.highlightColor : (warningContent.visible ? Theme.secondaryHighlightColor : Theme.primaryColor))
			onClicked: warningContent.visible = !warningContent.visible
		}
		IconButton {
			id: btnAddImage
			enabled: mediaModel.count < 4
			anchors {
				verticalCenter: privacy.verticalCenter
				left: btnContentWarning.right
				leftMargin: Theme.paddingSmall
			}
			icon.source: "image://theme/icon-s-attach?"
				+ (pressed ? Theme.highlightColor : (warningContent.visible ? Theme.secondaryHighlightColor : Theme.primaryColor))
			onClicked: {
				btnAddImage.enabled = false
				var once = true
				var imagePicker = pageStack.push("Sailfish.Pickers.ImagePickerPage", {"allowedOrientations": Orientation.All})
				imagePicker.selectedContentChanged.connect(function () {
					var imagePath = imagePicker.selectedContent
					console.log(imagePath)
					imageUploader.setUploadUrl(Logic.conf.instance + "/api/v1/media")
					imageUploader.setFile(imagePath)
					imageUploader.setAuthorizationHeader(Logic.conf.api_user_token)
					imageUploader.upload()
				})
			}
		}
		ImageUploader {
			id: imageUploader

			onProgressChanged: {
				console.log("progress " + progress)
				uploadProgress.width = parent.width * progress
			}

			onSuccess: {
				uploadProgress.width = 0
				console.log(replyData)

				mediaModel.append(JSON.parse(replyData))
			}

			onFailure: {
				uploadProgress.width = 0
				btnAddImage.enabled = true
				console.log(status)
				console.log(statusText)
			}
		}
		ComboBox {
			id: privacy
			anchors {
                top: toot.bottom
				topMargin: -Theme.paddingSmall * 2
				left: btnAddImage.right
				right: btnSend.left
			}
			menu: ContextMenu {
				MenuItem {
                    text: qsTr("Public")
				}
				MenuItem {
                    text: qsTr("Unlisted")
				}
				MenuItem {
                    text: qsTr("Followers-only")
				}
				MenuItem {
                    text: qsTr("Direct")
				}
			}
		}

		IconButton {
			id: btnSend
			icon.source: "image://theme/icon-m-send?"
				+ (pressed ? Theme.highlightColor : Theme.primaryColor)
			anchors {
                top: toot.bottom
				right: parent.right
                rightMargin: Theme.paddingSmall
			}
			enabled: toot.text !== "" && toot.text.length < tootMaxChar && uploadProgress.width == 0
			onClicked: {
                var visibility = ["public", "unlisted", "private", "direct"]
				var media_ids = []
				for (var k = 0; k < mediaModel.count; k++) {
					console.log(mediaModel.get(k).id)
					media_ids.push(mediaModel.get(k).id)
				}

				var msg = {
					"action": 'statuses',
					"method": 'POST',
					"model": mdl,
					"mode": "append",
					"params": {
						"status": toot.text,
						"visibility": visibility[privacy.currentIndex],
						"media_ids": media_ids
					},
					"conf": Logic.conf
				}
				if (toot_id)
					msg.params['in_reply_to_id'] = (toot_id) + ""

				if (warningContent.visible && warningContent.text.length > 0) {
					msg.params['sensitive'] = 1
					msg.params['spoiler_text'] = warningContent.text
				}

				worker.sendMessage(msg)
				warningContent.text = ""
				toot.text = ""
				mediaModel.clear()
                pageStack.pop()
			}
		}

		Rectangle {
			id: uploadProgress
			color: Theme.highlightBackgroundColor
			anchors.bottom: parent.bottom
			anchors.left: parent.left
			height: 3
		}
	}
	Component.onCompleted: {
		toot.cursorPosition = toot.text.length
		if (mdl.count > 0) {
			var setIndex = 0
			switch (mdl.get(0).status_visibility) {
			case "unlisted":
				setIndex = 1
				break
			case "private":
				setIndex = 2
				break
			case "direct":
				privacy.enabled = false
				setIndex = 3
				break
			default:
				privacy.enabled = true
				setIndex = 0
			}
			privacy.currentIndex = setIndex
		}

		console.log(JSON.stringify())

		worker.sendMessage({
			"action": 'statuses/' + mdl.get(0).status_id + '/context',
			"method": 'GET',
			"model": mdl,
			"params": { },
			"conf": Logic.conf
		})
	}
	Component {
		id: firstWizardPage

		Dialog {
			id: emoticonsDialog
			canAccept: false //selector.currentIndex >= 0

			//acceptDestination: conversationPage
			onAcceptPendingChanged: {
				if (acceptPending) {

					// Tell the destination page what the selected category is
					// acceptDestinationInstance.category = selector.value
				}
			}

			SilicaGridView {
				id: gridView
				anchors.fill: parent
				cellWidth: gridView.width / 6
				cellHeight: cellWidth
				header: PageHeader {
					title: qsTr("Emojis")
					description: qsTr("Tap to insert")
				}
				model: ListModel {
					ListElement { section: "smileys"; glyph: "😁" }
					ListElement { section: "smileys"; glyph: "😂" }
					ListElement { section: "smileys"; glyph: "😃" }
					ListElement { section: "smileys"; glyph: "😄" }
					ListElement { section: "smileys"; glyph: "😅" }
					ListElement { section: "smileys"; glyph: "😆" }
					ListElement { section: "smileys"; glyph: "😉" }
					ListElement { section: "smileys"; glyph: "😊" }
					ListElement { section: "smileys"; glyph: "😋" }
					ListElement { section: "smileys"; glyph: "😌" }
					ListElement { section: "smileys"; glyph: "😍" }
					ListElement { section: "smileys"; glyph: "😏" }
					ListElement { section: "smileys"; glyph: "😒" }
					ListElement { section: "smileys"; glyph: "😓" }
					ListElement { section: "smileys"; glyph: "😔" }
					ListElement { section: "smileys"; glyph: "😖" }
					ListElement { section: "smileys"; glyph: "😘" }
					ListElement { section: "smileys"; glyph: "😚" }
					ListElement { section: "smileys"; glyph: "😜" }
					ListElement { section: "smileys"; glyph: "😝" }
					ListElement { section: "smileys"; glyph: "😞" }
					ListElement { section: "smileys"; glyph: "😠" }
					ListElement { section: "smileys"; glyph: "😡" }
					ListElement { section: "smileys"; glyph: "😢" }
					ListElement { section: "smileys"; glyph: "😣" }
					ListElement { section: "smileys"; glyph: "😤" }
					ListElement { section: "smileys"; glyph: "😥" }
					ListElement { section: "smileys"; glyph: "😨" }
					ListElement { section: "smileys"; glyph: "😩" }
					ListElement { section: "smileys"; glyph: "😪" }
					ListElement { section: "smileys"; glyph: "😫" }
					ListElement { section: "smileys"; glyph: "😭" }
					ListElement { section: "smileys"; glyph: "😰" }
					ListElement { section: "smileys"; glyph: "😱" }
					ListElement { section: "smileys"; glyph: "😲" }
					ListElement { section: "smileys"; glyph: "😳" }
					ListElement { section: "smileys"; glyph: "😵" }
					ListElement { section: "smileys"; glyph: "😷" }
					ListElement { section: "smileys"; glyph: "😸" }
					ListElement { section: "smileys"; glyph: "😹" }
					ListElement { section: "smileys"; glyph: "😺" }
					ListElement { section: "smileys"; glyph: "😻" }
					ListElement { section: "smileys"; glyph: "😼" }
					ListElement { section: "smileys"; glyph: "😽" }
					ListElement { section: "smileys"; glyph: "😾" }
					ListElement { section: "smileys"; glyph: "😿" }
					ListElement { section: "smileys"; glyph: "🙀" }
					ListElement { section: "smileys"; glyph: "🙅" }
					ListElement { section: "smileys"; glyph: "🙆" }
					ListElement { section: "smileys"; glyph: "🙇" }
					ListElement { section: "smileys"; glyph: "🙈" }
					ListElement { section: "smileys"; glyph: "🙉" }
					ListElement { section: "smileys"; glyph: "🙊" }
					ListElement { section: "smileys"; glyph: "🙋" }
					ListElement { section: "smileys"; glyph: "🙌" }
					ListElement { section: "smileys"; glyph: "🙍" }
					ListElement { section: "smileys"; glyph: "🙎" }
					ListElement { section: "smileys"; glyph: "🙏" }

					ListElement { section: "Transport and map"; glyph: "🚀" }
					ListElement { section: "Transport and map"; glyph: "🚃" }
					ListElement { section: "Transport and map"; glyph: "🚀" }
					ListElement { section: "Transport and map"; glyph: "🚄" }
					ListElement { section: "Transport and map"; glyph: "🚅" }
					ListElement { section: "Transport and map"; glyph: "🚇" }
					ListElement { section: "Transport and map"; glyph: "🚉" }
					ListElement { section: "Transport and map"; glyph: "🚌" }
					ListElement { section: "Transport and map"; glyph: "🚏" }
					ListElement { section: "Transport and map"; glyph: "🚑" }
					ListElement { section: "Transport and map"; glyph: "🚒" }
					ListElement { section: "Transport and map"; glyph: "🚓" }
					ListElement { section: "Transport and map"; glyph: "🚕" }
					ListElement { section: "Transport and map"; glyph: "🚗" }
					ListElement { section: "Transport and map"; glyph: "🚙" }
					ListElement { section: "Transport and map"; glyph: "🚚" }
					ListElement { section: "Transport and map"; glyph: "🚢" }
					ListElement { section: "Transport and map"; glyph: "🚨" }
					ListElement { section: "Transport and map"; glyph: "🚩" }
					ListElement { section: "Transport and map"; glyph: "🚪" }
					ListElement { section: "Transport and map"; glyph: "🚫" }
					ListElement { section: "Transport and map"; glyph: "🚬" }
					ListElement { section: "Transport and map"; glyph: "🚭" }
					ListElement { section: "Transport and map"; glyph: "🚲" }
					ListElement { section: "Transport and map"; glyph: "🚶" }
					ListElement { section: "Transport and map"; glyph: "🚹" }
					ListElement { section: "Transport and map"; glyph: "🚺" }
					ListElement { section: "Transport and map"; glyph: "🚻" }
					ListElement { section: "Transport and map"; glyph: "🚼" }
					ListElement { section: "Transport and map"; glyph: "🚽" }
					ListElement { section: "Transport and map"; glyph: "🚾" }
					ListElement { section: "Transport and map"; glyph: "🛀" }

					ListElement { section: "Horoscope Signs"; glyph: "♈" }
					ListElement { section: "Horoscope Signs"; glyph: "♉" }
					ListElement { section: "Horoscope Signs"; glyph: "♊" }
					ListElement { section: "Horoscope Signs"; glyph: "♋" }
					ListElement { section: "Horoscope Signs"; glyph: "♌" }
					ListElement { section: "Horoscope Signs"; glyph: "♍" }
					ListElement { section: "Horoscope Signs"; glyph: "♎" }
					ListElement { section: "Horoscope Signs"; glyph: "♏" }
					ListElement { section: "Horoscope Signs"; glyph: "♐" }
					ListElement { section: "Horoscope Signs"; glyph: "♑" }
					ListElement { section: "Horoscope Signs"; glyph: "♒" }
					ListElement { section: "Horoscope Signs"; glyph: "♓" }
				}
				delegate: BackgroundItem {
					width: gridView.cellWidth
					height: gridView.cellHeight
					Label {
						anchors.centerIn: parent
						color: (highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor)
						font.pixelSize: Theme.fontSizeLarge
						text: glyph
					}
					onClicked: {
						var cursorPosition = toot.cursorPosition
						toot.text = toot.text.substring(
									0, cursorPosition) + model.glyph + toot.text.substring(
									cursorPosition)
						toot.cursorPosition = cursorPosition + model.glyph.length
						emoticonsDialog.canAccept = true
						emoticonsDialog.accept()
					}
				}
			}
		}
	}
}
