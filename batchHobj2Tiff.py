import numpy as np
import cv2

import struct, time, os

def read_hobj(image_filename):
	start_time = time.time()
	print('Getting HOBJ file >>> {:s}'.format(image_filename))
	with open(image_filename,'rb') as f:
		ibuffer 	= f.read(84)
		#
		npixels 	= struct.unpack('i',ibuffer[72:76][::-1])[0]
		rows 		= struct.unpack('h',ibuffer[80:82][::-1])[0]+1
		cols 		= struct.unpack('h',ibuffer[82:84][::-1])[0]+1
		#
		print('Image width/height is {:d}/{:d}.'.format(cols, rows))
		print('# of pixels is {:d}.'.format(npixels))
		#
		f.seek(84+rows*6+17)
		image_str 	= f.read(npixels*2)
		bit_format 	= '<{:d}{:s}'.format(npixels, 'h')
		image_array 	= struct.unpack(bit_format, image_str)
		print('Read time: {:.2f} seconds.'.format(time.time() - start_time))
	return np.array(image_array).reshape(rows , cols)


# Path to .hobj images
imgFolder = r'D:\Documents\School Documents\2020-2021 Senior Year College\Research\Data\20029F1\HOBJ'
# Path to save converted .tiff files
saveDir = r'D:\Documents\School Documents\2020-2021 Senior Year College\Research\Data\20029F1\Tiff'
# Path to save scaled .tiff files
sclSaveDir = r'D:\Documents\School Documents\2020-2021 Senior Year College\Research\Data\20029F1\Scaled'

for fileName in os.listdir(imgFolder):
    
    # get the path to the image
    imgPath = os.path.join(imgFolder, fileName)
    # read the hobj as a numpy array
    imgArr = read_hobj(imgPath)
    
    # scale the image array so we can see it
    sclImgArr = imgArr - np.min(imgArr)
    sclImgArr = (sclImgArr * float(np.iinfo(np.uint16).max) / np.max(sclImgArr)).astype(np.uint16)
    
    # convert the array to uint16 for tiff purposes
    imgArr = imgArr.astype(np.uint16)
    
    # debayer it into a color image (RGGB CFA)
    # imgArr = cv2.cvtColor(imgArr, cv2.COLOR_BayerRG2RGB)
    sclImgArr = cv2.cvtColor(sclImgArr, cv2.COLOR_BayerRG2RGB)
    
    # remove hobj from the end of the file (leaving the .)
    fileNameNoExt = fileName[0:(len(fileName) - 4)]
    # add the tiff extension
    fileNameTiff = fileNameNoExt + 'tiff'
    
    # write the files
    cv2.imwrite(os.path.join(saveDir, fileNameTiff), imgArr)
    cv2.imwrite(os.path.join(sclSaveDir, fileNameTiff), sclImgArr)

