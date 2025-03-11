function displayGrid(shipGrid, shotGrid)
    % Display the player's grid with ships and shots
    
    % Column headers
    fprintf('    1   2   3   4   5   6   7   8   9   10 \n');
    fprintf('  +---+---+---+---+---+---+---+---+---+---+\n');
    
    % Grid rows
    for i = 1:10
        fprintf('%c |', 'A' + i - 1);
        
        for j = 1:10
            if shotGrid(i, j) == 2
                % Hit
                fprintf(' X |');
            elseif shotGrid(i, j) == 1
                % Miss
                fprintf(' O |');
            elseif shipGrid(i, j) > 0
                % Ship
                fprintf(' S |');
            else
                % Empty water
                fprintf(' ~ |');
            end
        end
        
        fprintf('\n  +---+---+---+---+---+---+---+---+---+---+\n');
    end
end