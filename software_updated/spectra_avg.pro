pro spectra_avg,f1,f2,f3=f3,f4=f4,f5=f5,f6=f6,f7=f7,f8=f8,f9=f9,f10=f10,f11=f11,f12=f12,f13=f13,f14=f14,f15=f15,f16=f16,f17=f17,f18=f18,f19=f19,f20=f20,output=output,m1min=m1min,m1max=m1max,m2min=m2min,m2max=m2max,m3min=m3min,m3max=m3max,m4min=m4min,m4max=m4max,m5min=m5min,m5max=m5max,m6min=m6min,m6max=m6max,m7min=m7min,m7max=m7max,m8min=m8min,m8max=m8max,m9min=m9min,m9max=m9max,m10min=m10min,m10max=m10max,m11min=m11min,m11max=m11max,m12min=m12min,m12max=m12max,m13min=m13min,m13max=m13max,m14min=m14min,m14max=m14max,m15min=m15min,m15max=m15max,m16min=m16min,m16max=m16max,m17min=m17min,m17max=m17max,m18min=m18min,m18max=m18max,m19min=m19min,m19max=m19max,m20min=m20min,m20max=m20max,columns=columns

;PURPOSE
;This program calculates the variance weighted average of up to 20
;spectra.  It implements the variance weighting of Bevington, p.57.
;At least 2 spectra are required as input.
;This program can handle up to 20 spectra.
;This program dynamically adapts to the number of spectra entered.
;This program assumes that the inputted spectra have been wavelength
;calibrated (likely using master_shift.pro).

;
;REQUIRED INPUT 
;       f1 and f2     = Filenames of columnated spectra to be coadded.
;                       The wavelength grid of f1 is used as the reference.

;OPTIONAL INPUT
;       f3-f20        = Filenames of columnated spectra to be coadded
;                       along with the required f1 and f2.
;       f1min & f1max = Flags for wavelength values to be ignored for
;                       the corresponding spectrum.  The program
;                       assigns a ridiculously high error to spectrum 
;                       points within these bounds for the specified
;                       spectra.  These values must be obtained by
;                       inspecting the spectra by eye or id'ing
;                       bad regions using another method.  This is
;                       useful when individual snapshots have
;                       localized contamination.
;       columns       = Flag to tell the program that the input data
;                       is a 3 column spectrum file (wavelength, flux, 
;                       flux_error).  If this is not set the input
;                       file is assumed to be that of columnated
;                       uvotpy output (pixel_number, wavelength,
;                       count_rate, bgl1, bgr1, flux, flux_error).
;

;OUTPUT
;       output        = set flag equal to a string containing desired
;                       filename of output
;
;NOTES
;       This program cannot handle more than 20 spectra at once.
;       Errors are necessary, otherwise you can't sigma weight.
;       Errors cannot be made up, otherwise the calculation is meaningless.
;       This program interpolates spectra f2-f20 onto the lambda scale
;       of f1. It doesn't do anything more fancy to avoid odd behavior
;       on the edges where there may not be overlap of multiple spectra.

;REQUIRED PACKAGES
;sum.pro (available online)
;total.pro (replacing sum.pro with total)
;interpolate_function_errors.pro

;CALLING SEQUENCE
;spectra_avg,f1,f2, [,f3-f20] [,m1min=integer] [,m1max=integer] [,/columns] 

i=2 ;because at least 2 spectra are required as input

