pro master_shift,filein1,filein2,uvot1=uvot1,uvot2=uvot2,minlam=minlam,maxlam=maxlam,outfile=outfile,watch=watch,vgrism1=vgrism1,vgrism2=vgrism2

;PURPOSE
;This program calculates a chi squared minimized wavelength shift
;between 2 spectra.

;REQUIRED INPUTS
;filein1 = Filename of spectrum taken as fiducial wavelength scale.
;filein2 = Filename of spectrum to be shifted in wavelength.

;OPTIONAL INPUTS
;uvot1   = Set this flag if filein1 is uvotpy output .dat file made
;          from the .pha file.  If this keyword is not set the program 
;          assumes a 3 columnated spectra file (wavelength, flux, 
;          flux_error) (EX:/uvot1)
;uvot2   = Same as uvot1, but applicable to filein2.
;minlam  = Minimum lambda to be used in calculating chi^2 statistic.
;          If this is not set the program uses the entirety of filein1 
;          toward the blue in the calculation. 
;maxlam  = Maximum lambda to be used in calculating chi^2 statistic.
;          If this is not set the program uses the entirety of filein1
;          toward the red in the calculation.
;outfile = File to output  the filein2 spectrum to after applying best
;          fit shift
;watch   = /watch to show fitting and hold display of best match onscreen

;REQUIREMENTS
; sn/interpolate_function.pro for interpolating spectra 

;CALLING SEQUENCE
;master_shift,filein1,filein2, [,/uvot1] [,/uvot2] [,minlam=integer]
;[,maxlam=integer] [,outfile=string] [,/watch]

;METHOD
;This program shifts filein2 spectrum in 1A increments by -200A to
;+200A, then calculates the mutually overlapping regions of the
;spectrum, then interpolates the filein2 spectrum onto the filein1
;wavelength scale, then calculates the chi^2 statistic for the full
;range of shifts, then picks the shift value that yields the minimum
;chi^2, then plots the chi^2 vs shift and (filein1, filein2+shift),
;then if outfile is flagged outputs the final shifted filein2 spectrum.

;EXECUTE
;master_shift,'2011fe/rui/M001223.dat','uvot_spec/2011fe/UGRISM/final_spec/sw00032081006ugu_1ord_20110828_2s.dat'
;master_shift,'uvot_spec/2011fe/UGRISM/00032081006/uvot/image/sw00032081006ugu_1ord_2.dat','uvot_spec/2011fe/UGRISM/00032081006/uvot/image/sw00032081006ugu_1ord_1.dat',/uvot1,/uvot2,minlam=2750,maxlam=4750,outfile='uvot_spec/2011fe/UGRISM/00032081006/uvot/image/sw00032081006ugu_1ord_1s.dat'



;READ IN THE SPECTRA FILES
;upon Paul Kuin changing the uvotpy output format I rearranged the
;a6,a7 and a5 variable reading order to reflect the updated
;formatting. 04/04/2014.
if KEYWORD_SET(uvot1) then readcol,filein1,a1,a2,a3,a4,a6,a7,a5,a8,a9,a10,a11,a12,a13,a14,a15,a16,a17,a18,a19,a20,format='(d,d,d,d,d,d,d,d,d,d,d,d,d,d,d,d,d,d,d,d)',/silent $
else if KEYWORD_SET(vgrism1) then readcol,filein1,a1,a2,a3,a4,a6,a7,a5,a8,a9,a10,a11,a12,a13,format='(d,d,d,d,d,d,d,d,d,d,d,d,d)',/silent $
else readcol,filein1,a2,a6,a7,format='(d,d,d)',/silent ;for 3 column .dat format
;only use values that aren't 'NaN'
use=where(finite(a6) eq 1 )
a2=a2[use]
a6=a6[use]
a7=a7[use]

if KEYWORD_SET(uvot2) then readcol,filein2,b1,b2,b3,b4,b6,b7,b5,b8,b9,b10,b11,b12,b13,b14,b15,b16,b17,b18,b19,b20,format='(d,d,d,d,d,d,d,d,d,d,d,d,d,d,d,d,d,d,d,d)',/silent $
else if KEYWORD_SET(vgrism2) then readcol,filein2,b1,b2,b3,b4,b6,b7,b5,b8,b9,b10,b11,b12,b13,format='(d,d,d,d,d,d,d,d,d,d,d,d,d)',/silent $
else readcol,filein2,b2,b6,b7,format='(d,d,d)',/silent ;for 3 column .dat format
;only use values that aren't 'NaN'
use=where(finite(b6) eq 1)
b2=b2[use]
b6=b6[use]
b7=b7[use]
if KEYWORD_SET(uvot2) then begin
b1=b1[use]
b3=b3[use]
b4=b4[use]
b5=b5[use]
b8=b8[use]
b9=b9[use]
b10=b10[use]
b11=b11[use]
b12=b12[use]
b13=b13[use]
b14=b14[use]
b15=b15[use]
b16=b16[use]
b17=b17[use]
b18=b18[use]
b19=b19[use]
b20=b20[use]
endif

