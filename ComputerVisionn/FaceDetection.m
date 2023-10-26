clear all; close all; clc;


faceDetector = vision.CascadeObjectDetector();

fileReader = vision.VideoFileReader('WIN_20221007_14_28_04_Pro.mp4');

videoFrame = step(fileReader);

%%yüzü arama
yuzCerceve = step(faceDetector,videoFrame);

cikisVideo = insertObjectAnnotation(videoFrame,'rectangle',yuzCerceve,'tespit');
figure,imshow(cikisVideo),title('Yüz tespiti yapildi');

yuzCercevePoints = bbox2points(yuzCerceve(1, :));

points = detectMinEigenFeatures(rgb2gray(videoFrame), 'ROI', yuzCerceve);

figure, imshow(videoFrame), hold on, title('Detected features');
plot(points);

pointTracker = vision.PointTracker('MaxBidirectionalError', 2);
points = points.Location;
initialize(pointTracker, points, videoFrame);

videoPlayer  = vision.VideoPlayer('Position',...
    [100 100 [size(videoFrame, 2), size(videoFrame, 1)]+30]);
oldPoints = points;
%{
while hasFrame(videoFrame)
    % get the next frame
    videoFrame = readFrame(videoReader);

    % Track the points. Note that some points may be lost.
    [points, isFound] = step(pointTracker, videoFrame);
    visiblePoints = points(isFound, :);
    oldInliers = oldPoints(isFound, :);
    
    if size(visiblePoints, 1) >= 2 % need at least 2 points
        
        % Estimate the geometric transformation between the old points
        % and the new points and eliminate outliers
        [xform, inlierIdx] = estimateGeometricTransform2D(...
            oldInliers, visiblePoints, 'similarity', 'MaxDistance', 4);
        oldInliers    = oldInliers(inlierIdx, :);
        visiblePoints = visiblePoints(inlierIdx, :);
        
        % Apply the transformation to the bounding box points
        bboxPoints = transformPointsForward(xform, bboxPoints);
                
        % Insert a bounding box around the object being tracked
        bboxPolygon = reshape(bboxPoints', 1, []);
        videoFrame = insertShape(videoFrame, 'polygon', bboxPolygon, ...
            'LineWidth', 2);
                
        % Display tracked points
        videoFrame = insertMarker(videoFrame, visiblePoints, '+', ...
            'Color', 'white');       
        
        % Reset the points
        oldPoints = visiblePoints;
        setPoints(pointTracker, oldPoints);        
    end
    
    % Display the annotated video frame using the video player object
    step(videoPlayer, videoFrame);
end
%}
% Clean up
release(videoPlayer);

[hue,~,~] = rgb2hsv(videoFrame);
figure,imshow(hue),title('Hue kanal?');
rectangle('Position',yuzCerceve(1,:),'EdgeColor',[1 0 0],'LineWidt',3);


%Mouth  LeftEye,RightEye , FrontalLBP  UpperBody
burunTespiti = vision.CascadeObjectDetector('Nose','UseROI',true);
burunCevresi = step(burunTespiti,videoFrame,yuzCerceve(1,:));

tracker = vision.HistogramBasedTracker;
initializeObject(tracker,hue,burunCevresi(1,:));

videoBilgileri = info(fileReader);

videoPlayer = vision.VideoPlayer('Position', [300 300 videoBilgileri.VideoSize+30]);

while ~isDone(fileReader)
    
    videoFrame = step(fileReader);
    [hue,~,~] = rgb2hsv(videoFrame);
    
    yuzCevresi = step(tracker,hue);
    cikisVideosu = insertObjectAnnotation(videoFrame,'rectangle',yuzCevresi,'Yuz');
    step(videoPlayer,cikisVideosu)
end
release(fileReader);
release(videoPlayer);



