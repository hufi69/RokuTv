' Task for loading shows from Greater Love TV API
sub init()
    m.top.functionName = "loadShows"
end sub

sub loadShows()
    print "Loading shows from Greater Love TV API:"; m.top.apiUrl

    ' Create HTTP request with proper headers
    request = createObject("roUrlTransfer")
    request.setUrl(m.top.apiUrl)
    request.setCertificatesFile("common:/certs/ca-bundle.crt")
    request.setRequest("GET")
    
    ' Add required headers for Greater Love TV API
    request.addHeader("User-Agent", "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Safari/605.1.15")
    request.addHeader("Accept", "application/json, text/plain, */*")
    request.addHeader("Referer", "https://greaterlove.tv/")
    request.addHeader("Content-Type", "application/json")

    ' Make request
    response = request.getToString()

    if response <> "" then
        ' Parse JSON response
        json = ParseJson(response)

        if json <> invalid and json.status = "success" and json.data <> invalid then
            print "Successfully loaded"; json.total_shows; "shows from Greater Love TV API"
            
            ' Convert to content nodes
            contentArray = []

            ' Iterate through shows in the data object
            for each showName in json.data
                showData = json.data[showName]
                if showData <> invalid and showData.episodes <> invalid and showData.episodes.count() > 0
                    showNode = createObject("roSGNode", "ContentNode")

                    ' Convert episodes with enhanced data
                    episodes = []
                    for each episode in showData.episodes
                        episodeNode = createObject("roSGNode", "ContentNode")
                        
                        ' Use direct_url (HLS) for better Roku playback
                        videoUrl = ""
                        if episode.direct_url <> invalid and episode.direct_url <> ""
                            videoUrl = episode.direct_url
                        else if episode.embed_url <> invalid and episode.embed_url <> ""
                            videoUrl = episode.embed_url
                        end if
                        
                        ' Generate thumbnail URL from video ID
                        videoId = extractVideoIdFromUrl(episode.embed_url)
                        thumbnailUrl = ""
                        if videoId <> ""
                            thumbnailUrl = "https://player.castr.com/api/v1/vod/" + videoId + "/thumbnail"
                        end if
                        
                        episodeNode.addFields({
                            "episodeId": episode.id.toStr(),
                            "fileName": episode.episode_name,
                            "enabled": true,
                            "url": videoUrl,
                            "direct_url": episode.direct_url,
                            "embed_url": episode.embed_url,
                            "title": episode.episode_name,
                            "description": "Episode " + episode.id.toStr(),
                            "hdPosterUrl": thumbnailUrl,
                            "creationTime": episode.created_at,
                            "thumbnailUrl": thumbnailUrl,
                            "show_name": episode.show_name
                        })
                        episodes.push(episodeNode)
                    end for

                    showNode.addFields({
                        "_id": showName.replace(" ", "_").toLower(),
                        "name": showName,
                        "enabled": true,
                        "type": "vod",
                        "image_url": showData.image_url,
                        "data": episodes,
                        "episodes": episodes,
                        "episodeCount": episodes.count()
                    })
                    contentArray.push(showNode)
                end if
            end for

            m.top.content = contentArray
            print "Processed"; contentArray.count(); "shows with episodes"
        else
            print "Invalid JSON response or no data field"
            m.top.content = []
        end if
    else
        print "Empty response from Greater Love TV API"
        m.top.content = []
    end if
end sub

function getFieldValue(obj as object, fieldName as string) as dynamic
    if obj <> invalid and obj[fieldName] <> invalid
        return obj[fieldName]
    end if
    return ""
end function

function extractVideoIdFromUrl(url as string) as string
    ' Extract video ID from Castr embed URL
    ' Example: https://player.castr.com/vod/FEgYaygr8QDofmKX -> FEgYaygr8QDofmKX
    if url <> invalid and url.instr("/vod/") > -1
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