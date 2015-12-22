function PatchFindingAndPlacement(patchDim, overlapDim, originalImage, colorMap)
    % Dimensions of original image
    originalDimensions = size(originalImage);
    % Create the matrix for the normal map being generated
    generatedNormalMap = zeros(3 * (originalDimensions(1) - overlapDim(2)), 3 * (originalDimensions(2) - overlapDim(2)));
    % Create the matrix for holding the normal map with seams displayed
    generatedNormalMapWithSeams = zeros(3 * (originalDimensions(1) - overlapDim(2)), 3 * (originalDimensions(2)- overlapDim(2)));
    % Dimensions of final image
    finalDimensions = size(generatedNormalMap);
    % Matrix for holding the point on the original image used by the previous patch
    previousPoint = cell(finalDimensions(1), finalDimensions(2));
    % Matrix for holding all the points from the original image used by each patch
    metaData = cell(finalDimensions(1), finalDimensions(2));
    %Initialize data for the while loop
    r = 1;
    while r < finalDimensions(1)
        sprintf('Terrain Generation: %g%% left', 100 * (1.0 - r / finalDimensions(1)))
        c = 1;
        while c < finalDimensions(2)
            if r == 1
                % Top Left cornor: Just place patch
                if c == 1
                    % Pick first patch at random
                    x = rand * (originalDimensions(1) - patchDim(1)) + 1;
                    y = rand * (originalDimensions(2) - patchDim(2)) + 1;
                    x = int32(x);
                    y = int32(y);
                    % Place coordinates picked in metaData matrix
                    for metaR = 1 : patchDim(1)
                       for metaC = 1 : patchDim(2)
                           metaData{metaR + r - 1, metaC + c - 1} = [x + metaR, y + metaC];
                       end
                    end
                % Top row: Only overlap on left of patch
                else
                    % Get patch to compare against
                    xy = previousPoint{r, c - patchDim(2) + overlapDim(2)};
                    overlap = GetSectionFromMatrix(originalImage, xy(1), xy(2) + patchDim(2) - overlapDim(2), overlapDim(1), overlapDim(2));
                    % Calculate SSD
                    seed = rand * 1000;
                    SSD = SSDWithRandomEval(overlap, originalImage, xy(1), xy(2) + patchDim(2) - overlapDim(2), overlapDim(1), overlapDim(2), patchDim, seed);
                    % Find the point with overall minimum error
                    coord = FindMinCoordinate(SSD);
                    x = coord(1);
                    y = coord(2);
                    % Place coordinates picked in metaData matrix
                    for metaR = 1 : patchDim(1)
                       for metaC = overlapDim(2) : patchDim(2)
                           metaData{metaR + r - 1, metaC + c - 1} = [x + metaR, y + metaC];
                       end
                    end
                end
            else
                % First Column: Only overlap on top of patch
                if c == 1
                    % Get patch to compare against
                    xy = previousPoint{r - patchDim(1) + overlapDim(2), c};
                    overlap = GetSectionFromMatrix(originalImage, xy(1) + patchDim(1) - overlapDim(2), xy(2), overlapDim(2), overlapDim(1));
                    % Calculate SSD
                    seed = rand * 1000;
                    SSD = SSDWithRandomEval(overlap, originalImage, xy(1) + patchDim(1) - overlapDim(2) , xy(2), overlapDim(2), overlapDim(1), patchDim, seed);
                    % Find the point with overall minimum error
                    coord = FindMinCoordinate(SSD);
                    x = coord(1);
                    y = coord(2); 
                    % Place coordinates picked in metaData matrix
                    for metaR = overlapDim(2) : patchDim(1)
                       for metaC = 1 : patchDim(2)
                           metaData{metaR + r - 1, metaC + c - 1} = [x + metaR, y + metaC];
                       end
                    end
                % General Case: Overlap on top and left of patch
                else
                    seed = rand * 1000;
                    % Get left patch to compare against
                    xy = previousPoint{r, c - patchDim(2) + overlapDim(2)};
                    overlap = GetSectionFromMatrix(originalImage, xy(1), xy(2) + patchDim(2) - overlapDim(2), overlapDim(1), overlapDim(2));
                    % Calculate SSD
                    SSDVert = SSDWithRandomEval(overlap, originalImage, xy(1), xy(2) + patchDim(2) - overlapDim(2), overlapDim(1), overlapDim(2), patchDim, seed);
                    % Get top patch to compare against
                    xy = previousPoint{r - patchDim(1) + overlapDim(2), c};
                    overlap = GetSectionFromMatrix(originalImage, xy(1) + patchDim(1) - overlapDim(2), xy(2), overlapDim(2), overlapDim(1));
                    % Calculate SSD
                    SSDHori = SSDWithRandomEval(overlap, originalImage, xy(1) + patchDim(1) - overlapDim(2) , xy(2), overlapDim(2), overlapDim(1), patchDim, seed);
                    % Combine the two SSD matrices
                    SSD = SSDVert + SSDHori;
                    % Find the point with overall minimum error
                    coord = FindMinCoordinate(SSD);
                    x = coord(1);
                    y = coord(2);                    
                    % Place coordinates picked in metaData matrix
                    for metaR = overlapDim(2) : patchDim(1)
                       for metaC = overlapDim(2) : patchDim(2)
                           metaData{metaR + r - 1, metaC + c - 1} = [x + metaR, y + metaC];
                       end
                    end
                end
            end
            % Save point for use later
            previousPoint{r,c} = [x,y];
            % Get texture data for this patch
            patch = GetSectionFromMatrix(originalImage, x, y, patchDim(1), patchDim(2));
            % Place Patch on final image (includes seam finding and overlap merging)
            images = PlacePatch(generatedNormalMap, generatedNormalMapWithSeams, metaData, patch, r, c, x, y, overlapDim);
            % Get return values
            generatedNormalMap = images{1};
            generatedNormalMapWithSeams = images{2};
            metaData = images{3};
            c = c + patchDim(2) - overlapDim(2);   
        end
        r = r + patchDim(1) - overlapDim(2);
    end
    sprintf('Terrain Generation complete!')
    % Generate figures and write out files
    figure('Name', 'Generated_Normal_Map')
    image(generatedNormalMap)
    figure('Name', 'Generated_Normal_Map_With_Seams')
    image(generatedNormalMapWithSeams)
    generatedNormalMap = generatedNormalMap.*(1/64);
    imwrite(generatedNormalMap,'Generated_Normal_Map.png')
    % Use metaData to construct a color version of the generated terrain
    color = uint8(zeros(finalDimensions(1), finalDimensions(2), 3));
    for r = 1 : finalDimensions(1)
       for c = 1 : finalDimensions(2)
          color(r,c,1) = colorMap(metaData{r,c}(1), metaData{r,c}(2),1);
          color(r,c,2) = colorMap(metaData{r,c}(1), metaData{r,c}(2),2);
          color(r,c,3) = colorMap(metaData{r,c}(1), metaData{r,c}(2),3);
       end
    end
    figure('Name', 'Generated_Terrain')
    image(color)
    imwrite(color,'Generated_Terrain.jpg','jpg','Comment','My JPEG file')
end
