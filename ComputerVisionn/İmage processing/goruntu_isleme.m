clc; close all; clear;

%r1 = imread("Hababam.jpg");
r1 = imread("windows.jpg");
griGoruntu= rgb2gray(r1); %gri yapma fonk.
red_chan = r1(:,:,1);
green_chan = r1(:,:,2);
blue_chan = r1(:,:,3);





figure;imshow(r1),title("Renkli");
figure; imshow(griGoruntu),title("Gri Görüntü");
figure;imshow(red_chan);
figure;imshow(green_chan);
figure;imshow(blue_chan);







