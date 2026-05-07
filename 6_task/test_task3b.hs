-- Тесты для задачи 3Б: строка из трёх слов

import Task3B

main :: IO ()
main = do
    putStrLn "=== Тесты задачи 3Б: строка из трёх слов ==="

    let testCases =
            [ ("hello world foo",           True,  "три слова без лишних пробелов")
            , ("  hello  world  foo  ",     True,  "три слова с пробелами по краям и между")
            , ("a b c",                     True,  "три однобуквенных слова")
            , ("first second third",        True,  "три обычных слова")
            , ("  one   two   three  ",     True,  "три слова, много пробелов")
            , ("\tword1  word2\tword3\n",   True,  "три слова с табуляцией и переносом")
            , ("hello world",               False, "два слова")
            , ("one",                       False, "одно слово")
            , ("",                          False, "пустая строка")
            , ("     ",                     False, "только пробелы")
            , ("one two three four",        False, "четыре слова")
            , ("  leading spaces",          False, "два слова с ведущими пробелами")
            ]

    let passed = length [() | (s, expected, _) <- testCases,
                              consistsOfThreeWords s == expected]
    let total  = length testCases

    mapM_ runTest testCases

    putStrLn $ "\nПройдено: " ++ show passed ++ "/" ++ show total
    if passed == total
        then putStrLn "✓ Все тесты задачи 3Б пройдены"
        else fail "Некоторые тесты НЕ пройдены"

runTest :: (String, Bool, String) -> IO ()
runTest (s, expected, desc) = do
    let result = consistsOfThreeWords s
    let ok = result == expected
    putStrLn $ "  " ++ (if ok then "✓" else "✗") ++ " " ++ desc
            ++ " → " ++ show result
            ++ (if not ok then " (ожидалось " ++ show expected ++ ")" else "")
