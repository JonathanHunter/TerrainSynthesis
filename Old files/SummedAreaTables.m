% function SummedAreaTables()
%     s([13,9,5,1;14,10,6,2;15,11,7,3;16,12,8,4])
% end

function sat = SummedAreaTables(matrix)
    dim = size(matrix);
    sat = zeros(dim(1), dim(2)); 
    sum = 0;
    for r = 1:dim(1)
        sum = sum + matrix(r,1);
        sat(r,1) = sum;
    end
    sum = 0;
    for c = 1:dim(2)
        sum = sum + matrix(1,c);
        sat(1,c) = sum;
    end
    for r = 2:dim(1)
        for c = 2:dim(2)
           sat(r,c) = sat(r - 1, c) + sat(r, c - 1) - sat(r - 1, c - 1) + matrix(r, c); 
        end
    end
end