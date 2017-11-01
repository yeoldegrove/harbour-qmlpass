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

CoverBackground {
    Label {
        id: label
        anchors.centerIn: parent
        Image {
            id: icon
            anchors.centerIn: parent
            source: "/usr/share/icons/hicolor/256x256/apps/qmlpass.png"
        }
    }

    CoverActionList {
        id: coverAction

//        CoverAction {
//            iconSource: "image://theme/icon-cover-search"
//            onTriggered: pageStack.push(Qt.resolvedUrl("../pages/FirstPage.qml"))
//        }
    }
}

