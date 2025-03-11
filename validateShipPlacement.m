function valid = validateShipPlacement(grid, row, col, orientation, shipLength)
% VALIDATESHIPPLACEMENT - Validate if a ship can be placed at the specified location
% Inputs:
%   grid - 10x10 matrix with current ship placements
%   row - Row index (1-10)
%   col - Column index (1-10)
%   orientation - 1 for horizontal, 2 for vertical
%   shipLength - Length of the ship to place
% Outputs:
%   valid - Boolean, true if placement is valid
    
    % Check if the ship fits on the board
    if orientation == 1 && col + shipLength - 1 > 10  % Horizontal
        valid = false;
        return;
    elseif orientation == 2 && row + shipLength - 1 > 10  % Vertical
        valid = false;
        return;
    end
    
    % Check if the fields are available
    valid = true;
    if orientation == 1  % Horizontal
        for i = 0:(shipLength-1)
            if grid(row, col+i) ~= 0
                valid = false;
                return;
            end
        end
    else  % Vertical
        for i = 0:(shipLength-1)
            if grid(row+i, col) ~= 0
                valid = false;
                return;
            end
        end
    end
end