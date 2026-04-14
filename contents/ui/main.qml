/*
 * KWin - the KDE window manager
 * This file is part of the KDE project.
 * SPDX-FileCopyrightText: 2020 Chris Holland <zrenfire@gmail.com>
 * SPDX-FileCopyrightText: 2023 Nate Graham <nate@kde.org>
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick
import QtQuick.Layouts 1.1
import org.kde.plasma.core as PlasmaCore
import org.kde.ksvg 1.0 as KSvg
import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.kwin 3.0 as KWin
import org.kde.kirigami 2.20 as Kirigami

KWin.TabBoxSwitcher {
    id: tabBox

    Instantiator {
        active: tabBox.visible
        delegate: PlasmaCore.Dialog {
            location: PlasmaCore.Types.Floating
            visible: true
            flags: Qt.X11BypassWindowManagerHint
            x: tabBox.screenGeometry.x + tabBox.screenGeometry.width * 0.5 - dialogMainItem.width * 0.5
            y: tabBox.screenGeometry.y + tabBox.screenGeometry.height * 0.5 - dialogMainItem.height * 0.5

            mainItem: FocusScope {
                id: dialogMainItem

                focus: true

                property int maxWidth: tabBox.screenGeometry.width * 0.9
                property int maxHeight: tabBox.screenGeometry.height * 0.7
                property real screenFactor: tabBox.screenGeometry.width / tabBox.screenGeometry.height
                property int maxGridColumnsByWidth: Math.floor(maxWidth / thumbnailGridView.cellWidth)

                property int gridColumns: {
                    const c = Math.min(thumbnailGridView.count, maxGridColumnsByWidth);
                    const residue = thumbnailGridView.count % c;
                    if (residue == 0) {
                        return c;
                    }
                    return columnCountRecursion(c, c, c - residue);
                }

                property int gridRows: Math.ceil(thumbnailGridView.count / gridColumns)
                property int optimalWidth: thumbnailGridView.cellWidth * gridColumns
                property int optimalHeight: thumbnailGridView.cellHeight * gridRows
                width: Math.min(Math.max(thumbnailGridView.cellWidth, optimalWidth), maxWidth)
                height: Math.min(Math.max(thumbnailGridView.cellHeight, optimalHeight), maxHeight)

                clip: true

                function columnCountRecursion(prevC, prevBestC, prevDiff) {
                    const c = prevC - 1;

                    if (prevC * prevC <= thumbnailGridView.count + prevDiff ||
                            maxHeight < Math.ceil(thumbnailGridView.count / c) * thumbnailGridView.cellHeight) {
                        return prevBestC;
                    }
                    const residue = thumbnailGridView.count % c;
                    if (residue == 0) {
                        return c;
                    }
                    const diff = c - residue;

                    if (diff < prevDiff) {
                        return columnCountRecursion(c, c, diff);
                    } else if (diff == prevDiff) {
                        return columnCountRecursion(c, prevBestC, diff);
                    }
                    return columnCountRecursion(c, prevBestC, diff);
                }

                KSvg.FrameSvgItem {
                    id: hoverItem
                    imagePath: "widgets/viewitem"
                    prefix: "hover"
                    visible: false
                }

                GridView {
                    id: thumbnailGridView
                    anchors.fill: parent
                    focus: false
                    model: tabBox.model
                    currentIndex: tabBox.currentIndex

                    readonly property int iconSize: Kirigami.Units.iconSizes.huge
                    readonly property int captionRowHeight: Kirigami.Units.gridUnit * 2
                    readonly property int columnSpacing: Kirigami.Units.gridUnit
                    readonly property int thumbnailWidth: Kirigami.Units.gridUnit * 16
                    readonly property int thumbnailHeight: thumbnailWidth * (1.0/dialogMainItem.screenFactor)
                    cellWidth: hoverItem.margins.left + thumbnailWidth + hoverItem.margins.right
                    cellHeight: hoverItem.margins.top + captionRowHeight + thumbnailHeight + hoverItem.margins.bottom

                    keyNavigationWraps: true
                    highlightMoveDuration: 0

                    delegate: MouseArea {
                        id: thumbnailGridItem
                        width: thumbnailGridView.cellWidth
                        height: thumbnailGridView.cellHeight
                        focus: GridView.isCurrentItem
                        hoverEnabled: true

                        Accessible.name: model.caption
                        Accessible.role: Accessible.ListItem

                        onClicked: {
                            tabBox.model.activate(index);
                        }

                        ColumnLayout {
                            id: columnLayout
                            z: 0
                            spacing: thumbnailGridView.columnSpacing
                            anchors.fill: parent
                            anchors.leftMargin: hoverItem.margins.left * 2
                            anchors.topMargin: hoverItem.margins.top * 2
                            anchors.rightMargin: hoverItem.margins.right * 2
                            anchors.bottomMargin: hoverItem.margins.bottom * 2

                            Item {
                                Layout.fillWidth: true
                                Layout.fillHeight: true

                                KWin.WindowThumbnail {
                                    anchors.fill: parent
                                    wId: windowId
                                }

                                Kirigami.Icon {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    anchors.verticalCenter: parent.bottom
                                    anchors.verticalCenterOffset: Math.round(-thumbnailGridView.iconSize / 4)
                                    width: thumbnailGridView.iconSize
                                    height: thumbnailGridView.iconSize

                                    source: model.icon
                                }

                                PlasmaComponents3.ToolButton {
                                    id: closeButton
                                    anchors {
                                        right: parent.right
                                        top: parent.top
                                        rightMargin: -columnLayout.anchors.rightMargin
                                        topMargin: -columnLayout.anchors.topMargin
                                    }
                                    visible: model.closeable && typeof tabBox.model.close !== 'undefined' &&
                                            (thumbnailGridItem.containsMouse
                                            || closeButton.hovered
                                            || thumbnailGridItem.focus
                                            || Kirigami.Settings.tabletMode
                                            || Kirigami.Settings.hasTransientTouchInput
                                            )
                                    icon.name: 'window-close-symbolic'
                                    onClicked: {
                                        tabBox.model.close(index);
                                    }
                                }
                            }

                            PlasmaComponents3.Label {
                                Layout.fillWidth: true
                                text: model.caption
                                font.weight: thumbnailGridItem.focus ? Font.Bold : Font.Normal
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                textFormat: Text.PlainText
                                elide: Text.ElideRight
                            }
                        }
                    }

                    highlight: KSvg.FrameSvgItem {
                        imagePath: "widgets/viewitem"
                        prefix: "hover"
                    }

                    onCurrentIndexChanged: tabBox.currentIndex = thumbnailGridView.currentIndex;
                }

                Kirigami.PlaceholderMessage {
                    anchors.centerIn: parent
                    width: parent.width - Kirigami.Units.largeSpacing * 2
                    icon.source: "edit-none"
                    text: i18ndc("kwin", "@info:placeholder no entries in the task switcher", "No open windows")
                    visible: thumbnailGridView.count === 0
                }

                Keys.onPressed: {
                    if (event.key == Qt.Key_Left || event.key == Qt.Key_A) {
                        thumbnailGridView.moveCurrentIndexLeft();
                    } else if (event.key == Qt.Key_Right || event.key == Qt.Key_D) {
                        thumbnailGridView.moveCurrentIndexRight();
                    } else if (event.key == Qt.Key_Up || event.key == Qt.Key_W) {
                        thumbnailGridView.moveCurrentIndexUp();
                    } else if (event.key == Qt.Key_Down || event.key == Qt.Key_S) {
                        thumbnailGridView.moveCurrentIndexDown();
                    } else {
                        return;
                    }

                    thumbnailGridView.currentIndexChanged(thumbnailGridView.currentIndex);
                }
            }
        }
    }
}
