#!/bin/bash
# _tools/runner/permission-selftest/impl/sandbox-exec.sh
#
# Перевіряє права доступу всередині sandbox-exec сесії.
# Формат tests-файлу: description|command|expected
#   expected: "deny"  — очікуємо, що команда впаде з помилкою (доступ заборонено)
#             "allow" — очікуємо, що команда виконається успішно (доступ дозволено)

echo "PERMISSION SELF-CHECK - before started."

TESTS_FILE="$1"
FAILED=0

# if mode == 0 -> we must check test hard
# otherwise -> just show tests result but continue to start sandbox. This is flag for debugging.
MODE=0

# читаємо файл тестів рядок за рядком, розбиваючи кожен рядок по "|" на 3 змінні
while IFS="|" read -r description command expected; do
  # пропускаємо порожні рядки та коментарі
  [[ -z "$description" || "$description" == \#* ]] && continue

  echo "Command: $command."

  # виконуємо команду з тесту:
  # "> /dev/null" — глушимо звичайний вивід (stdout), він нам не потрібен
  # "2>&1" — після цього направляємо помилки (stderr) туди, куди зараз йде stdout,
  #          тобто в змінну error_output потрапляє тільки текст помилки, якщо вона була
  error_output=$(bash -c "$command" 2>&1 > /dev/null)

  # $? — код завершення останньої команди: 0 = успіх, будь-що інше = помилка
  # locale-незалежний спосіб визначити deny/allow, на відміну від пошуку тексту помилки
  exit_code=$?

  # ненульовий код = сталася помилка = команда була заблокована = "deny"
  if [ "$exit_code" -ne 0 ]; then
    result="deny"
    # логуємо факт помилки одразу тут, незалежно від того, чи це очікувано —
    # бо сам факт помилки і її текст цінні для дебагу в будь-якому випадку
    echo "[$description] exit $exit_code: $error_output"
  else
    result="allow"
  fi

  # порівнюємо реальний результат з тим, що очікували в tests-файлі
  if [ "$result" == "$expected" ]; then
    echo "[OK ✅] $description"
  else
    # результат не збігся з очікуваним — це провал: або заборонене не заблокувалось,
    # або дозволене чомусь не спрацювало (наприклад, профіль занадто суворий)
    echo "[FAIL ❌] $description (очікував $expected, отримав $result, exit code $exit_code)"
    FAILED=1
  fi
  echo " "

done < "$TESTS_FILE"

# Handle tests result - if it failed or not.
# повертаємо 0 тільки якщо всі тести пройшли — той, хто викликав цей скрипт,
# перевіряє цей код і вирішує, чи відкривати сесію далі
echo "FAILED: $FAILED"
echo "MODE: $MODE"

if [ "$FAILED" -eq 0 ]; then
  echo "PERMISSION SELF-CHECK - done ✅."
  exit 0
elif [ "$MODE" -eq 0 ]; then
  echo "PERMISSION SELF-CHECK - failed ❌."
  exit $FAILED
else
  echo "PERMISSION SELF-CHECK - failed ❌ but this is [DEBUG] mode (won't throw error)."
  exit 0
fi
