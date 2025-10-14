' MainScene BrightScript Logic - Netflix Style Design
' Modern streaming UI with carousels

sub init()
    print "MainScene init - Greater Love TV"

    ' Get UI elements
    m.ministerGridBg = m.top.findNode("ministerGridBg")
    m.continueWatchingList = m.top.findNode("continueWatchingList")
    m.categoriesList = m.top.findNode("categoriesList")
    m.premiumShowsList = m.top.findNode("premiumShowsList")
    m.showsList = m.top.findNode("showsList")
    m.liveStreamsList = m.top.findNode("liveStreamsList")
    m.videoPlayer = m.top.findNode("videoPlayer")
    m.loadingSpinner = m.top.findNode("loadingSpinner")
    m.focusIndicator = m.top.findNode("focusIndicator")
    
    ' Navigation buttons
    m.homeLabel = m.top.findNode("homeLabel")
    m.aboutLabel = m.top.findNode("aboutLabel")
    m.categoriesLabel = m.top.findNode("categoriesLabel")
    m.infoLabel = m.top.findNode("infoLabel")

    ' Navigation state
    m.currentSection = 0  ' Start with continue watching
    m.sections = [m.continueWatchingList, m.categoriesList, m.premiumShowsList, m.showsList, m.liveStreamsList]
    m.sectionNames = ["Continue Watching", "Categories", "Premium Shows", "All Shows", "Live Streams"]

    ' Set initial focus to continue watching
    m.continueWatchingList.setFocus(true)
    m.currentFocusList = m.continueWatchingList

    ' Setup observers
    m.continueWatchingList.observeField("itemSelected", "onItemSelected")
    m.categoriesList.observeField("itemSelected", "onItemSelected")
    m.premiumShowsList.observeField("itemSelected", "onItemSelected")
    m.showsList.observeField("itemSelected", "onItemSelected")
    m.liveStreamsList.observeField("itemSelected", "onItemSelected")
    m.videoPlayer.observeField("state", "onVideoPlayerState")

    ' Setup focus observers for better navigation feedback
    m.continueWatchingList.observeField("itemFocused", "onItemFocused")
    m.categoriesList.observeField("itemFocused", "onItemFocused")
    m.showsList.observeField("itemFocused", "onItemFocused")
    m.liveStreamsList.observeField("itemFocused", "onItemFocused")

    ' Load content
    loadContent()
end sub

sub setupHeroBackground()
    ' Setup minister grid background
    ministerItems = []
    
    ' Generate minister thumbnails for background
    for i = 0 to 31
        ministerItem = createObject("roSGNode", "ContentNode")
        ministerItem.hdPosterUrl = "pkg:/images/minister_placeholder.png"
        ministerItems.append(ministerItem)
    end for
    
    ' Create grid content
    gridContent = createObject("roSGNode", "ContentNode")
    gridContent.appendChild(ministerItems)
    m.ministerGridBg.content = gridContent
end sub

sub setupContinueWatching()
    ' Setup continue watching carousel
    continueItems = []
    
    channels = [
        {title: "DAYSTAR", color: "0x0099cc"},
        {title: "CANADA LIVE", color: "0xffffff"},
        {title: "ESPAÑOL", color: "0xff6b6b"},
        {title: "ISRAEL", color: "0x0066cc"},
        {title: "ESPAÑA", color: "0x00cc99"}
    ]
    
    for each channel in channels
        item = createObject("roSGNode", "ContentNode")
        item.title = channel.title
        item.hdPosterUrl = "pkg:/images/channel_placeholder.png"
        item.contentType = "live"
        continueItems.append(item)
    end for
    
    content = createObject("roSGNode", "ContentNode")
    content.appendChild(continueItems)
    m.continueWatchingList.content = content
end sub

