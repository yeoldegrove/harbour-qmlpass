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

    property string resultPathString: "        "

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

            // need this object to delete clipboard after 30 seconds
            Timer {
                id: timer
            }


            TextField {
                id: resultPath
                label: "path"
                text: resultPathString
                readOnly: true
            }
            TextField {
                id: resultLogin
                label: "login"
                text: "login..."
                readOnly: true
                onClicked: {
                    Clipboard.text = resultLogin.text
                    info.text = "login copied to clipboard"
                }
            }
            PasswordField {
                id: resultPassword
                label: "password"
                text: "        "
                echoMode: TextInput.Password
                readOnly: true
                // TODO: do the password clearing easier if possible
                onClicked: {
                    Clipboard.text = resultPassword.text
                    py.call('passwordstore.passwordstore.show_pass', [resultPathString], function(result){
                        function delay(delayTime, cb) {
                            timer.interval = delayTime;
                            timer.repeat = false;
                            timer.triggered.connect(cb);
                            timer.start();
                        }
                        // WARNING!!! SHOWS PASSWORD IN CLEARTEXT IN DEBUG OUTPUT !!!
                        //console.log('got password: ' + result);
                        if (result.length > 0) {
                           resultPassword.text = result;
                           Clipboard.text = result;
                        }
                        // wait 30 seconds and delete password from clipboard
                        delay(30000, function() {
                            Clipboard.text = ""
                        })
                    });
                    info.text = "password has been copied to clipboard.\nIt will be cleared after 30 seconds."
                }
            }
            TextField {
                id: resultUrl
                label: "url"
                text: "url..."
                readOnly: true
                onClicked: {
                    Clipboard.text = resultUrl.text
                    info.text = "url copied to clipboard"
                }
            }
            Label {
                id: info
                x: Theme.horizontalPageMargin
                text: {
                    if ( resultPassword.text != "        " ) {
                        qsTr("password has been copied to clipboard.\nIt will be cleared after 30 seconds.\n\nUse pulldown to show password.")
                    } else {
                        qsTr("No password could be decrypted.\nPlease cache your passphrase first.\nUse startpage's pulldown menu.\n\nIf you already did this,\nyour passphrase is wrong.")
                    }
                }
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
                     function delay(delayTime, cb) {
                         timer.interval = delayTime;
                         timer.repeat = false;
                         timer.triggered.connect(cb);
                         timer.start();
                     }
                     // WARNING!!! SHOWS PASSWORD IN CLEARTEXT IN DEBUG OUTPUT !!!
                     //console.log('got password: ' + result);
                     if (result.length > 0) {
                        resultPassword.text = result;
                        Clipboard.text = result;
                     }
                     // wait 30 seconds and delete password from clipboard
                     delay(30000, function() {
                         Clipboard.text = ""
                     })
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

            function delay(delayTime, cb) {
                timer.interval = delayTime;
                timer.repeat = false;
                timer.triggered.connect(cb);
                timer.start();
            }
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

