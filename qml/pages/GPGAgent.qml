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

    property string uid
    property string passphrase

    // To enable PullDownMenu, place our content in a SilicaFlickable
    SilicaFlickable {
        anchors.fill: parent
        id: flick

        // PullDownMenu and PushUpMenu must be declared in SilicaFlickable, SilicaListView or SilicaGridView
        PullDownMenu {
            MenuItem {
                text: qsTr("create default gpg-agent config")
                onClicked: {
                    py.call('gpg.gpg.create_default_agent_config', [], function() {});
                    py.call('gpg.gpg.read_agent_config', [],
                        function(result){
                            console.log("found config " + " " + result);
                            gpgAgentConfig.text = result
                        }

                    );
                }
            }
            MenuItem {
                text: qsTr("reset values to default gpg-agent config")
                onClicked: {
                    py.call('gpg.gpg.reset_default_agent_config', [], function() {});
                    py.call('gpg.gpg.read_agent_config', [],
                        function(result){
                            console.log("found config " + " " + result);
                            gpgAgentConfig.text = result
                        }

                    );
                }
            }
            MenuItem {
                text: qsTr("Clear Passphrase / kill gpg-agent")
                onClicked: {
                    py.call('gpg.gpg.kill_agent', [], function() {});
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

            TextArea {
                width: parent.width
                id: gpgAgentConfig
                label: "gpg-agent config (~/.gnupg/gpg-agent.conf)"
                readOnly: false
                onClicked: gpgAgentConfigSave.visible = true
            }

            Button {
                id: gpgAgentConfigSave
                text: "save"
                visible: false
                onClicked: {
                    py.call('gpg.gpg.write_agent_config', [gpgAgentConfig.text], function() {});
                    gpgAgentConfigSave.visible = false
                }
            }

            Label {
                id: explanations
                x: Theme.horizontalPageMargin
                text: qsTr("- Click on the gpg-agent config to edit and save it.\n\n- Use pulldown for more actions.")
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
                py.call('gpg.gpg.read_agent_config', [],
                    function(result){
                        //for (var i=0; i<result.length; i++) {
                            console.log("found config " + " " + result);
                            gpgAgentConfig.text = result
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