sub setupCategories()
    ' Setup categories carousel with Greater Love TV content
    categoryItems = []

    categories = [
        {title: "LIVE STREAMS", label: "Watch Live", image: "GL_live_1.png", action: "focus_live"},
        {title: "ALL SHOWS", label: "Browse All", image: "app_logo.png", action: "focus_shows"},
        {title: "ABOUT US", label: "Our Mission", image: "about_us_top.png", action: "show_about"},
        {title: "CONNECT", label: "QR Codes", image: "donate_qrcode.png", action: "show_qr"},
        {title: "PRAYER REQUESTS", label: "We Pray", image: "prayer_request_qrcode.png", action: "show_prayer"}
    ]

    for each category in categories
        item = createObject("roSGNode", "ContentNode")
        item.title = category.title
        item.description = category.label
        item.hdPosterUrl = "pkg:/images/" + category.image
        item.contentType = "category"
        item.categoryType = category.title.toLower().replace(" ", "_")
        item.action = category.action
        categoryItems.append(item)
    end for

    content = createObject("roSGNode", "ContentNode")
    content.appendChild(categoryItems)
    m.categoriesList.content = content
end sub

sub setupShows()
    ' Setup shows carousel with circular thumbnails
    showItems = []
    
    shows = [
        {title: "Oasis Ministries", subtitle: "Anthony & Shelia Wynn"},
        {title: "Jessica & Micah Wynn", subtitle: "Lead By The Word"},
        {title: "Created To Praise", subtitle: "Tim Hill"},
        {title: "Manna-Fest", subtitle: "Perry Stone"},
        {title: "Pace Assembly", subtitle: "Joey And Rita Rogers"},
        {title: "Word Of Life Min", subtitle: "Dr. Cesar Miranda"}
    ]
    
    for each show in shows
        item = createObject("roSGNode", "ContentNode")
        item.title = show.title
        item.description = show.subtitle
        item.hdPosterUrl = "pkg:/images/show_circular.png"
        item.contentType = "show"
        showItems.append(item)
    end for
    
    content = createObject("roSGNode", "ContentNode")
    content.appendChild(showItems)
    m.showsList.content = content
end sub

sub setupLiveStreams()
    ' Setup live streams carousel with proper Greater Love TV streams
    liveItems = []

    ' Load real live streams from API task
    m.loadLiveStreamsTask = createObject("roSGNode", "LoadLiveStreamsTask")
    m.loadLiveStreamsTask.observeField("content", "onLiveStreamsLoaded")
    m.loadLiveStreamsTask.control = "RUN"
end sub

sub onLiveStreamsLoaded(event as object)
    liveStreams = event.getData()
    print "Live streams loaded:", liveStreams.count()

    if liveStreams <> invalid and liveStreams.count() > 0
        liveItems = []

        for each stream in liveStreams
            if stream.enabled = true
                item = createObject("roSGNode", "ContentNode")
                item.title = stream.name
                item.description = "Live Christian Programming"

                ' Use the proper live stream images
                if stream.name.instr("Channel 1") > -1 or stream.name.instr("TV I") > -1
                    item.hdPosterUrl = "pkg:/images/GL_live_1.png"
                else if stream.name.instr("Channel 2") > -1 or stream.name.instr("TV II") > -1
                    item.hdPosterUrl = "pkg:/images/GL_live_2.png"
                else
                    item.hdPosterUrl = "pkg:/images/app_logo.png"
                end if

                item.contentType = "livestream"

                ' Use HLS URL if available, otherwise embed URL
                if stream.hls_url <> invalid and stream.hls_url <> ""
                    item.url = stream.hls_url
                else if stream.playback <> invalid and stream.playback.hls_url <> invalid
                    item.url = stream.playback.hls_url
                else if stream.embed_url <> invalid
                    item.url = stream.embed_url
                else if stream.playback <> invalid and stream.playback.embed_url <> invalid
                    item.url = stream.playback.embed_url
                end if

                item.streamData = stream
                liveItems.append(item)
            end if
        end for

        content = createObject("roSGNode", "ContentNode")
        content.appendChild(liveItems)
        m.liveStreamsList.content = content
    else
        ' Fallback to static setup if API fails
        setupStaticLiveStreams()
    end if
end sub

sub setupStaticLiveStreams()
    ' Fallback static live streams setup
    liveItems = []

    streams = [
        {title: "Greater Love TV I", url: "https://rpn.bozztv.com/dvrfl03/itv04060/index.m3u8", image: "GL_live_1.png"},
        {title: "Greater Love TV II", url: "https://rpn.bozztv.com/dvrfl04/itv04019/index.m3u8", image: "GL_live_2.png"}
    ]

    for each stream in streams
        item = createObject("roSGNode", "ContentNode")
        item.title = stream.title
        item.description = "Live Christian Programming"
        item.hdPosterUrl = "pkg:/images/" + stream.image
        item.contentType = "livestream"
        item.url = stream.url
        liveItems.append(item)
    end for

    content = createObject("roSGNode", "ContentNode")
    content.appendChild(liveItems)
    m.liveStreamsList.content = content
