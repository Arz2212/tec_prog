hanoi(N, Moves) :-
    integer(N),
    N > 0,
    N =< 10,
    hanoi_solve(N, left, right, center, Moves).

hanoi_solve(1, From, To, _Via, [move(From, To)]) :- !.

hanoi_solve(N, From, To, Via, Moves) :-
    N > 1,
    N1 is N - 1,
    hanoi_solve(N1, From, Via, To, Moves1),
    hanoi_solve(1, From, To, Via, Middle),
    hanoi_solve(N1, Via, To, From, Moves2),
    append(Moves1, Middle, Temp),
    append(Temp, Moves2, Moves).
