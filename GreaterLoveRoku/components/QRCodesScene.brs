' QR Codes Scene BrightScript Logic
' Connect with Greater Love Network functionality

sub init()
    print "QRCodesScene init"
    
    ' Get UI elements
    m.focusIndicator = m.top.findNode("focusIndicator")
    m.backButton = m.top.findNode("backButton")
    
    ' QR Cards
    m.qrCards = [
        m.top.findNode("donateCard"),
        m.top.findNode("storyCard"),
        m.top.findNode("prayerCard"),
        m.top.findNode("appCard")
    ]
    
    ' Focus management
    m.currentFocus = 0
    m.focusIndicator.visible = true
    updateFocus()
    
    ' Set up key handling
    m.top.observeField("focusedChild", "onFocusChanged")
end sub

sub updateFocus()
    if m.currentFocus >= 0 and m.currentFocus < m.qrCards.count()
        ' Update focus indicator position
        cardPositions = [
            [190, 240],  ' Donate
            [640, 240],  ' Story  
            [1090, 240], ' Prayer
            [1540, 240]  ' App
        ]
        
        m.focusIndicator.translation = cardPositions[m.currentFocus]
        m.focusIndicator.visible = true
        
        print "Focus on QR card:", m.currentFocus
    end if
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    if press
        if key = "left"
            if m.currentFocus > 0
                m.currentFocus = m.currentFocus - 1
                updateFocus()
                return true
            end if
        else if key = "right"
            if m.currentFocus < m.qrCards.count() - 1
                m.currentFocus = m.currentFocus + 1
                updateFocus()
                return true
            end if
        else if key = "OK"
            handleQRSelection()
            return true
        else if key = "back"
            ' Return to main scene
            m.top.backPressed = true
            return true
        end if
    end if
    
    return false
end function

sub handleQRSelection()
    qrTypes = ["donate", "story", "prayer", "app"]
    selectedType = qrTypes[m.currentFocus]
    
    print "QR Code selected:", selectedType
    
    ' Show info dialog for the selected QR code
    dialog = createObject("roSGNode", "Dialog")
    dialog.title = "QR Code Information"
    
    if selectedType = "donate"
        dialog.message = "Scan this QR code with your mobile device to support Greater Love Network with a donation."
    else if selectedType = "story"
        dialog.message = "Scan this QR code to share your testimony and story with Greater Love Network."
    else if selectedType = "prayer"
        dialog.message = "Scan this QR code to submit a prayer request to Greater Love Network."
    else if selectedType = "app"
        dialog.message = "Scan this QR code to download the Greater Love Network mobile app."
    end if
    
    dialog.buttons = ["OK"]
    dialog.observeField("buttonSelected", "onDialogButton")
    m.top.dialog = dialog
end sub

sub onDialogButton(event as object)
    m.top.dialog = invalid
end sub

sub onFocusChanged(event as object)
    ' Handle focus changes if needed
end sub