;READ IN THE SPECTRA FILES (.dat converted from .pha)
;04/04/2014 Paul Kuin changed the output format of uvotpy spectra.
;The line directly below this note is the old format.  The line 2
;below this note is the new format.
;readcol,f1,pixno1,lambda1,netrate1,bgl1,bgr1,flux1,fluxerr1,format=('d,d,d,d,d,d,d'),/silent
if KEYWORD_SET(columns) then readcol,f1,lambda1,flux1,fluxerr1,format=('d,d,d'),/silent else $
readcol,f1,pixno1,lambda1,netrate1,bgl1,flux1,fluxerr1,format=('d,d,d,d,d,d'),/silent
good1=where(flux1 ge -1E30 and flux1 le 1E30) ;filter out all of the NaN values
lambda1=lambda1[good1] ;redefine arrays without NaN values
flux1=flux1[good1]
fluxerr1=fluxerr1[good1]
if (KEYWORD_SET(m1min) and KEYWORD_SET(m1max)) then begin ;give bad portions of the spectra
   if m1min eq 'min' then m1min=float(min(lambda1))              ;ridiculously large errors so they
   if m1max eq 'max' then m1max=float(max(lambda1))              ;don't get used in calculating
   bad1=where(lambda1 ge m1min and lambda1 le m1max)      ;the final value
   fluxerr1[bad1]=fluxerr1[bad1]+1E15
endif

if KEYWORD_SET(columns) then readcol,f2,lambda2,flux2,fluxerr2,format=('d,d,d'),/silent else $
readcol,f2,pixno2,lambda2,netrate2,bgl2,flux2,fluxerr2,format=('d,d,d,d,d,d'),/silent
good2=where(flux2 ge -1E30 and flux2 le 1E30)
lambda2=lambda2[good2]
flux2=flux2[good2]
fluxerr2=fluxerr2[good2]
if (KEYWORD_SET(m2min) and KEYWORD_SET(m2max)) then begin 
   if m2min eq 'min' then m2min=float(min(lambda2))
   if m2max eq 'max' then m2max=float(max(lambda2))
   bad2=where(lambda2 ge m2min and lambda2 le m2max)
   fluxerr2[bad2]=fluxerr2[bad2]+1E15
endif

if KEYWORD_SET(f3) then begin
   i++
   if KEYWORD_SET(columns) then readcol,f3,lambda3,flux3,fluxerr3,format=('d,d,d'),/silent else $
   readcol,f3,pixno3,lambda3,netrate3,bgl3,flux3,fluxerr3,format=('d,d,d,d,d,d'),/silent
   good3=where(flux3 ge -1E30 and flux3 le 1E30)
   lambda3=lambda3[good3]
   flux3=flux3[good3]
   fluxerr3=fluxerr3[good3]
   if (KEYWORD_SET(m3min) and KEYWORD_SET(m3max)) then begin 
      if m3min eq 'min' then m3min=float(min(lambda3))
      if m3max eq 'max' then m3max=float(max(lambda3))
      bad3=where(lambda3 ge m3min and lambda3 le m3max)
      fluxerr3[bad3]=fluxerr3[bad3]+1E15
   endif
endif
if KEYWORD_SET(f4) then begin
   i++
   if KEYWORD_SET(columns) then readcol,f4,lambda4,flux4,fluxerr4,format=('d,d,d'),/silent else $
   readcol,f4,pixno4,lambda4,netrate4,bgl4,flux4,fluxerr4,format=('d,d,d,d,d,d'),/silent
   good4=where(flux4 ge -1E30 and flux4 le 1E30)
   lambda4=lambda4[good4]
   flux4=flux4[good4]
   fluxerr4=fluxerr4[good4]
   if (KEYWORD_SET(m4min) and KEYWORD_SET(m4max)) then begin 
      if m4min eq 'min' then m4min=float(min(lambda4))
      if m4max eq 'max' then m4max=float(max(lambda4))
      bad4=where(lambda4 ge m4min and lambda4 le m4max)
      fluxerr4[bad4]=fluxerr4[bad4]+1E15
   endif
endif
if KEYWORD_SET(f5) then begin
   i++
   if KEYWORD_SET(columns) then readcol,f5,lambda5,flux5,fluxerr5,format=('d,d,d'),/silent else $
   readcol,f5,pixno5,lambda5,netrate5,bgl5,flux5,fluxerr5,format=('d,d,d,d,d,d'),/silent
   good5=where(flux5 ge -1E30 and flux5 le 1E30)
   lambda5=lambda5[good5]
   flux5=flux5[good5]
   fluxerr5=fluxerr5[good5]
   if (KEYWORD_SET(m5min) and KEYWORD_SET(m5max)) then begin 
      if m5min eq 'min' then m5min=float(min(lambda5))
      if m5max eq 'max' then m5max=float(max(lambda5))
      bad5=where(lambda5 ge m5min and lambda5 le m5max)
      fluxerr5[bad5]=fluxerr5[bad5]+1E15
   endif
