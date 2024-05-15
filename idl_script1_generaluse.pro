pro idl_script1_generaluse, tobsid, oobsid, te, oe1, oe2, oe3, xcoor_oe1, ycoor_oe1, xcoor_oe2, ycoor_oe2, xcoor_oe3, ycoor_oe3, xcoor_te1, ycoor_te1, xcoor_te2, ycoor_te2, oback, tback

; CONVERT ARGUMENT INTO STRING
tobsid_string = strtrim(tobsid,2)
; ADDING ZEROS
tobsid_zeros = ["000",tobsid_string]
templateobsid = tobsid_zeros.Join()
; DEFINE THE VARIABLE AS A STRING BEFORE READING IT IN
;templateobsid = ''
;READ THE INPUT IN FROM THE TERMINAL
;read, templateobsid, prompt='Type in the obsid for the template image'
; CHECKING TEMPLATE ID IS CORRECT
print, 'Template target ID  = ', templateobsid

; CONVERT ARGUMENT INTO STRING
oobsid_string = strtrim(oobsid,2)
; ADDING ZEROS
oobsid_zeros = ["000",oobsid_string]
observationobsid = oobsid_zeros.Join()
; DEFINE THE VARIABLE AS A STRING BEFORE READING IT IN
;observationobsid = ''
;READ THE INPUT IN FROM THE TERMINAL
;read, observationobsid, prompt='Type in the obsid for the original observed image'
; CHECKING OBSERVATION ID IS CORRECT
print, 'Original observation target ID = ', observationobsid





; ONLY ONE EXTENSION
if te eq 2 then begin

    ;COADD THE 2 TEMPLATE SNAPSHOTS INTO A SINGLE, HIGHER SIGNAL-TO-NOISE
    ;TEMPLATE
    ;set up the pathway for optimal_shift_time
    ost_pat1 = [templateobsid,"/uvot/image/sw",templateobsid,"ugu_dt.img"]
    ost_path1 = ost_pat1.Join()
    ost_pat2 = [templateobsid,"/uvot/image/sw",templateobsid,"ugu_dt_coadd.fits"]
    ost_path2 = ost_pat2.Join()
    optimal_shift_time,1,tback,ost_path1,ost_path2,ost_path1,xcoor_te1,ycoor_te1,xcoor_te2,ycoor_te2,/coadd,ext2=2
    ;optimal_shift_time,1,50,'00032094018/uvot/image/sw00032094018ugu_dt.img','00032094018/uvot/image/sw00032094018ugu_dt_coadd.fits','00032094018/uvot/image/sw00032094018ugu_dt.img',1080.,934.,1074.,925.,/coadd,ext2=2
    ;optimal_shift_time,(operate on 1st image extension=1),(sky background
    ;estimate=50),(filename of template image),(output image),(filename
    ;of template image again),(x position of zeroth order feature in 1st
    ;image extension),(y position of zeroth order feature in 1st image extension),(x position of zeroth order feature in 2nd
    ;image extension),(y position of zeroth order feature in 2nd image
    ;extension),(/coadd flag indicates that you wish to coadd image
    ;extensions 1 and 2),(ext2=2 indicates that you wish to coadd the 2nd
    ;image extension onto the first image extension)

    ;TRANSLATE THE TEMPLATE IMAGE TO OVERLAY THE DATA IMAGE AND FLUX SCALE
    ost_pat3 = [observationobsid,"/uvot/image/sw",observationobsid,"ugu_dt.img"]
    ost_path3 = ost_pat3.Join()
    ost_pat4 = [observationobsid,"/uvot/image/sw",observationobsid,"ugu_dt_template_1.fits"]
    ost_path4 = ost_pat4.Join()
    ost_pat5 = [observationobsid,"/uvot/image/sw",observationobsid,"ugu_dt_template_2.fits"]
    ost_path5 = ost_pat5.Join()
    ost_pat6 = [observationobsid,"/uvot/image/sw",observationobsid,"ugu_dt_template_3.fits"]
    ost_path6 = ost_pat6.Join()
    ost_pat7 = [observationobsid,"/uvot/image/sw",observationobsid,"ugu_dt_subtracted_1.fits"]
    ost_path7 = ost_pat7.Join()
    ost_pat8 = [observationobsid,"/uvot/image/sw",observationobsid,"ugu_dt_subtracted_2.fits"]
    ost_path8 = ost_pat8.Join()
    ost_pat9 = [observationobsid,"/uvot/image/sw",observationobsid,"ugu_dt_subtracted_3.fits"]
    ost_path9 = ost_pat9.Join()
    optimal_shift_time,oe1,oback,ost_path2,ost_path4,ost_path3,xcoor_oe1,ycoor_oe1,xcoor_te1,ycoor_te1,outputsubtract=ost_path7,addext=0
    if oe2 ne 0 then begin
        optimal_shift_time,oe2,oback,ost_path2,ost_path5,ost_path3,xcoor_oe2,ycoor_oe2,xcoor_te1,ycoor_te1,outputsubtract=ost_path8,addext=0
    endif
    if oe3 ne 0 then begin
        optimal_shift_time,oe3,oback,ost_path2,ost_path6,ost_path3,xcoor_oe3,ycoor_oe3,xcoor_te1,ycoor_te1,outputsubtract=ost_path9,addext=0
    endif
    ;optimal_shift_time,1,40.,'00032094018/uvot/image/sw00032094018ugu_dt_coadd.fits','00032094004/uvot/image/sw00032094004ugu_dt_template_1.fits','00032094004/uvot/image/sw00032094004ugu_dt.img',1102.,879.,1080.,934.,outputsubtract='00032094004/uvot/image/sw00032094004ugu_dt_subtracted_1.fits'
    ;optimal_shift_time,2,40.,'00032094018/uvot/image/sw00032094018ugu_dt_coadd.fits','00032094004/uvot/image/sw00032094004ugu_dt_template_2.fits','00032094004/uvot/image/sw00032094004ugu_dt.img',1090.,891.,1080.,934.,outputsubtract='00032094004/uvot/image/sw00032094004ugu_dt_subtracted_2.fits'
    ;optimal_shift_time,3,40.,'00032094018/uvot/image/sw00032094018ugu_dt_coadd.fits','00032094004/uvot/image/sw00032094004ugu_dt_template_3.fits','00032094004/uvot/image/sw00032094004ugu_dt.img',1094.,919.,1080.,934.,outputsubtract='00032094004/uvot/image/sw00032094004ugu_dt_subtracted_3.fits'
    ;optimal_shift_time,(operate on the third image extension),(sky
    ;background estimate=40),(template image),(output image),(data
    ;image),(x position of zeroth order feature in data image),(y position
    ;of zeroth order feature in data image),(x position of zeroth order
    ;feature in template image),(y position of zeroth order feature in
    ;template image),(output a residual image of data image minus template 
    ;image),(makes sure it is looking for the right extension in the template image)

