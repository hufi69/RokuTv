' Episode List Scene Logic for Greater Love TV
sub init()
    print "EpisodeListScene init - Greater Love TV"

    ' Get UI elements
    m.showTitle = m.top.findNode("showTitle")
    m.showDescription = m.top.findNode("showDescription")
    m.episodeCount = m.top.findNode("episodeCount")
    m.episodesList = m.top.findNode("episodesList")
    m.videoPlayer = m.top.findNode("videoPlayer")
    m.loadingSpinner = m.top.findNode("loadingSpinner")
    m.noEpisodesLabel = m.top.findNode("noEpisodesLabel")
    m.backButton = m.top.findNode("backButton")
    m.focusIndicator = m.top.findNode("focusIndicator")

    ' Set initial focus to back button
    m.backButton.setFocus(true)
    m.currentFocus = "back"

    ' Setup observers
    m.episodesList.observeField("itemSelected", "onEpisodeSelected")
    m.episodesList.observeField("itemFocused", "onEpisodeFocused")
    m.videoPlayer.observeField("state", "onVideoPlayerState")
    m.top.observeField("showData", "onShowDataChanged")

    ' Setup key handling
    m.top.observeField("focusedChild", "onFocusedChildChange")
end sub

sub onShowDataChanged()
    if m.top.showData <> invalid
        setupEpisodesList()
    end if
end sub

sub setupEpisodesList()
    showData = m.top.showData
    print "Setting up episodes for show:", showData.name

    ' Set show information
    m.showTitle.text = showData.name
    m.showDescription.text = "Episodes from " + showData.name

    ' Setup episodes (API uses 'data' field)
    episodes = showData.data
    if episodes <> invalid and episodes.count() > 0
        enabledEpisodes = []

        ' Filter enabled episodes
        for each episode in episodes
            if episode.enabled = true
                enabledEpisodes.push(episode)
            end if
        end for

        ' Update episode count
        episodeCountText = enabledEpisodes.count().toStr() + " episode"
        if enabledEpisodes.count() <> 1
            episodeCountText = episodeCountText + "s"
        end if
        m.episodeCount.text = episodeCountText

        if enabledEpisodes.count() > 0
            ' Create content for episodes list
            contentArray = []

            for i = 0 to enabledEpisodes.count() - 1
                episode = enabledEpisodes[i]
                episodeItem = createObject("roSGNode", "ContentNode")

                ' Set episode details
                episodeItem.title = getEpisodeTitle(episode)
                episodeItem.description = getDurationString(episode) + " • " + getCreationDate(episode)

                ' Get playback URL (try embed first, then HLS)
                playbackUrl = getEpisodeUrl(episode)
                episodeItem.url = playbackUrl

                ' Set thumbnail (use generated thumbnail from video ID)
                videoId = episode.episodeId
                if videoId <> invalid and videoId <> ""
                    ' Remove .mp4 extension if present
                    if videoId.instr(".mp4") > -1
                        videoId = videoId.replace(".mp4", "")
                    end if
                    ' Generate thumbnail URL from Castr API
                    episodeItem.hdPosterUrl = "https://player.castr.com/api/v1/vod/" + videoId + "/thumbnail"
                else
                    ' Fallback to app logo
                    episodeItem.hdPosterUrl = "pkg:/images/app_logo.png"
                end if

                ' Store episode data for playback
                episodeItem.episodeData = episode
                episodeItem.episodeNumber = i + 1

                contentArray.push(episodeItem)
            end for

            ' Create content node and add episodes
            episodeContent = createObject("roSGNode", "ContentNode")
            episodeContent.appendChild(contentArray)

            ' Set content to list
            m.episodesList.content = episodeContent
            m.episodesList.visible = true
            m.noEpisodesLabel.visible = false
        else
            ' No enabled episodes
            m.episodesList.visible = false
            m.noEpisodesLabel.visible = true
            m.episodeCount.text = "0 episodes"
        end if
    else
        ' No episodes data
        m.episodesList.visible = false
        m.noEpisodesLabel.visible = true
        m.episodeCount.text = "0 episodes"
    end if
end sub

