%% This code is to generate prior term

function labelcost = label_prior(ita,C)
disp('------compute labelcost-------');
    [X, Y] = meshgrid(0:C-1, 0:C-1);
    labelcost = min(abs(X - Y),ita);
end