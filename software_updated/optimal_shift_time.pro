pro optimal_shift_time,ext,skycounts,backfile,backfileoutput,datafile,x1,y1,x2,y2,override=override,coadd=coadd,ext2=ext2,outputsubtract=outputsubtract,force=force,factor=factor,backscale=backscale,addext=addext

;PURPOSE
;This program attempts to find a best suited offset between a SN data
;image and a galaxy template image with the same roll angle and small
;xy offset.  It shifts the galaxy template by the best shift and then
;calculates a best suited ratio of signal (diffracted spectra) in both
;images using relative exposure times.  Output is either: 1) a flux
;scaled galaxy template shifted onto the SN data image xy coordinate
;system, or 2) a coadded image of 2 galaxy templates (use coadd and
;ext2 flags for this).  This program should be called individually for
;each snapshot.
;template  

;INPUTS
;  ext            Extension number of the SN data image snapshot in
;                 the *dt.img file
;  skycounts      Rough estimate of the background counts in the SN data image.
;                 This value should be taken from an empty patch of sky 
;                 exposed to light (lower right quadrant of clocked image). 
;  backfile       File containing the galaxy template image. Must have
;                 same roll angle and approximately same RA & Dec as SN
;                 data image.  This image is possibly coadded.
;  backfileoutput Output file for final subtracted image.  This image
;                 has the same pixel coordinates as datafile.
;  datafile       SN data input image. This image will have backfile
;                 shifted in xy to overlay it as closely as possible and
;                 have a scaled version of backfile created to act as
;                 a template for it.  Optionally, you can have the
;                 template subtracted from this image as a sanity
;                 check (do not extract spectra from the subtracted
;                 image as it will not properly capture the
;                 coincidence loss of the detector!)  
;  x1, y1         X & Y coordinates of a source in the SN data image.
;                 This value is used to make a crude guess of the
;                 offset between the two images.
;  x2, y2         X & Y coordinates of a source in the galaxy template image.
;                 This value is used to make a crude guess of the
;                 offset between the two images.
;  override       Integer number of best matched xy offset shifts to
;                 throw out.  This number should be initially unset
;                 and if upon inspecting the output a bad shift is
;                 observed it should be incremented in units of 1
;                 until an ideal xy shift is observed. This is rarely needed.
;  force          Force the program to use the input offsets as the
;                 best suited offsets. This is rarely needed.
;  coadd          flag this if you are coadding template observations
;                 into a single master template observation.  In this
;                 case you must also use the ext2 keyword to signify
;                 the extension number of the second frame to be
;                 coadded onto the coordinates of ext.
;  ext2           See coadd.
;  outputsubtract Set this optional flag to a string. An output image of 
;                 datafile-backfileoutput will be created with the
;                 string as the filename.
;                 This is not a default because these images are big
;                 and will not be used in the uvotpy analysis.
; backscale       Scales the background template such that the median
;                 background count levels are the same in the data
;                 and template images. This scaling is applied
;                 following the exposure time scaling and is a crude
;                 way of correcting for the sensitivity loss of swift
;                 that occurred between the SN data observations and
;                 the template observations.  This is sometimes
;                 necessary when the templates are observed many years
;                 after the data observations.
; addext          It changed based on whether you are using a coadded 
;                 template image or a template image with just 1 extension.
;                 When coadding template images, it does not need addext, 
;                 but coadded image needs addext=0 and 1 ext template image 
;                 needs addext=1 when making the subtracted image.


;REQUIRED PACKAGES (available online)
;readfits, writefits (IDL astro library)
;shift.pro
;grid_tps.pro
;conmake.pro (contour surface plotting)
;resistant_mean.pro

