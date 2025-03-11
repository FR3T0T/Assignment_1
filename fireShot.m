function fireShot(src, ~)
% FIRESHOT - Handles clicks on the enemy's board to shoot
% Inputs:
%   src - Source handle for callback
    
    fig = ancestor(src, 'figure');
    gameData = getappdata(fig, 'gameData');
    handles = getappdata(fig, 'handles');
    
    % Check if the game is active
    if ~strcmp(gameData.gameState, 'playing') || ~gameData.playerTurn
        return;
    end
    
    % Get coordinates from click
    coords = get(src, 'CurrentPoint');
    col = floor(coords(1,1)) + 1;
    row = floor(coords(1,2)) + 1;
    
    % Check if the click is within the board
    if col < 1 || col > 10 || row < 1 || row > 10
        return;
    end
    
    % Check if the field has already been shot
    if gameData.playerShots(row, col) > 0
        set(handles.statusText, 'String', 'You already shot here! Choose another field.');
        return;
    end
    
    % Display coordinates
    coordStr = sprintf('%c%d', 'A' + row - 1, col);
    
    % Register player's shot
    if gameData.computerGrid(row, col) > 0
        % Hit
        shipType = gameData.computerGrid(row, col);
        gameData.playerShots(row, col) = 2; % Mark as hit
        set(handles.statusText, 'String', sprintf('HIT! You hit a %s at %s!', gameData.ships(shipType).name, coordStr));
        
        % Track ship damage
        gameData.computerHits(shipType) = gameData.computerHits(shipType) + 1;
        
        % Check if ship sunk
        if gameData.computerHits(shipType) == gameData.ships(shipType).length
            set(handles.statusText, 'String', sprintf('You sank the opponent''s %s!', gameData.ships(shipType).name));
        end
    else
        % Miss
        gameData.playerShots(row, col) = 1; % Mark as miss
        set(handles.statusText, 'String', sprintf('MISS! Your shot at %s hit nothing.', coordStr));
    end
    
    % Update display
    updateGridDisplay(handles.enemyBoard, zeros(10,10), gameData.playerShots, false);
    
    % Check for win
    if sum(gameData.computerHits) == sum([gameData.ships.length])
        gameData.gameState = 'gameover';
        set(handles.statusText, 'String', 'VICTORY! You sank all the opponent''s ships!');
        set(handles.enemyBoard, 'ButtonDownFcn', []);
        setappdata(fig, 'gameData', gameData);
        
        % Show victory message
        showGameResult(fig, true);
        return;
    end
    
    % Switch turn
    gameData.playerTurn = false;
    setappdata(fig, 'gameData', gameData);
    
    % Computer's turn - with a small delay so the player can see what happens
    pause(0.8);
    computerTurn(fig);
end