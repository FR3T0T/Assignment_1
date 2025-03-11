function startGame(src, ~)
% STARTGAME - Starter et nyt spil og nulstiller alle spildata
% Inputs:
%   src - Source handle for callback
    
    % Start et nyt spil
    fig = ancestor(src, 'figure');
    gameData = getappdata(fig, 'gameData');
    handles = getappdata(fig, 'handles');
    
    % Nulstil spildatastrukturen
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
    
    % Opdater status
    set(handles.statusText, 'String', sprintf('Placer dit %s (%d felter)\nVælg orientering og klik på dit bræt.', ...
                                             gameData.ships(1).name, gameData.ships(1).length));
    
    % Opdater brætterne
    drawGrid(handles.playerBoard);
    drawGrid(handles.enemyBoard);
    
    % Aktiver placeringsfunktion
    set(handles.playerBoard, 'ButtonDownFcn', @placeShip);
    
    % Placer computerens skibe
    gameData.computerGrid = placeComputerShips(gameData.computerGrid, gameData.ships);
    
    % Gem opdateret spilledata
    setappdata(fig, 'gameData', gameData);
end