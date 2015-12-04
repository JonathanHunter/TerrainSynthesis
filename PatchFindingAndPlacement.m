
function PatchFindingAndPlacement(patchDim, overlapDim, originalImage, colorMap)
%     patchDim = [64, 64];
%     overlapDim = [64,16];
%     originalImage = double((imread('C:\Users\Jonathan\Desktop\lily2_input', 'gif')));
%     patchDim = [32, 32];
%     overlapDim = [32,8];
%     originalImage = double((imread('C:\Users\Jonathan\Desktop\olives', 'gif')));
%     patchDim = [16, 16];
%     overlapDim = [16,4];
%     originalImage = double(rgb2gray((imread('C:\Users\Jonathan\Desktop\161', 'jpeg'))));
%     minimum = min(originalImage(:));
%     maxim = max(originalImage(:));
%     originalImage = originalImage - minimum;
%     originalImage = originalImage.*(50/(maxim-minimum));
%     originalImage = originalImage.*(70/(maxim-minimum));
%     originalImage = originalImage.*(50/(maxim-minimum));
    dim = size(originalImage);
    newImage = zeros(dim(1) * 3 - 3 * overlapDim(2), dim(2) * 3 - 3 * overlapDim(2));
    newImageSeams = zeros(dim(1) * 3 - 3 * overlapDim(2), dim(2) * 3 - 3 * overlapDim(2));
    finalDim = size(newImage);
    previousPoint = cell(finalDim(1), finalDim(2));
    metaData = cell(finalDim(1), finalDim(2));
    r = 1;
    x = 1;
    y = 1;
    while r < finalDim(1)
        r / finalDim(1)
        c = 1;
        while c < finalDim(2)
            if r == 1
                if c == 1
                    x = rand * (dim(1) - patchDim(1)) + 1;
                    y = rand * (dim(2) - patchDim(2)) + 1;
                    x = int32(x);
                    y = int32(y);
                    for metaR = 1 : patchDim(1)
                       for metaC = 1 : patchDim(2)
                           metaData{metaR + r - 1, metaC + c - 1} = [x + metaR, y + metaC];
                       end
                    end
                else
                    xy = previousPoint{r, c - patchDim(2) + overlapDim(2)};
                    overlap = GetSection(originalImage, xy(1), xy(2) + patchDim(2) - overlapDim(2), overlapDim(1), overlapDim(2));
                    seed = rand * 1000;
                    SSD = SSDWithRandomEval(overlap, originalImage, xy(1), xy(2) + patchDim(2) - overlapDim(2), overlapDim(1), overlapDim(2), patchDim, seed);
                    coord = FindMin(SSD);
                    x = coord(1);
                    y = coord(2);
                    for metaR = 1 : patchDim(1)
                       for metaC = overlapDim(2) : patchDim(2)
                           metaData{metaR + r - 1, metaC + c - 1} = [x + metaR, y + metaC];
                       end
                    end
                end
            else
                if c == 1
                    xy = previousPoint{r - patchDim(1) + overlapDim(2), c};
                    overlap = GetSection(originalImage, xy(1) + patchDim(1) - overlapDim(2), xy(2), overlapDim(2), overlapDim(1));
                    seed = rand * 1000;
                    SSD = SSDWithRandomEval(overlap, originalImage, xy(1) + patchDim(1) - overlapDim(2) , xy(2), overlapDim(2), overlapDim(1), patchDim, seed);
                    coord = FindMin(SSD);
                    x = coord(1);
                    y = coord(2); 
                    for metaR = overlapDim(2) : patchDim(1)
                       for metaC = 1 : patchDim(2)
                           metaData{metaR + r - 1, metaC + c - 1} = [x + metaR, y + metaC];
                       end
                    end
                else
                    seed = rand * 1000;
                    xy = previousPoint{r, c - patchDim(2) + overlapDim(2)};
                    overlap = GetSection(originalImage, xy(1), xy(2) + patchDim(2) - overlapDim(2), overlapDim(1), overlapDim(2));
                    SSDVert = SSDWithRandomEval(overlap, originalImage, xy(1), xy(2) + patchDim(2) - overlapDim(2), overlapDim(1), overlapDim(2), patchDim, seed);
                    
                    xy = previousPoint{r - patchDim(1) + overlapDim(2), c};
                    overlap = GetSection(originalImage, xy(1) + patchDim(1) - overlapDim(2), xy(2), overlapDim(2), overlapDim(1));
                    SSDHori = SSDWithRandomEval(overlap, originalImage, xy(1) + patchDim(1) - overlapDim(2) , xy(2), overlapDim(2), overlapDim(1), patchDim, seed);
                        
                    SSD = SSDVert + SSDHori;
                        
                    coord = FindMin(SSD);
                    x = coord(1);
                    y = coord(2);
                    for metaR = overlapDim(2) : patchDim(1)
                       for metaC = overlapDim(2) : patchDim(2)
                           metaData{metaR + r - 1, metaC + c - 1} = [x + metaR, y + metaC];
                       end
                    end
                end
            end
            previousPoint{r,c} = [x,y];
            patch = GetSection(originalImage, x, y, patchDim(1), patchDim(2));
            images = PlaceSection(newImage, newImageSeams, patch, r, c, overlapDim, metaData, x, y, r, c);
            newImage = images{1};
            newImageSeams = images{2};
            metaData = images{3};
            c = c + patchDim(2) - overlapDim(2);   
        end
        r = r + patchDim(1) - overlapDim(2);
    end
    figure('Name', 'Generated_Normal_Map')
    image(newImage)
    figure('Name', 'Generated_Normal_Map_With_Seams')
    image(newImageSeams)
    newImage = newImage.*(1/50);
    imwrite(newImage,'Generated_Normal_Map.png')
    color = zeros(finalDim(1), finalDim(2));
    for r = 1 : finalDim(1)
       for c = 1 : finalDim(2)
          color(r,c) = colorMap(metaData{r,c}(1), metaData{r,c}(2));
       end
    end
    figure('Name', 'Generated_Terrain')
    image(color)
    color = color.*(1/50);
    imwrite(color,'Generated_Terrain.png')
