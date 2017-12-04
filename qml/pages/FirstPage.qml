/*
Copyright (C) 2017  Eike Waldt
Contact: jolla@yeoldegrove.de

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program. If not, see <http://www.gnu.org/licenses/>.
*/

import QtQuick 2.0
import Sailfish.Silica 1.0
import io.thp.pyotherside 1.4


Page {
    id: page

    allowedOrientations: Orientation.All

    SilicaFlickable {
        anchors.fill: parent
        id: flick

        PullDownMenu {
            MenuItem {
                text: qsTr("manage passphrases")
                onClicked: pageStack.push(Qt.resolvedUrl("PassphrasePage.qml"))
            }
            MenuItem {
                text: qsTr("manage gpg-agent config")
                onClicked: pageStack.push(Qt.resolvedUrl("GPGAgent.qml"))
            }
            MenuItem {
                text: qsTr("git pull")
                onClicked: py.call('passwordstore.passwordstore.git_pull',[],
                                   function(result){
                                       listModel.clear();
                                       log.text = result
                                   }
                               );
            }
        }

        contentHeight: column.height
    }

        Column {
            id: column
            anchors.fill: parent

            width: page.width
            spacing: Theme.paddingLarge
            PageHeader {
                title: qsTr("qmlpass")
            }
            Label {
                x: Theme.horizontalPageMargin
                text: qsTr("Hello Sailors.\nPlease search a password.")
                color: Theme.secondaryHighlightColor
                font.pixelSize: Theme.fontSizeExtraLarge
            }

            SearchField {
                id: searchfield
                placeholderText: "Search password..."
                width: page.width
                inputMethodHints: Qt.ImhNoAutoUppercase
                //execute on enter clicked
                //EnterKey.onClicked:
                //execute every time the text changes
                focus: true
                onTextChanged: py.call('passwordstore.passwordstore.search',[text],
                    function(result){
                        listModel.clear();
                        for (var i=0; i<result.length; i++) {
                            console.log('got result: ' + result[i]);
                            listModel.append({name: result[i]});
                        }
                    }
                );
            }

            SilicaListView {
                width: column.width
                height: childrenRect.height

                id: listView
                model: ListModel{
                    id: listModel
// example item
//                    ListElement {
//                        name: "Apple"
//                        cost: 2.45
//                    }
                }

                delegate: BackgroundItem {
                    id: delegate

                    Label {
                        x: Theme.paddingLarge
                        text: name
                        anchors.verticalCenter: parent.verticalCenter
                        color: delegate.highlighted ? Theme.highlightColor : Theme.primaryColor
                    }
                    signal qmlSignal(string msg);
                    onClicked: {
                        pageStack.push(Qt.resolvedUrl("ResultPage.qml"), {"resultPathString": name})
                    }
                }
            }

            TextField {
                id: log
                readOnly: true
            }

        }


    Python {
        id:py
        Component.onCompleted: {
            addImportPath(Qt.resolvedUrl('.').substr('file://'.length));

            importModule('passwordstore', function () {});

            setHandler('stdout', function(stdout) {
                console.log('stdout:' + stdout)
            });

            setHandler('stderr', function(stderr) {
                console.log('stderr:' + stderr)
            });
        }

        onError: {
            // when an exception is raised, this error handler will be called
            console.log('python error: ' + traceback);
        }

        onReceived: {
            // asychronous messages from Python arrive here
            // in Python, this can be accomplished via pyotherside.send()
            console.log('got message from python: ' + data);
        }
    }
}

