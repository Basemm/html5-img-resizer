App =
    transitionEndEvent: 'webkitTransitionEnd otransitionend oTransitionEnd msTransitionEnd transitionend'

    init: ->
        $('.menu .item.add-files .icon').click( @addFiles.bind(@) )
        $('.menu .item.options .icon').click( @showOptions.bind(@) )
        $('.menu .item.resize .icon').click( @resize.bind(@) )
        $('.menu .item.about .icon').click( @showAbout.bind(@) )

        # Assigning blur event with jQuery won't work, need to check
        # and submit bug report
        $('.menu .item.options')[0].onblur = () -> App.closeSubMenu( $(@) )
        $('.menu .item.about')[0].onblur = () -> App.closeSubMenu( $(@) )


    #===============================================================
    # Menu Events
    addFiles: ->


    showOptions: ->
        @openSubMenu( $('.menu .item.options') )


    resize: ->


    showAbout: ->
        @openSubMenu( $('.menu .item.about') )


    #===============================================================
    # Helper functions
    openSubMenu: ($item) ->
        $item.on(@transitionEndEvent, ->
            $item.off(@transitionEndEvent)
                 .addClass('submenu-active')
        )

        $item.addClass('title-active')


    closeSubMenu: ($item) ->
        $subMenu = $item.find('.submenu')

        $subMenu.on(@transitionEndEvent, ->
            $item.removeClass('title-active')
            $subMenu.off(@transitionEndEvent)
        )

        $item.removeClass('submenu-active')

    #===============================================================
    # Core functions
    resizeImgs: (nameImg, options, cb) ->
        nameArrayBuffer = []
        totalImgs = Object.keys(nameImg).length
        totalCompletedImgs = 0

        for name, img of nameImg
            if options.scale
                options.dimensions = @scale2Dimension( [img.width, img.height],
                                                       options.scale )

            canvas = @resizedImgCanvas(img, options.dimensions)

            #copy 'name' inside the closure to avoid overwrites
            do (name) ->
                App.canvasToArrayBuffer( canvas, options.type, options.quality, (arrayBuffer) ->
                    nameArrayBuffer[name] = arrayBuffer

                    totalCompletedImgs++

                    if totalCompletedImgs == totalImgs
                        #run callback when all images resized & converted
                        cb( nameArrayBuffer )
                )


    scale2Dimension: (curDim, scale) ->
        [curDim[0] * (scale / 100), curDim[1] * (scale / 100)]


    resizedImgCanvas: (img, dimensions) ->
        canvas = document.createElement('canvas')
        ctx = canvas.getContext('2d')

        canvas.width = dimensions[0]
        canvas.height = dimensions[1]

        ctx.drawImage(img, 0, 0, img.width, img.height, 0 ,
                      0, dimensions[0], dimensions[1])

        canvas


    canvasToArrayBuffer: (canvas, type, quality, cb) ->
        canvas.toBlob( (blob) ->
            fr = new FileReader()

            fr.onload = (e) ->
                cb( e.target.result  )

            fr.readAsArrayBuffer( blob );

          #quality only for jpeg ranges from 0.0 to 1.0
        , 'image/' + type, quality)


    zipArrayBuffers: (nameArrayBuffer, ext) ->
        zip = new JSZip();

        for name, arrayBuffer of nameArrayBuffer
            zip.file(name + '.' + ext, arrayBuffer, {binary: true});

        zip.generate({type:"blob"})


    saveBlob: (blob, name) ->
        saveAs(blob, name);
