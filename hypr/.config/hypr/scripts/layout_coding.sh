#!/bin/bash

# Функция для ожидания появления окна по классу
wait_for_window() {
    local class=$1
    local timeout=15  # Увеличил таймаут до 15 секунд
    local elapsed=0
    echo "Ожидаем окно с классом: $class"
    while [ $elapsed -lt $timeout ]; do
        if hyprctl clients | grep -q "class: $class"; then
            echo "Окно $class появилось"
            return 0
        fi
        sleep 0.3
        elapsed=$((elapsed + 1))
    done
    echo "Таймаут ожидания окна $class"
    return 1
}

# Функция для ожидания окна по части названия (для xdg-terminal-exec)
wait_for_window_title() {
    local title_part=$1
    local timeout=15
    local elapsed=0
    echo "Ожидаем окно с title содержащим: $title_part"
    while [ $elapsed -lt $timeout ]; do
        if hyprctl clients | grep -i "title:.*$title_part"; then
            echo "Окно с title '$title_part' появилось"
            return 0
        fi
        sleep 0.3
        elapsed=$((elapsed + 1))
    done
    echo "Таймаут ожидания окна с title '$title_part'"
    return 1
}

# 1. VS Code - слева, полная высота
code &
if wait_for_window "Code" "code"; then
    hyprctl dispatch movewindow l
    hyprctl dispatch resizeactive exact 50% 100%
    hyprctl dispatch movewindow 0 0
else
    echo "VS Code не запустился вовремя"
fi

# Небольшая пауза между операциями
#sleep 0.2

# 2. Obsidian - справа сверху
obsidian &
if wait_for_window "obsidian" "obsidian"; then
    hyprctl dispatch movewindow r
    hyprctl dispatch resizeactive exact 50% 50%
    hyprctl dispatch movewindow 50% 0
else
    echo "Obsidian не запустился вовремя"
fi

#sleep 0.2

# 3. Docker (lazydocker) - справа снизу
xdg-terminal-exec --app-id=TUI.tile -e lazydocker &

# Для xdg-terminal-exec нужно ожидать либо конкретный класс, либо title
if wait_for_window "TUI.tile" "TUI.tile" || wait_for_window_title "lazydocker"; then
    hyprctl dispatch movewindow r
    hyprctl dispatch resizeactive exact 50% 50%
    hyprctl dispatch movewindow 50% 50%
else
    echo "Lazydocker не запустился вовремя"
fi

# фокус на VS Code
hyprctl dispatch focuswindow class:Code
