function coord = FindMinCoordinate(SSD)
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