end sub

sub loadContent()
    print "Loading Greater Love TV content..."
    m.loadingSpinner.visible = true

    ' Setup all content sections
    setupHeroBackground()
    setupContinueWatching()
    setupCategories()
    loadRealShows()
    setupLiveStreams()

    ' Hide loading spinner
    m.loadingSpinner.visible = false
end sub

sub setupPremiumShows()
    ' Setup premium shows carousel with shows that have most episodes
    print "Setting up Premium Shows..."
    
    ' This will be populated when real shows are loaded
    ' For now, setup placeholder
    premiumItems = []
    
    content = createObject("roSGNode", "ContentNode")
    content.appendChild(premiumItems)
    m.premiumShowsList.content = content
end sub

sub setupPremiumShowsWithRealData(shows as object)
    ' Setup premium shows with real API data (shows with most episodes)
    premiumItems = []
    
    ' Filter shows that have episodes and sort by episode count
    showsWithEpisodes = []
    for each show in shows
        if show.data <> invalid and show.data.count() > 0 and show.enabled = true
            show.episodeCount = show.data.count()
            showsWithEpisodes.push(show)
        end if
    end for
    
    ' Sort by episode count (descending) - simple bubble sort for BrightScript
    for i = 0 to showsWithEpisodes.count() - 2
        for j = 0 to showsWithEpisodes.count() - 2 - i
            if showsWithEpisodes[j].episodeCount < showsWithEpisodes[j + 1].episodeCount
                temp = showsWithEpisodes[j]
                showsWithEpisodes[j] = showsWithEpisodes[j + 1]
                showsWithEpisodes[j + 1] = temp
            end if
        end for
    end for
    
    ' Take top 6 shows as premium
    premiumCount = showsWithEpisodes.count()
    if premiumCount > 6 then premiumCount = 6
    
    for i = 0 to premiumCount - 1
        show = showsWithEpisodes[i]
        item = createObject("roSGNode", "ContentNode")
        item.title = show.name
        item.description = show.episodeCount.toStr() + " Episodes ⭐ PREMIUM"
        item.hdPosterUrl = "pkg:/images/app_logo.png"
        item.contentType = "show"
        item.showData = show
        premiumItems.append(item)
    end for
    
    content = createObject("roSGNode", "ContentNode")
    content.appendChild(premiumItems)
    m.premiumShowsList.content = content
    
    print "Premium Shows setup complete:", premiumItems.count(), "shows"
end sub

sub loadRealShows()
    ' Load real shows from API using the LoadShowsTask
    m.loadShowsTask = createObject("roSGNode", "LoadShowsTask")
    m.loadShowsTask.apiUrl = "https://api.castr.com/v2/videos?page=1&per_page=50"
    m.loadShowsTask.observeField("content", "onShowsLoaded")
    m.loadShowsTask.control = "RUN"
end sub

sub onShowsLoaded(event as object)
    shows = event.getData()
    print "Shows loaded:", shows.count()

    if shows <> invalid and shows.count() > 0
        ' Store shows globally for access
        m.allShows = shows

        ' Setup both premium shows and all shows with real data
        setupPremiumShowsWithRealData(shows)
        setupShowsWithRealData(shows)
    else
        ' Fallback to mock shows if API fails
        setupPremiumShows()
        setupShows()
    end if
end sub

sub setupShowsWithRealData(shows as object)
    ' Setup shows carousel with real API data
    showItems = []

    ' Take first 6 shows for the carousel
    showCount = shows.count()
    if showCount > 6 then showCount = 6

    for i = 0 to showCount - 1
        show = shows[i]
        if show.enabled = true
            item = createObject("roSGNode", "ContentNode")
            item.title = show.name
            item.description = show.episodeCount.toStr() + " episodes"

            ' Use app logo as placeholder for show thumbnail
            item.hdPosterUrl = "pkg:/images/app_logo.png"
            item.contentType = "show"
            item.showData = show
            showItems.append(item)
        end if
    end for

    content = createObject("roSGNode", "ContentNode")
    content.appendChild(showItems)
    m.showsList.content = content