endif
if KEYWORD_SET(f6) then begin
   i++
   if KEYWORD_SET(columns) then readcol,f6,lambda6,flux6,fluxerr6,format=('d,d,d'),/silent else $
   readcol,f6,pixno6,lambda6,netrate6,bgl6,flux6,fluxerr6,format=('d,d,d,d,d,d'),/silent
   good6=where(flux6 ge -1E30 and flux6 le 1E30)
   lambda6=lambda6[good6]
   flux6=flux6[good6]
   fluxerr6=fluxerr6[good6]
   if (KEYWORD_SET(m6min) and KEYWORD_SET(m6max)) then begin 
      if m6min eq 'min' then m6min=float(min(lambda6))
      if m6max eq 'max' then m6max=float(max(lambda6))
      bad6=where(lambda6 ge m6min and lambda6 le m6max)
      fluxerr6[bad6]=fluxerr6[bad6]+1E15
   endif
endif
if KEYWORD_SET(f7) then begin
   i++
   if KEYWORD_SET(columns) then readcol,f7,lambda7,flux7,fluxerr7,format=('d,d,d'),/silent else $
   readcol,f7,pixno7,lambda7,netrate7,bgl7,flux7,fluxerr7,format=('d,d,d,d,d,d'),/silent
   good7=where(flux7 ge -1E30 and flux7 le 1E30)
   lambda7=lambda7[good7]
   flux7=flux7[good7]
   fluxerr7=fluxerr7[good7]
   if (KEYWORD_SET(m7min) and KEYWORD_SET(m7max)) then begin 
      if m7min eq 'min' then m7min=float(min(lambda7))
      if m7max eq 'max' then m7max=float(max(lambda7))
      bad7=where(lambda7 ge m7min and lambda7 le m7max)
      fluxerr7[bad7]=fluxerr7[bad7]+1E15
   endif
endif
if KEYWORD_SET(f8) then begin
   i++
   if KEYWORD_SET(columns) then readcol,f8,lambda8,flux8,fluxerr8,format=('d,d,d'),/silent else $
   readcol,f8,pixno8,lambda8,netrate8,bgl8,flux8,fluxerr8,format=('d,d,d,d,d,d'),/silent
   good8=where(flux8 ge -1E30 and flux8 le 1E30)
   lambda8=lambda8[good8]
   flux8=flux8[good8]
   fluxerr8=fluxerr8[good8]
   if (KEYWORD_SET(m8min) and KEYWORD_SET(m8max)) then begin 
      if m8min eq 'min' then m8min=float(min(lambda8))
      if m8max eq 'max' then m8max=float(max(lambda8))
      bad8=where(lambda8 ge m8min and lambda8 le m8max)
      fluxerr8[bad8]=fluxerr8[bad8]+1E15
   endif
endif
if KEYWORD_SET(f9) then begin
   i++
   if KEYWORD_SET(columns) then readcol,f9,lambda9,flux9,fluxerr9,format=('d,d,d'),/silent else $
   readcol,f9,pixno9,lambda9,netrate9,bgl9,flux9,fluxerr9,format=('d,d,d,d,d,d'),/silent
   good9=where(flux9 ge -1E30 and flux9 le 1E30)
   lambda9=lambda9[good9]
   flux9=flux9[good9]
   fluxerr9=fluxerr9[good9]
   if (KEYWORD_SET(m9min) and KEYWORD_SET(m9max)) then begin 
      if m9min eq 'min' then m9min=float(min(lambda9))
      if m9max eq 'max' then m9max=float(max(lambda9))
      bad9=where(lambda9 ge m9min and lambda9 le m9max)
      fluxerr9[bad9]=fluxerr9[bad9]+1E15
   endif
