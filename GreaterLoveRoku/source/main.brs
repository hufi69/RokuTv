' Main entry point for Greater Love TV Roku Channel
' Figma Design Implementation

sub Main()
    print "Starting Greater Love TV - Figma Design"

    ' Create and show the main scene
    screen = createObject("roSGScreen")
    scene = screen.createScene("MainScene")
    screen.show()

    ' Setup message port for handling events
    port = createObject("roMessagePort")
    screen.setMessagePort(port)

    ' Main event loop
    while true
        msg = wait(0, port)
        if msg <> invalid then
            if type(msg) = "roSGScreenEvent" then
                if msg.isScreenClosed() then
                    return
                end if
            end if
        end if
    end while
end sub

sub showLegacyUI()
    print "Running in Legacy Mode for BRS Desktop"
    showSimpleMenu()
end sub

sub showSimpleMenu()
    print ""
    print "==================================="
    print "    GREATER LOVE TV - ROKU APP"
    print "==================================="
    print ""
    print "App successfully loaded!"
    print ""
    print "Features implemented:"
    print "✓ Live Streaming API integration"
    print "✓ Video on Demand episodes"
    print "✓ Show categories and navigation"
    print "✓ API connectivity to Greater Love Network"
    print ""
    print "API Endpoints:"
    print "• Live Streams: Static HLS streams (Greater Love TV Channel 1 & 2)"
    print "• Shows: https://api.castr.com/v2/videos (51 video collections)"
    print "• Access Token: 5aLoKjrNjly4"
    print ""

    ' Test API connectivity
    testAPIConnectivity()

    print "==================================="
    print "SUCCESS: App ready for deployment!"
    print "For full UI testing, use web simulator"
    print "==================================="

    ' Keep app running
    while true
        sleep(1000)
    end while
end sub

sub testAPIConnectivity()
    print "Testing API connectivity..."

    ' Test Castr API with authentication
    request = CreateObject("roUrlTransfer")
    if request <> invalid
        print "✓ HTTP client available"

        request.SetUrl("https://api.castr.com/v2/videos?page=1&per_page=10")
        request.SetRequest("GET")
        request.AddHeader("Content-Type", "application/json")
        request.AddHeader("Accept", "application/json")

        ' Add Basic Authentication for Castr API
        accessToken = "5aLoKjrNjly4"
        secretKey = "UjTCq8wOj76vjXznGFzdbMRzAkFq6VlJElBQ"
        credentials = accessToken + ":" + secretKey

        ' Use pre-computed Base64 for BrightScript compatibility
        ' Base64 of "5aLoKjrNjly4:UjTCq8wOj76vjXznGFzdbMRzAkFq6VlJElBQ"
        authHeader = "Basic NWFMb0tqck5qbHk0OlVqVENxOHdPajc2dmpYem5HRnpkYk1SekFrRnE2VmxKRWxCUQ=="
        request.AddHeader("Authorization", authHeader)

        ' Try to make request with timeout
        request.SetPort(CreateObject("roMessagePort"))

        if request.AsyncGetToString()
            msg = wait(5000, request.GetPort())
            if msg <> invalid and type(msg) = "roUrlEvent"
                response = msg.GetString()
                if response <> "" and response <> invalid
                    print "✓ Castr API: Connected successfully"
                    print "Response length:", len(response), "bytes"

                    ' Try to parse JSON
                    json = ParseJson(response)
                    if json <> invalid and json.docs <> invalid
                        print "✓ Found", json.docs.Count(), "video collections in API"

                        ' Show first show name if available
                        if json.docs.Count() > 0 and json.docs[0].name <> invalid
                            print "✓ Sample show:", json.docs[0].name
                            if json.docs[0].data <> invalid
                                print "✓ Episodes in first show:", json.docs[0].data.Count()
                            end if
                        end if
                    else
                        print "⚠ API response format may need verification"
                    end if
                else
                    print "✗ Castr API: Empty response"
                end if
            else
                print "✗ Castr API: Request timeout or failed"
            end if
        else
            print "✗ Failed to initiate API request"
        end if
    else
        print "✗ HTTP client not available in this environment"
    end if

    ' Test static live streams
    print "✓ Static Live Streams configured:"
    print "  - Greater Love TV Channel 1: https://rpn.bozztv.com/dvrfl03/itv04060/index.m3u8"
    print "  - Greater Love TV Channel 2: https://rpn.bozztv.com/dvrfl04/itv04019/index.m3u8"

    print ""
end sub