;METHOD
;This program uses x1,y1,x2,y2 values to calculate a guess at the
;offset between the SN data image and the galaxy template.
;x1,y1,x2,y2 should be measured as the physical coordinates of a 0th
;order feature in ds9 in each image.  The accuracy must be within 10
;pixels.  The program then shifts the template image on a 20x20
;pixel grid in one pixel increments (-10 pix through +10 pix in x&y)
;and subtracts the template from the data image and
;calculates a standard deviation of pixel values. A surface plot
;showing the values of the standard deviation is produced and should
;show a dark blob as the minimum value.  The xy shift corresponding to
;minimum standard deviation is taken to be the best suited shift.
;Next a flux scaling factor between the two images is derived as the
;ratio of exposure times.  Two output options are available depending
;on the command line input: 1) if no flags are set the program assumes
;that you are shifting and flux scaling a template to match a
; data image.  In this case the template is x&y shifted to
;overlay the data image and flux scaled and outputted.  2) if the
;coadd flag is set(the ext2 keyword must be set as well.),  in this
;case the program assumes that you are attempting to coadd individual
;snapshots of swift templates into a single master
;template and will x&y shift backfile to overlay datafile, coadd the
;images, update the EXPOSURE keyword in the image header and output
;the image.

;CALLING SEQUENCE
;optimal_shift_time,ext,skycounts,backfile,backfileoutput,datafile,x1,y1,x2,y2
;[,override=integer] [,/force] [,coadd] [,ext2=integer]
;[,outputsubtract=string] [,/backscale]

;EXECUTE
;optimal_shift_time,2,50.,'uvot_spec/2011fe/UGRISM/00032101012/uvot/image/sw00032101012ugu_dt_coadded.fits','uvot_spec/2011fe/UGRISM/00032101004/uvot/image/sw00032101004ugu_dt_template_2.fits','uvot_spec/2011fe/UGRISM/00032101004/uvot/image/sw00032101004ugu_dt.fits',1282.,859.,1282.,815.,outputsubtract='uvot_spec/2011fe/UGRISM/00032101004/uvot/image/sw00032101004ugu_dt_subtracted_2.fits'

;SET SIGMA CLIPPING RANGES FOR CRUDELY ESTIMATING SKY BRIGHTNESS
sigmafactorlow=2
sigmafactorhigh=6

;CALCULATE AN INITIAL OFFSET GUESS FROM INPUTTED LOCATIONS
xguess=x1-x2
yguess=y1-y2
print,'xguess, yguess: ',xguess,yguess

;READ IN FITS FILES
if KEYWORD_SET(coadd) then backimage=readfits(backfile,headbackimage,exten_no=ext2) else if KEYWORD_SET(ext2) then backimage=readfits(backfile,headbackimage,exten_no=ext2) else backimage=readfits(backfile,headbackimage,exten_no=addext)
dataimage=readfits(datafile,headdataimage,exten_no=ext)
;backimageshift=shift(backimage, xguess, yguess)
;writefits,backfileoutput,backimageshift,headbackimage

;CALCULATE A FIRST GUESS FOR A SCALING FACTOR BTWN SCIENCE IMAGE
;AND BACKGROUND
;usebackimage=where(backimage gt skycounts*2 and backimage lt 2000,nusebackimage)
usedataimage=where(dataimage gt skycounts*2 and dataimage lt 2000,nusedataimage)
;ratio=median(backimage[usebackimage])/median(dataimage[usedataimage])
;print,ratio

;PICK EXPOSURE TIMES OUT OF THE IMAGE HEADERS
timeback=sxpar(headbackimage,'EXPOSURE',count=ntimeback)
timedata=sxpar(headdataimage,'EXPOSURE',count=ntimedata)

print,'exposure time background: ',timeback
print,'exposure time data:       ',timedata


;CALCULATE A FLUX SCALING RATIO BASED ON THE EXPOSURE TIMES INPUT
ratio=timeback/timedata
print,'ratio:                    ',ratio

