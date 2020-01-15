// --- Constants ---
SET THROTTLE_BACK to 350.
SET THROTTLE_TARGET to 0.45.
SET BOOST_FUEL_RESERVE to 900.
SET PITCH_OVER to 14000.
SET ORB_INSERT_THRS to 4000.
SET LAUNCHER_MASS to 149.743.
SET PAYLOAD_MASS to SHIP:MASS - LAUNCHER_MASS.

// --- Variables ---
SET booster_sep TO FALSE.
SET has_fairing TO FALSE.
SET burnout TO FALSE.
SET booster_tank to ship:partstagged("bst-tank")[0].
lock booster_fuel to booster_tank:resources[0]:amount.

// --- Functions ---
function ramp_throttle {
    PARAMETER P1.
    PARAMETER P2.
    PARAMETER P3 is 0.1.
    // Parameters:
    // P1 - throttle end
    // P2 - ramp time
    // P3 - time res (optional)

    SET delta to P1 - THROTTLE.
    SET num_steps to P2 / P3.
    SET throt_res to delta / num_steps.

    IF delta > 0 {

        UNTIL THROTTLE > P1 or THROTTLE = P1 {
            SET THROTTLE TO THROTTLE + throt_res.
            WAIT P3.
        }
    }
    ELSE {

        UNTIL THROTTLE < P1 or THROTTLE = P1 {
            SET THROTTLE TO THROTTLE + throt_res.
            WAIT P3.
        }
    }
}

function fairing_check {

    LIST PARTS in comps.
    FOR comp IN comps {
        IF comp:NAME:CONTAINS("fairing") {
            RETURN TRUE.
        }
    }

    RETURN FALSE.
}

function abort_control {
    SET THROTTLE to 0.
    UNLOCK STEERING.
    SAS ON.
    SET SHIP:CONTROL:NEUTRALIZE to True.
    PRINT "RESUMING MANUAL CONTROL.".
}

SET has_fairing to fairing_check().

// --- Abort Conditions --- 
ON ABORT {
    abort_control().
}

ON AG10 {
    abort_control().
}

// --- Async Flight Directives ---

// Landing gear up when rate is positive
WHEN VERTICALSPEED > 5 THEN {
    SET GEAR TO FALSE.
}

// RCS on at predefined alt
WHEN ALTITUDE > 11000 THEN {
    RCS ON.
    PRINT "RCS ON".
    IF has_fairing {
        PRINT "JETT FAIRING".
        STAGE.
    }
}

// Stage boosters when they reach reserve level
WHEN booster_fuel < BOOST_FUEL_RESERVE THEN {
    PRINT "JETT BOOSTERS".
    SET THROTTLE to 0.
    WAIT 0.5.
    STAGE.
    SET THROTTLE to 1.
    SET booster_sep TO TRUE.
}

// --- Syncronized Flight Section --- 

SET countdown to 5.
UNTIL countdown = 0 {
    CLEARSCREEN.
    PRINT "VEHICLE SUMMARY".
    PRINT "Payload mass:         " + PAYLOAD_MASS + " tonnes".
    PRINT "Throttle back speed:  " + THROTTLE_BACK + " m/s".
    PRINT "Throttle back target: " + THROTTLE_TARGET * 100 + "%".
    PRINT "Pitch over altitude:  " + PITCH_OVER + " m".

    PRINT "".
    PRINT "".
    PRINT "Launch in " + countdown.
    WAIT 1. 
    SET countdown to countdown - 1.
}

PRINT "IGNITION". 
SET THROTTLE to 0.3.
ship:partstagged("ship")[0]:controlfrom().
SAS ON.
STAGE. // Let's go!

// Ramp up throttle to start
PRINT "BEGIN THROTTLE RAMP UP".
ramp_throttle(1, 6).
PRINT "END THROTTLE RAMP UP".

UNTIL VERTICALSPEED > THROTTLE_BACK {
    // Wait until climb rate is at defined limit
}

// Throttle back for max Q
PRINT "BEGIN THROTTLE RAMP DOWN 1".
ramp_throttle(THROTTLE_TARGET, 3).
PRINT "END THROTTLE RAMP DOWN".

// Begin pitch over at defined altitude
UNTIL ALTITUDE > PITCH_OVER  {
    
}

set pitch to 90.
LOCK STEERING to HEADING(90,pitch,0).
SAS OFF.

PRINT "BEGIN PITCH OVER 1".
UNTIL pitch < 10 {
    SET pitch to pitch - 0.03.
    WAIT 0.01.
}
PRINT "END PITCH OVER".

// Wait until core booster is empty to proceed
UNTIL booster_sep AND burnout {
    LIST ENGINES in gens.
    FOR gen in gens {
        IF gen:NAME = "engineLargeSkipper" AND gen:FLAMEOUT {
            SET burnout to TRUE.
        }
    }
}

PRINT "STAGING".
SET SHIP:CONTROL:PILOTMAINTHROTTLE to 0.
WAIT 0.5.
STAGE.
SET SHIP:CONTROL:PILOTMAINTHROTTLE to 0.05.

PRINT "BEGIN PITCH OVER 2".
UNTIL pitch < 1 {
    SET pitch to pitch - 0.03.
    WAIT 0.01.
}
PRINT "END PITCH OVER".

PRINT "BEGIN ORBIT INSERTION BURN".
lock diff_from_apoap to SHIP:ORBIT:APOAPSIS - ALTITUDE. 
LOCK throt_percent TO 1 - (diff_from_apoap / ORB_INSERT_THRS).

UNTIL SHIP:ORBIT:PERIAPSIS > 71000 {
    // Wait until perapsis is above atmosphere
    IF diff_from_apoap < ORB_INSERT_THRS {
        SET SHIP:CONTROL:PILOTMAINTHROTTLE to throt_percent.
    }
    ELSE {
        SET SHIP:CONTROL:PILOTMAINTHROTTLE to 0.
    }
}
PRINT "END ORBIT INSERTION BURN".

abort_control().

PRINT "".
PRINT "".
PRINT "Fly safe!".