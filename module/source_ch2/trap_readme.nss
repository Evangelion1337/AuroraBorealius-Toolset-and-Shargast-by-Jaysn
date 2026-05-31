/*

*General Notes*

To use these scripts in your module you need to add this line to your
OnModuleLoad event in Module Properties.

--
ExecuteScript("trap_on_load");
--


To place a trap put down a copy of the placeable of the trap you want to use,
the huge boulder for the rolling rock trap, the rug for the rugpit trap etc.

You then have to put down a trapped object with the correct tag.  Triggers for
each trap type are already in the palette to make this easier.  But if you want
a trap to be triggered by a door or chest you'll have to modify the tag
yourself.  All you have to do is set the beginning of the traps tag to the
string given in each traps description.  For example, if you want a rolling
boulder attached to a chest the chest's tag must begin "RBFTrap".  The chest
will also need it's disarm script set to "trap_disarm", and it's triggered script
set to "trap_fire".

The traps set up in this mod should help you understand if you're having
problems.  Be careful though, a placeable will always link itself to the closest
trap with the correct tag.

Reset switches need their tag set to the tag of the trap they reset, with a
single digit on the end.  This digit tells the switch whether it should reset
the closest trap with that tag, or the second closest, or third, etc.

To reset the closest one the digit must be 1, so for a reset switch to reset
the closest standard rolling boulder trap it's tag should be "RBFTrap1".

Details on each trap follow.

- Lacero


*Razor Wire*

Search DC: 22
Disarm DC: 10
Reflex DC: 25/10
Damage:    2d6 slashing
Tag:       RWFTrap

This trap cannot be reset and will work until it is disarmed.
When someone knows the trap is there the Reflex DC is reduced to 10.
Also damage is halved for a failed disarm attempt.
When someone takes >=6 damage from the trap they have their movement reduced by
half for 20 seconds.


*Rolling Boulder*

Search DC: 20
Disarm DC: 22
Reflex DC: 25
Damage:    2d6 bludgeoning
Tag:       RBFTrap

The trap hits everyone in a cylinder along the boulder's path.
The trap stays around once fired, but will not trigger again until it is reset
by pulling the reset switch.  Disarming the trap permanently stop it from
working.
When the trap deals any damage at all to someone they are knocked down for 30
seconds, exactly the same as the knockdown feat.


*Rug Pit Trap*

Search DC: 24
Disarm DC: 20
Reflex DC: 20/10
Damage:    2d6 bludgeoning
Tag:       RPFTrap

The trap stays open once fired, and will trigger when anyone walks over the
hole, if you make the reflex save you take no damage.  While open the trap has
a Reflex save of 10, to make it look like a normal carpet again pull the reset
switch.
Disarming the trap will make it into a normal carpet.
When hit by the trap people are made to dissappear for 60 seconds, while they
climb out.  Unfortunately the animation for this makes them fly away, but as
VFX_COM_UNLOAD_MODEL doesn't do anything it's the best way I know.


*Metal Pit Trap*

Search DC: 20
Disarm DC: 23
Reflex DC: 15/10
Damage:    2d6 bludgeoning
Tag:       MPFTrap

The trap stays open once fired, and will trigger when anyone walks over the
hole, if you make the reflex save you take no damage.  While open the trap has
a Reflex save of 10, to close it and hide it again pull the lever.
Disarming the trap will close the pit and leave it visible.
When hit by the trap people are made to dissappear for 30 seconds, while they
climb out.  Unfortunately the animation for this makes them fly away, but as
VFX_COM_UNLOAD_MODEL doesn't do anything it's the best way I know.


*Wall Blade Trap*

Search DC: 22
Disarm DC: 22
Reflex DC: 15
Damage:    4x4d2 piercing
Tag:       WSFTrap         //Notice this is different to what you'd expect

The trap can be reset, and so will work more than once.
The trap hits the person who triggered it with 4 blades, each doing 4d2 piercing
damage and saved for separately.
Disarming the trap will put the spikes away and leave the placeable visible.


*Falling Bricks Trap*

Search DC: 20
Disarm DC: 20
Reflex DC: 15
Damage:    2d6 bludgeoning
Tag:       FBFTrap

The trap will only work once.  Everyone within 2 metres of the trap is hit
when it goes off.
Disarming the trap will hide the placeable.


*Swinging Rock Trap*

Search DC: 20
Disarm DC: 20
Reflex DC: 15
Damage:    4d6 bludgeoning
Tag:       SRFTrap

The trap can be reset and so will work more than once.  Everyone within 2
metres of the trap is hit when it goes off.
Disarming the trap will leave the placeable visible with the rock near the
ceiling.


*Swinging Blade Trap*

Search DC: 22
Disarm DC: 22
Reflex DC: 15
Damage:    1d13 slashing
Tag:       SBFTrap

The trap can be reset and so will work more than once.  Everyone within 2
metres of the trap is hit when it goes off.
Disarming the trap will leave the placeable visible with the blade near the
ceiling.


*Whirling Blade Trap*

Search DC: 20
Disarm DC: 20
Reflex DC: 20
Damage:    2d4+2 slashing
Tag:       WBFTrap

The trap can be reset and so will work more than once.  Everyone within 5
metres of the trap is hit every round when it is active.
Disarming the trap will stop it permanently.


*Flood Trap*

Search DC: 17
Disarm DC: 23
Reflex DC: -
Damage:    Death in 5 rounds
Tag:       FlFTrap

The trap can be reset and so will work more than once.
Everyone in the area of the water is killed 5 rounds after the trap is
triggered, unless the reset switch is pulled before this happens.
Also when triggered the trap will close and lock the nearest door.
While in the water people have the slow effect.
Disarming the trap will NOT get rid of water that is already there.
*/
