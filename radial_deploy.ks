list parts in comps.

for comp in ship:partstagged("radial-deploy") {
        print "rolling...".
        comp:controlfrom().
        set dir_to_face to r(ship:facing:pitch, ship:facing:yaw, 270).
        sas off.
        lock steering to dir_to_face.
        wait 10.
        sas on.
        unlock steering.
        comp:decoupler:getmodule("ModuleAnchoredDecoupler"):doevent("decouple").
        print "away".  
}

ship:partstagged("ship")[0]:controlfrom().
set dir_to_face to r(ship:facing:pitch, ship:facing:yaw, 270).
wait 5.
unlock steering.
SET SHIP:CONTROL:NEUTRALIZE to True.
PRINT "RESUMING MANUAL CONTROL.".