function displayTargetGrid(shotGrid)
    % Display the target grid with shot history
    
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
            else
                % Unknown
                fprintf(' ~ |');
            end
        end
        
        fprintf('\n  +---+---+---+---+---+---+---+---+---+---+\n');
    end
end