function valid = validateShipPlacement(grid, row, col, orientation, shipLength)
% VALIDATESHIPPLACEMENT - Valider om et skib kan placeres på det angivne sted
% Inputs:
%   grid - 10x10 matrix with current ship placements
%   row - Row index (1-10)
%   col - Column index (1-10)
%   orientation - 1 for horizontal, 2 for vertical
%   shipLength - Length of the ship to place
% Outputs:
%   valid - Boolean, true if placement is valid
    
    % Tjek om skibet passer på brættet
    if orientation == 1 && col + shipLength - 1 > 10  % Vandret
        valid = false;
        return;
    elseif orientation == 2 && row + shipLength - 1 > 10  % Lodret
        valid = false;
        return;
    end
    
    % Tjek om felterne er ledige
    valid = true;
    if orientation == 1  % Vandret
        for i = 0:(shipLength-1)
            if grid(row, col+i) ~= 0
                valid = false;
                return;
            end
        end
    else  % Lodret
        for i = 0:(shipLength-1)
            if grid(row+i, col) ~= 0
                valid = false;
                return;
            end
        end
    end
end