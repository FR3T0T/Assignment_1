function fireShot(src, ~)
% FIRESHOT - Håndterer klik på fjendens bræt for at skyde
% Inputs:
%   src - Source handle for callback
    
    fig = ancestor(src, 'figure');
    gameData = getappdata(fig, 'gameData');
    handles = getappdata(fig, 'handles');
    
    % Tjek om spillet er i gang
    if ~strcmp(gameData.gameState, 'playing') || ~gameData.playerTurn
        return;
    end
    
    % Få koordinater fra klik
    coords = get(src, 'CurrentPoint');
    col = floor(coords(1,1)) + 1;
    row = floor(coords(1,2)) + 1;
    
    % Tjek om klikket er inden for brættet
    if col < 1 || col > 10 || row < 1 || row > 10
        return;
    end
    
    % Tjek om feltet allerede er beskudt
    if gameData.playerShots(row, col) > 0
        set(handles.statusText, 'String', 'Du har allerede skudt her! Vælg et andet felt.');
        return;
    end
    
    % Vis koordinater
    coordStr = sprintf('%c%d', 'A' + row - 1, col);
    
    % Registrer spillerens skud
    if gameData.computerGrid(row, col) > 0
        % Hit
        shipType = gameData.computerGrid(row, col);
        gameData.playerShots(row, col) = 2; % Mark as hit
        set(handles.statusText, 'String', sprintf('HIT! Du ramte et %s på %s!', gameData.ships(shipType).name, coordStr));
        
        % Track ship damage
        gameData.computerHits(shipType) = gameData.computerHits(shipType) + 1;
        
        % Check if ship sunk
        if gameData.computerHits(shipType) == gameData.ships(shipType).length
            set(handles.statusText, 'String', sprintf('Du sænkede modstanderens %s!', gameData.ships(shipType).name));
        end
    else
        % Miss
        gameData.playerShots(row, col) = 1; % Mark as miss
        set(handles.statusText, 'String', sprintf('MISS! Dit skud på %s ramte ingenting.', coordStr));
    end
    
    % Opdater visning
    updateGridDisplay(handles.enemyBoard, zeros(10,10), gameData.playerShots, false);
    
    % Check for win
    if sum(gameData.computerHits) == sum([gameData.ships.length])
        gameData.gameState = 'gameover';
        set(handles.statusText, 'String', 'SEJR! Du sænkede alle modstanderens skibe!');
        set(handles.enemyBoard, 'ButtonDownFcn', []);
        setappdata(fig, 'gameData', gameData);
        
        % Vis sejrbesked
        showGameResult(fig, true);
        return;
    end
    
    % Skift tur
    gameData.playerTurn = false;
    setappdata(fig, 'gameData', gameData);
    
    % Computerens tur - med lille forsinkelse så spilleren kan se hvad der sker
    pause(0.8);
    computerTurn(fig);
end