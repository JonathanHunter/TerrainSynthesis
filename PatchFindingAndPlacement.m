function PatchFindingAndPlacement()
    patchDim = [64,64];
    overlapDim = [64,16];
    originalImage = double((imread('C:\Users\Jonathan\Desktop\lily2_input', 'gif')));
    minimum = min(originalImage(:));
    maxim = max(originalImage(:));
    originalImage = originalImage - minimum;
    originalImage = originalImage.*(50/(maxim-minimum));
    dim = size(originalImage);
    newImage = zeros(dim(1) * 3, dim(2) * 3 - 3 * overlapDim(2));
    finalDim = size(newImage);
    r = 1;
    x = 0;
    y = 0;
    while r < finalDim(1)
        c = 1;
        while c < finalDim(2)
            if c == 1
                x = rand * dim(1) + 1;
                y = rand * dim(2) + 1;
                x = int32(x);
                y = int32(y);
            else
                overlap = GetSection(newImage, r, c, overlapDim(1), overlapDim(2));
                SSD = SSDWithAreaExclusion(overlap, originalImage, x, y + patchDim(2), overlapDim(1), overlapDim(2));
                coord = FindMin(SSD);
                x = coord(1)
                y = coord(2)
            end
            patch = GetSection(originalImage, x, y, patchDim(1), patchDim(2));
            newImage = PlaceSection(newImage, patch, r, c, overlapDim); 
            c = c + patchDim(2) - overlapDim(2);    
        end
        r = r + patchDim(1);
    end
    image(newImage)
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

function newImage = PlaceSection(Image, patch, r, c, overlapDim)
    dim = size(patch);
    for x = r : (dim(1) + r - 1)
       if c > 1
           Image(x,c: c + overlapDim(2) - 1) = Blend(Image(x,c: c + overlapDim(2) - 1), patch(x - r + 1, 1:overlapDim(2)));
           Image(x,c + overlapDim(2) - 1 :(dim(2)+ c - 1)) = patch(x - r + 1, overlapDim(2):dim(2));
       else 
           Image(x,c:(dim(2)+ c - 1)) = patch(x - r + 1,1:dim(2));
       end
    end
    newImage = Image;
end

function blended = Blend(ImageRow, patchRow)
    width = size(ImageRow);
    blended = zeros(1, width(2));
    for a = 1:width(2)
        blended(1,a) = ImageRow(a)*(1-a/width(2)) + patchRow(a)*(a/width(2));
    end
end

function coord = FindMin(SSD)
    dim = size(SSD);
    min = 255;
    coord =[0,0];
    for r = 1:dim(1)
        for c = 1:dim(2)
            if SSD(r,c) < min
               min = SSD(r,c);
               coord = [r,c];
            end
        end
    end
end