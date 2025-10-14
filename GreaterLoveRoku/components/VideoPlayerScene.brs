' Video Player Scene Logic - Figma Design
' Modern video player with overlay controls and episode navigation

sub init()
    print "VideoPlayerScene init - Figma Design"
    
    ' Get UI elements
    m.videoPlayer = m.top.findNode("videoPlayer")
    m.videoOverlay = m.top.findNode("videoOverlay")
    m.backButton = m.top.findNode("backButton")
    m.videoTitle = m.top.findNode("videoTitle")
    m.controlsContainer = m.top.findNode("controlsContainer")
    m.progressBarFill = m.top.findNode("progressBarFill")
    m.currentTime = m.top.findNode("currentTime")
    m.totalTime = m.top.findNode("totalTime")
    m.playButton = m.top.findNode("playButton")
    m.loadingSpinner = m.top.findNode("loadingSpinner")
    m.episodeDots = m.top.findNode("episodeDots")

    ' Set initial focus
    m.backButton.setFocus(true)

    ' Setup observers
    m.videoPlayer.observeField("state", "onVideoPlayerState")
    m.videoPlayer.observeField("position", "onVideoPosition")
    m.videoPlayer.observeField("duration", "onVideoDuration")
    m.backButton.observeField("itemSelected", "onBackButtonSelected")
    m.playButton.observeField("itemSelected", "onPlayButtonSelected")
    m.top.observeField("videoContent", "onVideoContentChanged")

    ' Setup episode dots
    setupEpisodeDots()
end sub

sub onVideoContentChanged()
    if m.top.videoContent <> invalid then
        ' Set video content
        m.videoPlayer.content = m.top.videoContent
        m.videoTitle.text = m.top.videoContent.title
        
        ' Check if it's a Castr embed URL
        videoUrl = m.top.videoContent.url
        if videoUrl <> invalid and videoUrl.find("player.castr.com") > -1
            ' For Castr embed URLs, we need to handle them differently
            ' Roku Video node can handle some embed URLs directly
            print "Playing Castr embed URL:"; videoUrl
        end if
        
        ' Start playing
        m.videoPlayer.control = "play"
        m.loadingSpinner.visible = true
    end if
end sub

sub setupEpisodeDots()
    ' Setup episode navigation dots
    dots = [m.top.findNode("dot1"), m.top.findNode("dot2"), m.top.findNode("dot3"), m.top.findNode("dot4"), m.top.findNode("dot5")]
    m.episodeDotsArray = dots
    
    ' Set first dot as active
    setActiveDot(0)
end sub

sub setActiveDot(index as integer)
    ' Update dot colors
    for i = 0 to m.episodeDotsArray.count() - 1
        if i = index then
            m.episodeDotsArray[i].color = "0xFFFFFF"
        else
            m.episodeDotsArray[i].color = "0x666666"
        end if
    end for
end sub

sub onVideoPlayerState(event as object)
    state = event.getData()
    print "Video player state:"; state

    if state = "playing" then
        m.loadingSpinner.visible = false
        m.videoOverlay.visible = false
        m.controlsContainer.visible = false
    else if state = "paused" then
        m.videoOverlay.visible = true
        m.controlsContainer.visible = true
    else if state = "buffering" then
        m.loadingSpinner.visible = true
    else if state = "finished" then
        ' Auto-advance to next episode or return to content
        onVideoFinished()
    else if state = "error" then
        showErrorDialog("Playback Error", "Unable to play this video. Please try again.")
    end if
end sub

sub onVideoPosition(event as object)
    position = event.getData()
    if m.videoPlayer.duration > 0 then
        ' Update progress bar
        progress = (position / m.videoPlayer.duration) * 1600
        m.progressBarFill.width = progress
        
        ' Update time display
        m.currentTime.text = formatTime(position)
    end if
end sub

sub onVideoDuration(event as object)
    duration = event.getData()
    m.totalTime.text = formatTime(duration)
end sub

function formatTime(seconds as float) as string
    minutes = int(seconds / 60)
    secs = int(seconds - (minutes * 60))
    return minutes.toStr() + ":" + secs.toStr().padStart(2, "0")
end function

sub onBackButtonSelected(event as object)
    print "Back button selected"
    ' Stop video and return to previous screen
    m.videoPlayer.control = "stop"
    m.top.getParent().callFunc("showHomeScene")
end sub

sub onPlayButtonSelected(event as object)
    if m.videoPlayer.state = "playing" then
        m.videoPlayer.control = "pause"
        m.playButton.findNode("playButtonText").text = "▶"
    else
        m.videoPlayer.control = "play"
        m.playButton.findNode("playButtonText").text = "⏸"
    end if
end sub

sub onVideoFinished()
    print "Video finished"
    ' Show completion dialog or auto-advance
    showDialog("Video Complete", "Would you like to watch the next episode?")
end sub

sub showErrorDialog(title as string, message as string)
    dialog = createObject("roSGNode", "Dialog")
    dialog.title = title
    dialog.message = message
    dialog.buttons = ["OK"]
    m.top.appendChild(dialog)
    dialog.observeField("buttonSelected", "onDialogButton")
    dialog.setFocus(true)
end sub

sub showDialog(title as string, message as string)
    dialog = createObject("roSGNode", "Dialog")
    dialog.title = title
    dialog.message = message
    dialog.buttons = ["Yes", "No"]
    m.top.appendChild(dialog)
    dialog.observeField("buttonSelected", "onDialogButton")
    dialog.setFocus(true)
end sub

sub onDialogButton(event as object)
    buttonIndex = event.getData()
    ' Close dialog
    event.getRoSGNode().getParent().removeChild(event.getRoSGNode())
    
    if buttonIndex = 0 then
        ' Yes - advance to next episode
        advanceToNextEpisode()
    else
        ' No - return to content
        m.top.getParent().callFunc("showHomeScene")
    end if
end sub

sub advanceToNextEpisode()
    ' Logic to advance to next episode
    print "Advancing to next episode"
    ' Implementation would depend on episode data structure
end sub
