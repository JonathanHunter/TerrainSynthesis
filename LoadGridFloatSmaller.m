function LoadGridFloatSmaller()
%     pathFlt = 'C:\Users\Jonathan\Desktop\n47w122\floatn47w122_1.flt';
%     pathHDR = 'C:\Users\Jonathan\Desktop\n47w122\floatn47w122_1.hdr';
%     pathFlt = 'C:\Users\Jonathan\Desktop\n39w080\floatn39w080_1.flt';
%     pathHDR = 'C:\Users\Jonathan\Desktop\n39w080\floatn39w080_1.hdr';
%     shrink = 15;
    pathFlt = 'C:\Users\Jonathan\Desktop\n45w111\floatn45w111_13.flt';
    pathHDR = 'C:\Users\Jonathan\Desktop\n45w111\floatn45w111_13.hdr';
    % How much to shrink the height field by
    shrink = 100;
    % Read in height field dimensions
    hdr = fopen(pathHDR);
    dim = fscanf(hdr, '%*s%d');
    fclose(hdr);
    % Read in height field
    ftl = fopen(pathFlt);
    a = fread(ftl, dim(1)*dim(2), 'float32', 'ieee-le');
    fclose(ftl);
    i = reshape(a, [dim(1), dim(2)]);
    clear a;    
    % Shrink height field by specified amount
    temp = zeros(int32(dim(1)/shrink), int32(dim(2)/shrink));
    for r = 1:int32(dim(1)/shrink)
        for c = 1:int32(dim(2)/shrink)
            x = r * shrink;
            if(x > dim(1))
                x = dim(1);
            end
            y = c * shrink;
            if(y > dim(2))
                y = dim(2);
            end
            temp(r, c) = i(x, y); 
        end
    end
    i = temp;
    dim = [int32(dim(1)/shrink), int32(dim(2)/shrink)];    
%   % Grab specific section from height field
% 	temp = zeros(150, dim(2));
%     for r = 1:150
%         temp(r, :) = i(r, 1:dim(2)); 
%     end
% 	i = temp;
% 	dim = [dim(2), 150];   
    % Normalize data
    i = transpose(i);
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
    % Write out normal map
    imwrite(slopes,'Normal_Map.png')
    % Normalize the data
    minimum = min(slopes(:));
    maxim = max(slopes(:));
    slopes = slopes - minimum;
    slopes = slopes.*(50/(maxim-minimum));
    % Generate figures
    figure('Name', 'Height_Map')
    image(i)
    figure('Name', 'Normal_Map')
    image(slopes)
    % Generate terrain
	PatchFindingAndPlacement([64, 64], [64, 16], slopes, i)
end