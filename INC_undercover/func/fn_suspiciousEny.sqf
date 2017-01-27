/*
Suspicious enemy loop
*/

_this spawn {
	params ["_unit","_suspiciousEnemy"];

	if (_suspiciousEnemy getVariable ["INC_isSuspicious",false]) exitWith {true};

	_suspiciousEnemy setVariable ["INC_isSuspicious",true];

	[_suspiciousEnemy,_unit] remoteExec ["doWatch",2];

	sleep (random 15);

	if ((3 * (_unit getVariable ["INC_disguiseValue",1])) > (random 100)) exitWith {
		_suspiciousEnemy setVariable ["INC_isSuspicious",false];
		[_unit] call INCON_fnc_compromised;
		sleep (random 3);
		{
			[_x] call INCON_fnc_compromised;
			sleep (random 3);
		} forEach ((units _unit) select {
			(_x getVariable ["INC_anyKnowsSO",false]) &&
			{(_x distance _unit) < (10 * (_unit getVariable ["INC_disguiseValue",1]))} &&
			{((22 * (_x getVariable ["INC_disguiseValue",1])) > (random 100))}
		});
		true
	};

	if !((15 * (_unit getVariable ["INC_disguiseValue",1])) > (random 100)) exitWith {
		_suspiciousEnemy setVariable ["INC_isSuspicious",false];
		[_suspiciousEnemy,objNull] remoteExec ["doWatch",2];
	};

	if (45 > (random 100)) then {
		private ["_comment"];
		switch (_unit getVariable ["INC_goneIncog",false]) do {
			case true: {
				_comment = selectRandom ["Who the fuck are you?","I don't recognise you.","I don't like the look of you.","You look strange.","What are you doing?","I'd like to know which unit you're from.","Who are you with?","You're not supposed to be here.","You're not with us are you?"];
			};
			case false: {
				_comment = selectRandom ["I recognise you from somewhere.","You hiding something?","Stop right there, let me get a good look at you.","Stop. Don't move.","Stay right there."];
			};
		};
		[[_suspiciousEnemy, _comment] remoteExec ["globalChat",_unit]];
	};

	sleep (random 15);

	if !((15 * (_unit getVariable ["INC_disguiseValue",1])) > (random 100)) exitWith {
		_suspiciousEnemy setVariable ["INC_isSuspicious",false];
	};

	waitUntil {

		if ((!alive _suspiciousEnemy) || {!captive _unit}) exitWith {true};

		if (10 > random 100) then {

			[_suspiciousEnemy,([(getPosWorld _unit),20] call CBA_fnc_Randpos)] remoteExec ["doMove",2];
		};

		sleep (random 15);

		[_suspiciousEnemy,_unit] remoteExec ["doTarget",2];

		if (
			(((((speed _unit) + 3) / 1) * (_unit getVariable ["INC_disguiseValue",1])) > (random 100)) &&
			{(50 / (_unit distance _suspiciousEnemy)) > random 20}
		) exitWith {
			_suspiciousEnemy setVariable ["INC_isSuspicious",false];

			if (45 > (random 100)) then {
				private ["_comment"];
				switch (_unit getVariable ["INC_goneIncog",false]) do {
					case true: {
						_comment = selectRandom ["We've got an imposter!","He's one of them!","He's not one of us!","Get him!","He's in disguise!","Oh shit!"];
					};
					case false: {
						_comment = selectRandom ["He's one of them!","Fuck this guy!","I warned you!","Fucking weirdo!","Get this guy!","Kill him!"];
					};
				};
				[[_suspiciousEnemy, _comment] remoteExec ["globalChat",_unit]];
			};

			[_unit] call INCON_fnc_compromised;
			sleep (random 3);
			{
				[_x] call INCON_fnc_compromised;
				sleep (random 3);
			} forEach ((units _unit) select {
				(_x getVariable ["INC_anyKnowsSO",false]) &&
				{(_x distance _unit) < (10 * (_unit getVariable ["INC_disguiseValue",1]))} &&
				{((22 * (_x getVariable ["INC_disguiseValue",1])) > (random 100))}
			});
			true
		};

		if !((30 * (_unit getVariable ["INC_disguiseValue",1])) > (random 100)) exitWith {
			_suspiciousEnemy setVariable ["INC_isSuspicious",false];
			true
		};

		(!(((_suspiciousEnemy getHideFrom _unit) distanceSqr _unit) < 20) || {!alive _suspiciousEnemy} || {!captive _unit})
	};
};
