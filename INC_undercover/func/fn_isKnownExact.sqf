/* ----------------------------------------------------------------------------
Function:

Description:

Parameters:

Returns:

Examples:

Author:
---------------------------------------------------------------------------- */

private ["_alertedUnits","_alertedGroups","_getHideFromUnit"];

params [["_side",sideEmpty],["_unit",player],["_distSqr",1400]];

if (_side == sideEmpty) exitWith {false};

_unit = vehicle _unit;
private _result = false;

{if (((leader _x getHideFrom _unit) distanceSqr _unit < _distSqr) && {alive leader _x}) exitWith {_result = true}; false} forEach (allGroups select {
	(side (leader _x) isEqualTo _side)
});

_result
