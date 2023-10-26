clear; close;clc;

faceD = vision.CascadeObjectDetector("Nose","UseROI",true);
fileR = vision.VideoFileReader('WIN_20221007_14_17_05_Pro.mp4');
yuzCerceve = step(faceD,videoFrame);

videoBilgileri = info(fileReader);
videoPlayer = vision.VideoPlayer("Position",[300 300 videoBilgileri.videoSize+20]);

while ~isDone(fileReader)
   videoFrame = step(fileR);
    [hue, ~,~] = rgb2hsv(videoFrame);
    
    yuzCercevesi = step(tracker,hue);
    exitVideo = insertObjectAnnotation(videoFrame,"rectangle", yuzCerceve,"Yüz");
    step(videoPlayer,exitVideo);
end

release(fileR);
release(videoPlayer);