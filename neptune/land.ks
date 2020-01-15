// --- Constants ---
SET GEAR_THRES to 1000.
SET DESC_TARG to -10.

// --- State Machine ---
CLEARSCREEN.
// System begins in wait state
set state to 0.
print "State: On pad".

// Go to wait state when launch detected
WHEN state = 0 and VERTICALSPEED > 5 THEN {
    
    set state to 1.
    print "State: Waiting".
}

// Go to falling state when neg rae detected
WHEN state = 1 and VERTICALSPEED < -1 THEN {
    
    ship:partstagged("bst")[0]:getmodule("ModuleCommand"):setfield("hibernation", false).
    rcs on.
    sas on.
    set sasmode to "retrograde".
    for brake in ship:partstagged("brake-fin"){
        brake:getmodule("ModuleAeroSurface"):setfield("pitch", false).
        brake:getmodule("ModuleAeroSurface"):setfield("yaw", false).
    }

    set state to 2.
    print "State: Falling".
}

// Deploy gear when falling and under threshold alt
WHEN state = 2 and altitude < 1000 THEN {

    set gear to true.
    set state to 3.
    print "DEPLOY GEAR".
}

UNTIL state = 2 {

}

set brakes to true.

until altitude < 3000 {

}

print "State: Controlled descent".

UNTIL state = 3 {

    IF VERTICALSPEED < -100  {

        set throttle to 0.5.
    }

    IF VERTICALSPEED > -100  {

        set throttle to 0.
    }

    wait 0.5.
}

print "State: Landing control".

UNTIL ship:status = "LANDED" {

    If altitude < 400 and altitude > 200 {

        IF VERTICALSPEED < DESC_TARG  {

            set throttle to 0.25.
        }

        IF VERTICALSPEED > DESC_TARG  {

            set throttle to 0.
        }
    }
    else if altitude < 200 {

            IF VERTICALSPEED < DESC_TARG  {

            set throttle to 0.2.
        }

        IF VERTICALSPEED > DESC_TARG  {

            set throttle to 0.
        } 
    }
    ELSE {

        IF VERTICALSPEED < DESC_TARG  {

            set throttle to 0.3.
        }

        IF VERTICALSPEED > DESC_TARG  {

            set throttle to 0.
        }
    }

    wait 0.1.
}

set throttle to 0.
set brakes to false.
print "landed".