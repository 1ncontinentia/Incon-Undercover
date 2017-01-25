/*
Suspicious enemy loop
*/

_this spawn {
	params ["_unit","_suspiciousEnemy"];

	_suspiciousEnemy setVariable ["INC_isSuspicious",true];

	_suspiciousEnemy doWatch _unit;

	sleep (random 15);

	if !((30 * (_unit getVariable ["INC_disguiseValue",1])) > (random 100)) exitWith {
		_suspiciousEnemy setVariable ["INC_isSuspicious",false];
	};

	if (45 > (random 100)) then {
		private ["_comment"];
		switch (_unit getVariable ["INC_goneIncognito",false]) do {
			case true: {
				_comment = selectRandom ["Who the fuck are you?","I don't recognise you.","I don't like the look of you.","You look strange.","What are you doing?","I'd like to know which unit you're from.","Who are you with?","You're not supposed to be here.","You're not with us are you?"];
			};
			case false: {
				_comment = selectRandom ["I recognise you from somewhere.","You hiding something?","Stop right there, let me get a good look at you.","Stop. Don't move.","Stay right there."];
			};
		};
		[[_suspiciousEnemy, _comment] remoteExec ["globalChat",_unit]];
	};

	_suspiciousEnemy doWatch _unit;

	sleep (random 25);

	if !((40 * (_unit getVariable ["INC_disguiseValue",1])) > (random 100)) exitWith {
		_suspiciousEnemy setVariable ["INC_isSuspicious",false];
	};

	waitUntil {

		if (30 > random 100) then {_suspiciousEnemy doMove ([(getPosWorld _unit),20] call CBA_fnc_Randpos);};

		sleep (random 15);

		_suspiciousEnemy doWatch _unit;

		_suspiciousEnemy doTarget _unit;

		if (((((speed _unit) + 4) / 1.6) * (_unit getVariable ["INC_disguiseValue",1])) > (random 100)) exitWith {
			_suspiciousEnemy setVariable ["INC_isSuspicious",false];
			[_unit] call INCON_fnc_compromised;
			true
		};

		if !((70 * (_unit getVariable ["INC_disguiseValue",1])) > (random 100)) exitWith {
			_suspiciousEnemy setVariable ["INC_isSuspicious",false];
			true
		};

		(!((_suspiciousEnemy getHideFrom _unit) distanceSqr _unit < 30) || {!alive _suspiciousEnemy} || {!captive _unit})
	};
};
