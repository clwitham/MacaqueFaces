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

### Face Detection
For a given video file the program MacaqueFaces_Detection.m will process the video and output the detected faces to jpeg files.
Run MacaqueFaces_Detection(video_file,output_dir) from the command line.
Requires two inputs:
- **video_file:** file path and name of video file to analyse (see [Matlab help](https://uk.mathworks.com/help/matlab/ref/videoreader-object.html) for supported video formats).
- **output_dir:** directory to save output to (output includes jpeg files of the detected faces and the processed video stills and a csv file containing a list of the locations of the detected faces).

### Recognition
#### Training
Run MacaqueFaces_Train(image_dir,output_fname,cval) from the command line.
Requires three inputs:
- **image_dir:** file path of the directory containing the image files sorted by identity (see ModelSet for example of required folder structure).
- **output_fname:** filename to save classification model to (saved as .mat file).
- **cval:** optional variable to set the number of folds to use for cross-validation (if left blank will be set to 10 by default).

## License
See the LICENSE.md file for details
Please cite Witham, CL. JNeuroMeth in any publications
