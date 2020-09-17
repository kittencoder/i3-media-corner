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
    echo -e "[\e[91m BXDSWFC \e[0m]"
    echo -e "Setting class on window \e[93m$wname\e[0m to \e[93m$targetclass\e[0m"
    xprop -id $wid -f WM_CLASS 8s -set WM_CLASS $targetclass
    echo -e "[\e[91m AXDSWFC \e[0m]"

    # Announce script starting
    echo -e "Dragging along window \e[95m$wname\e[0m [\e[36m$wid\e[0m]"

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
        echo -e "Adjusting width to \e[35m"(math "floor(floor((($w/100)*$setw)*$wfac)/$w*100)")"\e[0m%. of screen size"
        i3-msg "[id=\"$wid\"] resize set width "(math "floor((($w/100)*$setw)*$wfac)") >/dev/null
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
        echo -e "Adjusting height to ratio \e[35m$setw\e[0m/\e[35m$seth\e[0m."
        i3-msg "[id=\"$wid\"] resize set height "(math "floor($winWidth*($seth/$setw))") >/dev/null
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

    i3-msg "[id=\"33554437\"] move absolute position $x $y" >/dev/null

    ###
    ### Main window dragging script
    ###
    ##  updates whenever a window is changed
    ##  -> to use less resources, and detect workspace-changes upon that
    ##
    set pws UNSET
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
        end
        # if $cws != $pws
        # wait for a title change or timeout (wichever earlier) to trigger a refresh
        timeout 1m xtitle -s | read >/dev/null
        echo $status >/dev/null
    end
    # while true

end
# function
function DRAG_WINDOW_checkSystem --description "check system for required binaries and provide install-instructions in case of missing software"
    if not which xtitle >/dev/null
        echo "# xtitle script for showing the current window title"
        echo "apt -y install libxcb-ewmh-dev"
        echo "git clone --recursive --depth 1 https://github.com/baskerville/xtitle"
        echo "pushd xtitle"
        echo make
        echo "sudo make install"
        echo popd
        echo "rm -rf xtitle"
    end
    if not which xdotool >/dev/null
        echo "# xdotool for identifying windows"
        echo "sudo apt install -y xdotool"
    end
    if not which jq >/dev/null
        echo "# jq for parsing and going through json data"
        echo "sudo apt install -y jq"
    end
    echo -e "# autogenerated install script done!"
end