function getEpisodeTitle(episode as object) as string
    fileName = episode.fileName
    if fileName <> invalid
        ' Remove .mp4 extension and clean up filename
        title = fileName.replace(".mp4", "")
        ' Remove common prefixes for cleaner titles
        title = title.replace("Episode ", "Ep ")
        title = title.replace("episode ", "Ep ")
        return title
    end if
    return "Episode"
end function

function getDurationString(episode as object) as string
    if episode.mediaInfo <> invalid and episode.mediaInfo.durationMins <> invalid
        duration = episode.mediaInfo.durationMins
        hours = int(duration / 60)
        minutes = duration - (hours * 60)

        if hours > 0
            return hours.toStr() + "h " + minutes.toStr() + "m"
        else
            return minutes.toStr() + "m"
        end if
    end if
    return "Duration unknown"
end function

function getCreationDate(episode as object) as string
    if episode.creationTime <> invalid and episode.creationTime <> ""
        ' Parse ISO date and format it nicely
        dateTime = createObject("roDateTime")
        dateTime.fromISO8601String(episode.creationTime)
        return dateTime.asDateStringLoc("short-month-no-weekday")
    end if
    return "Date unknown"
end function

function getEpisodeUrl(episode as object) as string
    if episode.playback <> invalid
        if episode.playback.embed_url <> invalid and episode.playback.embed_url <> ""
            return episode.playback.embed_url
        else if episode.playback.hls_url <> invalid and episode.playback.hls_url <> ""
            return episode.playback.hls_url
        end if
    end if
    return ""
end function

' Focus management and navigation
sub onFocusedChildChange()
    focusedChild = m.top.focusedChild
    if focusedChild <> invalid
        if focusedChild.id = "backButton"
            m.currentFocus = "back"
            m.focusIndicator.visible = false
        else if focusedChild.id = "episodesList"
            m.currentFocus = "episodes"
            updateFocusIndicator()
        end if
    end if
end sub

sub onEpisodeFocused(event as object)
    focusedIndex = event.getData()
    updateFocusIndicator()
end sub

sub updateFocusIndicator()
    if m.currentFocus = "episodes" and m.episodesList.content <> invalid
        focusedIndex = m.episodesList.itemFocused
        if focusedIndex >= 0
            ' Position focus indicator on the focused episode
            m.focusIndicator.translation = [50, 150 + (focusedIndex * 130)]
            m.focusIndicator.visible = true
        end if
    end if
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    if press
        if key = "back"
            ' Handle back button press
            if m.videoPlayer.visible
                ' If video is playing, stop it and return to episode list
                returnToEpisodeList()
                return true
            else
                ' Return to main scene
                m.top.backPressed = true
                return true
            end if
        else if key = "OK" or key = "play"
            if m.currentFocus = "back"
                ' Back button pressed
                m.top.backPressed = true
                return true
            else if m.currentFocus = "episodes"
                ' Episode selected
                onEpisodeSelected(invalid)
                return true
            end if
        else if key = "up" or key = "down"
            if m.currentFocus = "back" and key = "down"
                ' Move from back button to episodes list
                if m.episodesList.content <> invalid and m.episodesList.content.getChildCount() > 0
                    m.episodesList.setFocus(true)
                    return true
                end if
            else if m.currentFocus = "episodes" and key = "up"
                ' Check if at top of episodes list
                if m.episodesList.itemFocused = 0
                    m.backButton.setFocus(true)
                    return true
                end if
            end if
        end if
    end if
    return false
end function

sub onEpisodeSelected(event as object)
    selectedIndex = m.episodesList.itemFocused
    if selectedIndex >= 0 and m.episodesList.content <> invalid
        selectedEpisode = m.episodesList.content.getChild(selectedIndex)

        if selectedEpisode <> invalid
            if selectedEpisode.url <> invalid and selectedEpisode.url <> ""
                playEpisode(selectedEpisode)
            else
                showErrorDialog("Episode Unavailable", "This episode is currently not available for streaming.")
            end if
        end if
    end if
end sub

