App =
    # use namespace 'trans' to be able to remove those events. not
    # providing the nampe space will cause click handler also to
    # be removed when trying to remove those events
    transitionEndEvent: 'webkitTransitionEnd.trans otransitionend.trans
                         oTransitionEnd.trans msTransitionEnd.trans
                         transitionend.trans'

    init: ->
        $('#add-images').click( @addImages.bind(@) )
        $('#show-options').click( @showOptions.bind(@) )
        $('#resize').click( @resize.bind(@) )
        $('#show-about').click( @showAbout.bind(@) )

        $('#toggle-preview').click( @togglePreview.bind(@) )

        $('.menu .item:has(.submenu)').click( (e) ->
            # Prevent event bubble to avoid document
            # click handler closing submenu
            return false;
        )

        $(document).click( ->
            # close all active submenus. if the click happened
            # on a submenu we wont get here due to menu item
            # returning false
            App.closeSubMenu( $('.menu .item:has(.submenu).submenu-active') )
        )

    #===============================================================
    # Actions Events
    addImages: ->


    showOptions: ->
        @openSubMenu( $('.menu .item.options') )


    resize: ->


    showAbout: ->
        @openSubMenu( $('.menu .item.about') )


    togglePreview: ->
        $('.preview').toggleClass('hidden')


    #===============================================================
    # Helper functions
    openSubMenu: ($item) ->
        @closeOtherSubMenus($item)

        $item.on(@transitionEndEvent, ->
            $item.off('.trans')
                 .addClass('submenu-active')
        )

        $item.addClass('title-active')


    closeSubMenu: ($item) ->
        $subMenu = $item.find('.submenu')

        $subMenu.on(@transitionEndEvent, ->
            $item.removeClass('title-active')
            $subMenu.off('.trans')
        )

        $item.removeClass('submenu-active')

    closeOtherSubMenus: ($curItem) ->
        $items = $('.menu .item:has(.submenu)').not( $curItem )

        $items.each( ->
            $item = $(@)
            App.closeSubMenu($item)
        )

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
