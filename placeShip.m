function placeShip(src, ~)
% PLACESHIP - Håndterer klik på spillerens bræt for at placere skibe
% Inputs:
%   src - Source handle for callback
    
    fig = ancestor(src, 'figure');
    gameData = getappdata(fig, 'gameData');
    handles = getappdata(fig, 'handles');
    
    % Tjek om vi er i placeringsfasen
    if ~strcmp(gameData.gameState, 'placing')
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
    
    % Få orientering (1=vandret, 2=lodret)
    orientation = get(handles.orientationSelector, 'Value');
    
    % Tjek om skibet kan placeres
    currentShip = gameData.currentShip;
    shipLength = gameData.ships(currentShip).length;
    
    % Validering af placeringen
    valid = validateShipPlacement(gameData.playerGrid, row, col, orientation, shipLength);
    
    if valid
        % Placer skibet
        if orientation == 1  % Vandret
            for i = 0:(shipLength-1)
                gameData.playerGrid(row, col+i) = currentShip;
            end
        else  % Lodret
            for i = 0:(shipLength-1)
                gameData.playerGrid(row+i, col) = currentShip;
            end
        end
        
        % Opdater visning
        updateGridDisplay(handles.playerBoard, gameData.playerGrid, gameData.computerShots, true);
        
        % Marker skibet som placeret
        gameData.ships(currentShip).placed = true;
        
        % Gå til næste skib eller start spillet
        if currentShip < length(gameData.ships)
            gameData.currentShip = currentShip + 1;
            set(handles.statusText, 'String', sprintf('Placer dit %s (%d felter)\nVælg orientering og klik på dit bræt.', ...
                                                    gameData.ships(gameData.currentShip).name, ...
                                                    gameData.ships(gameData.currentShip).length));
        else
            % Alle skibe placeret - start spillet
            gameData.gameState = 'playing';
            
            % Vis "spil starter" besked
            gameStartPanel = uipanel('Parent', fig, 'Position', [0.35, 0.45, 0.3, 0.1], ...
                'BackgroundColor', [0.9 1 0.9]);
           
            uicontrol('Parent', gameStartPanel, 'Style', 'text', ...
                'Position', [10, 35, 280, 25], 'String', 'Alle skibe placeret! Spillet starter!', ...
                'FontSize', 12, 'FontWeight', 'bold', 'BackgroundColor', [0.9 1 0.9]);
           
            % Tilføj en timer til at fjerne panelet efter 2 sekunder
            t = timer('ExecutionMode', 'singleShot', 'StartDelay', 2, ...
                'TimerFcn', @(~,~) delete(gameStartPanel));
            start(t);
            
            set(handles.statusText, 'String', 'Spillet er i gang! Klik på modstanderens bræt for at skyde.');
            set(handles.playerBoard, 'ButtonDownFcn', []);
            set(handles.enemyBoard, 'ButtonDownFcn', @fireShot);
        end
    else
        set(handles.statusText, 'String', 'Ugyldig placering! Prøv igen.');
    end
    
    setappdata(fig, 'gameData', gameData);
end