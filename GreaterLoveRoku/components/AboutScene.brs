' About Scene Logic for Greater Love TV
sub init()
    print "AboutScene init - Greater Love TV"

    ' Get UI elements
    m.backButton = m.top.findNode("backButton")
    m.qrCodesList = m.top.findNode("qrCodesList")

    ' Set initial focus to back button
    m.backButton.setFocus(true)

    ' Setup QR codes
    setupQRCodes()
end sub

sub setupQRCodes()
    ' Setup QR codes for connection options
    qrItems = []

    qrCodes = [
        {title: "Donate", image: "donate_qrcode.png"},
        {title: "Prayer", image: "prayer_request_qrcode.png"},
        {title: "Mobile App", image: "download_mobile_app_qrcode.png"},
        {title: "Tell Story", image: "tell_your_story_qrcode.png"}
    ]

    for each qr in qrCodes
        item = createObject("roSGNode", "ContentNode")
        item.title = qr.title
        item.hdPosterUrl = "pkg:/images/" + qr.image
        item.description = qr.title
        qrItems.append(item)
    end for

    content = createObject("roSGNode", "ContentNode")
    content.appendChild(qrItems)
    m.qrCodesList.content = content
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    if press
        if key = "back"
            ' Handle back button press
            m.top.backPressed = true
            return true
        else if key = "OK" or key = "play"
            ' Handle OK button on back button
            m.top.backPressed = true
            return true
        end if
    end if
    return false
end function