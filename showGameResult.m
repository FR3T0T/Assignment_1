function showGameResult(fig, isVictory)
% SHOWGAMERESULT - Shows final result when the game is finished
% Inputs:
%   fig - Handle to the main figure
%   isVictory - Boolean, true if the player won, false if the computer won
    
    handles = getappdata(fig, 'handles');
    
    % Create overlay panel with result
    resultPanel = uipanel('Parent', fig, 'Position', [0.3, 0.4, 0.4, 0.2], ...
        'BackgroundColor', [0.9 0.9 1], 'BorderType', 'line', ...
        'HighlightColor', 'blue', 'BorderWidth', 2);
    
    if isVictory
        resultText = 'VICTORY! You sank all of the opponent''s ships!';
        textColor = [0 0.5 0];
    else
        resultText = 'DEFEAT! The computer sank all your ships!';
        textColor = [0.8 0 0];
    end
    
    % Add text
    uicontrol('Parent', resultPanel, 'Style', 'text', ...
        'Position', [20, 30, 320, 50], 'String', resultText, ...
        'FontSize', 14, 'FontWeight', 'bold', 'ForegroundColor', textColor, ...
        'BackgroundColor', [0.9 0.9 1]);
    
    % Play again button
    uicontrol('Parent', resultPanel, 'Style', 'pushbutton', ...
        'Position', [120, 10, 120, 30], 'String', 'Play again', ...
        'Callback', @(~,~) restartGame(handles.startButton, resultPanel));
end