sub playEpisode(episodeItem as object)
    print "Playing episode:"; episodeItem.title; "URL:"; episodeItem.url

    ' Check if URL is an embed URL that needs processing
    episodeUrl = episodeItem.url
    if episodeUrl.instr("player.castr.com") > -1
        ' This is a Castr embed URL, try to extract direct video URL
        extractDirectVideoUrl(episodeItem)
    else if episodeUrl.instr(".m3u8") > -1
        ' This is already an HLS stream, play directly
        playVideoDirectly(episodeItem, episodeUrl, "hls")
    else if episodeUrl.instr(".mp4") > -1
        ' This is a direct MP4 URL
        playVideoDirectly(episodeItem, episodeUrl, "mp4")
    else
        ' Try to play as embed URL anyway
        playVideoDirectly(episodeItem, episodeUrl, "mp4")
    end if
end sub

sub extractDirectVideoUrl(episodeItem as object)
    ' Show loading while extracting URL
    m.loadingSpinner.visible = true

    ' Try to extract direct MP4 URL from Castr embed page
    ' For now, we'll use the embed URL directly and let Roku handle it
    ' In a production app, you might want to parse the embed page for the direct video URL

    embedUrl = episodeItem.url

    ' Hide loading and try to play
    m.loadingSpinner.visible = false

    ' Try common Castr direct URL patterns
    if embedUrl.instr("player.castr.com/vod/") > -1
        ' Extract video ID from embed URL
        videoId = extractVideoIdFromUrl(embedUrl)
        if videoId <> ""
            ' Try direct MP4 URL pattern (this may or may not work depending on Castr setup)
            directUrl = "https://player.castr.com/api/v1/vod/" + videoId + "/master.m3u8"
            playVideoDirectly(episodeItem, directUrl, "hls")
            return
        end if
    end if

    ' Fallback: try the embed URL directly
    playVideoDirectly(episodeItem, embedUrl, "mp4")
end sub

function extractVideoIdFromUrl(url as string) as string
    ' Extract video ID from Castr embed URL
    ' Example: https://player.castr.com/vod/FEgYaygr8QDofmKX -> FEgYaygr8QDofmKX
    if url.instr("/vod/") > -1
        parts = url.split("/vod/")
        if parts.count() > 1
            videoIdPart = parts[1]
            ' Remove any query parameters or fragments
            if videoIdPart.instr("?") > -1
                videoIdPart = videoIdPart.split("?")[0]
            end if
            if videoIdPart.instr("#") > -1
                videoIdPart = videoIdPart.split("#")[0]
            end if
            return videoIdPart
        end if
    end if
    return ""
end function

sub playVideoDirectly(episodeItem as object, videoUrl as string, streamFormat as string)
    print "Playing video directly:"; videoUrl; "Format:"; streamFormat

    ' Setup video content
    videoContent = createObject("roSGNode", "ContentNode")
    videoContent.url = videoUrl
    videoContent.title = episodeItem.title
    videoContent.streamFormat = streamFormat

    ' Add poster if available
    if episodeItem.hdPosterUrl <> invalid
        videoContent.hdPosterUrl = episodeItem.hdPosterUrl
    end if

    ' Show video player and hide other elements
    m.videoPlayer.content = videoContent
    m.videoPlayer.visible = true
    m.videoPlayer.setFocus(true)
    m.videoPlayer.control = "play"

    ' Hide UI elements
    m.episodesList.visible = false
    m.showTitle.visible = false
    m.showDescription.visible = false
    m.episodeCount.visible = false
    m.backButton.visible = false
    m.focusIndicator.visible = false
end sub

sub onVideoPlayerState(event as object)
    state = event.getData()
    print "Video player state:"; state

    if state = "finished" or state = "stopped"
        ' Return to episode list
        returnToEpisodeList()
    else if state = "error"
        showErrorDialog("Playback Error", "Unable to play this episode. Please try again.")
        returnToEpisodeList()
    end if
end sub

sub returnToEpisodeList()
    ' Hide video player and show all UI elements
    m.videoPlayer.visible = false
    m.loadingSpinner.visible = false

    ' Show UI elements
    m.episodesList.visible = true
    m.showTitle.visible = true
    m.showDescription.visible = true
    m.episodeCount.visible = true
    m.backButton.visible = true

    ' Restore focus to episodes list
    m.episodesList.setFocus(true)
    m.currentFocus = "episodes"
    updateFocusIndicator()
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

sub onDialogButton(event as object)
    ' Close dialog and return focus
    event.getRoSGNode().getParent().removeChild(event.getRoSGNode())
    returnToEpisodeList()
end sub