;CREATE A GRID OF PIXEL SHIFTS (-10 TO +10 PIX) AND AT EACH LOCATION
;SUBTRACT THE CRUDELY SCALED BACKGROUND FROM THE DATA IMAGE. CALCULATE
;THE STANDARD DEVIATION OF THE RESULT.  ASSUME THAT THE LOWEST STDEV
;IS THE BEST SUITED SHIFT. 
i=0
j=0
bins=20
;;bins=80
xshiftarray=dblarr(bins*bins)
yshiftarray=dblarr(bins*bins)
resultsarray=dblarr(bins*bins)
k=0
while i lt bins do begin
   xshift = xguess -bins/2 + i
   ;;xshift = xguess -(bins/8) + (i * 0.25)
   ;print, xshift
   while j lt bins do begin
      yshift = yguess -bins/2 +j
      ;;yshift = yguess -(bins/8) + (j * 0.25)
      backimageshift=shift(backimage,xshift,yshift)
      backimageshiftscaled=backimageshift/ratio
      subtracted=dataimage - backimageshiftscaled
     
      if xshift eq xguess and yshift eq yguess then begin
         writefits,'goodmatch.fits',subtracted,headdataimage
         ;hist=histogram(subtracted[usedataimage],locations=xbin,binsize=5)
         ;moo=max(hist,mooid)
         ;print,'goodmatch hist max: ',moo,xbin[mooid]
         ;phisto=plot(xbin,hist,xrange=[-100,100],title='Goodmatch.fits')
         med1=stddev(subtracted[usedataimage])
         print,'goodmatch stddev: ',med1
      endif
      if i eq 0 and j eq 0 then begin 
         writefits,'badmatch.fits',subtracted,headdataimage
         ;hist=histogram(subtracted[usedataimage],locations=xbin,binsize=5)
         ;phisto=plot(xbin,hist,xrange=[-100,100],title='Badmatch.fits')
         ;moo=max(hist,mooid)
         ;print,'badmatch hist max: ',moo,xbin[mooid]
         med2=stddev(subtracted[usedataimage])
         print,'badmatch stddev: ',med2
      endif
      xshiftarray[k]=xshift
      yshiftarray[k]=yshift
      resultsarray[k]=stddev(subtracted[usedataimage])
      ;resultsarray[k]=robust_sigma(subtracted)
      ;resultsarray[k]=mean(subtracted)
      ;hist=histogram(subtracted[usedataimage],locations=xbin,binsize=5)
      ;moo=max(hist,mooid)
      ;resultsarray[k]=xbin[mooid]
      ;print,yshift
      j=j+1
      k=k+1
   endwhile
   i=i+1
   j=0
endwhile

;MAKE A SPLINE SURFACE DESCRIBING THE SHIFT GRID STDDEVS AND PLOT
surf=grid_tps(xshiftarray,yshiftarray,resultsarray,ngrid=[bins,bins])
;conmake,surf,256,/cbar

;SELECT THE SHIFT CORRESPONDING TO LOWEST STDDEV FOLLOWING SUBTRACTION 
dud=min(resultsarray,best)

OVERRIDE_LOOP:
if KEYWORD_SET(override) then begin
   if override gt 0 then begin
      remove,best,resultsarray
      remove,best,xshiftarray
      remove,best,yshiftarray
      print,'Throwing out the best xy shift match.'
      override=override-1
   endif
   goto,OVERRIDE_LOOP
endif

if KEYWORD_SET(force) then begin
   print,'Forcing the offset to be the difference of input coordinates without calculating!!!'
   xshiftarray[best]=xguess
   yshiftarray[best]=yguess
   resultsarray[best]=med1
endif

;oplot,[xshiftarray[dud],yshiftarray[dud]],psym=2,color=255,psize=5
print,'Best xshift, yshift, stddev: ',xshiftarray[best],yshiftarray[best],resultsarray[best]
;xyshiftarray=dblarr(2,bins*bins)
;for i=0,bins*bins-1 do xyshiftarray[i]=[xshiftarray[i],yshiftarray[i]]
;for i=0,bins*bins-1 do print,xyshiftarray[i]

;xyshiftarray=[xshiftarray,yshiftarray]
;xyyshiftarray=reform(xyshiftarray,2,bins*bins)
;for i=0,bins-1 do print,xyyshiftarray[i]

