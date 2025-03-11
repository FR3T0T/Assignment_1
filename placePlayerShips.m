function grid = placePlayerShips(grid, ships)
    % Let player place ships on the grid
    
    fprintf('\n==== SHIP PLACEMENT ====\n');
    fprintf('You need to place 3 ships on your grid:\n');
    fprintf('- Battleship (length 4)\n');
    fprintf('- Cruiser (length 3)\n');
    fprintf('- Destroyer (length 2)\n\n');
    
    % Place each ship
    for i = 1:length(ships)
        fprintf('Placing %s (length %d)\n', ships(i).name, ships(i).length);
        placedSuccessfully = false;
        
        while ~placedSuccessfully
            % Show current grid - pass zeros of same size as second argument
            % This is important since displayGrid needs two arguments
            displayGrid(grid, zeros(size(grid)));
            
            % Get starting position
            posStr = input(sprintf('Enter starting position for %s (e.g., A1): ', ships(i).name), 's');
            [row, col] = parsePosition(posStr);
            
            % Check if position is valid
            if row < 1 || row > 10 || col < 1 || col > 10
                fprintf('Invalid position! Must be between A1 and J10.\n');
                continue;
            end
            
            % Get orientation
            dirStr = input('Enter direction (h for horizontal, v for vertical): ', 's');
            isHorizontal = lower(dirStr(1)) == 'h';
            
            % Check if ship fits on grid
            if isHorizontal && col + ships(i).length - 1 > 10
                fprintf('Ship would extend beyond the grid horizontally!\n');
                continue;
            elseif ~isHorizontal && row + ships(i).length - 1 > 10
                fprintf('Ship would extend beyond the grid vertically!\n');
                continue;
            end
            
            % Check if space is already occupied
            occupied = false;
            
            if isHorizontal
                for j = 0:ships(i).length-1
                    if grid(row, col+j) ~= 0
                        occupied = true;
                        break;
                    end
                end
            else
                for j = 0:ships(i).length-1
                    if grid(row+j, col) ~= 0
                        occupied = true;
                        break;
                    end
                end
            end
            
            if occupied
                fprintf('Space already occupied by another ship!\n');
                continue;
            end
            
            % Place the ship
            if isHorizontal
                for j = 0:ships(i).length-1
                    grid(row, col+j) = i;
                end
            else
                for j = 0:ships(i).length-1
                    grid(row+j, col) = i;
                end
            end
            
            placedSuccessfully = true;
        end
    end
    
    % Show final grid with all ships
    displayGrid(grid, zeros(size(grid)));
    fprintf('All ships placed successfully!\n\n');
    fprintf('Press any key to start the game...\n');
    pause;
end