end

function section = GetSection(Image, r, c, width, length)
    dim = size(Image);
    section = zeros(width,length);
    for i = 1:width
        x = r + i - 1;
        if x > dim(1)
            x = x - dim(1);
        end
        y = c + length - 1;
        if y > dim(2)
            y = y - dim(2);
            section(i, 1:(dim(2) - c + 1)) = Image(x, c:dim(2));
            section(i, (dim(2) - c + 2):length) = Image(x, 1:y);
        else
            section(i, 1:length) = Image(x, c:y);
        end
    end
end

function images = PlaceSection(Image, ImageSeam, patch, r, c, overlapDim, metaData, x, y, or, oc)
    image = cell(3);
    dim = size(patch);
    if r == 1
        if c > 1
            overlaps = VerticalSeamFind(GetSection(Image, r, c, overlapDim(1), overlapDim(2)), GetSection(patch, 1, 1, overlapDim(1), overlapDim(2)), metaData, x, y, or, oc);
            overlap = overlaps{1};
            overlapSeam = overlaps{2};
            metaData = overlaps{3};
            for a = r : (dim(1) + r - 1)
               Image(a,c: c + overlapDim(2) - 1) = overlap(a - r + 1, 1:overlapDim(2));
               ImageSeam(a,c: c + overlapDim(2) - 1) = overlapSeam(a - r + 1, 1:overlapDim(2));
               Image(a,c + overlapDim(2) :(dim(2)+ c )) = patch(a - r + 1, overlapDim(2):dim(2));
               ImageSeam(a,c + overlapDim(2) :(dim(2)+ c )) = patch(a - r + 1, overlapDim(2):dim(2));
            end
        else
            for a = r : (dim(1) + r - 1)
               Image(a,c:(dim(2)+ c - 1)) = patch(a - r + 1,1:dim(2));
               ImageSeam(a,c:(dim(2)+ c - 1)) = patch(a - r + 1,1:dim(2));
            end
        end
    else
        if c > 1  
            overlaps = VerticalSeamFind(GetSection(Image, r, c, overlapDim(1), overlapDim(2)), GetSection(patch, 1, 1, overlapDim(1), overlapDim(2)), metaData, x, y, or, oc);
            overlap = overlaps{1};
            overlapSeam = overlaps{2};
            metaData = overlaps{3};
            for a = r:r+overlapDim(1)-1
               Image(a ,c: c + overlapDim(2) - 1) = overlap(a - r + 1, 1:overlapDim(2));
               ImageSeam(a ,c: c + overlapDim(2) - 1) = overlapSeam(a - r + 1, 1:overlapDim(2));
            end     
            overlaps = HorizontalSeamFind(GetSection(Image, r, c, overlapDim(2), overlapDim(1)), GetSection(patch, 1, 1, overlapDim(2), overlapDim(1)), metaData, x, y, or, oc);
            overlap = overlaps{1};
            overlapSeam = overlaps{2};
            metaData = overlaps{3};
            for a = r:r+overlapDim(2)-1
               Image(a,c : c + overlapDim(1) - 1) = overlap(a - r + 1, 1 :overlapDim(1));
               ImageSeam(a,c : c + overlapDim(1) - 1) = overlapSeam(a - r + 1, 1 :overlapDim(1));
            end    
            for a = r+overlapDim(2):r+overlapDim(1)-1
                Image(a ,c + overlapDim(2) :(dim(2)+ c )) = patch(a - r + 1, overlapDim(2):dim(2));
                ImageSeam(a ,c + overlapDim(2) :(dim(2)+ c )) = patch(a - r + 1, overlapDim(2):dim(2));
            end
        else
            overlaps = HorizontalSeamFind(GetSection(Image, r, c, overlapDim(2), overlapDim(1)), GetSection(patch, 1, 1, overlapDim(2), overlapDim(1)), metaData, x, y, or, oc);
            overlap = overlaps{1};
            overlapSeam = overlaps{2};
            metaData = overlaps{3};
            for a = r:r+overlapDim(2)-1
               Image(a,c: c + overlapDim(1) - 1) = overlap(a - r + 1, 1:overlapDim(1));
               ImageSeam(a,c: c + overlapDim(1) - 1) = overlapSeam(a - r + 1, 1:overlapDim(1));
            end            
            for a = r+overlapDim(2)-1 : (dim(1) + r - 1)
               Image(a,c:(dim(2)+ c - 1)) = patch(a - r + 1,1:dim(2));
               ImageSeam(a,c:(dim(2)+ c - 1)) = patch(a - r + 1,1:dim(2));
            end
        end
    end
    
