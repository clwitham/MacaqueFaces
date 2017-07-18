function [] = MacaqueFaces_Recognition(video_file,output_dir,save_images,model_file)
%% Run face detection and recognition on a single video file.
% Aimed at videos of rhesus macaque monkeys.
% Produces CSV file containing locations and identities of detected faces
% video_file: filepath and filename of video
% output_dir: directory to save results to
% save_images: set to 1 to save processed frames as image,
%                     0 to produce CSV file only
% recognition_model: model produced by MacaqueFaces_Train.m and containing
% classification model.

%% Parameters
flag=2; % set flag to 1 to run face only detection, set to 2 to run face + eyes/nose detection
Threshold=8; % Threshold of face cascade object detector, set low to increase sensitivity, high to reduce number of false positives
Frames=2; % Set number of frames per second to process, setting to 0 will cause all frames to be processed
Output_Format='jpg'; % outputs images as jpegs; change to 'png' if desired

%% Open Detection Models
filepath=fullfile(cd,'XMLFiles','MacaqueFrontalFaceModel.xml');
FaceDetector=vision.CascadeObjectDetector(filepath,'MergeThreshold',Threshold); % assumes models are located in same directory as program files; please change if this is not the case
if flag==2
    filepath=fullfile(cd,'XMLFiles','MacaqueSingleEyeModel.xml');
    EyeDetector=vision.CascadeObjectDetector(filepath,'MergeThreshold',1);
    filepath=fullfile(cd,'XMLFiles','MacaqueNoseModel.xml');
    NoseDetector=vision.CascadeObjectDetector(filepath,'MergeThreshold',1);
end

%% Check Input Arguments

if ~exist(output_dir,'dir')
    try
        mkdir(output_dir)
    catch
        errordlg('Invalid Output Directory');
    end
end

try
    recognition_model=load(model_file);
catch
    errordlg('Invalid Model File');
end
if (~isfield(recognition_model,'obj'))||(~isfield(recognition_model,'pca_coeffs'))||(~isfield(recognition_model,'pca_mean'))
    errordlg('Invalid Model File');
end




%% Open Video
try
    video_input=VideoReader(video_file);
catch
    errordlg('Invalid Video File');
end
[~,vidname]=fileparts(video_file);
totalF=floor(video_input.Duration.*video_input.FrameRate); % calculate total number of frames

%% Calculate Interval between Frames
if Frames==0
    FrameInt=1;
else
    FrameInt=round(video_input.FrameRate/Frames);
end

%% Setup variable for face detection information (frame, position of face, coordinates of eyes and nose - if flag is set to 2)
if flag==2
    detection_info=zeros(10000,6);
else
    detection_info=zeros(10000,12);
end
totalfaces=0;

%% Run Face Detection
frameno=0;
wb=waitbar(0,'Detecting Faces','CreateCancelBtn','setappdata(gcbf,''canceling'',1)'); % set up wait bar to track progress and include cancel function
setappdata(wb,'canceling',0);
while hasFrame(video_input)
    
    I=readFrame(video_input); % read in frame
    frameno=frameno+1;
    
    if getappdata(wb,'canceling')
        break
    end
    waitbar(frameno/totalF);
    
    if rem(frameno,FrameInt)==0
        facebox=step(FaceDetector,I); % run face detection
        nofaces=size(facebox,1);
        NewI=I;
        goodfaces=0;
        
        for p=1:nofaces
            
            CropI=imcrop(I,facebox(p,:)); % Isolate facial image
            CropI=imresize(CropI,[100,100]); % Resize facial image to 100x100 pixels
            if flag==1
                isgood=1;
            else
                isgood=1;
                reye=step(EyeDetector,imcrop(CropI,[1,1,50,50])); % run eye detection on upper left quadrant of image (for right eye)
                leye=step(EyeDetector,imcrop(CropI,[51,1,50,50])); % run eye detection on upper right quadrant of image (for left eye)
                nose=step(NoseDetector,imcrop(CropI,[26,1,50,100])); % run nose detection on central column
                if isempty(reye)||isempty(leye)||isempty(nose)
                    isgood=0; % if either of the eyes or the nose is not detected classify this as a bad image
                end
            end
            
            if isgood
                totalfaces=totalfaces+1;
                detection_info(totalfaces,1)=frameno;
                detection_info(totalfaces,2)=p;
                detection_info(totalfaces,3)=facebox(p,1)+(0.5*facebox(p,3));
                detection_info(totalfaces,4)=facebox(p,2)+(0.5*facebox(p,4));
                detection_info(totalfaces,5)=facebox(p,3);
                detection_info(totalfaces,6)=facebox(p,4);
                
                if flag==2
                    % convert bounding boxes from eyes and nose detection to x,y coordinates in original frame
                    reye_x=reye(1,1)+(reye(3)*0.5);
                    detection_info(totalfaces,7)=(reye_x/100)*facebox(p,3)+facebox(p,1);
                    reye_y=reye(1,2)+(reye(4)*0.5);
                    detection_info(totalfaces,8)=(reye_y/100)*facebox(p,4)+facebox(p,2);
                    
                    leye_x=leye(1,1)+50+(leye(3)*0.5);
                    detection_info(totalfaces,9)=(leye_x/100)*facebox(p,3)+facebox(p,1);
                    leye_y=leye(1,2)+(leye(4)*0.5);
                    detection_info(totalfaces,10)=(leye_y/100)*facebox(p,4)+facebox(p,2);
                    
                    nose_x=nose(1,1)+25+(nose(3)*0.5);
                    detection_info(totalfaces,11)=(nose_x/100)*facebox(p,3)+facebox(p,1);
                    nose_y=nose(1,2)+(nose(4)*0.5);
                    detection_info(totalfaces,12)=(nose_y/100)*facebox(p,4)+facebox(p,2);
                    
                end
                
                vec=extractLBPFeatures(rgb2gray(CropI),'Radius',1,'NumNeighbors',8,'CellSize',[20,20]);
                vec=(vec-recognition_model.pca_mean)*recognition_model.pca_coeffs;
                id=predict(recognition_model.obj,vec);
                goodfaces=goodfaces+1;
                if save_images
                    NewI=insertShape(NewI,'Rectangle',facebox(p,:),'LineWidth',4); % insert bounding box into frame to show detected face
                    NewI=insertObjectAnnotation(NewI,'Rectangle',facebox(p,:),id,'FontSize',24); % insert bounding box into frame to show detected face
                end
            end
        end
        if goodfaces>0&&save_images
            fname=fullfile(output_dir,[vidname,'_',num2str(frameno),'_detections.',Output_Format]);
            imwrite(NewI,fname);  % write processed frame to jpeg file
        end
    end
end
delete(wb);


%% Write List of Detected Faces and Coordinates to CSV File
detection_info=detection_info(1:totalfaces,:);
if flag==1
    T=array2table(detection_info,'VariableNames',{'FrameNumber','ImageNumber','Face_x','Face_y','Face_Width','Face_Height'});% convert output to table
else
    T=array2table(detection_info,'VariableNames',{'FrameNumber','ImageNumber','Face_x','Face_y','Face_Width','Face_Height',...
        'RightEye_x','RightEye_y','LeftEye_x','LeftEye_y','Nose_x','Nose_y'});% convert output to table
end
fname=fullfile(output_dir,[vidname,'_detection_results.csv']);
writetable(T,fname); % save output to CSV file
