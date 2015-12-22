function images = PlacePatch(Image, ImageSeam, metaData, patch, r, c, x, y, overlapDim)
    imageDim = size(Image);
    dim = size(patch);
    if r == 1
        % Top Left cornor: Just place patch
        if c == 1
            for row = r : (dim(1) + r - 1)
               Image(row , c : (dim(2) + c - 1)) = patch(row - r + 1, 1 : dim(2));
               ImageSeam(row, c : (dim(2) + c - 1)) = patch(row - r + 1, 1 : dim(2));
            end
        % Top row: Only overlap on left of patch
        else
            % Merge overlap
            overlaps = VerticalSeamFind(GetSectionFromMatrix(Image, r, c, overlapDim(1), overlapDim(2)), GetSectionFromMatrix(patch, 1, 1, overlapDim(1), overlapDim(2)), metaData, x, y, r, c);
            % Get return values
            overlap = overlaps{1};
            overlapSeam = overlaps{2};
            metaData = overlaps{3};
            % Ensure patch placement doesn't go over image length
            if c + dim(2) >= imageDim(2)
                colLimit = imageDim(2);
                patchColLimit = dim(2) - (c + dim(2) - imageDim(2));
            else
                colLimit = (dim(2) + c);
                patchColLimit = dim(2);
            end
            % Place patch including new merged overlap
            for row = r : (dim(1) + r - 1)
               Image(row, c : c + overlapDim(2) - 1) = overlap(row - r + 1, 1 : overlapDim(2));
               ImageSeam(row, c : c + overlapDim(2) - 1) = overlapSeam(row - r + 1, 1 : overlapDim(2));
               Image(row, c + overlapDim(2) : colLimit) = patch(row - r + 1, overlapDim(2) : patchColLimit);
               ImageSeam(row, c + overlapDim(2) : colLimit) = patch(row - r + 1, overlapDim(2) : patchColLimit);
            end
        end
    else
        % First Column: Only overlap on top of patch
        if c == 1
            % Merge overlap
            overlaps = HorizontalSeamFind(GetSectionFromMatrix(Image, r, c, overlapDim(2), overlapDim(1)), GetSectionFromMatrix(patch, 1, 1, overlapDim(2), overlapDim(1)), metaData, x, y, r, c);
            % Get return values
            overlap = overlaps{1};
            overlapSeam = overlaps{2};
            metaData = overlaps{3};
            % Ensure patch placement doesn't go over image length
            if r + overlapDim(2) >= imageDim(1)
                rowLimit = imageDim(1);
            else
                rowLimit = r + overlapDim(2) - 1;
            end
            % Place overlap
            for row = r : rowLimit
               Image(row, c : c + overlapDim(1) - 1) = overlap(row - r + 1, 1 : overlapDim(1));
               ImageSeam(row, c : c + overlapDim(1) - 1) = overlapSeam(row - r + 1, 1 : overlapDim(1));
            end
            % Ensure patch placement doesn't go over image length
            if r + dim(1) >= imageDim(1)
                rowLimit = imageDim(1);
            else
                rowLimit = (dim(1) + r - 1);
            end
            % Place rest of patch
            for row = r + overlapDim(2) - 1 : rowLimit
               Image(row, c : (dim(2) + c - 1)) = patch(row - r + 1, 1 : dim(2));
               ImageSeam(row, c : (dim(2) + c - 1)) = patch(row - r + 1, 1 : dim(2));
            end
        % General Case: Overlap on top and left of patch
        else  
            % Merge vertical overlap
            overlaps = VerticalSeamFind(GetSectionFromMatrix(Image, r, c, overlapDim(1), overlapDim(2)), GetSectionFromMatrix(patch, 1, 1, overlapDim(1), overlapDim(2)), metaData, x, y, r, c);
            % Get return values
            overlap = overlaps{1};
            overlapSeam = overlaps{2};
            metaData = overlaps{3};
            % Ensure patch placement doesn't go over image length
            if r + overlapDim(1) >= imageDim(1)
                rowLimit = imageDim(1);
            else
                rowLimit = r + overlapDim(1) - 1;
            end
            if c + overlapDim(2) >= imageDim(2)
                colLimit = imageDim(2);
                patchColLimit = imageDim(2) - c + 1;
            else
                colLimit = c + overlapDim(2) - 1;
                patchColLimit = overlapDim(2);
            end
            % Place vertical overlap
            for row = r : rowLimit
               Image(row , c : colLimit) = overlap(row - r + 1, 1 : patchColLimit);
               ImageSeam(row , c : colLimit) = overlapSeam(row - r + 1, 1 : patchColLimit);
            end     
            % Merge horizontal overlap
            overlaps = HorizontalSeamFind(GetSectionFromMatrix(Image, r, c, overlapDim(2), overlapDim(1)), GetSectionFromMatrix(patch, 1, 1, overlapDim(2), overlapDim(1)), metaData, x, y, r, c);
            % Get return values
            overlap = overlaps{1};
            overlapSeam = overlaps{2};
            metaData = overlaps{3};
            % Ensure patch placement doesn't go over image length
            if r + overlapDim(2) >= imageDim(1)
                rowLimit = imageDim(1);
            else
                rowLimit = r + overlapDim(2) - 1;
            end
            if c + overlapDim(1) >= imageDim(2)
                colLimit = imageDim(2);
                patchColLimit = imageDim(2) - c + 1;
            else
                colLimit = c + overlapDim(1) - 1;
                patchColLimit = overlapDim(1);
            end
            % Place horizontal overlap
            for row = r : rowLimit
               Image(row, c : colLimit) = overlap(row - r + 1, 1 : patchColLimit);
               ImageSeam(row, c : colLimit) = overlapSeam(row - r + 1, 1 : patchColLimit);
            end    
            % Ensure patch placement doesn't go over image length
            if r + dim(1) >= imageDim(1)
                rowLimit = imageDim(1);
            else
                rowLimit = dim(1) + r - 1;
            end
            if c + dim(2) >= imageDim(2)
                colLimit = imageDim(2);
                patchColLimit = imageDim(2) - c;
            else
                colLimit = dim(2) + c;
                patchColLimit = dim(2);
            end
            % Place rest of patch
            for row = r + overlapDim(2) - 1 : rowLimit
               Image(row, c + overlapDim(2) : colLimit) = patch(row - r + 1, overlapDim(2) : patchColLimit);
               ImageSeam(row, c + overlapDim(2) : colLimit) = patch(row - r + 1, overlapDim(2) : patchColLimit);
            end
        end
    end
    images = {Image, ImageSeam, metaData};
