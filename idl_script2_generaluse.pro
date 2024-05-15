pro idl_script2_generaluse, oobsid, oe

; CONVERT ARGUMENT INTO STRING
oobsid_string = strtrim(oobsid,2)
; ADDING ZEROS
oobsid_zeros = ["000",oobsid_string]
observationobsid = oobsid_zeros.Join()
; CHECKING OBSERVATION ID IS CORRECT
print, 'Original observation target ID = ', observationobsid

;set up the pathways for master_shift
ms_pat1 = [observationobsid,"/uvot/image/sw",observationobsid,"ugu_1ord_1.dat"]
ms_path1 = ms_pat1.Join()
ms_pat2 = [observationobsid,"/uvot/image/sw",observationobsid,"ugu_1ord_1s.dat"]
ms_path2 = ms_pat2.Join()
ms_pat3 = [observationobsid,"/uvot/image/sw",observationobsid,"ugu_1ord_2.dat"]
ms_path3 = ms_pat3.Join()
ms_pat4 = [observationobsid,"/uvot/image/sw",observationobsid,"ugu_1ord_2s.dat"]
ms_path4 = ms_pat4.Join()
ms_pat5 = [observationobsid,"/uvot/image/sw",observationobsid,"ugu_1ord_3.dat"]
ms_path5 = ms_pat5.Join()
ms_pat6 = [observationobsid,"/uvot/image/sw",observationobsid,"ugu_1ord_3s.dat"]
ms_path6 = ms_pat6.Join()

;set up the pathways for spectra_avg
sa_pat = [observationobsid,"/uvot/image/sw",observationobsid,"ugu_1ord_final.dat"]
sa_path = sa_pat.Join()

if oe eq 1 then begin
    ;;;;;;;;;;;;;WAVELENGTH SHIFT THE SPECTRA TO GIVE THE BEST ALIGNMENT AMONG THE SNAPSHOTS
    master_shift,ms_path1,ms_path1,/uvot1,/uvot2,minlam=3000.,maxlam=5000.,outfile=sa_path ;ALIGN 1ST EXTENSION WITH THE 1ST EXTENSION (NOT REALLY NECESSARY, BUT CONVENIENT)
    ;master_shift,'00032094004/uvot/image/sw00032094004ugu_1ord_1.dat','00032094004/uvot/image/sw00032094004ugu_1ord_1.dat',/uvot1,/uvot2,minlam=3000.,maxlam=5000.,outfile='00032094004/uvot/image/sw00032094004ugu_1ord_1s.dat' ;ALIGN 1ST EXTENSION WITH THE 1ST EXTENSION (NOT REALLY NECESSARY, BUT CONVENIENT)
endif

if oe eq 2 then begin
    ;;;;;;;;;;;;;WAVELENGTH SHIFT THE SPECTRA TO GIVE THE BEST ALIGNMENT AMONG THE SNAPSHOTS
    master_shift,ms_path1,ms_path1,/uvot1,/uvot2,minlam=3000.,maxlam=5000.,outfile=ms_path2 ;ALIGN 1ST EXTENSION WITH THE 1ST EXTENSION (NOT REALLY NECESSARY, BUT CONVENIENT)
    ;master_shift,'00032094004/uvot/image/sw00032094004ugu_1ord_1.dat','00032094004/uvot/image/sw00032094004ugu_1ord_1.dat',/uvot1,/uvot2,minlam=3000.,maxlam=5000.,outfile='00032094004/uvot/image/sw00032094004ugu_1ord_1s.dat' ;ALIGN 1ST EXTENSION WITH THE 1ST EXTENSION (NOT REALLY NECESSARY, BUT CONVENIENT)

    master_shift,ms_path1,ms_path3,/uvot1,/uvot2,minlam=3000.,maxlam=5000.,outfile=ms_path4 ;ALIGN 2ND EXTENSION WITH THE 1ST EXTENSION 
    ;master_shift,'00032094004/uvot/image/sw00032094004ugu_1ord_1.dat','00032094004/uvot/image/sw00032094004ugu_1ord_2.dat',/uvot1,/uvot2,minlam=3000.,maxlam=5000.,outfile='00032094004/uvot/image/sw00032094004ugu_1ord_2s.dat' ;ALIGN 2ND EXTENSION WITH THE 1ST EXTENSION 

    ;;;;;;;;;;;;;COADD THE WAVELENGTH SHIFTED SPECTRA INTO A SINGLE, LESS NOISY, FINAL SPECTRUM
    spectra_avg,ms_path2,ms_path4,output=sa_path
    ;spectra_avg,'00032094004/uvot/image/sw00032094004ugu_1ord_1s.dat','00032094004/uvot/image/sw00032094004ugu_1ord_2s.dat',output='00032094004/uvot/image/sw00032094004ugu_1ord_final.dat'