end sub

sub onItemSelected(event as object)
    selectedIndex = event.getData()
    selectedList = event.getRoSGNode()
    selectedItem = selectedList.content.getChild(selectedIndex)

    print "Selected item:"; selectedItem.title; "Type:"; selectedItem.contentType

    ' Handle different content types
    if selectedItem.contentType = "livestream"
        playLiveStream(selectedItem)
    else if selectedItem.contentType = "show"
        navigateToEpisodeList(selectedItem)
    else if selectedItem.contentType = "category"
        showCategoryContent(selectedItem)
    else if selectedItem.contentType = "live"
        playChannel(selectedItem)
    end if
end sub

sub navigateToEpisodeList(showItem as object)
    print "Navigating to episode list for:", showItem.title

    ' Create episode list scene
    episodeScene = createObject("roSGNode", "EpisodeListScene")

    ' Pass show data to the episode scene
    if showItem.showData <> invalid
        episodeScene.showData = showItem.showData
    else
        ' If no real show data, create a mock one
        mockShow = createObject("roSGNode", "ContentNode")
        mockShow.name = showItem.title
        mockShow.episodes = []
        episodeScene.showData = mockShow
    end if

    ' Set up observer for back button
    episodeScene.observeField("backPressed", "onEpisodeSceneBack")

    ' Show the episode scene
    m.top.appendChild(episodeScene)
    episodeScene.setFocus(true)

    ' Hide main scene elements
    m.continueWatchingList.visible = false
    m.categoriesList.visible = false
    m.showsList.visible = false
    m.liveStreamsList.visible = false

    ' Store reference to episode scene
    m.currentEpisodeScene = episodeScene
end sub

sub onEpisodeSceneBack(event as object)
    print "Back pressed from episode scene"

    ' Remove episode scene
    if m.currentEpisodeScene <> invalid
        m.top.removeChild(m.currentEpisodeScene)
        m.currentEpisodeScene = invalid
    end if

    ' Show main scene elements
    m.continueWatchingList.visible = true
    m.categoriesList.visible = true
    m.showsList.visible = true
    m.liveStreamsList.visible = true

    ' Restore focus to shows list
    m.showsList.setFocus(true)
    m.currentFocusList = m.showsList
end sub

sub playLiveStream(item as object)
    ' Play live stream
    if item.url <> invalid and item.url <> ""
        videoContent = createObject("roSGNode", "ContentNode")
        videoContent.url = item.url
        videoContent.title = item.title
        videoContent.streamFormat = "hls"
        videoContent.live = true
        
        m.videoPlayer.content = videoContent
        m.videoPlayer.visible = true
        m.videoPlayer.setFocus(true)
        m.videoPlayer.control = "play"
    else
        showDialog("Stream Unavailable", "This stream is currently unavailable.")
    end if
end sub

sub playChannel(item as object)
    showDialog(item.title, "Playing channel: " + item.title)
end sub

sub showDetails(item as object)
    showDialog(item.title, item.description)
end sub

sub showCategoryContent(item as object)
    print "Category selected:", item.title, "Action:", item.action

    if item.action = "show_about"
        navigateToAboutScene()
    else if item.action = "focus_live"
        ' Focus on live streams section
        m.liveStreamsList.setFocus(true)
        m.currentFocusList = m.liveStreamsList
        m.currentSection = 4  ' Updated index for live streams
    else if item.action = "focus_shows"
        ' Focus on all shows section
        m.showsList.setFocus(true)
        m.currentFocusList = m.showsList
        m.currentSection = 3  ' Updated index for all shows
    else if item.action = "show_qr"
        navigateToQRCodesScene()
    else if item.action = "show_prayer"
        navigateToQRCodesScene()
    else
        showDialog(item.title, item.description)
    end if
end sub

sub navigateToQRCodesScene()
    print "Navigating to QR Codes scene"

    ' Create QR codes scene
    qrScene = createObject("roSGNode", "QRCodesScene")

    ' Set up observer for back button
    qrScene.observeField("backPressed", "onQRSceneBack")

    ' Switch to QR scene
    m.top.getScene().appendChild(qrScene)
    qrScene.setFocus(true)
end sub

