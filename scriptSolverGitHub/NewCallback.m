function output_txt = NewCallback(obj,event_obj)
% Display the position of the data cursor
% obj          Currently not used (empty)
% event_obj    Handle to event object
% output_txt   Data cursor text string (string or cell array of strings).

pos = get(event_obj,'Position');

output_txt = {['X: ',num2str(pos(1),4)],...
    ['Y: ',num2str(pos(2),4)]};

% If there is a Z-coordinate in the position, display it as well
if length(pos) > 2
    output_txt{end+1} = ['Z: ',num2str(pos(3),4)];
end

% search for the correct data point
    xIdx = find(event_obj.Target.XData == pos(1));
    yIdx = find(event_obj.Target.YData == pos(2));
    zIdx = find(event_obj.Target.ZData == pos(3));
    % select single data point, and find value
    idx = intersect(intersect(xIdx,yIdx),zIdx);
    value = event_obj.Target.CData(idx(1)); 
    % add to the data cursor text
    output_txt{end+1} = sprintf('Val: %.4f',value);