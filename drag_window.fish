#!/usr/bin/env fish
function drag_window --description "drag the clicked window to all visited workspaces"
    ###
    ### check arguments          
    ###
    set -l current false
    set -l setw false
    set -l seth false
    set -l awid false
    set -l wfac 1
    set -l position tr
    set -l margin 50
    set -l marginh false
    set -l targetclass floating
    set -l evade false
    set -l evadeEnabled false
    for arg in $argv
        if [ "$setw" = true ]
            set setw $arg
            continue
        end
        if [ "$seth" = true ]
            set seth $arg
            continue
        end
        if [ "$awid" = true ]
            set awid $arg
            continue
        end
        if [ "$wfac" = true ]
            set wfac $arg
            continue
        end
        if [ "$margin" = true ]
            set margin $arg
            continue
        end
        if [ "$marginh" = true ]
            set marginh $arg
            continue
        end
        if [ "$targetclass" = true ]
            set targetclass $arg
            continue
        end
        if [ "$evade" = true ]
            # set evade $arg
            set evadeEnabled true
            continue
        end

        switch $arg
            case current
                set current true
            case w
                set setw true
            case h
                set seth true
            case id
                set awid true
            case wfac
                set wfac true
            case margin
                set margin true
            case marginh
                set marginh true
            case targetclass
                set targetclass true
            case evade
                set evade true
                set evadeEnabled true
            case tr
                set position tr
            case tl
                set position tl
            case br
                set position br
            case bl
                set position bl
            case checkSystem
                echo -e "# Providing install script: "
                DRAG_WINDOW_checkSystem
                return
            case help
                echo -e "Usage:"
                echo -e "drag_window [\e[33mcurrent\e[0m] [\e[33mtl\e[0m|\e[33mtr\e[0m|\e[33mbr\e[0m|\e[33mbl\e[0m] [\e[33mw \e[35mnumber\e[0m] [\e[33mh \e[35mnumber\e[0m] [\e[33mid \e[35mnumber\e[0m] [\e[33mwfac \e[35mnumber\e[0m] [\e[33mmargin \e[35mnumber\e[0m] [\e[33mmarginh \e[35mnumber\e[0m] [\e[33mtargetclass \e[35mword\e[0m] [\e[33mcheckSystem\e[0m]"
                echo -e "               `-~-> drags the selected window to the current workspace until script is terminated (front-mini-media-player)"
                echo ""
                echo -e "           \e[33mcurrent\e[0m : defaults to \e[94mfalse\e[0m, automatically selects the currently focused window (useful when used with a hotkey)"
                echo ""
                echo -e "     [\e[33mtl\e[0m|\e[33mtr\e[0m|\e[33mbr\e[0m|\e[33mbl\e[0m] : defaults to \e[94m$position\e[0m, \e[32mtop-left\e[0m, \e[32mtop-right\e[0m, \e[32mbottom-right\e[0m, \e[32mbottom-left\e[0m alignment"
                echo ""
                echo -e "        [\e[33mw \e[35mnumber\e[0m] : defaults to \e[94mfalse\e[0m, width in percentage of total screen width"
                echo ""
                echo -e "        [\e[33mh \e[35mnumber\e[0m] : defaults to \e[94mfalse\e[0m, height in relation to windows with (eg. use w 16 h 9 to set a 16:9 ratio, use in conjunction with [\e[33mwfac\e[0m] for best effect)"
                echo ""
                echo -e "       [\e[33mid \e[35mnumber\e[0m] : defaults to \e[94mfalse\e[0m, pass a window-id to select a window (instead of click select, or current window)"
                echo ""
                echo -e "     [\e[33mwfac \e[35mnumber\e[0m] : defaults to \e[94m$wfac\e[0m, scale the window-size by that factor"
                echo ""
                echo -e "   [\e[33mmargin \e[35mnumber\e[0m] : defaults to \e[94m$margin\e[0m, how far away from the screen-border"
                echo ""
                echo -e "  [\e[33mmarginh \e[35mnumber\e[0m] : defaults to \e[94m\$margin\e[0m, how far away from the screen-border horizontally\n                   `-> when not specified same as \e[33m\$margin\e[0m, when specified \e[33m\$margin\e[0m is for vertical margin"
                echo ""
                echo -e "[\e[33mtargetclass \e[35mword\e[0m] : defaults to \e[94m$targetclass\e[0m, the window-class to be set as floating-active (useful for making it transparent, etc.)"
                echo ""
                echo -e "           [\e[33mevade\e[0m] : defaults to \e[94m$evade\e[0m, when activated the window will evade the mouse quadrant of the screen, to click the window, focus it (via keyboard-focus-floating?)"
                echo ""
                echo -e "     [\e[33mcheckSystem\e[0m] : checks the system for executables and provides pipeable installation instructions"
                echo ""
                return
        end
    end

    ### 
    ### Selection of window
    ### 
    if $current
        echo -e "Selecting current window..."
        set wid (xdotool getwindowfocus getwindowpid)
    else if [ "$awid" != false ]
        echo -e "Using Window id [\e[36m$awid\e[0m]"
        set wid $awid
    else
        echo -e "Please select the window to drag along..."
        # select window with click
        set wid (xdotool selectwindow)
    end
    # get window name for printing
    set wname (xprop -id $wid | egrep "_NET_WM_NAME" | sed -r 's/^_NET_WM_NAME.[^)]*.\s*=\s*"([^"]*)"/\1/g')

    # float window if not yet floated
    set -l isFloated (xprop -id $wid | egrep "I3_FLOATING_WINDOW" | wc -l)
    if [ $isFloated -gt 0 ]
        echo -e "window \e[93m$wname\e[0m$isFloated already floated"
    else
        echo -e "Float window \e[93m$wname\e[0m$isFloated"
        i3-msg "[id=\"$wid\"] floating toggle" >/dev/null
    end
    # set floating-class on window
    echo -e "Setting class on window \e[93m$wname\e[0m to \e[93m$targetclass\e[0m"
    xprop -id $wid -f WM_CLASS 8s -set WM_CLASS $targetclass

    # Announce script starting
    echo -e "Dragging along window \e[95m$wname\e[0m [\e[36m$wid\e[0m] TO $position"
    DRAG_WINDOW_setCorner $wid $setw $seth $margin $marginh $wfac $position

    ###
    ### Main window dragging script
    ###
    ##  updates whenever a window is changed
    ##  -> to use less resources, and detect workspace-changes upon that
    ##
    set pws UNSET
    set lmouseCorner NONE
    set cpos $position
    while true
        # main function loop
        # monitor for switching workspaces
        set cws (i3-msg -t get_workspaces | jq '.[] | select(.focused==true).name' | cut -d"\"" -f2)
        if [ "$cws" != "$pws" ]
            # move window if workspace changed and update last move target
            i3-msg '[id="'$wid'"] move to workspace '$cws >/dev/null
            if [ "$pws" != UNSET ]
                echo -e "Moving \e[95m$wname\e[0m from WS \e[33m$pws\e[0m to \e[92m$cws\e[0m"
            end
            set pws $cws
        else if $evadeEnabled
            set -l windowFocused (i3-msg -t get_tree | jq '.. | select(.window==33554437)? | .focused')
            if ! $windowFocused
                set -l c (DRAG_WINDOW_getCorner)
                if [ "$lmouseCorner" != "$c" ]
                    set lmouseCorner $c
                    if [ "$c" = "$position" ]
                        switch $position
                            case tl
                                DRAG_WINDOW_setCorner $wid $setw $seth $margin $marginh $wfac bl
                                set cpos bl
                            case tr
                                DRAG_WINDOW_setCorner $wid $setw $seth $margin $marginh $wfac br
                                set cpos br
                            case bl
                                DRAG_WINDOW_setCorner $wid $setw $seth $margin $marginh $wfac tl
                                set cpos tl
                            case br
                                DRAG_WINDOW_setCorner $wid $setw $seth $margin $marginh $wfac tr
                                set cpos tr
                        end
                    else
                        # if in main quadrant, if not move back
                        DRAG_WINDOW_setCorner $wid $setw $seth $margin $marginh $wfac $position
                        set cpos $position
                    end
                end
                # if moved
            end # if not focused
        end
        #  else if evading mode
        DRAG_WINDOW_waitForEvent $evadeEnabled
        echo $status >/dev/null
    end
    # while true

