function LoadGridFloat()
    pathFlt = 'C:\Users\Jonathan\Desktop\n47w122\floatn47w122_1.flt';
    pathHDR = 'C:\Users\Jonathan\Desktop\n47w122\floatn47w122_1.hdr';
    k = 255;
    hdr = fopen(pathHDR);
    dim = fscanf(hdr, '%*s%d');
    fclose(hdr);
    ftl = fopen(pathFlt);
    a = fread(ftl, dim(1)*dim(2), 'float32', 'ieee-le');
    fclose(ftl);
    i = reshape(a, [dim(1), dim(2)]);
    clear a;
    temp = zeros(255, 255);
    for r = 1:255
       temp(r, :) = i(r, 1:255); 
    end
    i = temp;
    dim = [255, 255];
%     minimum = min(i(:))
%     maxim = max(i(:))
%     i = i - minimum;
%     i = i.*(50/(maxim-minimum));
    i = transpose(i);
    slopes = zeros(dim(1), dim(2));
    dist = 30.87;
    dx = 0;
    dy = 0;
    L = [0, 0, 1];
    N = [0, 0, 0];
    
    for r = 1:dim(1)
        if mod(r,10) == 0
            r / dim(1)
        end
       for c = 1:dim(2)
           if r == 1
              dx = (i(r + 1, c) - i(r, c)) / 2 * dist;
           else
               if r == dim(1)
                  dx = (i(r - 1, c) - i(r, c)) / 2 * dist;
               else
                  dx = (i(r - 1, c) - i(r + 1, c)) / 2 * dist;
               end
           end           
           if c == dim(2)
              dy = (i(r, c - 1) - i(r, c)) / 2 * dist;
           else
               if c == 1
                dy = (i(r, c + 1) - i(r, c)) / 2 * dist;
               else
                dy = (i(r, c + 1) - i(r, c - 1)) / 2 * dist;
               end
           end
           N = [-dx, -dy, 1];
           N = N / norm(N);
           d = dot(N, L);
           slopes(r,c) = d;
       end
    end
    minimum = min(slopes(:))
    maxim = max(slopes(:))
    slopes = slopes - minimum;
    slopes = slopes.*(50/(maxim-minimum));
    min(slopes(:))
    max(slopes(:))
    figure('Name', 'image')
    image(i)
    figure('Name', 'slopes')
    image(slopes)
%     slopes = slopes.*(255/k);
    imwrite(slopes,'a.tif')
%     PatchFindingAndPlacement([64, 64], [64, 32], slopes)
end