;shade_surf,surf,charsize=2,ax=75
;print,surf
if KEYWORD_SET(coadd) then begin
   backimageshift=shift(backimage,xshiftarray[best],yshiftarray[best])
   coaddedimage=dataimage + backimageshift
   sxaddpar,headdataimage,'EXPOSURE',timedata+timeback
   writefits,backfileoutput,coaddedimage,headdataimage
endif else begin
;apply the best shift and time-based estimate of scaling ratio and
;export image 
   backimageshift=shift(backimage,xshiftarray[best],yshiftarray[best])
   if KEYWORD_SET(factor) then    backimageshiftscaled=backimageshift/ratio *factor $
   else backimageshiftscaled=backimageshift/ratio
   sxaddpar,headbackimage,'EXPOSURE',timeback/ratio
   writefits,backfileoutput,backimageshiftscaled,headbackimage

   if KEYWORD_SET(outputsubtract) then begin
      writefits,outputsubtract,dataimage-backimageshiftscaled,headdataimage
      print,'Outputting a subtracted image. NOT TO BE USED IN uvotpy!!!'
   endif
endelse
;subtracted=dataimage - (backimageshift*ratio)
;writefits,backfileoutput,subtracted,headdataimage

;hist=histogram(subtracted[usedataimage],locations=xbin,binsize=5)
;moo=max(hist,mooid)
;print,'Iterative match max: ',moo,xbin[mooid]
;phisto=plot(xbin,hist,xrange=[-100,100],title='iterative match')
;THIS PROGRAM HAS GIVEN AN ESTIMATE OF THE X&Y SHIFTS GIVING THE BEST
;OVERLAPS.  WHEN YOU CONTINUE TRY PLOTTING THE SUBTRACTED GRISM IMAGES
;TO TEST THE QUALITY OF THE FEATURE REMOVAL.  
  ;may have to tweak the method of finding the ratio to divide by
  ;may have to tweak the method of finding the best x&y shifts.


;if backscale is flagged scale the template image such that the
;background counts are the same
if KEYWORD_SET(backscale) then begin
   data=dataimage[870:1200,770:1060]
   back=backimageshiftscaled[870:1200,770:1060]
   data2=median(dataimage[870:1200,770:1060])
   back2=median(backimageshiftscaled[870:1200,770:1060])
   ;resistant_mean,dataimage[870:1200,770:1060],3,data2
   ;resistant_mean,backimageshiftscaled[870:1200,770:1060],3,back2
   ;data2=mode(dataimage[870:1200,770:1060],0.01)
   ;back2=mode(backimageshiftscaled[870:1200,770:1060],0.01)
   scalingfactor=data2/back2
   print,'data, back, back_scaling_factor:  ',data2,back2,scalingfactor
   plot,Histogram(data)
   oplot,Histogram(back),color=255
   oplot,[data2,data2],[0,1E8]
   oplot,[back2,back2],[0,1E8]
   writefits,backfileoutput,backimageshiftscaled*scalingfactor,headbackimage
   ;writefits,backscale,back,backhead
   ;writefits,'uvot_spec/2011by/UGRISM/00031977006/uvot/image/test2.fits',data,headdataimage
endif



;SKIP THE MORE COMPLICATED FLUX SCALING ROUTINE BELOW
goto,HERE

