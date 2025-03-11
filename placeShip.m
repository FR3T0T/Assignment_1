function placeShip(src, ~)
% PLACESHIP - Handles clicks on the player's board to place ships
% Inputs:
%   src - Source handle for callback
    
    fig = ancestor(src, 'figure');
    gameData = getappdata(fig, 'gameData');
    handles = getappdata(fig, 'handles');
    
    % Check if we are in the placement phase
    if ~strcmp(gameData.gameState, 'placing')
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
    
    % Get orientation (1=horizontal, 2=vertical)
    orientation = get(handles.orientationSelector, 'Value');
    
    % Check if the ship can be placed
    currentShip = gameData.currentShip;
    shipLength = gameData.ships(currentShip).length;
    
    % Validation of the placement
    valid = validateShipPlacement(gameData.playerGrid, row, col, orientation, shipLength);
    
    if valid
        % Place the ship
        if orientation == 1  % Horizontal
            for i = 0:(shipLength-1)
                gameData.playerGrid(row, col+i) = currentShip;
            end
        else  % Vertical
            for i = 0:(shipLength-1)
                gameData.playerGrid(row+i, col) = currentShip;
            end
        end
        
        % Update display
        updateGridDisplay(handles.playerBoard, gameData.playerGrid, gameData.computerShots, true);
        
        % Mark the ship as placed
        gameData.ships(currentShip).placed = true;
        
        % Go to next ship or start the game
        if currentShip < length(gameData.ships)
            gameData.currentShip = currentShip + 1;
            set(handles.statusText, 'String', sprintf('Place your %s (%d cells)\nSelect orientation and click on your board.', ...
                                                    gameData.ships(gameData.currentShip).name, ...
                                                    gameData.ships(gameData.currentShip).length));
        else
            % All ships placed - start the game
            gameData.gameState = 'playing';
            
            % Show "game starts" message
            gameStartPanel = uipanel('Parent', fig, 'Position', [0.35, 0.45, 0.3, 0.1], ...
                'BackgroundColor', [0.9 1 0.9]);
           
            uicontrol('Parent', gameStartPanel, 'Style', 'text', ...
                'Position', [10, 35, 280, 25], 'String', 'All ships placed! Game starts!', ...
                'FontSize', 12, 'FontWeight', 'bold', 'BackgroundColor', [0.9 1 0.9]);
           
            % Add a timer to remove the panel after 2 seconds
            t = timer('ExecutionMode', 'singleShot', 'StartDelay', 2, ...
                'TimerFcn', @(~,~) delete(gameStartPanel));
            start(t);
            
            set(handles.statusText, 'String', 'Game in progress! Click on the opponent''s board to shoot.');
            set(handles.playerBoard, 'ButtonDownFcn', []);
            set(handles.enemyBoard, 'ButtonDownFcn', @fireShot);
        end
    else
        set(handles.statusText, 'String', 'Invalid placement! Try again.');
    end
    
    setappdata(fig, 'gameData', gameData);
end