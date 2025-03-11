function computerTurn(fig)
% COMPUTERTURN - Håndterer computerens tur
% Inputs:
%   fig - Handle til hovedfiguren
    
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
    set(handles.statusText, 'String', sprintf('Computeren skyder på %s', coordStr));
    pause(0.5);
    
    % Process shot
    if gameData.playerGrid(row, col) > 0
        % Hit
        shipType = gameData.playerGrid(row, col);
        gameData.computerShots(row, col) = 2; % Mark as hit
        
        set(handles.statusText, 'String', sprintf('HIT! Computeren ramte dit %s på %s!', ...
                                                gameData.ships(shipType).name, coordStr));
        
        % Track ship damage
        gameData.playerHits(shipType) = gameData.playerHits(shipType) + 1;
        
        % Check if ship sunk
        if gameData.playerHits(shipType) == gameData.ships(shipType).length
            set(handles.statusText, 'String', sprintf('Computeren sænkede dit %s!', gameData.ships(shipType).name));
        end
    else
        % Miss
        gameData.computerShots(row, col) = 1; % Mark as miss
        set(handles.statusText, 'String', sprintf('MISS! Computerens skud på %s ramte ingenting.', coordStr));
    end
    
    % Update display
    updateGridDisplay(handles.playerBoard, gameData.playerGrid, gameData.computerShots, true);
    
    % Check for loss
    if sum(gameData.playerHits) == sum([gameData.ships.length])
        gameData.gameState = 'gameover';
        set(handles.statusText, 'String', 'NEDERLAG! Computeren sænkede alle dine skibe!');
        set(handles.enemyBoard, 'ButtonDownFcn', []);
        setappdata(fig, 'gameData', gameData);
        
        % Vis nederlagsbesked
        showGameResult(fig, false);
        return;
    end
    
    % Switch turns back to player
    gameData.playerTurn = true;
    pause(0.5);
    
    % Prompt player for next move
    set(handles.statusText, 'String', sprintf('%s\nDin tur - klik på modstanderens bræt for at skyde.', ...
                                            get(handles.statusText, 'String')));
    
    setappdata(fig, 'gameData', gameData);
end