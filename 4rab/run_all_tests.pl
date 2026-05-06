% Скрипт для запуска всех тестов
% Запуск: swipl -s run_all_tests.pl -t halt

:- initialization(run_all, main).

run_all :-
    format('========================================~n'),
    format('  ЗАПУСК ВСЕХ ТЕСТОВ~n'),
    format('========================================~n~n'),

    format('--- Задача 1А: тётя-племянница ---~n'),
    consult('test_task1a.pl'),
    nl,

    format('--- Задача 2А: удалить каждый 3-й ---~n'),
    consult('test_task2a.pl'),
    nl,

    format('--- Задача 3Б: нечётная длина ---~n'),
    consult('test_task3b.pl'),
    nl,

    format('--- Задача 4Б: вхождение списка ---~n'),
    consult('test_task4b.pl'),
    nl,

    format('--- Задача 5А: flatten 1 уровень ---~n'),
    consult('test_task5a.pl'),
    nl,

    format('========================================~n'),
    format('  ВСЕ ТЕСТЫ ЗАВЕРШЕНЫ~n'),
    format('========================================~n').