endif
if KEYWORD_SET(f10) then begin
   i++
   if KEYWORD_SET(columns) then readcol,f10,lambda10,flux10,fluxerr10,format=('d,d,d'),/silent else $
   readcol,f10,pixno10,lambda10,netrate10,bgl10,flux10,fluxerr10,format=('d,d,d,d,d,d'),/silent
   good10=where(flux10 ge -1E30 and flux10 le 1E30)
   lambda10=lambda10[good10]
   flux10=flux10[good10]
   fluxerr10=fluxerr10[good10]
   if (KEYWORD_SET(m10min) and KEYWORD_SET(m10max)) then begin 
      if m10min eq 'min' then m10min=float(min(lambda10))
      if m10max eq 'max' then m10max=float(max(lambda10))
      bad10=where(lambda10 ge m10min and lambda10 le m10max)
      fluxerr10[bad10]=fluxerr10[bad10]+1E15
   endif
endif
if KEYWORD_SET(f11) then begin
   i++
   if KEYWORD_SET(columns) then readcol,f11,lambda11,flux11,fluxerr11,format=('d,d,d'),/silent else $
   readcol,f11,pixno11,lambda11,netrate11,bgl11,flux11,fluxerr11,format=('d,d,d,d,d,d'),/silent
   good11=where(flux11 ge -1E30 and flux11 le 1E30)
   lambda11=lambda11[good11]
   flux11=flux11[good11]
   fluxerr11=fluxerr11[good11]
   if (KEYWORD_SET(m11min) and KEYWORD_SET(m11max)) then begin 
      if m11min eq 'min' then m11min=float(min(lambda11))
      if m11max eq 'max' then m11max=float(max(lambda11))
      bad11=where(lambda11 ge m11min and lambda11 le m11max)
      fluxerr11[bad11]=fluxerr11[bad11]+1E15
   endif
endif
if KEYWORD_SET(f12) then begin
   i++
   if KEYWORD_SET(columns) then readcol,f12,lambda12,flux12,fluxerr12,format=('d,d,d'),/silent else $
   readcol,f12,pixno12,lambda12,netrate12,bgl12,flux12,fluxerr12,format=('d,d,d,d,d,d'),/silent
   good12=where(flux12 ge -1E30 and flux12 le 1E30)
   lambda12=lambda12[good12]
   flux12=flux12[good12]
   fluxerr12=fluxerr12[good12]
   if (KEYWORD_SET(m12min) and KEYWORD_SET(m12max)) then begin 
      if m12min eq 'min' then m12min=float(min(lambda12))
      if m12max eq 'max' then m12max=float(max(lambda12))
      bad12=where(lambda12 ge m12min and lambda12 le m12max)
      fluxerr12[bad12]=fluxerr12[bad12]+1E15
   endif
endif
if KEYWORD_SET(f13) then begin
   i++
   if KEYWORD_SET(columns) then readcol,f13,lambda13,flux13,fluxerr13,format=('d,d,d'),/silent else $
   readcol,f13,pixno13,lambda13,netrate13,bgl13,flux13,fluxerr13,format=('d,d,d,d,d,d'),/silent
   good13=where(flux13 ge -1E30 and flux13 le 1E30)
   lambda13=lambda13[good13]
   flux13=flux13[good13]
   fluxerr13=fluxerr13[good13]
   if (KEYWORD_SET(m13min) and KEYWORD_SET(m13max)) then begin 
      if m13min eq 'min' then m13min=float(min(lambda13))
      if m13max eq 'max' then m13max=float(max(lambda13))
      bad13=where(lambda13 ge m13min and lambda13 le m13max)
      fluxerr13[bad13]=fluxerr13[bad13]+1E15
   endif