;plot,a2,a6
;oplot,b2,b6,color=255

;ITERATE SHIFTING THE 2ND SPECTRUM FILE
shift=dindgen(401)-200
chisqarr=dindgen(401)
for k=0,400 do begin
   b2shift=b2+shift[k];shift the 2nd spectrum by a value

   if KEYWORD_SET(minlam) eq 0 and KEYWORD_SET(maxlam) eq 0 then begin; if matching entire overlapping region
      minnlam=max([a2[0],b2shift[0]])
      maxxlam=min([a2[n_elements(a2)-1],b2shift[n_elements(b2)-1]])
   endif else begin
      minnlam=minlam
      maxxlam=maxlam
   endelse

   ;pick out the values that overlap after shifting
   gooda=where(a2 ge minnlam and a2 le maxxlam,ngooda)
   goodb=where(b2shift ge minnlam and b2shift le maxxlam,ngoodb)
   ;plot,a2[gooda],a6[gooda]
   ;oplot,b2shift[goodb],b6[goodb],color=255
   ;wait,0.01

   ;interpolate the 2nd spectrum to the 1st
   array=interpolate_function(a2[gooda],a6[gooda],b2shift[goodb],b6[goodb])
   goodb2shift=dblarr(n_elements(array)/2)
   goodb6=dblarr(n_elements(array)/2)
   for j=0,n_elements(array)/2-1 do goodb2shift[j]=array[0,j]
   for j=0,n_elements(array)/2-1 do goodb6[j]=array[1,j]
   if KEYWORD_SET(watch) then begin
      plot,a2[gooda],a6[gooda]
      oplot,goodb2shift,goodb6,color=255
      wait,0.001
   endif
   
   ;calculate chi^2 statistic
   chisqarr[k]=total( (goodb6-a6[gooda])^2)
  
endfor

!p.multi=[0,1,2]

;plot the chi squared statistics and the shift value producing the min chi^2
plot,shift,chisqarr,ytitle='chi squared',xtitle='lambda shift (Angstroms)',title=filein2
minchisqarr=min(chisqarr,location)
oplot,[shift[location],shift[location]],[1E-30,1E27]

;apply the best fit shift to the 2nd spectrum
b2=b2+shift[location]

plot,a2,a6
oplot,b2,b6,color=255
oplot,[minnlam,minnlam],[-1E30,1E30],linestyle=1
oplot,[maxxlam,maxxlam],[-1E30,1E30],linestyle=1
wait,0.001
!p.multi=0

entry=''
if KEYWORD_SET(watch) then read,entry,prompt='Check the shift. Press Enter to continue.'

if KEYWORD_SET(outfile) then begin
   openw,luo,outfile,/get_lun
   if KEYWORD_SET(uvot2) then for i=0,n_elements(b2)-1 do printf,luo,b1[i],b2[i],b3[i],b4[i],b6[i],b7[i],b5[i],b8[i],b9[i],b10[i],b11[i],b12[i],b13[i],b14[i],b15[i],b16[i],b17[i],b18[i],b19[i],b20[i],format='(e24.17,x,e24.17,x,e24.17,x,e24.17,x,e24.17,x,e24.17,x,e24.17,x,e24.17,x,e24.17,x,e24.17,x,e24.17,x,e24.17,x,e24.17,x,e24.17,x,e24.17,x,e24.17,x,e24.17,x,e24.17,x,e24.17,x,e24.17)' else $ 
      if KEYWORD_SET(vgrism2) then for i=0,n_elements(b2)-1 do printf,luo,b1[i],b2[i],b3[i],b4[i],b6[i],b7[i],b5[i],b8[i],b9[i],b10[i],b11[i],b12[i],b13[i],format='(e24.17,x,e24.17,x,e24.17,x,e24.17,x,e24.17,x,e24.17,x,e24.17,x,e24.17,x,e24.17,x,e24.17,x,e24.17,x,e24.17,x,e24.17)' else $ ;for vgrism formatted files
      for i=0,n_elements(b2)-1 do printf,luo,b2[i],b6[i],b7[i],format='(e24.17,x,e24.17,x,e24.17)' ;for standard .dat files
   close,luo
   free_lun,luo
endif

end