%     for x = r : (dim(1) + r - 1)
%        if c > 1
%            Image(x,c: c + overlapDim(2) - 1) = Blend(Image(x,c: c + overlapDim(2) - 1), patch(x - r + 1, 1:overlapDim(2)));
%            Image(x,c + overlapDim(2) - 1 :(dim(2)+ c - 1)) = patch(x - r + 1, overlapDim(2):dim(2));
%        else 
%            Image(x,c:(dim(2)+ c - 1)) = patch(x - r + 1,1:dim(2));
%        end
%     end
    images = {Image, ImageSeam, metaData};
end

function blended = Blend(ImageRow, patchRow)
    width = size(ImageRow);
    blended = zeros(1, width(2));
    for a = 1:width(2)
        blended(1,a) = ImageRow(a)*(1-a/width(2)) + patchRow(a)*(a/width(2));
    end
end

function overlaps = VerticalSeamFind(imageOverlap, patchOverlap, metaData, x, y, or, oc)
    overlaps = cell(3);
    squareDif = imageOverlap - patchOverlap;
    squareDif = squareDif.^2;
    seam = findSeamVert(squareDif);
    dim = size(imageOverlap);
    overlap = zeros(dim(1), dim(2));
    overlapSeam = zeros(dim(1), dim(2));
    for r = 1:dim(1)
       for c = 1:dim(2)
          if(c == seam(r))
              overlap(r,c) = patchOverlap(r,c);%(imageOverlap(r,c) * .5) + (patchOverlap(r,c) * .5);
              overlapSeam(r,c) = 0;
              metaData{r + or -1, c + oc - 1} = [x + r - 1, y + c - 1];
          else
              if(c < seam(r))
                overlap(r,c) = imageOverlap(r,c);
                overlapSeam(r,c) = imageOverlap(r,c);
              else
                overlap(r,c) = patchOverlap(r,c);
                overlapSeam(r,c) = patchOverlap(r,c);
                metaData{r + or -1, c + oc - 1} = [x + r - 1, y + c - 1];
              end
          end
       end
    end
    overlaps = {overlap, overlapSeam, metaData};
end

