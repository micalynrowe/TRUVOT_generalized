#!!!! YOU MUST LAUNCH HEASOFT PRIOR TO EXECUTING THIS SCRIPT!!!!
#  ('heainit' is the default method of launching)

#import some python packages
import os
import os.path
from uvotpy import uvotgrism
from uvotpy import uvotgetspec
import pyfits
import numpy

def truvot(targetid,ra,dec,exts,tw):
    #SET VARIABLES REQUIRED FOR UVOTPY (TARGET LOCATION ON SKY)
    ra = float(ra)
    dec = float(dec)
    tw = float(tw) # need to add tw back in as an input to use this!!!
    #targetid = str(targetid)

    os.chdir(targetid+'/uvot/image') #CHANGE WORKING DIRECTORY TO BE THE DATA DIRECTORY

    obsid = targetid #OBSID OF OBSERVATION
    ext = 1 #OPERATE ON THE 1ST IMAGE EXTENSION
    e=pyfits.getdata('sw'+targetid+'ugu_dt_template_1.fits') #READ IN THE TEMPLATE FOR THIS SNAPSHOT AS AN ARRAY
    uvotgetspec.trackwidth = tw
    print ('Changed the trackwidth!!!!')
    Z = uvotgetspec.getSpec(ra,dec,obsid,ext,fit_second=True,wr_outfile=True,chatter=1,background_template=e,clobber=True) #EXECUTE UVOTPY
    if exts > 1:
        ext = 2 #REPEAT THE PROCEDURE FOR THE 2ND IMAGE EXTENSION
        e=pyfits.getdata('sw'+targetid+'ugu_dt_template_2.fits')
        uvotgetspec.trackwidth = tw
        Z = uvotgetspec.getSpec(ra,dec,obsid,ext,fit_second=True,wr_outfile=True,chatter=1,background_template=e,clobber=True)
        if exts > 2:
            ext = 3 #REPEAT THE PROCEDURE FOR THE 3RD IMAGE EXTENSION
            e=pyfits.getdata('sw'+targetid+'ugu_dt_template_3.fits')
            uvotgetspec.trackwidth = tw
            Z = uvotgetspec.getSpec(ra,dec,obsid,ext,fit_second=True,wr_outfile=True,chatter=1,background_template=e,clobber=True)
    os.chdir('../../..') #CHANGE BACK TO THE ORIGINAL DIRECTORY
    print ('Finished extracting '+targetid+' using UVOTPY!')

    #CONVERT THE UVOTPY OUTPUT SPECTRA INTO A COLUMNATED FORMAT
    path = './'+targetid+'/uvot/image/sw'+targetid+'ugu_1ord_1_f.pha'
    if os.path.isfile(path) == True:
        thr = pyfits.open('./'+targetid+'/uvot/image/sw'+targetid+'ugu_1ord_1_f.pha')
        data = thr[2].data                                                   
        numpy.savetxt('./'+targetid+'/uvot/image/sw'+targetid+'ugu_1ord_1.dat',data)
        if exts > 1:
            path3 = './'+targetid+'/uvot/image/sw'+targetid+'ugu_1ord_2_f.pha'
            if os.path.isfile(path3) == True:
                thr = pyfits.open('./'+targetid+'/uvot/image/sw'+targetid+'ugu_1ord_2_f.pha')
                data = thr[2].data                                                   
                numpy.savetxt('./'+targetid+'/uvot/image/sw'+targetid+'ugu_1ord_2.dat',data)
            else:
                thr = pyfits.open('./'+targetid+'/uvot/image/sw'+targetid+'ugu_1ord_2_g.pha')
                data = thr[2].data                                                   
                numpy.savetxt('./'+targetid+'/uvot/image/sw'+targetid+'ugu_1ord_2.dat',data)
            if exts > 2:
                path4 = './'+targetid+'/uvot/image/sw'+targetid+'ugu_1ord_3_f.pha'
                if os.path.isfile(path4) == True:
                    thr = pyfits.open('./'+targetid+'/uvot/image/sw'+targetid+'ugu_1ord_3_f.pha')
                    data = thr[2].data                                                   
                    numpy.savetxt('./'+targetid+'/uvot/image/sw'+targetid+'ugu_1ord_3.dat',data)
                else:
                    thr = pyfits.open('./'+targetid+'/uvot/image/sw'+targetid+'ugu_1ord_3_g.pha')
                    data = thr[2].data                                                   
                    numpy.savetxt('./'+targetid+'/uvot/image/sw'+targetid+'ugu_1ord_3.dat',data)
    else:
        thr = pyfits.open('./'+targetid+'/uvot/image/sw'+targetid+'ugu_1ord_1_g.pha')
        data = thr[2].data                                                   
        numpy.savetxt('./'+targetid+'/uvot/image/sw'+targetid+'ugu_1ord_1.dat',data)
        if exts > 1:
            path1 = './'+targetid+'/uvot/image/sw'+targetid+'ugu_1ord_2_g.pha'
            if os.path.isfile(path1) == True:
                thr = pyfits.open('./'+targetid+'/uvot/image/sw'+targetid+'ugu_1ord_2_g.pha')
                data = thr[2].data                                                   
                numpy.savetxt('./'+targetid+'/uvot/image/sw'+targetid+'ugu_1ord_2.dat',data)
            else:
                thr = pyfits.open('./'+targetid+'/uvot/image/sw'+targetid+'ugu_1ord_2_f.pha')
                data = thr[2].data                                                   
                numpy.savetxt('./'+targetid+'/uvot/image/sw'+targetid+'ugu_1ord_2.dat',data)
            if exts > 2:
                path2 = './'+targetid+'/uvot/image/sw'+targetid+'ugu_1ord_3_g.pha'
                if os.path.isfile(path2) == True:
                    thr = pyfits.open('./'+targetid+'/uvot/image/sw'+targetid+'ugu_1ord_3_g.pha')
                    data = thr[2].data                                                   
                    numpy.savetxt('./'+targetid+'/uvot/image/sw'+targetid+'ugu_1ord_3.dat',data)
                else:
                    thr = pyfits.open('./'+targetid+'/uvot/image/sw'+targetid+'ugu_1ord_3_f.pha')
                    data = thr[2].data                                                   
                    numpy.savetxt('./'+targetid+'/uvot/image/sw'+targetid+'ugu_1ord_3.dat',data)
