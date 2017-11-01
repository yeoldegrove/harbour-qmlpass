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

    // The effective value will be restricted by ApplicationWindow.allowedOrientations
    allowedOrientations: Orientation.All

    property string uid: name
    property string passphrase: inputPassphrase.text

    // To enable PullDownMenu, place our content in a SilicaFlickable
    SilicaFlickable {
        anchors.fill: parent
        id: flick

        // PullDownMenu and PushUpMenu must be declared in SilicaFlickable, SilicaListView or SilicaGridView
        PullDownMenu {
            MenuItem {
                text: qsTr("create gpg-agent config")
                onClicked: {
                    py.call('gpg.gpg.create_agent_config', [], function() {});
                }
            }
            MenuItem {
                text: qsTr("Clear Passphrase / kill gpg-agent")
                onClicked: {
                    py.call('gpg.gpg.kill_agent', [], function() {});
                    py.call('gpg.gpg.list_uids', [],
                          function(result){
                              listModelUIDs.clear();
                              for (var i=0; i<result.length; i++) {
                                  console.log("found uid " + " " + result[i]);
                                  listModelUIDs.append({name: result[i]});
                              }
                          }
                    );
                }
            }
        }

        // Tell SilicaFlickable the height of its content.
        contentHeight: column.height
    }

        // Place our content in a Column.  The PageHeader is always placed at the top
        // of the page, followed by our content.
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
                text: qsTr("\nFound these gpg UIDs\nwith (un)cached passphrases ...")
                color: Theme.secondaryHighlightColor
                font.pixelSize: Theme.fontSizeMedium
            }

            TextField {
                id: inputUID
                label: "gpg uid"
                placeholderText: "gpg uid..."
                //text: resultLoginString
                visible: false
            }
            PasswordField {
                id: inputPassphrase
                label: "passphrase"
                placeholderText: "passphrase..."
                echoMode: TextInput.Password
                //onPressAndHold: { echoMode: TextInput.Normal}
                readOnly: false
                visible: false
                EnterKey.onClicked: {
                    page.passphrase = inputPassphrase.text
                    py.call('gpg.gpg.cache_uid', [page.uid, page.passphrase], function() {});
                    py.call('gpg.gpg.list_uids', [],
                          function(result){
                              listModelUIDs.clear();
                              for (var i=0; i<result.length; i++) {
                                  console.log("found uid " + " " + result[i]);
                                  listModelUIDs.append({name: result[i]});
                              }
                          }
                    );
                }
            }

            SilicaListView {
                width: column.width
                height: childrenRect.height

                id: listViewUIDs
                model: ListModel{
                    id: listModelUIDs
// example item
//                    ListElement {
//                        name: "Apple"
//                        cost: 2.45
//                    }
                }

                delegate: BackgroundItem {
                    id: delegateUIDs

                    Label {
                        x: Theme.paddingLarge
                        text: name
                        anchors.verticalCenter: parent.verticalCenter
                        color: delegateUIDs.highlighted ? Theme.highlightColor : Theme.primaryColor
                    }

                    onClicked: {
                        console.log("Clicked " + name)
                        inputPassphrase.visible = true
                        page.uid = name.replace("uncached - ", "").replace("cached - ", "")
                    }
                }
            }
            Label {
                x: Theme.horizontalPageMargin
                text: qsTr("- Click on UID to enter passphrase to cache\n- Use pulldown to clear passphrases\n   or change gpg-agent config.")
                color: Theme.secondaryHighlightColor
                font.pixelSize: Theme.fontSizeSmall
            }
        }


    Python {
        id:py
        Component.onCompleted: {
            addImportPath(Qt.resolvedUrl('.').substr('file://'.length));

            importModule('gpg', function () {});

            importModule('gpg', function() {
                 call('gpg.gpg.list_uids', [],
                      function(result){
                          listModelUIDs.clear();
                          for (var i=0; i<result.length; i++) {
                              console.log("found uid " + " " + result[i]);
                              listModelUIDs.append({name: result[i]});
                          }
                      }
                  );
            });

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

