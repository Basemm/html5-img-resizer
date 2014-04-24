App =
    # name -> DOMImage for all loaded images
    loadedImages: {}
    totalLoadedImages: 0
    prevImgWrapW: 100,
    prevImgWrapOW: 118, # outer width with margins
    prevImgWrapH: 70,

     # track '.preview .slide-panel' tracking style left
     # property is not accurate
    curSlideLeft: 0,

    # use namespace 'trans' to be able to remove those events. not
    # providing the nampe space will cause click handler also to
    # be removed when trying to remove those events
    transitionEndEvent: 'webkitTransitionEnd.trans otransitionend.trans
                         oTransitionEnd.trans msTransitionEnd.trans
                         transitionend.trans'

    init: ->
        $('#add-images').click( App.addImages )
        $('#show-options').click( App.showOptions )
        $('#resize').click( App.resize )
        $('#show-about').click( App.showAbout )

        $('#toggle-preview').click( App.togglePreview )

        $('.menu .item:has(.submenu)').click( (e) ->
            # Prevent event bubble to avoid document
            # click handler closing submenu
            e.stopPropagation();
        )

        $(document).click( ->
            # close all active submenus. if the click happened
            # on a submenu we wont get here due to menu item
            # returning false
            App.closeSubMenu( $('.menu .item:has(.submenu).submenu-active') )
        )

        $('#files').change( ->
            App.loadFiles( this.files )
        )

        # preview panel image hover effect
        $('.preview').on('mouseenter', '.img-wrap', ->
            $(@).addClass('hover');
        )

        $('.preview').on('mouseleave', '.img-wrap', ->
            $(@).removeClass('hover');
        )

        # show image in main view
        $('.preview').on('click', '.img-wrap', App.selectImage)
        $('.preview').on('click', '.img-wrap .icon-cancel', App.removeImage)

        $('#preview-next').click(App.previewNext)
        $('#preview-back').click(App.previewBack)

        $('[name="img-type"]').change(->
            val = $(this).val()

            if val == 'jpeg'
                $('#jpeg-quality').removeAttr('disabled', '')
                    .parents('.control-group')
                    .removeClass('disabled')
            else
                $('#jpeg-quality').attr('disabled', '')
                    .val('')
                    .parents('.control-group')
                    .addClass('disabled')
        )

        $('[name="resize-by"]').change(->
            val = $(this).val()

            $('#' + val + '-controls').show()
                .siblings('.subcontrol-group')
                .hide()
        )


    #===============================================================
    # Actions Events
    addImages: ->
        $('#files').click();


    showOptions: ->
        App.openSubMenu( $('.menu .item.options') )


    resize: ->
        options = {}

        type = $('[name="img-type"]:checked').val()

        options['type'] = type

        if type == 'jpeg'
            jpegQuality = $('#jpeg-quality').val() || '1'

            options['quality'] = jpegQuality

        resizeBy = $('[name="resize-by"]:checked').val()

        if resizeBy == 'scale'
            scale = $('#scale').val() || 100

            options['scale'] = scale

        if resizeBy == 'dimensions'
            w = parseFloat( $('#width').val() ) || 100
            h = parseFloat( $('#height').val() ) || 100

            options['dimensions'] = [w, h]

        App.resizeImgs(App.loadedImages, options, (nameArrayBuffer) ->
            ext = if type == 'png' then 'png' else 'jpg'
            zip = App.zipArrayBuffers(nameArrayBuffer,  ext)

            App.saveBlob(zip, 'resizedImage.zip')
        )


    showAbout: ->
        App.openSubMenu( $('.menu .item.about') )


    togglePreview: ->
        $('.preview').toggleClass('hidden')


    selectImage:  ->
        $this = $(@)

        $this.siblings('.active').removeClass('active')
        $this.addClass('active');

        $('#view').show().find('img')
            .attr('src', $this.find('img').attr('src'))


    removeImage: ->
        $prevNext = $('#preview-next')
        $prevBack = $('#preview-back')
        $imgWrap = $(@).parents('.img-wrap')

        if $imgWrap.hasClass('active')
            $('#view').hide()

        uniqueName = $imgWrap.data('unique-name')

        delete App.loadedImages[uniqueName]

        App.totalLoadedImages--

        $imgWrap.remove()

        $('.preview .slide-panel').width( App.totalLoadedImages * App.prevImgWrapOW )


        # When there's no more next images and available < 4
        if $prevNext.is(':hidden') && $prevBack.is(':visible')
            $prevBack.click()

        # No more next images
        if App.curSlideLeft + (App.totalLoadedImages - 4) * App.prevImgWrapOW == 0
            $prevNext.hide()

        if App.totalLoadedImages == 4
            $prevNext.hide()
            $prevBack.hide()

        if App.totalLoadedImages == 0
            $('.menu').addClass('no-images')
            $('.preview').hide()


        # prevent img selection click event
        return false;


    previewNext: ->
        $('#preview-back').show()

        App.curSlideLeft = App.curSlideLeft - App.prevImgWrapOW

        $('.preview .slide-panel').css('left', App.curSlideLeft + 'px')

        if App.curSlideLeft + (App.totalLoadedImages - 4) * App.prevImgWrapOW == 0
            $(@).hide()


    previewBack: ->
        $('#preview-next').show()

        App.curSlideLeft = App.curSlideLeft + App.prevImgWrapOW

        $('.preview .slide-panel').css('left', App.curSlideLeft + 'px')

        if App.curSlideLeft == 0
            $(@).hide()


    #===============================================================
    # Helper functions
    openSubMenu: ($item) ->
        App.closeOtherSubMenus($item)

        $item.on(App.transitionEndEvent, ->
            $item.off('.trans')
                 .addClass('submenu-active')
        )

        $item.addClass('title-active')


    closeSubMenu: ($item) ->
        $subMenu = $item.find('.submenu')

        $subMenu.on(App.transitionEndEvent, ->
            $subMenu.off('.trans')
            $item.removeClass('title-active')
        )

        $item.removeClass('submenu-active')


    closeOtherSubMenus: ($curItem) ->
        $items = $('.menu .item.title-active').not( $curItem )

        $items.each( ->
            App.closeSubMenu( $(@) )
        )


    loadFiles: (files) ->
        for file, index in files
            nameExt = file.name

            do (nameExt, index) ->
                fr = new FileReader()

                fr.onload = (e) ->

                    img = document.createElement('img')

                    img.onload = ->
                        if App.totalLoadedImages == 0
                            $('#view').show().find('img')
                                      .attr('src', img.src)

                            $('.menu').removeClass('no-images')

                            $('.preview').show()


                        App.loadImage(img, nameExt)

                    img.src = e.target.result

                fr.readAsDataURL(file)


    loadImage: (img, nameExt) ->
        # name without extension
        name = nameExt.slice(0, nameExt.indexOf('.'))
        uniqueName = name

        if App.loadedImages.hasOwnProperty(name)
            i = 1

            # get unique name in case that name already used
            while (true)
                uniqueName = name + '_' + i
                i++

                if !(App.loadedImages.hasOwnProperty(uniqueName))
                    break


        App.loadedImages[uniqueName] = img
        App.totalLoadedImages++

        # add to preview
        App.addPreviewImage(img, nameExt, uniqueName)


    addPreviewImage: (img, nameExt, uniqueName) ->
        w = img.width
        h = img.height
        nW = 0
        nH = 0
        dimensionsTxt = w + ' × ' + h;

        ###
            We need to resize the image to fit ".preview .img-wrap" DIV
            which by default 100 × 80, so we set one dimension & depend
            on browser default behaviour of preserving aspect ratio then
            we fill remaining of .img-wrap with padding to center image.
            Note we dont just the check the largest dimension component and
            set it as the .img-wrap isn't square so we need the ratios check
        ###
        if h > w || (h/w) >= (App.prevImgWrapH/App.prevImgWrapW)
            img.height = nH = App.prevImgWrapH
            nW = App.prevImgWrapH * (w/h)
        else
            img.width = nW = App.prevImgWrapW
            nH = App.prevImgWrapW * (h/w)

        wPadding = Math.abs( (nW - App.prevImgWrapW) / 2 )
        hPadding = Math.abs( (nH - App.prevImgWrapH) / 2 )

        imgStyles =
            'display': 'inline-block'
            'padding-left': wPadding
            'padding-right': wPadding
            'padding-top': hPadding
            'padding-bottom': hPadding

        $(img).css(imgStyles)

        $slidePanel = $('.preview .thumbs .slide-panel')
        slidePanelW = $slidePanel.width()

        # + 2 to give more space to avoid flicker
        $slidePanel.width( slidePanelW + App.prevImgWrapOW )

        if App.totalLoadedImages > 4
            $('#preview-next').show()


        stateClass = ''

        if App.totalLoadedImages == 1
            stateClass = 'active'

        $('<div class="img-wrap ' + stateClass + '">
            <div class="dimensions" title="' + dimensionsTxt + '">' + dimensionsTxt + '</div>
            <div class="name" title=" ' + nameExt + '">' + nameExt + '</div>
            <div class="icon-cancel"></div>
            </div>').append(img)
                    .data('unique-name', uniqueName)
                    .prependTo( $slidePanel )


    #===============================================================
    # Core functions
    resizeImgs: (nameImg, options, cb) ->
        nameArrayBuffer = []
        totalImgs = Object.keys(nameImg).length
        totalCompletedImgs = 0

        for name, img of nameImg
            if options.scale
                options.dimensions = App.scale2Dimension( [img.naturalWidth, img.naturalHeight],
                                                       options.scale )

            canvas = App.resizedImgCanvas(img, options.dimensions)

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

        ctx.drawImage(img, 0, 0, img.naturalWidth, img.naturalHeight, 0 ,
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
