function grid = placeComputerShips(grid, ships)
% PLACECOMPUTERSHIPS - Automatically place computer ships on the board
% Inputs:
%   grid - 10x10 matrix to place ships on
%   ships - Struct array with ship information
% Outputs:
%   grid - Updated grid with computer ships placed
    
    % Ship lengths
    shipLengths = [ships.length];
    
    % Place each ship
    for i = 1:length(shipLengths)
        placedSuccessfully = false;
        
        while ~placedSuccessfully
            % Random position and orientation
            row = randi(10);
            col = randi(10);
            isHorizontal = randi(2) == 1;
            
            % Check if ship fits on grid
            if isHorizontal && col + shipLengths(i) - 1 > 10
                continue;
            elseif ~isHorizontal && row + shipLengths(i) - 1 > 10
                continue;
            end
            
            % Check if space is already occupied
            occupied = false;
            
            if isHorizontal
                for j = 0:shipLengths(i)-1
                    if grid(row, col+j) ~= 0
                        occupied = true;
                        break;
                    end
                end
            else
                for j = 0:shipLengths(i)-1
                    if grid(row+j, col) ~= 0
                        occupied = true;
                        break;
                    end
                end
            end
            
            if occupied
                continue;
            end
            
            % Place the ship
            if isHorizontal
                for j = 0:shipLengths(i)-1
                    grid(row, col+j) = i;
                end
            else
                for j = 0:shipLengths(i)-1
                    grid(row+j, col) = i;
                end
            end
            
            placedSuccessfully = true;
        end
    end
end