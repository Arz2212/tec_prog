% Пустой список
flatten_one([], []).

flatten_one([H | T], Result) :-
    is_list(H),
    !,
    append(H, RestResult, Result),
    flatten_one(T, RestResult).

flatten_one([H | T], [H | RestResult]) :-
    flatten_one(T, RestResult).
