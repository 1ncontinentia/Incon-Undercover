private ["_undercoverGroup","_percentage","_civComment"];

params ["_civ","_undercoverUnit"];

_undercoverGroup = count units group _undercoverUnit;

_percentage = (linearConversion [0, 40000, (rating _undercoverUnit), 5, 70, true]);

if (_percentage > 30) then {
    if ((_percentage > (random 100)) && {_undercoverUnit getVariable ["isUndercover", false]}) then {

        if (_undercoverGroup < (5 + (ceil random 5))) then {

            _civComment = selectRandom ["I've heard about you.","You can count on me.","I admire what you're doing.","You have my support.","Thank you for helping rid us of this scourge.","Thank you for helping our people.","I don't want them to see my face."];
            [[_civ, _civComment] remoteExec ["globalChat",0]];
            (group _civ) setGroupOwner (owner _undercoverUnit);
            [[_civ,_undercoverUnit],"recruitSuccess"] remoteExecCall ["INCON_fnc_ucrMain",_undercoverUnit];

        } else {
            _civComment = selectRandom ["Keep up the good work guys.","You all just keep doing what you're doing.","You don't need me, I'll just hold you guys back.","You'll all be fine without me."];
            [[_civ, _civComment] remoteExec ["globalChat",0]];
        };

    } else {

        _civComment = selectRandom ["I am just a simple farmer's wife.","I like your style but I've got kids to feed.","Sorry, I'm too drunk.","You get those fuckers.","Get me some more raksi and I'll think about it.","My wife would kill me.","My foot hurts too much but I appreciate what you're doing.","You're a good man but I can't I'm afraid.","Man, I wish I could."];
        [[_civ, _civComment] remoteExec ["globalChat",0]];

    };

} else {

    if ((_percentage > (random 100)) && {_undercoverUnit getVariable ["isUndercover", false]} && {!(_undercoverUnit getVariable ["INC_undercoverCompromised", false])}) then {

        if (_undercoverGroup < (2 + (random 5))) then {

            _civComment = selectRandom ["This is for Cyril.","I'll get my fighting hat on.","I'm bored, why not.","I'll join you, but only because they ran over my rabbit.","I should really know better.","I'm going to regret this.","Fuck it, let's go.","My wife is going to kill me for this.","Well it's better than gardening."];
            [[_civ, _civComment] remoteExec ["globalChat",0]];
            (group _civ) setGroupOwner (owner _undercoverUnit);
            [[_civ,_undercoverUnit],"recruitSuccess"] remoteExecCall ["INCON_fnc_ucrMain",_undercoverUnit];

        } else {

            _civComment = selectRandom ["Don't you have enough already?","I haven't heard of you guys before. I'm out.","Prove yourselves and maybe I'll join you next time.","Who are you guys?","I don't like the look of you lot."];
            [[_civ, _civComment] remoteExec ["globalChat",0]];

        };

    } else {

        _civComment = selectRandom ["You stink.","Have a shower.","I'm good thanks.","My brother likes to do stupid things. Ask him.","While my nails are drying? No Way.","Try my cousin, he's a lunatic.","My piles are more threatening than you.","They will kill us all.","I don't speak Spanish.","There is nothing we can do.","What have you ever done for us?","Who are you?","Why should I join you?","Get out of here foreigner.","I would but I've got this really important thing on.","Prove yourself and I'll join you next time.","Yeah... good luck.","What's the point?","I'll fight them on my own time."];
        [[_civ, _civComment] remoteExec ["globalChat",0]];

    };

};