end

function overlaps = VerticalSeamFind(imageOverlap, patchOverlap, metaData, x, y, r, c)
    % Pre-compute the difference in the overlap for the seam finding
    squareDif = imageOverlap - patchOverlap;
    squareDif = squareDif.^2;
    % Find the seam
    seam = findSeamVert(squareDif);
    dim = size(imageOverlap);
    % Holds overlap
    overlap = zeros(dim(1), dim(2));
    % Holds overlap with solid color seam so its visible
    overlapSeam = zeros(dim(1), dim(2));
    % Create merged overlap.  Old on left, new patch on right
    for row = 1 : dim(1)
       for col = 1 : dim(2)
          % On seam, place new patch
          if(col == seam(row))
              overlap(row, col) = patchOverlap(row, col);
              overlapSeam(row, col) = 0;
              metaData{row + r -1, col + c - 1} = [x + row - 1, y + col - 1];
          else
              % Left of seam, place old texture
              if(col < seam(row))
                overlap(row, col) = imageOverlap(row,col);
                overlapSeam(row, col) = imageOverlap(row,col);
              % Right of seam, place new patch
              else
                overlap(row, col) = patchOverlap(row, col);
                overlapSeam(row, col) = patchOverlap(row, col);
                metaData{row + r -1, col + c - 1} = [x + row - 1, y + col - 1];
              end
          end
       end
    end
    overlaps = {overlap, overlapSeam, metaData};
end

function seam = findSeamVert(squareDif)
    dim = size(squareDif);
    seam = zeros(dim(1));
    % For each location the error is equal to the sum of the three locations below it
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
    % The minimum of the first row is the starting point of the seam we want to find
    minimum = squareDif(dim(1), 1);
    start = 1;
    for c = 1:dim(2)
        if(squareDif(dim(1), c) < minimum)
            minimum = squareDif(dim(1), c);
            start = c;
        end
    end
    seam(dim(1)) = start;
    % Find rest of seam by getting the minimum of the three locations below the previous row's seam point
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
    % Pre-compute the difference in the overlap for the seam finding
    squareDif = imageOverlap - patchOverlap;
    squareDif = squareDif.^2;
    % Find the seam
    seam = findSeamHori(squareDif);
    dim = size(imageOverlap);
    % Holds overlap
    overlap = zeros(dim(1), dim(2));
    % Holds overlap with solid color seam so its visible
    overlapSeam = zeros(dim(1), dim(2));
    % Create merged overlap.  Old above, new patch below
    for r = 1:dim(1)
       for c = 1:dim(2)
          % On seam, place new patch
          if(r == seam(c))
              overlap(r,c) = patchOverlap(r,c);%(imageOverlap(r,c) * .5) + (patchOverlap(r,c) * .5);
              overlapSeam(r,c) = 255;
              metaData{r + or - 1,c + oc - 1} = [x + r - 1, y + c - 1];
          else
              % Above of seam, place old texture
              if(r < seam(c))
                overlap(r,c) = imageOverlap(r,c);
                overlapSeam(r,c) = imageOverlap(r,c);
              % Below seam, place new patch
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
    % For each location the error is equal to the sum of the three locations below it
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
    % The minimum of the first row is the starting point of the seam we want to find
    for r = 1:dim(1)
        if(squareDif(r, dim(2)) < minimum)
            minimum = squareDif(r, dim(2));
            start = r;
        end
    end   
    seam(dim(2)) = start;
    % Find rest of seam by getting the minimum of the three locations below the previous row's seam point
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