end

function DRAG_WINDOW_setCorner --description "INTERNAL: set the window to a specific corner"
    set wid $argv[1]
    set setw $argv[2]
    set seth $argv[3]
    set margin $argv[4]
    set marginh $argv[5]
    set wfac $argv[6]
    set position $argv[7]

    # get window name for printing
    set wname (xprop -id $wid | egrep "_NET_WM_NAME" | sed -r 's/^_NET_WM_NAME.[^)]*.\s*=\s*"([^"]*)"/\1/g')
    # screen-size
    set w (i3-msg -t get_workspaces | jq '.[] | select(.focused==true).rect.width')
    set h (i3-msg -t get_workspaces | jq '.[] | select(.focused==true).rect.height')
    # window-data
    set windata (i3-msg -t get_tree | jq '.. | select(.window=='$wid')? | .')
    # window current dimensions
    set winWidth (echo $windata | jq '.rect.width')
    set winHeight (echo $windata | jq '.rect.height')
    # set width if specified
    if [ "$setw" != false ]
        set nw (math "floor($wfac*($setw * $w)/100)")
        if [ "$nw" != "$winWidth" ]
            echo -e "Adjusting width from \e[35m$winWidth\e[0mpx to \e[35m"$nw"\e[0mpx"
            i3-msg "[id=\"$wid\"] resize set width "$nw >/dev/null
        end
        # window-data (refresh after resize)
        set windata (i3-msg -t get_tree | jq '.. | select(.window=='$wid')? | .')
        # window current dimensions
        set winWidth (echo $windata | jq '.rect.width')
        set winHeight (echo $windata | jq '.rect.height')
    else
        set setw 100
    end
    # set height if specified
    if [ "$seth" != false ]
        set nh (math "floor($winWidth*($seth/$setw))")
        if [ "$nh" != "$winHeight" ]
            echo -e "Adjusting height from \e[35m$winHeight\e[0mpx to \e[35m$nh\e[0mpx"
            i3-msg "[id=\"$wid\"] resize set height "$nh >/dev/null
        end
        # window-data (refresh after resize)
        set windata (i3-msg -t get_tree | jq '.. | select(.window=='$wid')? | .')
        # window current dimensions
        set winWidth (echo $windata | jq '.rect.width')
        set winHeight (echo $windata | jq '.rect.height')
    end

    # window current dimensions
    set winWidth (echo $windata | jq '.rect.width')
    set winHeight (echo $windata | jq '.rect.height')
    # calc positions

    # top-right (default)
    set x (math "($w-$winWidth-$margin)")
    set y (math "($margin)")

    switch $position
        case tl
            # top-left
            set x (math "($margin)")
            set y (math "($margin)")
        case tr
            # top-right
            set x (math "($w-$winWidth-$margin)")
            set y (math "($margin)")
        case bl
            # bottom-left
            set x (math "($margin)")
            set y (math "($h-$winHeight-$margin)")
        case br
            # bottom-right
            set x (math "($w-$winWidth-$margin)")
            set y (math "($h-$winHeight-$margin)")
    end

    echo -e "Moving window \e[93m$wname\e[0m to position \e[94m$position\e[0m."
    i3-msg "[id=\"$wid\"] move absolute position $x $y" >/dev/null
