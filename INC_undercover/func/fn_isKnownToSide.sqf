
params [["_unit",player],["_side",sideEmpty]];

if (_side == sideEmpty) exitWith {false};

_unit = vehicle _unit;
private _result = false;

{if (((leader _x targetKnowledge _unit) select 0) && {alive leader _x}) exitWith {_result = true}; false} forEach (allGroups select {
	(side (leader _x) isEqualTo _side)
});

_result