;FIND A BETTER SCALING FACTOR USING THE SHIFTED IMAGE
;print,size(dataimage)
xmin=findgen(17)*100+200 ;define the lowest value of bins 100 pix wide 
ymin=findgen(17)*100+200 ;define the lowest value of bins 100 pix tall
ratioarray=dblarr(n_elements(xmin)*n_elements(ymin)) ;define array to hold the final ratio of SN_image_signal/Galaxy_image_signal
k=0 ;count for xmin array
l=0 ;count for ymin array
m=0 ;count for 
temparraydata=dblarr(10000)
temparrayback=dblarr(10000)
xarray=dblarr(10000)
yarray=dblarr(10000)
while k lt n_elements(xmin) do begin
   l=0
   while l lt n_elements(ymin) do begin
      n=0
      for i=0,99 do begin
         for j=0,99 do begin
            temparraydata[n]=dataimage[xmin[k]+i,ymin[l]+j]
            temparrayback[n]=backimageshift[xmin[k]+i,ymin[l]+j]
            xarray[n]=xmin[k]+i
            yarray[n]=ymin[l]+j
            n=n+1
         endfor
      endfor
      ;if k eq 0 and l eq 0 then begin
         ;print,median(temparraydata)
         ;print,median(temparrayback)
      ;endif
      ;print,xmin[k],ymin[l],i,j,n

      ;ratioarray[m]=median(temparraydata)/median(temparrayback)
      gooddata=where(temparraydata gt median(temparraydata)+stddev(temparraydata)*sigmafactorlow and temparraydata lt median(temparraydata)+stddev(temparraydata)*sigmafactorhigh,nsignaltemparraydata); contains values of SN data pixels with signal x times greater than the local background
      goodback=where(temparrayback gt median(temparrayback)+stddev(temparrayback)*sigmafactorlow and temparrayback lt median(temparrayback)+stddev(temparrayback)*sigmafactorhigh,nsignaltemparrayback);contains values of galaxy template image with signal x times greater than the local background
      signaltemparraydata=temparraydata[gooddata]
      signaltemparrayback=temparrayback[goodback]
      ratioarray[m]=median(signaltemparraydata)/median(signaltemparrayback)
      if k eq 0 and l eq 0 then begin ;make arrays of all pixels identified as signal.
         signalxarraydata=xarray[gooddata]
         signalyarraydata=yarray[gooddata]
         signalxarrayback=xarray[goodback]
         signalyarrayback=yarray[goodback]
      endif else begin
         signalxarraydata=[signalxarraydata,xarray[gooddata]]
         signalyarraydata=[signalyarraydata,yarray[gooddata]]
         signalxarrayback=[signalxarrayback,xarray[goodback]]
         signalyarrayback=[signalyarrayback,yarray[goodback]]
      endelse
                                ;BEGIN WORK HERE. THE RATIOARRAY ABOVE
                                ;IS NOT THE FINAL ARRAY TO RETURN. TAKE
                                ;STANDARD DEVIATIONS AND THEN PICK OUT
                                ;SOURCES AS SIGMA OUTLIERS ABOVE THE
                                ;LOCAL NOISE. RECORD THE RATIO OF SOURCES.

      m=m+1
      l=l+1
   endwhile
   k=k+1
   ;print,k
endwhile

;print,ratioarray
a=dindgen(n_elements(ratioarray))
plot,a,ratioarray,psym=2,xtitle='N (iteration)',ytitle='Signal_SN_image/Signal_galaxy_image',charsize=2
resistant_mean,ratioarray,3.0,best_ratio
oplot,[0,n_elements(ratioarray)+100],[best_ratio,best_ratio],color=500
print,'Best ratio of Signal_SN/Signal_galaxy: ', best_ratio

;MAKE REGIONS FILE FOR OPLOTTING THE SIGNAL PIXELS CHOSEN 
openw,luo,'data_signal.reg',/get_lun
for z=0,n_elements(signalxarraydata)-1 do printf,luo,'circle ',signalxarraydata[z],signalyarraydata[z],' 1',format='(a,i,i,a)'
close,luo
free_lun,luo
openw,lua,'back_signal.reg',/get_lun
for z=0,n_elements(signalxarrayback)-1 do printf,luo,'circle ',signalxarrayback[z],signalyarrayback[z],' 1',format='(a,i,i,a)'
close,luo
free_lun,luo
print,'The files in the working directory data_signal.red and back_signal.reg'
print,'are regions files mean to be overplotted upon the data and background'
print,'input images to display the regions selected as signal.'


;apply the best shift and improved estimate of scaling ratio and export
;image 
print,'Writing output file: ',backfileoutput
backimageshift=shift(backimage,xshiftarray[best],yshiftarray[best])
subtracted=dataimage - (backimageshift*best_ratio)
writefits,backfileoutput,subtracted,headdataimage
HERE:

end
