list parts in comps.
set deployables to ship:partstagged("radial-deploy").

// If num of deployables is even, contine
if mod(deployables:length, 2) = 0 {

    set num_half to deployables:length / 2.

    FROM {local x is 0.} UNTIL x = num_half STEP {set x to x+1.} DO  {

        // reset ship between deployments
        ship:partstagged("ship")[0]:controlfrom().
        set sasmode to "prograde".
        sas on. 
        wait 1. 
        
        print "Deploying " + (x + 1) + " of " + num_half.
        set comp to deployables[x].
        set opp_comp to deployables[x + num_half].
        print "rolling...".
        comp:controlfrom().
        set dir_to_face to r(ship:facing:pitch, ship:facing:yaw, 180).
        sas off.
        lock steering to dir_to_face.
        wait 5.
        sas on.
        unlock steering.
        comp:decoupler:getmodule("ModuleAnchoredDecoupler"):doevent("decouple").
        opp_comp:decoupler:getmodule("ModuleAnchoredDecoupler"):doevent("decouple").
        print "away".
    }
}
else {
    print "Cannot proceed with odd number of deployables. Stopping.".
}


ship:partstagged("ship")[0]:controlfrom().
set sasmode to "prograde".
sas on. 
wait 1.
set dir_to_face to r(ship:facing:pitch, ship:facing:yaw, 270).
lock steering to dir_to_face.
wait 1.
unlock steering.
SET SHIP:CONTROL:NEUTRALIZE to True.
PRINT "RESUMING MANUAL CONTROL.".