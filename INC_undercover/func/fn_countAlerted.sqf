/*

Detection function. This gets the number of units of the selected side that are aware of each member of the target group.

myVariable = [_regEnySide,_sneakyFucker] call INCON_fnc_countAlerted;

Returns number of units with beef against the target unit.

*/

private ["_alertedUnits","_alertedGroups","_getHideFromUnit"];

params [["_side",sideEmpty],["_detectedUnit",player],["_distSqr",1400]];

_alertedGroups = count (allGroups select {

    (side (leader _x) isEqualTo _side) && {((leader _x getHideFrom (vehicle _detectedUnit)) distanceSqr _detectedUnit < _distSqr) && {alive leader _x}}

});

_alertedGroups
