' Task for loading live streams - Static Greater Love TV channels
sub init()
    m.top.functionName = "loadLiveStreams"
end sub

sub loadLiveStreams()
    print "Loading Greater Love TV live streams"

    ' Create static live stream data with real HLS URLs
    contentArray = []

    ' Greater Love TV Channel 1
    channel1 = createObject("roSGNode", "ContentNode")
    channel1.addFields({
        "_id": "greater_love_tv_channel_1",
        "name": "Greater Love TV Channel 1",
        "enabled": true,
        "hls_url": "https://rpn.bozztv.com/dvrfl03/itv04060/index.m3u8",
        "embed_url": "https://swf.tulix.tv/iframe/greaterlove/",
        "broadcasting_status": "online",
        "thumbnail_url": "pkg:/images/GL_live_1.png",
        "description": "Greater Love TV - Live Christian Programming",
        "playback": {
            "hls_url": "https://rpn.bozztv.com/dvrfl03/itv04060/index.m3u8",
            "embed_url": "https://swf.tulix.tv/iframe/greaterlove/"
        }
    })
    contentArray.push(channel1)

    ' Greater Love TV Channel 2
    channel2 = createObject("roSGNode", "ContentNode")
    channel2.addFields({
        "_id": "greater_love_tv_channel_2",
        "name": "Greater Love TV Channel 2",
        "enabled": true,
        "hls_url": "https://rpn.bozztv.com/dvrfl04/itv04019/index.m3u8",
        "embed_url": "https://swf.tulix.tv/iframe/greaterlove2/",
        "broadcasting_status": "online",
        "thumbnail_url": "pkg:/images/GL_live_2.png",
        "description": "Greater Love TV Channel 2 - Live Christian Programming",
        "playback": {
            "hls_url": "https://rpn.bozztv.com/dvrfl04/itv04019/index.m3u8",
            "embed_url": "https://swf.tulix.tv/iframe/greaterlove2/"
        }
    })
    contentArray.push(channel2)

    ' Additional live streams can be added here
    ' For now, we'll use the two main Greater Love TV channels

    m.top.content = contentArray
    print "Loaded"; contentArray.count(); "live streams"
end sub

function getFieldValue(obj as object, fieldName as string) as dynamic
    if obj <> invalid and obj[fieldName] <> invalid
        return obj[fieldName]
    end if
    return ""
end function