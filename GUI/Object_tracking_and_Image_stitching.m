function varargout = Object_tracking_and_Image_stitching(varargin)
clc;
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Object_tracking_and_Image_stitching_OpeningFcn, ...
                   'gui_OutputFcn',  @Object_tracking_and_Image_stitching_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end

function Object_tracking_and_Image_stitching_OpeningFcn(hObject, eventdata, handles, varargin)

handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

function varargout = Object_tracking_and_Image_stitching_OutputFcn(hObject, eventdata, handles) 

varargout{1} = handles.output;

function pb_stitchimages_Callback(hObject, eventdata, handles)
%                  browsing for the image file
% [FileName,folder]=uigetfile('*.*','Select your image');
% 
% %Creating the full file name
% ImageName=fullfile(folder,FileName);
%                  browsing for the image folder
crop_folder=uigetdir('start_path','path for loading unstitched images');
stitched_folder=uigetdir('start_path','path for saving stitched images');

d=dir(horzcat(crop_folder,'\*.jpg'));
nn=size(d,1);
nn=nn/2;
clear d;
set(handles.text4,'string','Left Image');
set(handles.text1,'string','Right Image');

for n=1:1:nn
    
    try
        I01=imread(horzcat(crop_folder,'\a',num2str(n,'%03d'),'.jpg'));
    catch err
        if n>=nn
            break;
        else
            continue;
        end
    end
   
    axes(handles.ax_leftimage);   imshow(I01);
    pause(0.1);
    
    try
        I02=imread(horzcat(crop_folder,'\b',num2str(n,'%03d'),'.jpg'));
    catch err
        if n>=nn
            break;
        else
            continue;
        end
    end
    
    axes(handles.ax_rightimage);   imshow(I02);
    
    I1=rgb2gray(I01);
    I2=rgb2gray(I02);
    
    % I1_dash = downsample(I1,2);
    % I2_dash = downsample(I2,2);
    
    I1_dash = I1;
    I2_dash = I2;
    
    [m1 n1 d1]=size(I1_dash);
    [m2 n2 d2]=size(I2_dash);
    
    %figure;imshow(I2)
    for i=1:1:360
        I2_dash_rot=imrotate(I2_dash,i);
        
        FI1_dash=fft2(double(I1_dash),m1+m2-1,n1+n2-1);
        FI2_dash_rot=fft2(double(I2_dash_rot),m1+m2-1,n1+n2-1);
        
        
        Q=(FI1_dash.*conj(FI2_dash_rot))./(abs(FI1_dash.*conj(FI2_dash_rot)));
        
        q=ifft2(double(Q),m1+m2-1,n1+n2-1);
        i;
        
        [qx qy]=find(q==max(max(q)));
        peak(1,i)=max(max(q));
    end
    
    [peakx theeta_dash]=find(peak==max(peak));
    
    I2_rot=imrotate(I2_dash_rot,theeta_dash);
    %figure; imshow(I1)
    %figure; imshow(I2_rot)
    [r1 c1 dd1] = size(I1);
    [r2 c2 dd2] = size(I2_rot);
    
    F1 = fftshift(fft2(double(I1),r1+r2-1,c1+c2-1));
    F2 = fftshift(fft2(double(I2_rot),r1+r2-1,c1+c2-1));
    
    F = F1.*conj(F2);
    F = F./abs(F);
    
    p = (ifft2(F));
    
    [px py]=find(p==max(max(p)));
    
    if (I1(1,1)==I2_rot(end-px,end-py))
        img = zeros(r2-px+r1,c2-py+c1);
        img=cast(img,'uint8');
        img(1:r2,1:c2,:)=I2_rot;
        img(r2-px:r2-px+r1-1,c2-py:c2-py+c1-1,:)=I1;
    else
        img = zeros(px+r2,py+c2);
        img=cast(img,'uint8');
        img(1:r1,1:c1,:)=I1;
        img(px:px+r2-1,py:py+c2-1,:)=I2_rot;
    end
    
    
    axes(handles.ax_result);
    imshow(img);
    movie1(n)=getframe;
    imwrite(img, horzcat(stitched_folder,'\T (',num2str(n,'%d'),').jpg'));
end
set(handles.text4,'string','Image 2');
set(handles.text1,'string','Image 1');
pause(2);
figure('units','normalized','outerposition',[0 0 1 1]);
set(gcf,'Color', 'white')
text(0.2,0.6,'Stitching is complete!!','fontsize',50,'color','r');
text(0.2,0.4,'see the results','fontsize',50,'color','r');
set(gca,'Color','white');
set(gca,'XColor','white');
set(gca,'YColor','white');
pause(1.5);
close all;
% --- Executes on button press in pb_track_via_st_im.

