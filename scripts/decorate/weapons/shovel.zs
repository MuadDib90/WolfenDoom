class Shovel : NaziWeapon
{
	Default
	{
	//$Category Weapons (BoA)
	//$Title (1) Shovel
	//$Color 14
	Scale 0.5;
	Weapon.SelectionOrder 9999;
	Weapon.UpSound "shovel/select";
	Tag "$TAGSHOVL";
	Inventory.PickupMessage "$SHOVEL";
	-WEAPON.AMMO_CHECKBOTH
	+WEAPON.MELEEWEAPON
	+WEAPON.NOAUTOFIRE
	}
	States
	{
	Ready:
		SHUV A 1 A_WeaponReady;
		Loop;
	Deselect:
		SHUV A 1 A_Lower;
		SHUV A 0 A_Lower;
		Loop;
	Select:
		SHUV A 1 A_Raise;
		SHUV A 0 A_Raise;
		Loop;
	Fire:
		SHUV B 2 A_JumpIfInventory("PowerStrength",1,"PowerShovel");
		SHUV B 1 Offset(15,32);
		SHUV B 1 Offset(30,33) A_StartSound("shovel/miss", CHAN_WEAPON);
		SHUV B 1 Offset(52,35);
		SHUV B 1 Offset(78,38);
		SHUV B 1 Offset(92,44);
		SHUV B 1 Offset(64,50);
		SHUV C 1 Offset(30,38) A_CustomPunch(60,1,0,"ShovelPuff",100);
		SHUV C 1 Offset(1,44);
		SHUV D 1 Offset(-32,24);
		SHUV D 1 Offset(-50,28);
		SHUV E 1 Offset(-74,32);
		SHUV E 1 Offset(-100,36);
	FireFinish:
		TNT1 A 10;
		SHUV A 1 Offset(60,60);
		SHUV A 1 Offset(50,55);
		SHUV A 1 Offset(40,50) A_WeaponReady(WRF_NOBOB);
		SHUV A 1 Offset(30,45) A_WeaponReady(WRF_NOBOB);
		SHUV A 1 Offset(20,40) A_WeaponReady(WRF_NOBOB);
		SHUV A 1 Offset(10,35) A_WeaponReady(WRF_NOBOB);
		Goto Ready;
	PowerShovel:
		SHUV B 1 Offset(5,32);
		SHUV B 1 Offset(10,33) A_StartSound("shovel/miss", CHAN_WEAPON);
		SHUV B 1 Offset(16,35);
		SHUV B 1 Offset(24,38);
		SHUV B 1 Offset(26,39);
		SHUV B 1 Offset(27,40);
		SHUV C 1 Offset(20,38) A_CustomPunch(60*3,1,0,"ShovelPuff",120);
		SHUV C 1 Offset(10,39);
		SHUV C 1 Offset(-3,40);
		SHUV D 1 Offset(-19,32);
		SHUV D 1 Offset(-40,36);
		SHUV E 1 Offset(-64,40);
		SHUV E 1 Offset(-90,42);
		Goto FireFinish;
	Spawn:
		SHUV Z -1;
		Stop;
	}
}

class ShovelPuff: Actor
{
	Default
	{
	+NOBLOCKMAP
	+NOEXTREMEDEATH
	+NOGRAVITY
	+PUFFONACTORS
	+PUFFGETSOWNER
	RenderStyle "Add";
	ActiveSound "";
	AttackSound "shovel/wall";
	SeeSound "shovel/impact";
	Obituary "$OBSHOVEL";
	ProjectileKickback 100;
	DamageType "Melee";
	}
	States
	{
	Spawn:
	Melee:
		POOF A 0 A_AlertMonsters;
	Crash:
		POOF ABCDE 3;
		Stop;
	}
}