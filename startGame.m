function startGame(src, ~)
% STARTGAME - Starts a new game and resets all game data
% Inputs:
%   src - Source handle for callback
    
    % Start a new game
    fig = ancestor(src, 'figure');
    gameData = getappdata(fig, 'gameData');
    handles = getappdata(fig, 'handles');
    
    % Reset game data structure
    gameData.playerGrid = zeros(10, 10);
    gameData.computerGrid = zeros(10, 10);
    gameData.playerShots = zeros(10, 10);
    gameData.computerShots = zeros(10, 10);
    gameData.gameState = 'placing';
    gameData.currentShip = 1;
    gameData.playerTurn = true;
    gameData.playerHits = [0, 0, 0];
    gameData.computerHits = [0, 0, 0];
    for i = 1:length(gameData.ships)
        gameData.ships(i).placed = false;
    end
    
    % Update status
    set(handles.statusText, 'String', sprintf('Place your %s (%d cells)\nSelect orientation and click on your board.', ...
                                             gameData.ships(1).name, gameData.ships(1).length));
    
    % Update boards
    drawGrid(handles.playerBoard);
    drawGrid(handles.enemyBoard);
    
    % Activate placement function
    set(handles.playerBoard, 'ButtonDownFcn', @placeShip);
    
    % Place computer's ships
    gameData.computerGrid = placeComputerShips(gameData.computerGrid, gameData.ships);
    
    % Save updated game data
    setappdata(fig, 'gameData', gameData);
end