endif
if KEYWORD_SET(f14) then begin
   i++
   if KEYWORD_SET(columns) then readcol,f14,lambda14,flux14,fluxerr14,format=('d,d,d'),/silent else $
   readcol,f14,pixno14,lambda14,netrate14,bgl14,flux14,fluxerr14,format=('d,d,d,d,d,d'),/silent
   good14=where(flux14 ge -1E30 and flux14 le 1E30)
   lambda14=lambda14[good14]
   flux14=flux14[good14]
   fluxerr14=fluxerr14[good14]
   if (KEYWORD_SET(m14min) and KEYWORD_SET(m14max)) then begin 
      if m14min eq 'min' then m14min=float(min(lambda14))
      if m14max eq 'max' then m14max=float(max(lambda14))
      bad14=where(lambda14 ge m14min and lambda14 le m14max)
      fluxerr14[bad14]=fluxerr14[bad14]+1E15
   endif
endif
if KEYWORD_SET(f15) then begin
   i++
   if KEYWORD_SET(columns) then readcol,f15,lambda15,flux15,fluxerr15,format=('d,d,d'),/silent else $
   readcol,f15,pixno15,lambda15,netrate15,bgl15,flux15,fluxerr15,format=('d,d,d,d,d,d'),/silent
   good15=where(flux15 ge -1E30 and flux15 le 1E30)
   lambda15=lambda15[good15]
   flux15=flux15[good15]
   fluxerr15=fluxerr15[good15]
   if (KEYWORD_SET(m15min) and KEYWORD_SET(m15max)) then begin 
      if m15min eq 'min' then m15min=float(min(lambda15))
      if m15max eq 'max' then m15max=float(max(lambda15))
      bad15=where(lambda15 ge m15min and lambda15 le m15max)
      fluxerr15[bad15]=fluxerr15[bad15]+1E15
   endif
endif
if KEYWORD_SET(f16) then begin
   i++
   if KEYWORD_SET(columns) then readcol,f16,lambda16,flux16,fluxerr16,format=('d,d,d'),/silent else $
   readcol,f16,pixno16,lambda16,netrate16,bgl16,flux16,fluxerr16,format=('d,d,d,d,d,d'),/silent
   good16=where(flux16 ge -1E30 and flux16 le 1E30)
   lambda16=lambda16[good16]
   flux16=flux16[good16]
   fluxerr16=fluxerr16[good16]
   if (KEYWORD_SET(m16min) and KEYWORD_SET(m16max)) then begin 
      if m16min eq 'min' then m16min=float(min(lambda16))
      if m16max eq 'max' then m16max=float(max(lambda16))
      bad16=where(lambda16 ge m16min and lambda16 le m16max)
      fluxerr16[bad16]=fluxerr16[bad16]+1E15
   endif
endif
if KEYWORD_SET(f17) then begin
   i++
   if KEYWORD_SET(columns) then readcol,f17,lambda17,flux17,fluxerr17,format=('d,d,d'),/silent else $
   readcol,f17,pixno17,lambda17,netrate17,bgl17,flux17,fluxerr17,format=('d,d,d,d,d,d'),/silent
   good17=where(flux17 ge -1E30 and flux17 le 1E30)
   lambda17=lambda17[good17]
   flux17=flux17[good17]
   fluxerr17=fluxerr17[good17]
   if (KEYWORD_SET(m17min) and KEYWORD_SET(m17max)) then begin 
      if m17min eq 'min' then m17min=float(min(lambda17))
      if m17max eq 'max' then m17max=float(max(lambda17))
      bad17=where(lambda17 ge m17min and lambda17 le m17max)
      fluxerr17[bad17]=fluxerr17[bad17]+1E15
   endif
endif
if KEYWORD_SET(f18) then begin
   i++
   if KEYWORD_SET(columns) then readcol,f18,lambda18,flux18,fluxerr18,format=('d,d,d'),/silent else $
   readcol,f18,pixno18,lambda18,netrate18,bgl18,flux18,fluxerr18,format=('d,d,d,d,d,d'),/silent
   good18=where(flux18 ge -1E30 and flux18 le 1E30)
   lambda18=lambda18[good18]
   flux18=flux18[good18]
   fluxerr18=fluxerr18[good18]
   if (KEYWORD_SET(m18min) and KEYWORD_SET(m18max)) then begin 
      if m18min eq 'min' then m18min=float(min(lambda18))
      if m18max eq 'max' then m18max=float(max(lambda18))
      bad18=where(lambda18 ge m18min and lambda18 le m18max)
      fluxerr18[bad18]=fluxerr18[bad18]+1E15
   endif
