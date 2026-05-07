% Тесты для задачи 5А: flatten одного уровня
:- consult('task5a.pl').

test_flatten_one :-
    TestCases = [
        ([[a,b],[1,2,3],[c,d,[e,f]],[],[4]], [a,b,1,2,3,c,d,[e,f],4]),
        ([[],[],[]], []),
        ([[]], []),
        ([[a]], [a]),
        ([a,b,c], [a,b,c]),
        ([[1,2],[3,4]], [1,2,3,4])
    ],
    run_tests_5a(TestCases).

run_tests_5a([]) :-
    format('~n✓ ВСЕ ТЕСТЫ ПРОЙДЕНЫ~n').
run_tests_5a([(Input, Expected) | Rest]) :-
    flatten_one(Input, Result),
    (Result = Expected
        -> format('  ✓ flatten_one(~w) = ~w~n', [Input, Result])
        ;  format('  ✗ flatten_one(~w) = ~w (ожидалось ~w)~n', [Input, Result, Expected])
    ),
    run_tests_5a(Rest).

:- test_flatten_one.
