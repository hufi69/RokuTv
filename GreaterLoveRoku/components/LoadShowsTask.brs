' Task for loading shows from Castr API
sub init()
    m.top.functionName = "loadShows"
end sub

sub loadShows()
    print "Loading shows from Castr API:"; m.top.apiUrl

    ' Create HTTP request with authentication
    request = createObject("roUrlTransfer")
    request.setUrl(m.top.apiUrl)
    request.setCertificatesFile("common:/certs/ca-bundle.crt")
    request.setRequest("GET")
    request.addHeader("Content-Type", "application/json")
    request.addHeader("Accept", "application/json")

    ' Add Basic Authentication for Castr API
    accessToken = "5aLoKjrNjly4"
    secretKey = "UjTCq8wOj76vjXznGFzdbMRzAkFq6VlJElBQ"
    credentials = accessToken + ":" + secretKey
    
    ' Use pre-computed Base64 for BrightScript compatibility
    authHeader = "Basic NWFMb0tqck5qbHk0OlVqVENxOHdPajc2dmpYem5HRnpkYk1SekFrRnE2VmxKRWxCUQ=="
    request.addHeader("Authorization", authHeader)

    ' Make request
    response = request.getToString()

    if response <> "" then
        ' Parse JSON response
        json = ParseJson(response)

        if json <> invalid and json.docs <> invalid then
            print "Successfully loaded"; json.docs.count(); "shows from Castr API"
            
            ' Convert to content nodes
            contentArray = []

            for each show in json.docs
                if show.enabled = true and show.data <> invalid and show.data.count() > 0
                    showNode = createObject("roSGNode", "ContentNode")

                    ' Convert episodes with enhanced data
                    episodes = []
                    for each episode in show.data
                        if episode.enabled = true
                            episodeNode = createObject("roSGNode", "ContentNode")
                            
                            ' Generate thumbnail URL from video ID
                            videoId = episode.id.replace(".mp4", "")
                            thumbnailUrl = "https://player.castr.com/api/v1/vod/" + videoId + "/thumbnail"
                            
                            ' Construct proper video URL for Roku playback
                            videoUrl = ""
                            if episode.playback <> invalid and episode.playback.embed_url <> invalid
                                videoUrl = episode.playback.embed_url
                            end if
                            
                            episodeNode.addFields({
                                "episodeId": episode.id,
                                "fileName": episode.fileName,
                                "enabled": episode.enabled,
                                "bytes": episode.bytes,
                                "playback": episode.playback,
                                "url": videoUrl,
                                "title": episode.fileName.replace(".mp4", ""),
                                "description": "Duration: " + getFieldValue(episode.mediaInfo, "durationMins").toStr() + " minutes",
                                "hdPosterUrl": thumbnailUrl,
                                "creationTime": getFieldValue(episode, "creationTime"),
                                "author": getFieldValue(episode, "author"),
                                "thumbnailUrl": thumbnailUrl,
                                "duration": getFieldValue(episode.mediaInfo, "durationMins"),
                                "durationSeconds": getFieldValue(episode.mediaInfo, "duration"),
                                "width": getFieldValue(episode.mediaInfo, "width"),
                                "height": getFieldValue(episode.mediaInfo, "height"),
                                "fps": getFieldValue(episode.mediaInfo, "fps")
                            })
                            episodes.push(episodeNode)
                        end if
                    end for

                    showNode.addFields({
                        "_id": show._id,
                        "name": show.name,
                        "enabled": show.enabled,
                        "type": getFieldValue(show, "type"),
                        "creation_time": getFieldValue(show, "creation_time"),
                        "data": episodes,
                        "episodes": episodes,
                        "episodeCount": episodes.count()
                    })
                    contentArray.push(showNode)
                end if
            end for

            m.top.content = contentArray
            print "Processed"; contentArray.count(); "enabled shows with episodes"
        else
            print "Invalid JSON response or no docs field"
            m.top.content = []
        end if
    else
        print "Empty response from Castr API"
        m.top.content = []
    end if
end sub

function getFieldValue(obj as object, fieldName as string) as dynamic
    if obj <> invalid and obj[fieldName] <> invalid
        return obj[fieldName]
    end if
    return ""
end function