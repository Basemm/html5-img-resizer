'use strict';

x = expect

###
Helper Functions
###
isPNG = (arrayBuffer) ->
    #PNG files bytes 1,2,3 "zero based indexing" represent letter 'PNG'
    header = new Uint8Array(arrayBuffer, 1, 3)
    type = String.fromCharCode(header[0], header[1],
                               header[2])

    type == 'PNG'


isJPEG = (arrayBuffer) ->
    #JPEG files bytes 6,7,8,9 "zero based indexing" represent letter 'JFIF'
    header = new Uint8Array(arrayBuffer, 6, 4)
    type = String.fromCharCode(header[0], header[1],
                               header[2], header[3])

    type == 'JFIF'


arrayBufferToDataURL = (nameArrayBuffer, cb) ->
    total = Object.keys( nameArrayBuffer ).length
    totalDone = 0
    nameDataURL = {}

    for key, value of nameArrayBuffer
        do (key) ->
            blob = new Blob( [value] )
            fr = new FileReader();

            fr.onload = (e) ->
                nameDataURL[key] = e.target.result
                totalDone++

                if totalDone == total
                    cb( nameDataURL )

            fr.readAsDataURL(blob)

    return


DataURLToLoadedImgs = (nameDataURL, cb) ->
    total = Object.keys( nameDataURL ).length
    totalDone = 0
    nameImg = {}

    for key, value of nameDataURL
        do (key) ->
            img = document.createElement('img')

            img.onload = () ->
                nameImg[key] = img
                totalDone++

                if totalDone == total
                    cb(nameImg)

            img.src = value

    return


describe 'Testing batch image resizer', ->
    nameImg = []

    #test images dimensions
    originalDimensions =
        dice: [800, 600]
        cat: [640, 533]


    before (done) ->
        dice = document.createElement('img')
        cat = document.createElement('img')

        dice.src = 'base/test/images/dice.png'
        cat.src = 'base/test/images/cat.jpg'

        nameImg =
            dice: dice
            cat: cat

        #finish when both images loaded
        dice.onload = cat.onload = ->
            if dice.complete and cat.complete
                done()


    it 'Images converted to PNG & resized to fixed dimensions ', (done) ->
        options =
            type: 'png'
            dimensions: [200,200]


        cb = (nameArrayBuffer) ->
            #check type
            x( isPNG(nameArrayBuffer['dice']) ).be.true
            x( isPNG(nameArrayBuffer['cat']) ).be.true

            arrayBufferToDataURL( nameArrayBuffer, (nameDataURL) ->
                DataURLToLoadedImgs(nameDataURL, (nameImg) ->
                    #check dimensions
                    x( nameImg['dice'].width ).equal(200)
                    x( nameImg['dice'].height ).equal(200)

                    x( nameImg['cat'].width ).equal(200)
                    x( nameImg['cat'].height ).equal(200)

                    done()
                )
            )

        App.resizeImgs(nameImg, options, cb)


    it 'Images converted to JPG & scaled down by half', (done) ->
        options =
            type: 'jpeg'
            scale: 50
            quality: 0.5


        cb = (nameArrayBuffer) ->
            #check type
            x( isJPEG(nameArrayBuffer['dice']) ).be.true
            x( isJPEG(nameArrayBuffer['cat']) ).be.true

            arrayBufferToDataURL( nameArrayBuffer, (nameDataURL) ->
                DataURLToLoadedImgs(nameDataURL, (nameImg) ->
                    #check dimensions
                    x( nameImg['dice'].width ).equal(400)
                    x( nameImg['dice'].height ).equal(300)

                    x( nameImg['cat'].width ).equal(320)
                    x( nameImg['cat'].height ).equal(266)

                    done()
                )
            )

        App.resizeImgs(nameImg, options, cb)


    it 'Create zip file with provided names', (done) ->
        options =
            type: 'jpeg'
            scale: 50

        cb = (nameArrayBuffer) ->
            zipBlob = App.zipArrayBuffers( nameArrayBuffer, 'jpg' )
            fr = new FileReader()

            fr.onload = (e) ->
                zip = new JSZip(e.target.result)

                x( zip.file('dice.jpg').name ).equal( 'dice.jpg' )
                x( zip.file('cat.jpg').name ).equal( 'cat.jpg' )

                done()

            fr.readAsArrayBuffer(zipBlob)


        App.resizeImgs(nameImg, options, cb)
