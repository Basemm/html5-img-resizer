"use strict";

App =
    # name -> DOMImage for all loaded images
    loadedImgs: {}
    totalLoadedImgs: 0
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
        $('#add-imgs .icon').click( App.addImgs )
        $('#show-options .icon').click( App.showOptions )
        $('#resize .icon').click( App.resize )
        $('#show-about .icon').click( App.showAbout )

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
            $(@).addClass('hover')
        )

        $('.preview').on('mouseleave', '.img-wrap', ->
            $(@).removeClass('hover')
        )

        # show image in main view
        $('.preview').on('click', '.img-wrap', App.selectImg)
        $('.preview').on('click', '.img-wrap .icon-cancel', App.removeImg)

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
            $ctrl = $('#' + val + '-controls')

            $ctrl.show()
                .siblings('.subcontrol-group')
                .hide()

            $ctrl.find('input').eq(0).focus()

            if ( val == 'dimensions' )
                $('#aspect-ratio-hint').show()
            else
                $('#aspect-ratio-hint').hide()
        )


    #===============================================================
    # Actions Events
    addImgs: ->
        $('#files').click();


    showOptions: ->
        App.openSubMenu( $('#show-options') )


    resize: ->
        App.showLoading()

        # run after few millisecs to allow loading spinner to show
        setTimeout(->
            options = {}

            type = $('[name="img-type"]:checked').val()

            options['type'] = type

            if type == 'jpeg'
                # should validate input instead of using defaults everywhere!
                jpegQuality = $('#jpeg-quality').val() || 100

                options['quality'] = jpegQuality / 100

            resizeBy = $('[name="resize-by"]:checked').val()

            if resizeBy == 'scale'
                scale = $('#scale').val() || 100

                options['scale'] = scale

            if resizeBy == 'dimensions'
                w = parseFloat( $('#width').val() ) || 100
                h = parseFloat( $('#height').val() )

                options['dimensions'] = [w, h]

            App.resizeImgs(App.loadedImgs, options, (nameArrayBuffer) ->
                ext = if type == 'png' then 'png' else 'jpg'
                zip = App.zipArrayBuffers(nameArrayBuffer,  ext)

                App.saveBlob(zip, 'resizedImages.zip')

                App.hideLoading()
            )
        , 5)


    showAbout: ->
        App.openSubMenu( $('#show-about') )


    togglePreview: ->
        $('.preview').toggleClass('hidden')


    selectImg:  ->
        $this = $(@)

        $this.siblings('.active').removeClass('active')
        $this.addClass('active');

        $('#view').show().find('img')
            .attr('src', $this.find('img').attr('src'))


    removeImg: ->
        $prevNext = $('#preview-next')
        $prevBack = $('#preview-back')
        $imgWrap = $(@).parents('.img-wrap')

        if $imgWrap.hasClass('active')
            $('#view').hide()

        uniqueName = $imgWrap.data('unique-name')

        delete App.loadedImgs[uniqueName]

        App.totalLoadedImgs--

        $imgWrap.remove()

        $('.preview .slide-panel').width( App.totalLoadedImgs * App.prevImgWrapOW )


        # When there's no more next images and available < 4
        if $prevNext.is(':hidden') && $prevBack.is(':visible')
            $prevBack.click()

        # No more next images
        if App.curSlideLeft + (App.totalLoadedImgs - 4) * App.prevImgWrapOW == 0
            $prevNext.hide()

        if App.totalLoadedImgs == 4
            $prevNext.hide()
            $prevBack.hide()

        if App.totalLoadedImgs == 0
            $('.menu').addClass('no-imgs')
            $('.preview').hide()
            $('#start-adding-imgs').show()


        # prevent img selection click event
        return false;


    previewNext: ->
        $('#preview-back').show()

        App.curSlideLeft = App.curSlideLeft - App.prevImgWrapOW

        $('.preview .slide-panel').css('left', App.curSlideLeft + 'px')

        if App.curSlideLeft + (App.totalLoadedImgs - 4) * App.prevImgWrapOW == 0
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
        totalFiles = files.length
        totalLoadedFiles = 0

        # avoid showing loader if user cancelled add files dialog
        if totalFiles
            App.showLoading()

        for file, index in files
            nameExt = file.name

            do (nameExt, index) ->
                fr = new FileReader()

                fr.onload = (e) ->

                    img = document.createElement('img')

                    img.onload = ->
                        totalLoadedFiles++

                        if App.totalLoadedImgs == 0
                            $('#start-adding-imgs').hide()

                            $('#view').show().find('img')
                                      .attr('src', img.src)

                            $('.menu').removeClass('no-imgs')

                            $('.preview').show()


                        if totalLoadedFiles == totalFiles
                            App.hideLoading()


                        App.loadImg(img, nameExt)

                    img.src = e.target.result

                fr.readAsDataURL(file)


    loadImg: (img, nameExt) ->
        # name without extension
        name = nameExt.slice(0, nameExt.indexOf('.'))
        uniqueName = name

        if App.loadedImgs.hasOwnProperty(name)
            i = 1

            # get unique name in case that name already used
            while (true)
                uniqueName = name + '_' + i
                i++

                if !(App.loadedImgs.hasOwnProperty(uniqueName))
                    break


        App.loadedImgs[uniqueName] = img
        App.totalLoadedImgs++

        # add to preview
        App.addPreviewImg(img, nameExt, uniqueName)


    addPreviewImg: (img, nameExt, uniqueName) ->
        w = img.width
        h = img.height
        nW = 0
        nH = 0
        dimensionsTxt = w + ' × ' + h

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
            'padding-left': wPadding
            'padding-right': wPadding
            'padding-top': hPadding
            'padding-bottom': hPadding

        $(img).css(imgStyles)

        $slidePanel = $('.preview .thumbs .slide-panel')
        slidePanelW = $slidePanel.width()

        $slidePanel.width( slidePanelW + App.prevImgWrapOW )

        if App.totalLoadedImgs > 4
            $('#preview-next').show()


        stateClass = ''

        if App.totalLoadedImgs == 1
            stateClass = 'active'

        $('<div class="img-wrap ' + stateClass + '">
            <div class="dimensions" title="' + dimensionsTxt + '">' + dimensionsTxt + '</div>
            <div class="name" title=" ' + nameExt + '">' + nameExt + '</div>
            <div class="icon-cancel"></div>
            </div>').append(img)
                    .data('unique-name', uniqueName)
                    .appendTo( $slidePanel )


    showLoading: () ->
        $('.loading').css('display', 'table');


    hideLoading: () ->
        $('.loading').hide();


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
        w = dimensions[0]
        h = dimensions[1]

        # if user didnt supply height, calculate a height
        #  that preserve aspect ratio
        if !h
            h = w * (img.naturalHeight / img.naturalWidth)

        canvas.width = w
        canvas.height = h

        ctx.drawImage(img, 0, 0, img.naturalWidth, img.naturalHeight, 0 ,
                      0, w, h)

        canvas


    canvasToArrayBuffer: (canvas, type, quality, cb) ->
        canvas.toBlob( (blob) ->
            fr = new FileReader()

            fr.onload = (e) ->
                cb( e.target.result  )

            fr.readAsArrayBuffer( blob );

          #quality - only for jpeg - ranges from 0.0 to 1.0
        , 'image/' + type, quality)


    zipArrayBuffers: (nameArrayBuffer, ext) ->
        zip = new JSZip();

        for name, arrayBuffer of nameArrayBuffer
            zip.file(name + '.' + ext, arrayBuffer, {binary: true});

        zip.generate({type:"blob"})


    saveBlob: (blob, name) ->
        saveAs(blob, name);
