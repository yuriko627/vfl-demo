#!/usr/bin/env fish

osascript -e '
tell application "iTerm"
    activate
    create window with default profile

    tell current window
        -- Pane 1: Client1
        tell current session
            write text "cd ./vfl-demo/clients/client1/client1_training && fish client1_train.fish"
            split vertically with default profile
        end tell

        -- Pane 2: Client2
        tell session 2 of current tab
            write text "cd ./vfl-demo/clients/client2/client2_training && fish client2_train.fish"
            split vertically with default profile
        end tell

        -- Pane 3: Client3
        tell session 3 of current tab
            write text "cd ./vfl-demo/clients/client3/client3_training && fish client3_train.fish"
        end tell
    end tell
end tell'
