/*

Detection function. This gets the number of units of the selected side that are aware of each member of the target group.

myVariable = [_regEnySide,_sneakyFucker] call INCON_fnc_countAlerted;

Returns number of units with beef against the target unit.

*/

private ["_alertedUnits","_GroupsKnowAboutUnit","_getHideFromUnit"];

params [["_side",sideEmpty],["_detectedUnit",player],["_distSqr",1400]];

if (_side isEqualTo sideEmpty) exitWith {0};

_alertedUnits = [];

_GroupsKnowAboutUnit = allGroups select {

    (side _x isEqualTo _side) && {((leader _x getHideFrom _detectedUnit) distanceSqr _detectedUnit < _distSqr) && {alive leader _x} && {!captive leader _x}}

};

_GroupsKnowAboutUnit apply {_alertedUnits append units _x};

_alertedUnitCount = (0 + (count _alertedUnits));

_alertedUnitCount
