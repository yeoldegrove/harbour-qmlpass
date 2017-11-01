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

    property string resultPathString: "foo"

    SilicaFlickable {
        anchors.fill: parent
        id: flick

        PullDownMenu {
            MenuItem {
                text: qsTr("Show Password")
                onClicked: {
                    resultPassword.echoMode = TextInput.Normal
                }
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
                text: qsTr("Here is you password.")
                color: Theme.secondaryHighlightColor
                font.pixelSize: Theme.fontSizeExtraLarge
            }

            TextField {
                id: resultPath
                label: "path"
                placeholderText: "path..."
                text: resultPathString
            }

            TextField {
                id: resultLogin
                label: "login"
                placeholderText: "login..."
                text: "                              "
            }
            PasswordField {
                id: resultPassword
                label: "password"
                placeholderText: "password..."
                //text: resultPasswordString
                text: "                              "
                echoMode: TextInput.Password
                onPressAndHold: { echoMode: TextInput.Normal}
                readOnly: true
            }
            TextField {
                id: resultUrl
                label: "url"
                placeholderText: "url..."
                text: "                              "
            }
            Label {
                x: Theme.horizontalPageMargin
                text: qsTr("password has been copied to clipboard.\nUse pulldown to show it.")
                color: Theme.secondaryHighlightColor
                font.pixelSize: Theme.fontSizeMedium
            }




        }


    Python {
        id:py
        Component.onCompleted: {
            addImportPath(Qt.resolvedUrl('.').substr('file://'.length));

            importModule('passwordstore', function () {});

            importModule('passwordstore', function() {
                 call('passwordstore.passwordstore.show_login', [resultPathString], function(result){
                     if (result.length > 0) {
                        console.log('got login: ' + result);
                        resultLogin.text = result;
                     }
                 });
            });
            importModule('passwordstore', function() {
                 call('passwordstore.passwordstore.show_pass', [resultPathString], function(result){
                     // WARNING!!! SHOWS PASSWORD IN CLEARTEXT IN DEBUG OUTPUT !!!
                     //console.log('got password: ' + result);
                     if (result.length > 0) {
                        resultPassword.text = result;
                        Clipboard.text = result;
                     }
                 });
            });
            importModule('passwordstore', function() {
                 call('passwordstore.passwordstore.show_url', [resultPathString], function(result){
                     console.log('got url: ' + result);
                     if (result.length > 0) {
                         resultUrl.text = result;
                     }
                 });
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

