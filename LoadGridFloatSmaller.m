function LoadGridFloatSmaller()
    terrain = imread('Terrain', 'png');
    pathFlt = 'C:\Users\Jonathan\Desktop\Graphics Research\n39w080\floatn39w080_1.flt';
    pathHDR = 'C:\Users\Jonathan\Desktop\Graphics Research\n39w080\floatn39w080_1.hdr';
    % How much to shrink the height field by
    shrink = 15;
    % Read in height field dimensions
    hdr = fopen(pathHDR);
    dim = fscanf(hdr, '%*s%d');
    fclose(hdr);
    % Read in height field
    ftl = fopen(pathFlt);
    a = fread(ftl, dim(1) * dim(2), 'float32', 'ieee-le');
    fclose(ftl);
    i = reshape(a, [dim(1), dim(2)]);
    clear a;    
    % Shrink height field by specified amount
    temp = zeros(int32(dim(1) / shrink), int32(dim(2) / shrink));
    r = 1;
    % Shrink by averaging the pixels
    while r <= dim(1)
       c = 1;
       if r + shrink > dim(1)
           rowLimit = dim(1);
       else
           rowLimit = r + shrink;
       end
       while c <= dim(2)
           if c + shrink > dim(2)
               colLimit = dim(2);
           else
               colLimit = c + shrink;
           end
           s = 0.0;
           for row = r : rowLimit
                s = s + sum(i(row, c : colLimit));
           end
           temp(int32(r / shrink) + 1,int32(c / shrink) + 1) = s / ((colLimit - c) * (rowLimit - r));
           c = c + shrink;
       end
       r = r + shrink;
    end
    i = temp;
    dim = [int32(dim(1) / shrink), int32(dim(2) / shrink)];
    % Grab specific section from height field
    temp = zeros(int32(dim(1) / 1.5), dim(2));
    for r = 1 : int32(dim(1) / 1.5)
        temp(r, :) = i(r, 1 : dim(2));
    end
    i = temp;
    % Normalize data
    i = transpose(i);
    dim = size(i);
    minimum = min(i(:));
    maxim = max(i(:));
    i = i - minimum;
    i = i.*(50/(maxim-minimum));
    % Array to hold normal Map
    slopes = zeros(dim(1), dim(2));
    % Distance between pixels
    dist = 30.87 / shrink;
    % Light vector for shading
    L = [0, 0, 1];
    % Generate normal map
    for r = 1:dim(1)
        if mod(r,10) == 0
            sprintf('Normal Map Generation: %g%% left', 100 * (1.0 - r / dim(1)))
        end
       for c = 1:dim(2)
           % Get partial derivative in x
           if r == 1
              dx = (i(r + 1, c) - i(r, c)) / 2 * dist;
           else
               if r == dim(1)
                  dx = (i(r - 1, c) - i(r, c)) / 2 * dist;
               else
                  dx = (i(r - 1, c) - i(r + 1, c)) / 2 * dist;
               end
           end  
           % Get partial derivative in y
           if c == dim(2)
              dy = (i(r, c - 1) - i(r, c)) / 2 * dist;
           else
               if c == 1
                dy = (i(r, c + 1) - i(r, c)) / 2 * dist;
               else
                dy = (i(r, c + 1) - i(r, c - 1)) / 2 * dist;
               end
           end
           % Calculate normal
           N = [-dx, -dy, 1];
           N = N / norm(N);
           % Shade using light vector
           d = dot(N, L);
           slopes(r,c) = d;
       end
    end
    sprintf('Normal Map Generation complete!')
    % Normalize the data
    minimum = min(i(:));
    maxim = max(i(:));
    i = i - minimum;
    i = i.*(1/(maxim-minimum));
    % Write out height map
    imwrite(i,'Height_Map.png')
    % Write out normal map
    imwrite(slopes,'Normal_Map.png')
    % Normalize the data for figure display
    i = i.*64;
    slopes = slopes.*64;
    % Generate figures
    figure('Name', 'Height_Map')
    image(i)
    figure('Name', 'Normal_Map')
    image(slopes)
    % Generate terrain
	PatchFindingAndPlacement([64, 64], [64, 16], slopes, terrain)
end