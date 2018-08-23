% kind_out = HM_function_preprocess_deck(kind,do_connect)
function kind_out = HM_function_preprocess_deck(kind,do_connect)

    % ********************
    % Change DE into DD **
    % ********************
    disp('Combine east and west germany')
    logic_1 = ismember(double(kind(:,1:2)),['DD'],'rows');
    kind(logic_1,2) = 'E';

    % *****************************************
    % Change no counrty into their deck name **
    % *****************************************
    disp('Assign nations with deck information')
    logic_1 = ismember(double(kind(:,1:2)),['  '],'rows');
    kind(logic_1,1:2) = [kind(logic_1,3) kind(logic_1,3)];

    % ****************
    % connect decks **
    % ****************
    disp('Connect decks')
    if do_connect == 1,
        kind = HM_function_connect_deck(double(kind));
    end

    kind_out = kind;
end
