// --- Constants ---
SET BRAKE_THRES to 30000.
SET R_CHUTE_THRESH to 1500.
SET F_CHUTE_THRESH to 800.

// --- Variables ---
SET DEPLOY_ANG to 0.

// --- State Machine ---
CLEARSCREEN.
// System begins in wait state
set state to 0.
print "on pad".

WHEN VERTICALSPEED > 5 THEN {

    set state to 1.
    print "waiting".
}

// Go to falling state when neg rae detected
WHEN state = 1 and VERTICALSPEED < -1 THEN {

    ship:partstagged("core")[0]:getmodule("ModuleCommand"):setfield("hibernation", false).
    sas on.
    set sasmode to "prograde".

    set state to 2.
    print "falling".
}

WHEN state = 2 and ALTITUDE < R_CHUTE_THRESH THEN {
    
    stage.
    print "deployed rear chutes".
}


WHEN state = 2 and ALTITUDE < F_CHUTE_THRESH THEN {
    
    stage.
    sas off.
    print "deployed forward chutes".
}

UNTIL state = 2 AND ALTITUDE < BRAKE_THRES {

}

set brakes to true.

UNTIL DEPLOY_ANG = 90 {

    set DEPLOY_ANG to DEPLOY_ANG + 1.
    for brake in ship:partstagged("airbrake"){
        brake:getmodule("ModuleAeroSurface"):setfield("deploy angle", DEPLOY_ANG).
    }

    WAIT 0.5.
}

UNTIL ship:status = "SPLASHED" {

}

set brakes to false.
print "splashed".