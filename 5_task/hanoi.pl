

hanoi(N, Moves) :-
    integer(N),
    N > 0,
    N =< 10,
    hanoi_solve(N, left, right, center, Moves).

ъ

hanoi_solve(1, From, To, _Via, [move(From, To)]) :- !.

hanoi_solve(N, From, To, Via, Moves) :-
    N > 1,
    N1 is N - 1,
    hanoi_solve(N1, From, Via, To, Moves1),
    hanoi_solve(1, From, To, Via, Middle),
    hanoi_solve(N1, Via, To, From, Moves2),
    append(Moves1, Middle, Temp),
    append(Temp, Moves2, Moves).

% --- Проверка решения: validate(+N, +Moves) ---

validate(N, Moves) :-
    % Диски: 1 (самый маленький/верхний) ... N (самый большой/нижний).
    % Список на стержне: [верхний, ..., нижний].
    numlist(1, N, Disks),
    State = state(Disks, [], []),
    apply_moves(Moves, State, FinalState),
    % Конечное состояние: все диски на правом стержне, порядок сохранён.
    FinalState = state([], [], Disks).

apply_moves([], State, State).
apply_moves([move(From, To) | Rest], State, FinalState) :-
    apply_one_move(From, To, State, NextState),
    apply_moves(Rest, NextState, FinalState).

% Снять верхний диск со стержня From, положить на стержень To.
apply_one_move(From, To, state(L, C, R), state(L1, C1, R1)) :-
    take_from(From, state(L, C, R), Disk, state(L0, C0, R0)),
    put_on(To, Disk, state(L0, C0, R0), state(L1, C1, R1)).

take_from(left,  state([Top|Rest], C, R), Top, state(Rest, C, R)).
take_from(center,state(L, [Top|Rest], R), Top, state(L, Rest, R)).
take_from(right, state(L, C, [Top|Rest]), Top, state(L, C, Rest)).

put_on(left,  Disk, state(L, C, R), state([Disk|L], C, R)) :-
    (L = []; L = [Top|_], Disk < Top).
put_on(center,Disk, state(L, C, R), state(L, [Disk|C], R)) :-
    (C = []; C = [Top|_], Disk < Top).
put_on(right, Disk, state(L, C, R), state(L, C, [Disk|R])) :-
    (R = []; R = [Top|_], Disk < Top).



hanoi_moves_count(N, Count) :-
    Count is 2**N - 1.

% Печать решения

print_solution(N) :-
    hanoi(N, Moves),
    hanoi_moves_count(N, ExpectedCount),
    length(Moves, ActualCount),
    format('~nХанойская башня: N = ~d дисков~n', [N]),
    format('Ожидаемое число ходов: ~d~n', [ExpectedCount]),
    format('Фактическое число ходов: ~d~n~n', [ActualCount]),
    print_moves(Moves, 1).

print_moves([], _).
print_moves([move(From, To) | Rest], Index) :-
    format('  Ход ~d: ~w -> ~w~n', [Index, From, To]),
    NextIndex is Index + 1,
    print_moves(Rest, NextIndex).


:- initialization(main, main).

main :-
    current_prolog_flag(argv, Argv),
    (   Argv = [_, NStr]
    ->  atom_number(NStr, N),
        hanoi(N, Moves),
        maplist(format_move, Moves, Lines),
        maplist(writeln, Lines),
        halt(0)
    ;   writeln('Usage: swipl -g main -t halt hanoi.pl -- N'),
        halt(1)
    ).

format_move(move(From, To), Line) :-
    format(string(Line), '~w -> ~w', [From, To]).
