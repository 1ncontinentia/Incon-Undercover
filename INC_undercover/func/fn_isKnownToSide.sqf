/*

This script returns boolean on whether any living groups of a given side know about the unit.

*/

params [["_unit",player],["_detectingSide",sideEmpty]];

_unit = vehicle _unit;
private _result = false;

{if (((leader _x targetKnowledge _unit) select 0) && {alive leader _x}) exitWith {_result = true}; false} forEach (allGroups select {
	(side (leader _x) isEqualTo _detectingSide)});
};

_result
