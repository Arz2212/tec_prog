% Тесты для задачи 3Б: проверка нечётной длины списка
:- consult('task3b.pl').

test_odd_length :-
    format('=== Проверка нечётной длины ===~n'),
    % Тесты, которые ДОЛЖНЫ быть истиной (нечётная длина)
    TruthCases = [
        [1],
        [a,b,c],
        [1,2,3,4,5],
        [x,y,z,w,v]
    ],
    format('~nСлучаи с нечётной длиной (должны быть true):~n'),
    forall(member(List, TruthCases),
        (   (odd_length(List) -> Status = '✓ true ' ; Status = '✗ false')
        ,   format('  ~s: odd_length(~w)~n', [Status, List])
        )).

test_odd_length_false :-
    format('~n=== Проверка чётной длины ===~n'),
    % Тесты, которые ДОЛЖНЫ быть ложью (чётная длина)
    FalseCases = [
        [],
        [1,2],
        [a,b,c,d],
        [1,2,3,4,5,6]
    ],
    format('~nСлучаи с чётной длиной (должны быть false):~n'),
    forall(member(List, FalseCases),
        (   (odd_length(List) -> Status = '✗ true ' ; Status = '✓ false')
        ,   format('  ~s: odd_length(~w)~n', [Status, List])
        )).

:- test_odd_length, test_odd_length_false.