function pb_track_via_st_im_Callback(hObject, eventdata, handles)
% hObject    handle to pb_track_via_st_im (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

egg_images=uigetdir('start_path','path for loading stitched images');
a=imread(horzcat(egg_images,'\T (1).jpg'));

set(handles.text1,'string','Original Sequence');
d=dir(horzcat(egg_images,'\*.jpg'));
nn=size(d,1);
clear d;
set(handles.text1,'string','Original Sequence');

for n=2:1:nn
      try
        bb = imread(horzcat(egg_images,'\T (',num2str(n,'%3d'),').jpg'));
      catch err
          if n >= nn
              break;
          else
              continue;
          end
      end
      
      axes(handles.ax_rightimage);imshow(bb,'border','tight','InitialMagnification','fit');
      
      I1=bb; %I2=I;
      I2=uint8(a);
      I1=uint8(I1);
      I=I1-I2;
      I1 = im2bw(I,0.2);
      I = bwareaopen(I1,2000,8);
      BB=regionprops(I,'Boundingbox');
      BB1=struct2cell(BB);
      BB2=cell2mat(BB1);
      [s1 s2]=size(BB2);
      mx=0;
      for k=3:4:s2-1
          p=BB2(1,k)*BB2(1,k+1);
          if p>mx & (BB2(1,k)/BB2(1,k+1))<20
              mx=p;
              j=k;
          end
      end
     
      axes(handles.ax_result);imshow(bb,'border','tight','InitialMagnification','fit');
      
      hold on;
      try
          rectangle('Position',[BB2(1,j-2),BB2(1,j-1),BB2(1,j),BB2(1,j+1)],'EdgeColor','r','LineWidth',3,'Linestyle','--');
      catch err
          continue;
      end
      I1=bb; %I2=I;
      
      I1=uint8(I1);
      I=I1-I2;
      I1 = im2bw(I,0.4); % converting image to binary
      P = bwareaopen(I1,2000,8);% to remove a connected component having less than
      % a specified number of connected(4,8) pixels
      P1=I1-P;
      P1 = bwareaopen(P1,1,4);
      
      BB=regionprops(P1,'Boundingbox');
      BB1=struct2cell(BB);
      BB2=cell2mat(BB1);
      [s1 s2]=size(BB2);
      mx=0;
      
      for k=3:4:s2-1
          p=BB2(1,k)*BB2(1,k+1);
          if p>mx & (BB2(1,k)/BB2(1,k+1))<20
              mx=p;
              j=k;
          end
      end
      
      try
          rectangle('Position',[BB2(1,j-2),BB2(1,j-1),BB2(1,j),BB2(1,j+1)],'EdgeColor','r','LineWidth',3,'Linestyle','--');
      catch err
          continue;
      end  % end try/catch
      hold off ;
      pause(0.2);
end


set(handles.text1,'string','Image 1');
pause(2);
figure('units','normalized','outerposition',[0 0 1 1]);
set(gcf,'Color', 'white')
text(0.3,0.6,'End of Sequence!!','fontsize',50,'color','r');
set(gca,'Color','white');
set(gca,'XColor','white');
set(gca,'YColor','white');
pause(1.5);
% --- Executes on button press in pb_anttrack_video.

function pb_anttrack_video_Callback(hObject, eventdata, handles)
% hObject    handle to pb_anttrack_video (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%set(handles.ax_rightimage,'String','sdfsdfsdfsd');
ant_sequence=uigetfile('start_path','path for loading ant video');
ant = VideoReader(ant_sequence);

nFrames = ant.NumberOfFrames;
vidHeight = ant.Height;
vidWidth = ant.Width;

for k = 1 : nFrames
    mov(k).cdata = read(ant, k);
 %   imshow(mov(k).cdata);
%    pause(0.1);
end

a=mov(1).cdata;
Original_Image=a;
a = rgb2gray(a);
for n=2:1:nFrames

   bb=mov(n).cdata;
   axes(handles.ax_rightimage);
    %subplot(1,2,1);
    imshow(bb);
    b = rgb2gray(bb);
    
    I1=b; %I2=I;
    I2=uint8(a);
    I1=uint8(I1);
    clear I;
    clear b;
    I=I2-I1;
    
    I = im2bw(I,0.2); % converting image to binary
    % imshow(I);
    % pause;
    %also try to calculate the threshold value
    I = bwareaopen(I,10,8);% to remove a connected component having less than
    % a specified number of connected(4,8) pixels
    
    BB=regionprops(I,'Boundingbox');
    BB1=struct2cell(BB);
    BB2=cell2mat(BB1);
    [s1 s2]=size(BB2);
    mx=0;
    for k=3:4:s2-1
        p=BB2(1,k)*BB2(1,k+1);
        if p>mx & (BB2(1,k)/BB2(1,k+1))<20
            mx=p;
            j=k;
        end
    end
    
    %pause;
    % to save images only:x=figure;
    
    axes(handles.ax_result);
    %subplot(1,2,2);
    imshow(bb);title('Result','fontsize',20);title('Original Sequence','fontsize',20);
    
    %set(x,'Position',[0 0 screensize(3) screensize(4)]); to display full screen
    hold on;
    try
        rectangle('Position',[BB2(1,j-2),BB2(1,j-1),BB2(1,j),BB2(1,j+1)],'EdgeColor','r','LineWidth',2,'Linestyle','-');
    catch err
        continue;
    end
        hold off ;
    %to save images only:print(x, '-r80', '-dbitmap',horzcat('E:\Waleed\DIP Project\Tracked images\T (',num2str(n,'%3d'),').jpg'));
    %pause(0.5); remove comment if you don't want "getframe"
end
set(handles.text1,'string','Image 1');
pause(2);
figure('units','normalized','outerposition',[0 0 1 1]);
set(gcf,'Color', 'white')
text(0.3,0.6,'End of Sequence!!','fontsize',50,'color','r')
set(gca,'Color','white');
set(gca,'XColor','white');
set(gca,'YColor','white');
pause(1.5);
% --- Executes on button press in pb_anttrack_images.

function pb_anttrack_images_Callback(hObject, eventdata, handles)
% hObject    handle to pb_anttrack_images (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ant_images=uigetdir('start_path','path for loading ant sequence images');
%screensize=get(0,'ScreenSize');
%set(handles.ax_rightimage,'String','Original Sequence');
a=imread(horzcat(ant_images,'\T.jpg'));
a = rgb2gray(a);
%figure('units','normalized','outerposition',[0 0 1 1]);%To mkae the figure full screen

set(handles.text1,'string','Original Sequence');
d=dir(horzcat(ant_images,'\*.jpg'));
nn=size(d,1);
clear d;

for n=1:1:nn    
    
    try
        bb = imread(horzcat(ant_images,'\T (',num2str(n,'%3d'),').jpg'));
    catch err
        if n >= nn
            break
        end
    end
        
    axes(handles.ax_rightimage);
    imshow(bb);
    b = rgb2gray(bb);
    
    I1=b; %I2=I;
    I2=uint8(a);
    I1=uint8(I1);
    clear I;
    clear b;
    I=I2-I1;
    
    I = im2bw(I,0.2); % converting image to binary
    % imshow(I);
    % pause;
    %also try to calculate the threshold value
    I = bwareaopen(I,10,8);% to remove a connected component having less than
    % a specified number of connected(4,8) pixels
    
    %P = bwlable(I,8);% returns a matrix P, of the same size as O, containing labels for the connected
    % objects in O. The variable 8 can have a value of either 4 or 8, where 4 specifies
    % it defaults to 8.
    BB=regionprops(I,'Boundingbox');
    BB1=struct2cell(BB);
    BB2=cell2mat(BB1);
    [s1 s2]=size(BB2);
    mx=0;
    for k=3:4:s2-1
        p=BB2(1,k)*BB2(1,k+1);
        if p>mx & (BB2(1,k)/BB2(1,k+1))<20
            mx=p;
            j=k;
        end
    end
    
    axes(handles.ax_rightimage);
    subplot(1,2,2);imshow(bb)%,'border','tight','InitialMagnification','fit');
    %title('Result','fontsize',20);
    
    %set(x,'Position',[0 0 screensize(3) screensize(4)]); to display full screen
    hold on;
    try
        rectangle('Position',[BB2(1,j-2),BB2(1,j-1),BB2(1,j),BB2(1,j+1)],'EdgeColor','r','LineWidth',2,'Linestyle','-');
    catch err
        continue
    end
   % movie1(n)=getframe;
    hold off ; 
    %to save images only:print(x, '-r80', '-dbitmap',horzcat('E:\Waleed\DIP Project\Tracked images\T (',num2str(n,'%3d'),').jpg'));
    %pause(0.5); remove comment if you don't want "getframe"
end

%Displaying as movie
%pause;
%movie(movie1,2);
set(handles.text1,'string','Image 1');
pause(2);
figure('units','normalized','outerposition',[0 0 1 1]);
set(gcf,'Color', 'white')
text(0.3,0.6,'End of Sequence!!','fontsize',50,'color','r')
set(gca,'Color','white');
set(gca,'XColor','white');
set(gca,'YColor','white');
pause(1);
close all;
% --- Executes on button press in pb_cartrack_images.

function pb_cartrack_images_Callback(hObject, eventdata, handles)
% hObject    handle to pb_cartrack_images (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%clc;
%close all;
car_images=uigetdir('start_path','path for loading car sequence');
a=imread(horzcat(car_images,'\T.jpg'));
a = rgb2gray(a);

d=dir(horzcat(car_images,'\*.jpg'));
nn=size(d,1);
clear d;

set(handles.text1,'string','Original Sequence');


for n=1:1:nn 
    
    try
        bb = imread(horzcat(car_images,'\T (',num2str(n,'%3d'),').jpg'));
    catch err
        if n>= nn
            break;
        else
            continue
        end
    end
   axes(handles.ax_rightimage);imshow(bb);
   b = rgb2gray(bb);  
   
   I1=b; %I2=I;
   I2=uint8(a);
   I1=uint8(I1);
   clear I;
   clear b;
   I=I2-I1;
   
   I = im2bw(I,0.2); % converting image to binary
   % imshow(I);
   % pause;
   %also try to calculate the threshold value
   I = bwareaopen(I,10,8);% to remove a connected component having less than
   % a specified number of connected(4,8) pixels
   
   %P = bwlable(I,8);% returns a matrix P, of the same size as O, containing labels for the connected
   % objects in O. The variable 8 can have a value of either 4 or 8, where 4 specifies
   % it defaults to 8.
   BB=regionprops(I,'Boundingbox');
   BB1=struct2cell(BB);
   BB2=cell2mat(BB1);
   [s1 s2]=size(BB2);
   mx=0;
   for k=3:4:s2-1
       p=BB2(1,k)*BB2(1,k+1);
       if p>mx & (BB2(1,k)/BB2(1,k+1))<20
           mx=p;
           j=k;
       end
   end
   
   %pause;
   % to save images only:x=figure;
  
   axes(handles.ax_result);imshow(bb,'border','tight','InitialMagnification','fit');
     
  hold on;
  try
   rectangle('Position',[BB2(1,j-2),BB2(1,j-1),BB2(1,j),BB2(1,j+1)],'EdgeColor','r','LineWidth',3,'Linestyle','--');
  catch err
      continue;
  end
      
   % movie1(n)=getframe;
   hold off ; 
   %to save images only:print(x, '-r80', '-dbitmap',horzcat('E:\Waleed\DIP Project\Tracked images\T (',num2str(n,'%3d'),').jpg'));
   %pause(0.5); remove comment if you don't want "getframe"
end

%Displaying as movie
%pause;
%movie(movie1,2);
set(handles.text1,'string','Image 1');
pause(2);
figure('units','normalized','outerposition',[0 0 1 1]);
set(gcf,'Color', 'white')
text(0.3,0.6,'End of Sequence!!','fontsize',45,'color','r')
set(gca,'Color','white');
set(gca,'XColor','white');
set(gca,'YColor','white');
pause(1.5);
set(handles.text1,'string','Image 1');
close all;
% --- Executes on button press in pb_cartrack_video.

function pb_cartrack_video_Callback(hObject, eventdata, handles)
% hObject    handle to pb_cartrack_video (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

car_sequence=uigetfile('start_path','path for loading car_sequence');
car = VideoReader(car_sequence);

nFrames = car.NumberOfFrames;
vidHeight = car.Height;
vidWidth = car.Width;

set(handles.text1,'string','Original Sequence');

mov(1).cdata = read(car, 1);
a=mov(1).cdata;
Original_Image=a;
a = rgb2gray(a);

for n = 2:1:nFrames
   mov(n).cdata = read(car, n);
   bb = mov(n).cdata;
   axes(handles.ax_rightimage);imshow(bb);
   b = rgb2gray(bb);
   pause(0.1);
   
   I1=b; %I2=I;
   
   I2=uint8(a);
   I1=uint8(I1);
   clear I;
   clear b;
   I=I2-I1;
   
   I = im2bw(I,0.2); % converting image to binary
   %also try to calculate the threshold value
   I = bwareaopen(I,10,8);% to remove a connected component having less than
                          % a specified number of connected(4,8) pixels
   
   %P = bwlable(I,8);% returns a matrix P, of the same size as O, containing labels for the connected
                     % objects in O. The variable 8 can have a value of either 4 or 8, where 4 specifies
                     % it defaults to 8.
   BB=regionprops(I,'Boundingbox');
   BB1=struct2cell(BB);
   BB2=cell2mat(BB1);
   [s1 s2]=size(BB2);
   mx=0;
   for k=3:4:s2-1
       p=BB2(1,k)*BB2(1,k+1);
       if p>mx & (BB2(1,k)/BB2(1,k+1))<20
           mx=p;
           j=k;
       end
   end   
   
   axes(handles.ax_result); imshow(bb,'border','tight','InitialMagnification','fit'); 
   hold on;
   
   try
       rectangle('Position',[BB2(1,j-2),BB2(1,j-1),BB2(1,j),BB2(1,j+1)],'EdgeColor','r','LineWidth',3,'Linestyle','--');
   catch  err
       continue;
   end    
   hold off ; 
   %to save images only:print(x, '-r80', '-dbitmap',horzcat('E:\Waleed\DIP Project\Tracked images\T (',num2str(n,'%3d'),').jpg'));
   %pause(0.5); remove comment if you don't want "getframe"
end

pause(2);
figure('units','normalized','outerposition',[0 0 1 1]);
set(gcf,'Color', 'white')
text(0.3,0.6,'End of Sequence!!','fontsize',50,'color','r')
set(gca,'Color','white');
set(gca,'XColor','white');
set(gca,'YColor','white');
pause(1.5);
set(handles.text1,'string','Image 1');
close all;
% --- Executes on button press in pb_oneegg_track.

function pb_oneegg_track_Callback(hObject, eventdata, handles)
% hObject    handle to pb_oneegg_track (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
egg_images=uigetdir('start_path','path for loading car sequence');
a=imread(horzcat(egg_images,'\T (1).jpg'));
Original_Image=a;
a = rgb2gray(a);

set(handles.text1,'string','Original Sequence');
d=dir(horzcat(egg_images,'\*.jpg'));
nn=size(d,1);
clear d

for n=2:1:nn
    
    try
        bb = imread(horzcat(egg_images,'\T (',num2str(n,'%3d'),').jpg'));
    catch err
        if n >= nn
            break;
        else
            continue;
        end
    end
    
   axes(handles.ax_rightimage);imshow(bb);title('Original Sequence','fontsize',20);
   b = rgb2gray(bb);  
   
   I1=b; %I2=I;
   I2=uint8(a);
   I1=uint8(I1);
  % clear I;
   clear b;
   I=I1-I2;
   
   I = im2bw(I,0.2); % converting image to binary
   % imshow(I);
   % pause;
   %also try to calculate the threshold value
   I = bwareaopen(I,2000,8);% to remove a connected component having less than
   % a specified number of connected(4,8) pixels
   
   %P = bwlable(I,8);% returns a matrix P, of the same size as O, containing labels for the connected
   % objects in O. The variable 8 can have a value of either 4 or 8, where 4 specifies
   % it defaults to 8.
   BB=regionprops(I,'Boundingbox');
   BB1=struct2cell(BB);
   BB2=cell2mat(BB1);
   [s1 s2]=size(BB2);
   mx=0;
   for k=3:4:s2-1
       p=BB2(1,k)*BB2(1,k+1);
       if p>mx & (BB2(1,k)/BB2(1,k+1))<20
           mx=p;
           j=k;
       end
   end
   
   %pause;
   % to save images only:x=figure;
   
   %subplot(1,2,1);imshow(dd,'border','tight','InitialMagnification','fit');
   %title('ORIGINAL','fontsize',22);
   %subplot(1,2,2);
   axes(handles.ax_result);
   imshow(bb,'border','tight','InitialMagnification','fit');
   %title('RESULT','fontsize',22);
   
   %set(x,'Position',[0 0 screensize(3) screensize(4)]); to display full screen
   hold on;
   try
       rectangle('Position',[BB2(1,j-2),BB2(1,j-1),BB2(1,j),BB2(1,j+1)],'EdgeColor','r','LineWidth',3,'Linestyle','--');
   catch err
       continue;
   end
   % movie1(n)=getframe;
   hold off ; 
   %to save images only:print(x, '-r80', '-dbitmap',horzcat('E:\Waleed\DIP Project\Tracked images\T (',num2str(n,'%3d'),').jpg'));
   %pause(0.5); remove comment if you don't want "getframe"
end

%Displaying as movie
%pause;
%movie(movie1,2);
set(handles.text1,'string','Image 1');
pause(2);
figure('units','normalized','outerposition',[0 0 1 1]);
set(gcf,'Color', 'white')
text(0.3,0.6,'End of Sequence!!','fontsize',50,'color','r');
set(gca,'Color','white');
set(gca,'XColor','white');
set(gca,'YColor','white');
pause(1.5);
close all;
