//=============================================================================
// Defib Fists Primary.
//
// Rapid, two handed jabs with reasonable range. Everything is timed by notifys
// from the anims
//
// by Casey "Xavious" Johnson and Azarael
//=============================================================================
class DefibFistsPrimaryFire extends BallisticMeleeFire;

var bool bPunchLeft;

event ModeDoFire()
{
	local float f;

	Super.ModeDoFire();

	f = FRand();
	if (f > 0.50)
	{
		if (bPunchLeft)
			FireAnim = 'PunchL1';
		else
			FireAnim = 'PunchR1';		
	}
	else
	{
		if (bPunchLeft)
			FireAnim = 'PunchL2';
		else
			FireAnim = 'PunchR2';	
	}

	if (bPunchLeft)
		bPunchLeft=False;
	else
		bPunchLeft=True;	
}

simulated function bool HasAmmo()
{
	return true;
}

function DoDamage (Actor Other, vector HitLocation, vector TraceStart, vector Dir, int PenetrateCount, int WallCount, optional vector WaterHitLocation)
{
	local BallisticPawn Target;
	local int PrevHealth;
	Target=BallisticPawn(Other);
	
	if(IsValidHealTarget(Target))
	{
		PrevHealth = Target.Health;
		Target.GiveHealth(25, Target.HealthMax);
		DefibFists(Weapon).PointsHealed += Target.Health - PrevHealth;
		return;
	}
	
	if (Mover(Other) != None || Vehicle(Other) != None)
		return;
	super.DoDamage(Other, HitLocation, TraceStart, Dir, PenetrateCount, WallCount, WaterHitLocation);

}

function bool IsValidHealTarget(Pawn Target)
{
	if(Target==None||Target==Instigator)
		return False;

	if(Target.Health<=0)
		return False;

	if(!Level.Game.bTeamGame)
		return False;

	if(Vehicle(Target)!=None)
		return False;

	return (Target.Controller!=None && Instigator.Controller.SameTeamAs(Target.Controller));
}

function StartBerserk()
{
    	FireRate = 0.45;
		Damage = 150;
		DamageHead = 275;
		DamageLimb = 90;
	      DamageType=Class'BWBP_SKC_Fix.DTBERSERK';
    	      DamageTypeHead=Class'BWBP_SKC_Fix.DTBERSERK';
    		DamageTypeArm=Class'BWBP_SKC_Fix.DTBERSERK';
    		FireAnimRate = 2;
}

function StopBerserk()
{
      FireRate = default.FireRate;
		Damage = default.Damage;
		DamageHead = default.DamageHead;
		DamageLimb = default.DamageLimb;
     DamageType=Class'BWBP_SKC_Fix.DTBrawling';
     DamageTypeHead=Class'BWBP_SKC_Fix.DTBrawlingHead';
     DamageTypeArm=Class'BWBP_SKC_Fix.DTBrawlingLimb';
    FireAnimRate = default.FireAnimRate;
}

defaultproperties
{
	AmmoClass=Class'BWBP_SKC_Fix.Ammo_DefibCharge'
	AmmoPerFire=0
	bAISilent=True
	BallisticFireSound=(Sound=SoundGroup'BWAddPack-RS-Sounds.MRS38.RSS-ElectroSwing',Radius=32.000000,bAtten=True)
	BotRefireRate=0.800000
	bUseWeaponMag=False
	Damage=40
	DamageHead=75
	DamageLimb=30
	DamageType=Class'BWBP_SKC_Fix.DTShockGauntlet'
	DamageTypeArm=Class'BWBP_SKC_Fix.DTShockGauntlet'
	DamageTypeHead=Class'BWBP_SKC_Fix.DTShockGauntlet'
	FireAnim="PunchL1"
	FireAnimRate=1.250000
	FireRate=0.650000
	KICKFORCE=40000
	ShakeRotMag=(X=64.000000,Y=384.000000)
	ShakeRotRate=(X=3500.000000,Y=3500.000000,Z=3500.000000)
	ShakeRotTime=2.000000
     SwipePoints(0)=(offset=(Pitch=0))
     SwipePoints(1)=(offset=(Pitch=0))
     SwipePoints(2)=(offset=(Pitch=0))
     SwipePoints(4)=(offset=(Pitch=0))
     SwipePoints(5)=(offset=(Pitch=0))
     SwipePoints(6)=(offset=(Pitch=0))
	TraceRange=(Min=100.000000,Max=100.000000)
	WarnTargetPct=0.050000
}
