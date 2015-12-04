function sum = LookUpvalue(SummedAreaTable, r, c, patchDim, sourceDim)
%     r = sourceDim(1) - r + 1;
%     c = sourceDim(2) - c + 1;
%     SummedAreaTable = SummedAreaTables([13,9,5,1;14,10,6,2;15,11,7,3;16,12,8,4])
%     r = 1;
%     c = 1;
%     patchDim = [2,2];
%     sourceDim = [4,4];
    sum = 0;
    UpperRowBoundary = r + patchDim(1) - 1;
    %wrap around r
    if UpperRowBoundary > sourceDim(1) 
        % Get lower boundary
        LowerRowBoundary = UpperRowBoundary - sourceDim(1); 
        % fix upper bound
        UpperRowBoundary = sourceDim(1);   
        UpperCBoundary =  c + patchDim(2) - 1;
        
        % wrap around c
        if UpperCBoundary > sourceDim(2) 
            % get lower bound
            LowerCBoundary = UpperCBoundary - sourceDim(2); 
            % fix upper bound
            UpperCBoundary = sourceDim(2);
                    
            % remove extra blocks below r
            sum = sum + SummedAreaTable(UpperRowBoundary, UpperCBoundary) - SummedAreaTable(r - 1, UpperCBoundary); 

            % check for missing overflow blocks
            if r > 1
                % add missing overflow blocks
                sum = sum + SummedAreaTable(LowerRowBoundary, UpperCBoundary);
            end
            
            % remove extra blocks below c
            sum = sum + SummedAreaTable(UpperRowBoundary,UpperCBoundary) - SummedAreaTable(UpperRowBoundary,c); 
            % check for missing overflow blocks
            if c > 1 
               % add missing overflow blocks
               sum = sum + SummedAreaTable(UpperCBoundary, LowerCBoundary); 
            end
        % no c wrap around
        else
            % remove extra blocks below r
            sum = sum + SummedAreaTable(UpperRowBoundary, UpperCBoundary) - SummedAreaTable(LowerRowBoundary, UpperCBoundary); 

            % check for missing overflow blocks
            if r > 1
                % add missing overflow blocks
                sum = sum + SummedAreaTable(LowerRowBoundary, UpperCBoundary);
            end
            
            % check if unused blocks below c
            if c > 1 
               % remove excess blocks below c
               sum = sum - SummedAreaTable(LowerRowBoundary, c-1); 
            end
        end
    % no r wrap around
    else 
        UpperCBoundary =  c + patchDim(2) - 1;
        % wrap around c
        if UpperCBoundary > sourceDim(2) 
            % get lower bound
            LowerCBoundary = UpperCBoundary - sourceDim(2); 
            % fix upper bound
            UpperCBoundary = sourceDim(2);
            
            % Get sum of the area
            sum = SummedAreaTable(UpperRowBoundary, UpperCBoundary); 
            
            % remove extra blocks below c
            sum = sum + SummedAreaTable(UpperRowBoundary,UpperCBoundary) - SummedAreaTable(UpperRowBoundary,c); 
            % check for missing overflow blocks
            if c > 1 
               % add missing overflow blocks
               sum = sum + SummedAreaTable(UpperCBoundary, LowerCBoundary); 
            end
            
            % check if unused blocks below r
            if r > 1 
                % remove excess blocks below r
                sum = sum - SummedAreaTable(r - 1, UpperCBoundary); 
            end
        % no c wrap around
        else 
            % Get sum of the area
            sum = SummedAreaTable(UpperRowBoundary, UpperCBoundary);
            
            % check if unused blocks below c
            if c > 1 
               % remove excess blocks below c
               sum = sum - SummedAreaTable(UpperRowBoundary, c-1); 
            end
            
            % check if unused blocks below r
            if r > 1 
                % remove excess blocks below r
                sum = sum - SummedAreaTable(r - 1, UpperCBoundary); 
            end
            
            % check for double removed blocks
            if r > 1 && c > 1
               % add double removed blocks back
               sum = sum + SummedAreaTable(r - 1, c - 1);
            end
        end
    end
end