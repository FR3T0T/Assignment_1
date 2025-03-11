function computerTurn(fig)
% COMPUTERTURN - Handles the computer's turn
% Inputs:
%   fig - Handle to the main figure
    
    gameData = getappdata(fig, 'gameData');
    handles = getappdata(fig, 'handles');
    
    % Check if game is still active
    if ~strcmp(gameData.gameState, 'playing')
        return;
    end
    
    % Get computer shot based on difficulty
    [row, col] = getComputerShot(gameData.computerShots, gameData.playerGrid, gameData.difficulty);
    coordStr = sprintf('%c%d', 'A' + row - 1, col);
    
    % Update status to show computer's move
    set(handles.statusText, 'String', sprintf('Computer shoots at %s', coordStr));
    pause(0.5);
    
    % Process shot
    if gameData.playerGrid(row, col) > 0
        % Hit
        shipType = gameData.playerGrid(row, col);
        gameData.computerShots(row, col) = 2; % Mark as hit
        
        set(handles.statusText, 'String', sprintf('HIT! The computer hit your %s at %s!', ...
                                                gameData.ships(shipType).name, coordStr));
        
        % Track ship damage
        gameData.playerHits(shipType) = gameData.playerHits(shipType) + 1;
        
        % Check if ship sunk
        if gameData.playerHits(shipType) == gameData.ships(shipType).length
            set(handles.statusText, 'String', sprintf('Computer sank your %s!', gameData.ships(shipType).name));
        end
    else
        % Miss
        gameData.computerShots(row, col) = 1; % Mark as miss
        set(handles.statusText, 'String', sprintf('MISS! Computer''s shot at %s hit nothing.', coordStr));
    end
    
    % Update display
    updateGridDisplay(handles.playerBoard, gameData.playerGrid, gameData.computerShots, true);
    
    % Check for loss
    if sum(gameData.playerHits) == sum([gameData.ships.length])
        gameData.gameState = 'gameover';
        set(handles.statusText, 'String', 'DEFEAT! Computer sank all your ships!');
        set(handles.enemyBoard, 'ButtonDownFcn', []);
        setappdata(fig, 'gameData', gameData);
        
        % Display game over message
        showGameResult(fig, false);
        return;
    end
    
    % Switch turns back to player
    gameData.playerTurn = true;
    pause(0.5);
    
    % Prompt player for next move
    set(handles.statusText, 'String', sprintf('%s\nYour turn - click on the opponent''s board to shoot.', ...
                                            get(handles.statusText, 'String')));
    
    setappdata(fig, 'gameData', gameData);
end