end
function DRAG_WINDOW_getCorner --description "INTERNAL: get the current corner the mouse is in"
    # screen-size
    set w (i3-msg -t get_workspaces | jq '.[] | select(.focused==true).rect.width')
    set h (i3-msg -t get_workspaces | jq '.[] | select(.focused==true).rect.height')

    set -l mp (xdotool getmouselocation --shell)
    set -l x (echo $mp[1] | egrep -o "[0-9]*")
    set -l y (echo $mp[2] | egrep -o "[0-9]*")

    set -l top true
    if [ (math "floor($y/$h*2)") -gt 0 ]
        set top false
        echo -n b
    else
        echo -n t
    end
    set -l right false
    if [ (math "floor($x/$w*2)") -gt 0 ]
        set right true
        echo -n r
    else
        echo -n l
    end

end

function DRAG_WINDOW_checkRunning --description "INTERNAL: check if the background listeners for update-events are running"
    set -l j (jobs)
    set -l jobsXtitle (echo $j | egrep "xtitle" | wc -l)
    if [ $jobsXtitle -gt 0 ]
        echo xtitle
    end
    set -l mousemove (echo $j | egrep "getmouselocation" | wc -l)
    if [ $mousemove -gt 0 ]
        echo getmouselocation
    end
end

function DRAG_WINDOW_waitForEvent --description "INTERNAL: waits for an event occur that would justify an update"
    set -l c (DRAG_WINDOW_checkRunning)


    if ! $argv[1]
        timeout 1m xtitle -s | read >/dev/null
    end

    # wait for a title change or timeout (wichever earlier) to trigger a refresh
    if [ (echo $c | egrep -o "xtitle" | wc -l) -lt 1 ]
        fish -c "timeout 1m xtitle -s | read >/dev/null" &
    end
    if [ (echo $c | egrep -o "getmouselocation" | wc -l) -lt 1 ]
        fish -c 'set -l mp (xdotool getmouselocation --shell);xdotool mousemove --sync (echo $mp[1] | egrep -o "[0-9]*") (echo $mp[2] | egrep -o "[0-9]*")' &
    end
    while true
        set -l r (DRAG_WINDOW_checkRunning | wc -l)
        if [ $r -lt 2 ]
            return
        end
        sleep 0.1
    end
end
