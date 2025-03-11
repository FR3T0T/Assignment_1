function setDifficulty(src, ~)
% SETDIFFICULTY - Opdaterer sværhedsgrad baseret på brugervalg
% Inputs:
%   src - Source handle for callback
    
    % Opdater sværhedsgrad
    fig = ancestor(src, 'figure');
    gameData = getappdata(fig, 'gameData');
    gameData.difficulty = get(src, 'Value');
    setappdata(fig, 'gameData', gameData);
end