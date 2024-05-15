function interpolate_function,lam1,flu1,lam2,flu2

;PURPOSE
;this function will interpolate lam2 and flu2 onto the lambda grid of
;lam1 without regard for error values.  (If your data has errors and
;you want them retained you should use interpolate_function_errors.pro)
;
;INPUTS
;lam1  Wavelength values of a spectrum (array)
;flu1  Flux values of a spectrum corresponding to wavelengths in lam1
;lam2  Wavelength values of a spectrum (array)
;flu2  Flux values of a spectrum corresponding to wavelengths in lam2
;
;OUTPUT
;This function returns a multidimensional array to the program which called it.  The
;array must be unpacked by the calling program.

maxlam1=max(lam1,max_subscript)
maxlam1=lam1[max_subscript]+(lam1[max_subscript]-lam1[max_subscript-2])
use=where(lam2 ge min(lam1) and lam2 le maxlam1,nuse)
lam2use=lam2[use]
flu2use=flu2[use]

flu2interp=fltarr(n_elements(lam1))
for xx=0,n_elements(lam1)-1 do begin ;calc the filter transmission at each spectra lambda 
   diff=lam2use-lam1[xx] 
   neg=where(diff le 0,n)
   pos=where(diff ge 0,n)
   lam2usebelow=max(lam2use[neg],belowi);filter lambda nearest the spectra lambda (smaller) 
   lam2useabove=min(lam2use[pos],abovei);filter lambda nearest the spectra lambda (larger)
   flu2usebelow=flu2use[neg[belowi]];filter transmission at the nearest filter lambda (smaller)
   flu2useabove=flu2use[pos[abovei]];filter transmission at the nearest filter lambda (larger)
   percent=(lam1[xx]-lam2usebelow)/(lam2useabove-lam2usebelow)
   array=[flu2usebelow,flu2useabove]
   ;if xx eq 1 then print,percent
   flu2interp[xx]=interpolate(array,percent) ;interpolated transmission at spectra lambda
endfor
 ;print,lam1[1],flu2interp[1]
array=dblarr(2,n_elements(lam1))
for i=0,n_elements(lam1)-1 do array(0,i)=lam1[i]
for i=0,n_elements(lam1)-1 do array(1,i)=flu2interp[i]
return,array

;array1=dblarr(2,n_elements(lam1))
;for i=0,n_elements(lam1)-1 do array1(0,i)=lam1[i]
;for i=0,n_elements(lam1)-1 do array1(1,i)=flu1[i]
;print,array
;return,array1


end
