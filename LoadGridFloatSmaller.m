function LoadGridFloatSmaller()
%     pathFlt = 'C:\Users\Jonathan\Desktop\n47w122\floatn47w122_1.flt';
%     pathHDR = 'C:\Users\Jonathan\Desktop\n47w122\floatn47w122_1.hdr';
    pathFlt = 'C:\Users\Jonathan\Desktop\n39w080\floatn39w080_1.flt';
    pathHDR = 'C:\Users\Jonathan\Desktop\n39w080\floatn39w080_1.hdr';
    shrink = 10;
%     pathFlt = 'C:\Users\Jonathan\Desktop\n45w111\floatn45w111_13.flt';
%     pathHDR = 'C:\Users\Jonathan\Desktop\n45w111\floatn45w111_13.hdr';
%     shrink = 50;
    k = 255;
    hdr = fopen(pathHDR);
    dim = fscanf(hdr, '%*s%d');
    fclose(hdr);
    ftl = fopen(pathFlt);
    a = fread(ftl, dim(1)*dim(2), 'float32', 'ieee-le');
    fclose(ftl);
    i = reshape(a, [dim(1), dim(2)]);
    clear a;
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
    i = transpose(i);
    minimum = min(i(:));
    maxim = max(i(:));
    i = i - minimum;
    i = i.*(50/(maxim-minimum));

    slopes = zeros(dim(1), dim(2));
    dist = 30.87 / shrink;
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
    imwrite(slopes,'a.png')
    minimum = min(slopes(:));
    maxim = max(slopes(:));
    slopes = slopes - minimum;
    slopes = slopes.*(50/(maxim-minimum));
    min(slopes(:));
    max(slopes(:));
    figure('Name', 'image')
    image(i)
    figure('Name', 'slopes')
    image(slopes)
	PatchFindingAndPlacement([64, 64], [64, 32], slopes)
end