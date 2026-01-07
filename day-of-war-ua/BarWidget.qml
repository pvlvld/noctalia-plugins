import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Commons
import qs.Widgets
import qs.Services.UI
import qs.Services.System

Rectangle {
  id: root

  property var pluginApi: null
  property ShellScreen screen
  property string widgetId: ""
  property string section: ""

  property bool total: pluginApi?.pluginSettings?.total || false

  implicitWidth: row.implicitWidth + Style.marginM * 2
  implicitHeight: Style.barHeight
  color: Style.capsuleColor
  radius: Style.radiusM

  property date startDate: new Date("2014-02-20T00:00:00Z")
  property date startDateFullScale: new Date("2022-02-24T04:00:00Z")


  function getDays() {
    const now = new Date()
    const diff = now - (total ? startDate : startDateFullScale)
    return Math.floor(diff / (1000 * 60 * 60 * 24)) + 1
  }

  function getFullDateString() {
    const now = new Date()
    const start = total ? startDate : startDateFullScale
    let years = now.getUTCFullYear() - start.getUTCFullYear()
    let months = now.getUTCMonth() - start.getUTCMonth()
    let days = now.getUTCDate() - start.getUTCDate()

    if (days < 0) {
      months -= 1
      days += new Date(Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), 0)).getUTCDate()
    }

    if (months < 0) {
      years -= 1
      months += 12
    }

    return years + " Years, " + months + " Months, " + days + " Days since war started"
  }


  RowLayout {
    id: row
    anchors.centerIn: parent
    spacing: Style.marginS

    NIcon {
      icon: "heart-broken"
      color: Color.mPrimary
    }

    NText {
      text: getDays()
      color: Color.mOnSurface
      pointSize: Style.fontSizeS
    }
  }

  MouseArea {
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor

    onClicked: {
      if (pluginApi && pluginApi.pluginSettings) {
        pluginApi.pluginSettings.total = !total
        pluginApi.saveSettings()
        root.total = pluginApi.pluginSettings.total
        row.children[1].text = getDays()
        TooltipService.show(root, getFullDateString(), BarService.getTooltipDirection())
      }
    }

    onEntered: {
      TooltipService.show(root, getFullDateString(), BarService.getTooltipDirection())
    }
    onExited: {
      TooltipService.hide()
    }
  }

  Timer {
    interval: 30 * 60 * 1000 // 30m
    running: true
    repeat: true
    onTriggered: {
      row.children[1].text = getDays()
    }
  }
}