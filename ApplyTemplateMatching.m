function ApplyTemplateMatching(dataFolder,resultsFolder)

% Performed template matching using one method. Use the other

folderInfo = dir(dataFolder);
folderFiles = {folderInfo.name};
findGoodSubfolders = endsWith(folderFiles, "-1");
goodSubfolders = folderFiles(findGoodSubfolders);

for i = 1:length(goodSubfolders)
    currSubfolder = goodSubfolders(i);
    
    % Import Corresponding Results file
    tempData = matfile(resultsFolder + "/Data_ICI_" + currSubfolder + ".mat");
    imTemp = getfield(tempData.Data, 'temp');
    T_Offset = getfield(tempData.Data, 'T_Offset');
    
    % Import 3 .mat files from the current subfolder
    subfolderInfo = dir(char(dataFolder + "/" + currSubfolder));
    subfolderFiles = {subfolderInfo.name};
    
    findICIFiles = startsWith(subfolderFiles, "ICI_Tmp");
    ICIFiles = subfolderFiles(findICIFiles);
    im1_file = matfile(dataFolder+ "/" + currSubfolder + "/" + ICIFiles(1));
    im2_file = matfile(dataFolder+ "/" + currSubfolder + "/" + ICIFiles(2));
    im3_file = matfile(dataFolder+ "/" + currSubfolder + "/" + ICIFiles(3));
 
    im1 = im1_file.ICI_tmp1;
    im2 = im2_file.ICI_tmp2;
    im3 = im3_file.ICI_tmp3;
    
    imAve = (im1 + im2 + im3)/3;
    imComp = imAve - T_Offset;
    
    % Perform Template Matching
    [I_SSD,I_NCC]=template_matching(imTemp,imComp);
    [y,x]=find(I_SSD==max(I_SSD(:)));
    [h,w] = size(imTemp);
    x_corner = x-((w-1)/2);
    y_corner = y-((h-1)/2);
    
    % Gather image templates and parameters
    temp1 = im1(y_corner + (0:h-1), x_corner+ (0:w-1));
    temp2 = im2(y_corner + (0:h-1), x_corner+ (0:w-1));
    temp3 = im3(y_corner + (0:h-1), x_corner+ (0:w-1));
    parms = [x_corner y_corner h w];
    
    % Update the results file
    ResultsData = tempData;
    ResultsData.Properties.Writable = true;
    ResultsData.Data = setfield(ResultsData.Data, 'temp1', temp1);
    ResultsData.Data = setfield(ResultsData.Data, 'temp2', temp2);
    ResultsData.Data = setfield(ResultsData.Data, 'temp3', temp3);
    ResultsData.Data = setfield(ResultsData.Data, 'crop_diam', parms);
    
    % Save in matfile
    save(char(resultsFolder + "/Data_ICI_" + currSubfolder + "_new.mat"), 'ResultsData');
    
    %imshow(imComp(y_corner + (0:h-1), x_corner+ (0:w-1))-imTemp,[])
    %figure, 
    %subplot(2,2,1), imshow(imComp, []); hold on; plot(x,y,'r*'); title('Result')
    %subplot(2,2,2), imshow(imTemp, []); title('The K template');
    %subplot(2,2,3), imshow(I_SSD, []); title('SSD Matching');
    %subplot(2,2,4), imshow(I_NCC, []); title('Normalized-CC');
    
end
    