endif

if oe eq 3 then begin
    ;;;;;;;;;;;;;WAVELENGTH SHIFT THE SPECTRA TO GIVE THE BEST ALIGNMENT AMONG THE SNAPSHOTS
    master_shift,ms_path1,ms_path1,/uvot1,/uvot2,minlam=3000.,maxlam=5000.,outfile=ms_path2 ;ALIGN 1ST EXTENSION WITH THE 1ST EXTENSION (NOT REALLY NECESSARY, BUT CONVENIENT)
    ;master_shift,'00032094004/uvot/image/sw00032094004ugu_1ord_1.dat','00032094004/uvot/image/sw00032094004ugu_1ord_1.dat',/uvot1,/uvot2,minlam=3000.,maxlam=5000.,outfile='00032094004/uvot/image/sw00032094004ugu_1ord_1s.dat' ;ALIGN 1ST EXTENSION WITH THE 1ST EXTENSION (NOT REALLY NECESSARY, BUT CONVENIENT)

    master_shift,ms_path1,ms_path3,/uvot1,/uvot2,minlam=3000.,maxlam=5000.,outfile=ms_path4 ;ALIGN 2ND EXTENSION WITH THE 1ST EXTENSION 
    ;master_shift,'00032094004/uvot/image/sw00032094004ugu_1ord_1.dat','00032094004/uvot/image/sw00032094004ugu_1ord_2.dat',/uvot1,/uvot2,minlam=3000.,maxlam=5000.,outfile='00032094004/uvot/image/sw00032094004ugu_1ord_2s.dat' ;ALIGN 2ND EXTENSION WITH THE 1ST EXTENSION
    
    master_shift,ms_path1,ms_path5,/uvot1,/uvot2,minlam=3000.,maxlam=5000.,outfile=ms_path6 ; ALIGN 3RD EXTENSION WITH THE 1ST EXTENSION
    ;master_shift,'00032094004/uvot/image/sw00032094004ugu_1ord_1.dat','00032094004/uvot/image/sw00032094004ugu_1ord_3.dat',/uvot1,/uvot2,minlam=3000.,maxlam=5000.,outfile='00032094004/uvot/image/sw00032094004ugu_1ord_3s.dat' ; ALIGN 3RD EXTENSION WITH THE 1ST EXTENSION

    ;;;;;;;;;;;;;COADD THE WAVELENGTH SHIFTED SPECTRA INTO A SINGLE, LESS NOISY, FINAL SPECTRUM
    spectra_avg,ms_path2,ms_path4,f3=ms_path6,output=sa_path
    ;spectra_avg,'00032094004/uvot/image/sw00032094004ugu_1ord_1s.dat','00032094004/uvot/image/sw00032094004ugu_1ord_2s.dat',f3='00032094004/uvot/image/sw00032094004ugu_1ord_3s.dat',output='00032094004/uvot/image/sw00032094004ugu_1ord_final.dat'
endif

;master_shift,(reference spectrum),(spectrum to be
;wavelength shifted),(/uvot1 is flag that reference spectrum is uvotpy formatted
;data),(uvot2 is flag that 2nd spectrum is uvotpy formatted
;data),(minlam=minimum wavelength to be used in chi^2
;calculation),(maxlam=maximum wavelength to be used in chi^2
;calculation),(outfile=output file containing wavelength shifted spectrum.)

;spectra_avg,(1st spectrum to coadd [all other spectra are
;interpolated onto the wavelength scale of this spectrum]),(2nd
;spectrum to coadd),(f3=flag containing filename of 3rd spectrum to
;coadd [list all additional spectra up to f20 here if
;necessary]),(output=filename of the final, coadded spectrum)

end