sub onQRSceneBack(event as object)
    print "Returning from QR Codes scene"
    
    ' Remove QR scene
    qrScene = event.getRoSGNode()
    m.top.getScene().removeChild(qrScene)
    
    ' Return focus to main scene
    m.continueWatchingList.setFocus(true)
    m.currentFocusList = m.continueWatchingList
end sub

sub navigateToAboutScene()
    print "Navigating to About scene"

    ' Create about scene
    aboutScene = createObject("roSGNode", "AboutScene")

    ' Set up observer for back button
    aboutScene.observeField("backPressed", "onAboutSceneBack")

    ' Show the about scene
    m.top.appendChild(aboutScene)
    aboutScene.setFocus(true)

    ' Hide main scene elements
    m.continueWatchingList.visible = false
    m.categoriesList.visible = false
    m.showsList.visible = false
    m.liveStreamsList.visible = false

    ' Store reference to about scene
    m.currentAboutScene = aboutScene
end sub

sub onAboutSceneBack(event as object)
    print "Back pressed from about scene"

    ' Remove about scene
    if m.currentAboutScene <> invalid
        m.top.removeChild(m.currentAboutScene)
        m.currentAboutScene = invalid
    end if

    ' Show main scene elements
    m.continueWatchingList.visible = true
    m.categoriesList.visible = true
    m.showsList.visible = true
    m.liveStreamsList.visible = true

    ' Restore focus to categories list
    m.categoriesList.setFocus(true)
    m.currentFocusList = m.categoriesList
    m.currentSection = 1
end sub

sub onVideoPlayerState(event as object)
    state = event.getData()

    if state = "finished" or state = "stopped"
        ' Return to current list
        m.videoPlayer.visible = false
        m.currentFocusList.setFocus(true)
    else if state = "error"
        showDialog("Playback Error", "Unable to play this content. Please try again.")
        m.videoPlayer.visible = false
        m.currentFocusList.setFocus(true)
    end if
end sub

sub showDialog(title as string, message as string)
    dialog = createObject("roSGNode", "Dialog")
    dialog.title = title
    dialog.message = message
    dialog.buttons = ["OK"]
    m.top.appendChild(dialog)
    dialog.observeField("buttonSelected", "onDialogButton")
    dialog.setFocus(true)
end sub

sub onDialogButton(event as object)
    ' Close dialog
    event.getRoSGNode().getParent().removeChild(event.getRoSGNode())
    m.currentFocusList.setFocus(true)
end sub

' Enhanced navigation and focus management
sub onItemFocused(event as object)
    ' Update focus indicator when items are focused
    focusedList = event.getRoSGNode()
    focusedIndex = event.getData()

    ' Find which section is currently focused
    for i = 0 to m.sections.count() - 1
        if m.sections[i].isSameNode(focusedList)
            m.currentSection = i
            m.currentFocusList = focusedList
            print "Focus moved to section:", m.sectionNames[i], "item:", focusedIndex
            exit for
        end if
    end for
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    ' Handle key events for better TV remote navigation
    if press
        if key = "up" or key = "down"
            return handleVerticalNavigation(key)
        else if key = "back"
            ' Handle back button - exit app or return from video
            if m.videoPlayer.visible
                returnToMainUI()
                return true
            end if
        else if key = "options" or key = "info"
            ' INFO button pressed - show QR codes
            navigateToQRCodesScene()
            return true
        else if key = "replay"
            ' ABOUT US button - navigate to about scene
            navigateToAboutScene()
            return true
        end if
    end if
    return false
end function

function handleVerticalNavigation(key as string) as boolean
    ' Handle up/down navigation between sections
    if key = "up" and m.currentSection > 0
        ' Move to previous section
        newSection = m.currentSection - 1
        m.sections[newSection].setFocus(true)
        return true
    else if key = "down" and m.currentSection < m.sections.count() - 1
        ' Move to next section
        newSection = m.currentSection + 1
        m.sections[newSection].setFocus(true)
        return true
    end if
    return false
end function

sub returnToMainUI()
    ' Return from video player to main UI
    m.videoPlayer.visible = false
    m.videoPlayer.control = "stop"

    ' Show all UI elements
    m.continueWatchingList.visible = true
    m.categoriesList.visible = true
    m.showsList.visible = true
    m.liveStreamsList.visible = true

    ' Restore focus to current section
    m.currentFocusList.setFocus(true)
end sub