endif
if KEYWORD_SET(f19) then begin
   i++
   if KEYWORD_SET(columns) then readcol,f19,lambda19,flux19,fluxerr19,format=('d,d,d'),/silent else $
   readcol,f19,pixno19,lambda19,netrate19,bgl19,flux19,fluxerr19,format=('d,d,d,d,d,d'),/silent
   good19=where(flux19 ge -1E30 and flux19 le 1E30)
   lambda19=lambda19[good19]
   flux19=flux19[good19]
   fluxerr19=fluxerr19[good19]
   if (KEYWORD_SET(m19min) and KEYWORD_SET(m19max)) then begin 
      if m19min eq 'min' then m19min=float(min(lambda19))
      if m19max eq 'max' then m19max=float(max(lambda19))
      bad19=where(lambda19 ge m19min and lambda19 le m19max)
      fluxerr19[bad19]=fluxerr19[bad19]+1E15
   endif
endif
if KEYWORD_SET(f20) then begin
   i++
   if KEYWORD_SET(columns) then readcol,f20,lambda20,flux20,fluxerr20,format=('d,d,d'),/silent else $
   readcol,f20,pixno20,lambda20,netrate20,bgl20,flux20,fluxerr20,format=('d,d,d,d,d,d'),/silent
   good20=where(flux20 ge -1E30 and flux20 le 1E30)
   lambda20=lambda20[good20]
   flux20=flux20[good20]
   fluxerr20=fluxerr20[good20]
   if (KEYWORD_SET(m20min) and KEYWORD_SET(m20max)) then begin 
      if m20min eq 'min' then m20min=float(min(lambda20))
      if m20max eq 'max' then m20max=float(max(lambda20))
      bad20=where(lambda20 ge m20min and lambda20 le m20max)
      fluxerr20[bad20]=fluxerr20[bad20]+1E15
   endif
endif


;CREATE ARRAYS CONTAINING THE VARIABLE NAMES FOR ONLY THE QUANTITY
;OF SPECTRA THAT WERE ENTERED.  
lambdaarr=['lambda1','lambda2']
fluxarr=['flux1','flux2']
fluxerrarr=['fluxerr1','fluxerr2']
for j=3,i do begin
   lambdaarr=[lambdaarr,'lambda'+string(strcompress(j,/remove_all))]
   fluxarr=[fluxarr,'flux'+string(strcompress(j,/remove_all))]
   fluxerrarr=[fluxerrarr,'fluxerr'+string(strcompress(j,/remove_all))]
endfor

;INTERPOLATE ALL SPECTRA ONTO THE LAMBDA SCALE OF THE FIRST ONE 
;THEN OUTPUT AS 3 MULTIDIMENSIONAL ARRAYS
biglambda=dblarr(i,n_elements(lambda1))
bigflux=dblarr(i,n_elements(flux1))
bigfluxerr=dblarr(i,n_elements(fluxerr1))
for k=0,n_elements(lambda1)-1 do biglambda[0,k]=lambda1[k]
for k=0,n_elements(flux1)-1 do bigflux[0,k]=flux1[k]
for k=0,n_elements(fluxerr1)-1 do bigfluxerr[0,k]=fluxerr1[k]
for j=1,i-1 do begin
   lamvar=scope_varfetch(lambdaarr[j],/enter)
   fluvar=scope_varfetch(fluxarr[j],/enter)
   errvar=scope_varfetch(fluxerrarr[j],/enter)

   interp=interpolate_function_errors(lambda1,flux1,fluxerr1,lamvar,fluvar,errvar)  
   interplam=dblarr(n_elements(interp)/3);contains lambdas for interp spectrum
   interpflu=dblarr(n_elements(interp)/3);contains flux values for spectra interp at lam1 points
   interperr=dblarr(n_elements(interp)/3);         error
   for z=0,n_elements(interp)/3-1 do interplam[z]=interp[0,z] ; unpack the 2d array made by interp function
   for z=0,n_elements(interp)/3-1 do interpflu[z]=interp[1,z] ; ditto
   for z=0,n_elements(interp)/3-1 do interperr[z]=interp[2,z]

   for k=0,n_elements(lambda1)-1  do biglambda[j,k] =interplam[k]
   for k=0,n_elements(flux1)-1    do bigflux[j,k]   =interpflu[k]
   for k=0,n_elements(fluxerr1)-1 do bigfluxerr[j,k]=interperr[k]