function seam = findSeamVert(squareDif)
    dim = size(squareDif);
    seam = zeros(dim(1));
    for r = 2:dim(1)
       for c = 1:dim(2)
           if(c==1)
               squareDif(r,c) = squareDif(r,c) + min([squareDif(r-1, c), squareDif(r-1,c+1)]);
           else
               if(c==dim(2))
                    squareDif(r,c) = squareDif(r,c) + min([squareDif(r-1, c), squareDif(r-1,c-1)]);
               else 
                    squareDif(r,c) = squareDif(r,c) + min([squareDif(r-1, c), squareDif(r-1,c-1), squareDif(r-1,c+1)]);
               end
           end
       end
    end
    minimum = squareDif(dim(1), 1);
    start = 1;
    for c = 1:dim(2)
        if(squareDif(dim(1), c) < minimum)
            minimum = squareDif(dim(1), c);
            start = c;
        end
    end
    
    seam(dim(1)) = start;
    
    for r = dim(1) - 1 : -1 : 1
        minimum = squareDif(r, seam(r+1));
        seam(r) = seam(r+1);
        if seam(r+1) > 1 && minimum > squareDif(r, seam(r+1)-1)
            minimum = squareDif(r, seam(r+1)-1);
            seam(r) = seam(r+1)-1;
        end
        if seam(r+1) < dim(2) && minimum > squareDif(r, seam(r+1)+1)
            seam(r) = seam(r+1)+1;
        end
    end
end

function overlaps = HorizontalSeamFind(imageOverlap, patchOverlap, metaData, x, y, or, oc)
    overlaps = cell(3);
    squareDif = imageOverlap - patchOverlap;
    squareDif = squareDif.^2;
    seam = findSeamHori(squareDif);
    dim = size(imageOverlap);
    overlap = zeros(dim(1), dim(2));
    overlapSeam = zeros(dim(1), dim(2));
    for r = 1:dim(1)
       for c = 1:dim(2)
          if(r == seam(c))
              overlap(r,c) = patchOverlap(r,c);%(imageOverlap(r,c) * .5) + (patchOverlap(r,c) * .5);
              overlapSeam(r,c) = 255;
              metaData{r + or - 1,c + oc - 1} = [x + r - 1, y + c - 1];
          else
              if(r < seam(c))
                overlap(r,c) = imageOverlap(r,c);
                overlapSeam(r,c) = imageOverlap(r,c);
              else
                overlap(r,c) = patchOverlap(r,c);
                overlapSeam(r,c) = patchOverlap(r,c);
                metaData{r + or - 1, c + oc - 1} = [x + r - 1, y + c - 1];
              end
          end
       end
    end
    overlaps = {overlap, overlapSeam, metaData};
end

function seam = findSeamHori(squareDif)
    dim = size(squareDif);
    seam = zeros(dim(1));
    for c = 2:dim(2)
       for r = 1:dim(1)
           if(r==1)
               squareDif(r,c) = squareDif(r,c) + min([squareDif(r, c - 1), squareDif(r+1,c-1)]);
           else
               if(r==dim(1))
                    squareDif(r,c) = squareDif(r,c) + min([squareDif(r, c-1), squareDif(r-1,c-1)]);
               else 
                    squareDif(r,c) = squareDif(r,c) + min([squareDif(r, c-1), squareDif(r-1,c-1), squareDif(r+1,c-1)]);
               end
           end
       end
    end
    minimum = squareDif(dim(1), 1);
    start = 1;
    for r = 1:dim(1)
        if(squareDif(r, dim(2)) < minimum)
            minimum = squareDif(r, dim(2));
            start = r;
        end
    end
    
    seam(dim(2)) = start;
    
    for c = dim(2) - 1 : -1 : 1
        minimum = squareDif(seam(c+1), c);
        seam(c) = seam(c+1);
        if seam(c+1) > 1 && minimum > squareDif(seam(c+1)-1, c)
            minimum = squareDif(seam(c+1)-1, c);
            seam(c) = seam(c+1)-1;
        end
        if seam(c+1) < dim(1) && minimum > squareDif(seam(c+1)+1, c)
            seam(c) = seam(c+1)+1;
        end
    end
end

function coord = FindMin(SSD)
    dim = size(SSD);
    min = 255;
    coord =[1,1];
    for r = 1:dim(1)
        for c = 1:dim(2)
            if SSD(r,c) < min
               min = SSD(r,c);
               coord = [r,c];
            end
        end
    end
end