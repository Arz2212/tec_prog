% Тесты для задачи 2А: удаление каждого третьего элемента
:- consult('task2a.pl').

test_remove_third :-
    TestCases = [
        ([1,2,3,4,5,6,7], [1,2,4,5,7]),
        ([a,b,c,d,e], [a,b,d,e]),
        ([], []),
        ([1], [1]),
        ([1,2], [1,2]),
        ([1,2,3], [1,2]),
        ([1,2,3,4], [1,2,4]),
        ([1,2,3,4,5], [1,2,4,5]),
        ([1,2,3,4,5,6], [1,2,4,5]),
        ([1,2,3,4,5,6,7,8,9], [1,2,4,5,7,8])
    ],
    run_tests_2a(TestCases).

run_tests_2a([]) :-
    format('~n✓ ВСЕ ТЕСТЫ ПРОЙДЕНЫ~n').
run_tests_2a([(Input, Expected) | Rest]) :-
    remove_third(Input, Result),
    (Result = Expected
        -> format('  ✓ remove_third(~w) = ~w~n', [Input, Result])
        ;  format('  ✗ remove_third(~w) = ~w (ожидалось ~w)~n', [Input, Result, Expected])
    ),
    run_tests_2a(Rest).

:- test_remove_third.
