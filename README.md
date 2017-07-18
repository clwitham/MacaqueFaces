# MacaqueFaces
Facial Recognition Software for Macaque Monkeys

## Getting Started

### Prerequisites
**Matlab and the following toolboxes:**
- Computer Vision Toolbox
- Image Processing Toolbox
- Statistics and Machine Learning Toolbox

### Installing
Copy respository to desired directory and set to current directory in Matlab.

## Face Detection
For a given video file the program MacaqueFaces_Detection.m will process the video and output the detected faces to jpeg files.

Run MacaqueFaces_Detection(video_file,output_dir) from the command line.
Requires two inputs:
- **video_file:** file path and name of video file to analyse (see [Matlab help](https://uk.mathworks.com/help/matlab/ref/videoreader-object.html) for supported video formats).
- **output_dir:** directory to save output to (output includes jpeg files of the detected faces and the processed video stills and a csv file containing a list of the locations of the detected faces).

## Face Recognition
### Training
Trains a classification model (see paper for details) for use with MacaqueFaces_Recognition.m. Requires input in form of image files sorted by identity. A minimum of two images per individual is required. Where there are unqequal numbers of images per individual the minimum number of images per individual will be used for all individuals (for example if you had 10 images of individuals A and B and only 5 of C then 5 images will be selected randomly for each individual and used for training). For accurate cross-validation results a larger number of images per individual is required. 

Run MacaqueFaces_Train(image_dir,output_fname,cval) from the command line.
Requires three inputs:
- **image_dir:** file path of the directory containing the image files sorted by identity (see ModelSet for example of required folder structure).
- **output_fname:** filename to save classification model to (saved as .mat file).
- **cval:** optional variable to set the number of folds to use for cross-validation (if left blank will be set to 10 by default).

### Processing
For a given video and face recognition model file the program MacaqueFaces_Recognition.m will process the video, extract any detected faces and classify them using the recognition model. The output is in the form of a csv file containing the locations of the faces along with the identity. It is also possible to save the processed video stills by setting the 

Run MacaqueFaces_Recognition(video_file,output_dir,save_images,model_file) from the command line.
Requires four inputs:
- **video_file:** file path and name of video file to analyse (see [Matlab help](https://uk.mathworks.com/help/matlab/ref/videoreader-object.html) for supported video formats).
- **output_dir:** directory to save output to.
- **save_images:** set to 1 to save processed video stills as jpegs, 0 to just save csv file.
- **model_file:** file path and name of face recognition model file to use (this should be the output of MacaqueFaces_Train)

## Test Files
### Detection Set
Zipped file containing example images of faces, eyes and noses (all cropped and resized) for use with a cascade classifier trainer (please note no negative images are provided, free negative image sets are available on the internet).

### Model Set
Zipped file containing images for 34 individuals. Includes images of different qualities. See readme.md in the ModelSet directory for more details. For use with MacaqueFaces_Train.m.

### Test Video
Video of six monkeys to use for testing MacaqueFaces_Recognition.m. A model file is also provided.See readme.md in TestVideo directory for more details.

## License
See the LICENSE.md file for details
Please cite Witham, CL. JNeuroMeth in any publications
