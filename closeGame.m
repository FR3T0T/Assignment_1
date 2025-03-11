function closeGame(src, ~)
% CLOSEGAME - Handles closing of the game with confirmation dialog
% Inputs:
%   src - Source handle for callback
    
    % Confirm game exit
    choice = questdlg('Are you sure you want to exit the game?', ...
        'Exit Battleship', 'Yes', 'No', 'No');
    
    if strcmp(choice, 'Yes')
        delete(src);
    end
end