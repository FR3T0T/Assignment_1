function setDifficulty(src, ~)
% SETDIFFICULTY - Updates difficulty based on user selection
% Inputs:
% src - Source handle for callback

    % Update difficulty
    fig = ancestor(src, 'figure');
    gameData = getappdata(fig, 'gameData');
    gameData.difficulty = get(src, 'Value');
    setappdata(fig, 'gameData', gameData);
end