SWITCH TO 0.
DELETEPATH("0:/flight_data.csv").

LOCK log_line to MISSIONTIME  + ", " + 
                 altitude     + ", " + 
                 SHIP:GROUNDSPEED  + ", " +
                 SHIP:VERTICALSPEED + ", " +
                 SHIP:Q + ", " +
                 SHIP:CONTROL:PILOTMAINTHROTTLE + ", " + 
                 SHIP:CONTROL:PILOTPITCH.

LOG "time, altitude, ground speed, vertial speed, dynamic pressure, throttle, pitch" to flight_data.csv.

PRINT "Awaiting lauch. Fly safe!".

UNTIL MISSIONTIME > 0 { // Wait until mission starts 
}

PRINT "---starting telemetry---".

UNTIL altitude > 100000 {
    
    LOG log_line to flight_data.csv.
    WAIT 0.04.
}

SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.0.
LOG ",,,,,,," + "Orbit: " + SHIP:OBT:SEMIMAJORAXIS + "x" + SHIP:OBT:SEMIMINORAXIS to flight_data.csv.

PRINT "---end telemetry---".
PRINT "Orbit: " + SHIP:OBT:SEMIMAJORAXIS + "x" + SHIP:OBT:SEMIMINORAXIS.