endif else begin

    ;set up the pathway for optimal_shift_time
    ost_pat1 = [templateobsid,"/uvot/image/sw",templateobsid,"ugu_dt.img"]
    ost_path1 = ost_pat1.Join()

    ;TRANSLATE THE TEMPLATE IMAGE TO OVERLAY THE DATA IMAGE AND FLUX SCALE
    ost_pat3 = [observationobsid,"/uvot/image/sw",observationobsid,"ugu_dt.img"]
    ost_path3 = ost_pat3.Join()
    ost_pat4 = [observationobsid,"/uvot/image/sw",observationobsid,"ugu_dt_template_1.fits"]
    ost_path4 = ost_pat4.Join()
    ost_pat5 = [observationobsid,"/uvot/image/sw",observationobsid,"ugu_dt_template_2.fits"]
    ost_path5 = ost_pat5.Join()
    ost_pat6 = [observationobsid,"/uvot/image/sw",observationobsid,"ugu_dt_template_3.fits"]
    ost_path6 = ost_pat6.Join()
    ost_pat7 = [observationobsid,"/uvot/image/sw",observationobsid,"ugu_dt_subtracted_1.fits"]
    ost_path7 = ost_pat7.Join()
    ost_pat8 = [observationobsid,"/uvot/image/sw",observationobsid,"ugu_dt_subtracted_2.fits"]
    ost_path8 = ost_pat8.Join()
    ost_pat9 = [observationobsid,"/uvot/image/sw",observationobsid,"ugu_dt_subtracted_3.fits"]
    ost_path9 = ost_pat9.Join()
    optimal_shift_time,oe1,oback,ost_path1,ost_path4,ost_path3,xcoor_oe1,ycoor_oe1,xcoor_te1,ycoor_te1,outputsubtract=ost_path7,addext=1
    if oe2 ne 0 then begin
        optimal_shift_time,oe2,oback,ost_path1,ost_path5,ost_path3,xcoor_oe2,ycoor_oe2,xcoor_te1,ycoor_te1,outputsubtract=ost_path8,addext=1
    endif
    if oe3 ne 0 then begin
        optimal_shift_time,oe3,oback,ost_path1,ost_path6,ost_path3,xcoor_oe3,ycoor_oe3,xcoor_te1,ycoor_te1,outputsubtract=ost_path9,addext=1
    endif
    ;optimal_shift_time,1,40.,'00032094018/uvot/image/sw00032094018ugu_dt_coadd.fits','00032094004/uvot/image/sw00032094004ugu_dt_template_1.fits','00032094004/uvot/image/sw00032094004ugu_dt.img',1102.,879.,1080.,934.,outputsubtract='00032094004/uvot/image/sw00032094004ugu_dt_subtracted_1.fits'
    ;optimal_shift_time,2,40.,'00032094018/uvot/image/sw00032094018ugu_dt_coadd.fits','00032094004/uvot/image/sw00032094004ugu_dt_template_2.fits','00032094004/uvot/image/sw00032094004ugu_dt.img',1090.,891.,1080.,934.,outputsubtract='00032094004/uvot/image/sw00032094004ugu_dt_subtracted_2.fits'
    ;optimal_shift_time,3,40.,'00032094018/uvot/image/sw00032094018ugu_dt_coadd.fits','00032094004/uvot/image/sw00032094004ugu_dt_template_3.fits','00032094004/uvot/image/sw00032094004ugu_dt.img',1094.,919.,1080.,934.,outputsubtract='00032094004/uvot/image/sw00032094004ugu_dt_subtracted_3.fits'
    ;optimal_shift_time,(operate on the third image extension),(sky
    ;background estimate=40),(template image),(output image),(data
    ;image),(x position of zeroth order feature in data image),(y position
    ;of zeroth order feature in data image),(x position of zeroth order
    ;feature in template image),(y position of zeroth order feature in
    ;template image),(output a residual image of data image minus template 
    ;image),(makes sure it is looking for the right extension in the template image)

endelse


end
