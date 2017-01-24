/*

This script returns boolean on whether any living groups of a given side know about the unit.

*/

params [["_unit",player],["_detectingSide",sideEmpty]];

if (_detectingSide isEqualTo sideEmpty) exitWith {false};

_alertedGroups = allGroups select {
	(side _x isEqualTo _detectingSide) &&
	{(leader _x targetKnowledge _unit) select 0} &&
	{alive leader _x} &&
	{!captive leader _x}
};

if ((count _alertedGroups) == 0) then {false} else {true}