endfor

;DO STATISTICS AS ON P.57 OF BEVINGTON 
flustat=dblarr(i,n_elements(lambda1));contains xi/sigmai^2
errstat=dblarr(i,n_elements(lambda1));contains errors
for p=0,n_elements(lambda1)-1 do begin
   for y=0,i-1 do begin
      flustat[y,p]= bigflux[y,p]/bigfluxerr[y,p]^2 ;sigma(x_i/sigma_i^2)
      errstat[y,p]= 1/bigfluxerr[y,p]^2 ; sigma_mu^2=sigma(1/sigma_i^2_)
   endfor
endfor

;SUM ALL OF THE COMPONENTS FOR EACH FLUX POINT
flu=total(flustat,1)
err=total(errstat,1)

;CALCULATE THE FINAL MOST LIKELY FLUX FOR EACH LAMBDA AND ERROR
finalflux=flu/err
finalerr= 1/err ;this is sigma_mu^2

;PLOT FIRST SPECTRUM AND VARIANCE WEIGHTED SPECTRUM
plot,lambda1,flux1;,xrange=[3000,3500]
oplot,lambda1,flux2
if KEYWORD_SET(f3) then oplot,lambda3,flux3
if KEYWORD_SET(f4) then oplot,lambda4,flux4
if KEYWORD_SET(f5) then oplot,lambda5,flux5
if KEYWORD_SET(f6) then oplot,lambda6,flux6
if KEYWORD_SET(f7) then oplot,lambda7,flux7
if KEYWORD_SET(f8) then oplot,lambda8,flux8
if KEYWORD_SET(f9) then oplot,lambda9,flux9
if KEYWORD_SET(f10) then oplot,lambda10,flux10
if KEYWORD_SET(f11) then oplot,lambda11,flux11
if KEYWORD_SET(f12) then oplot,lambda12,flux12
if KEYWORD_SET(f13) then oplot,lambda13,flux13
if KEYWORD_SET(f14) then oplot,lambda14,flux14
if KEYWORD_SET(f15) then oplot,lambda15,flux15
if KEYWORD_SET(f16) then oplot,lambda16,flux16
if KEYWORD_SET(f17) then oplot,lambda17,flux17
if KEYWORD_SET(f18) then oplot,lambda18,flux18
if KEYWORD_SET(f19) then oplot,lambda19,flux19
if KEYWORD_SET(f20) then oplot,lambda20,flux20
oplot,lambda1,finalflux,color=255

;OUTPUT
if KEYWORD_SET(output) then begin
   openw,luo,output,/get_lun
   for j=0,n_elements(finalflux)-1 do printf,luo,lambda1[j],finalflux[j],sqrt(finalerr[j]),format='(e24.17,x,e24.17,x,e24.17)'
   close,luo
   free_lun,luo
endif else print,'NO OUTPUT IS BEING CREATED BECAUSE OUTPUT KEYWORD IS NOT SET'
      
print,'  DONT WORRY ABOUT STRING TO FLOAT CONVERSION ERROR IF YOU ARE USING THE LAMBDA LIMITATIONS KEYWORDS.  ITS A NECESSARY EVIL IN THIS CASE.'
end


