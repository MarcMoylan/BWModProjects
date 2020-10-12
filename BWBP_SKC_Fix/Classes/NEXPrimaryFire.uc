//=============================================================================
// EKS43PrimaryFire.
//
// Horizontalish swipe attack for the EKS43. Uses melee swpie system to do
// horizontal swipes. When the swipe traces find a player, the trace closest to
// the aim will be used to do the damage.
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class NEXPrimaryFire extends BallisticMeleeFire;

var() Array<name> SliceAnims;
var int SliceAnim;
var() sound		PunchSound;
//var bool bCanSwing;
var   float RailPower;
var bool	bIsCharging;

simulated function bool AllowFire()
{
	if (NEXPlasEdge(Weapon).HeatLevel >= 9.75 || !super.AllowFire())
		return false;
	return true;
}

function float GetDamage (Actor Other, vector HitLocation, vector Dir, out Actor Victim, optional out class<DamageType> DT)
{
	KickForce = NEXPlasEdge(Weapon).HeatLevel * default.KickForce;
	
	if (NEXPlasEdge(Weapon).bPoweredDown)
		DT = Class'DTBrawling';
	else if (NEXPlasEdge(Weapon).HeatLevel > 7)
		DT = Class'DTNEXOverheat'; 
	
	return super.GetDamage (Other, HitLocation, Dir, Victim, DT) * (1 + (NEXPlasEdge(Weapon).HeatLevel/2.5));
}

simulated event ModeDoFire()
{
	if (!NEXPlasEdge(Weapon).bPoweredDown && NEXPlasEdge(Weapon).HeatLevel >= 6.0 && NEXPlasEdge(Weapon).HeatLevel < 9.5)
		NEXPlasEdge(Weapon).PlaySound(NEXPlasEdge(Weapon).HighHeatSound,,1.0,,32);
	else if (!NEXPlasEdge(Weapon).bPoweredDown && NEXPlasEdge(Weapon).HeatLevel >= 10.0)
		NEXPlasEdge(Weapon).PlaySound(NEXPlasEdge(Weapon).ExtremeOverHeatSound,,6.0,,64);
	if (NEXPlasEdge(Weapon).bPoweredDown)
	{
		FireAnim = 'Punch';
		BallisticFireSound.Sound=PunchSound;
	}
	else
	{
		BallisticFireSound.Sound=default.BallisticFireSound.Sound;
		FireAnim = SliceAnims[SliceAnim];
		SliceAnim++;
		if (SliceAnim >= SliceAnims.Length)
			SliceAnim = 0;
	}
	Super.ModeDoFire();
	
	if (NEXPlasEdge(Weapon).bPoweredDown)
		NextFireTime = Level.TimeSeconds + 1.2;
}

// Do the trace to find out where bullet really goes
function MeleeDoTrace (Vector InitialStart, Rotator Dir, bool bWallHitter, int Weight)
{
	local int						i;
	local Vector					End, X, HitLocation, HitNormal, Start, WaterHitLoc, LastHitLocation;
	local Material					HitMaterial;
	local float						Dist;
	local Actor						Other, LastOther;
	local bool						bHitWall;

	// Work out the range
	Dist = TraceRange.Min + FRand() * (TraceRange.Max - TraceRange.Min);

	Start = InitialStart;
	X = Normal(Vector(Dir));
	End = Start + X * Dist;
	LastHitLocation=End;
	Weapon.bTraceWater=true;

	while (Dist > 0)		// Loop traces in case we need to go through stuff
	{
		// Do the trace
		Other = Trace (HitLocation, HitNormal, End, Start, true, , HitMaterial);
		Dist -= VSize(HitLocation - Start);
		if (Level.NetMode == NM_Client && (Other.Role != Role_Authority || Other.bWorldGeometry))
			break;
		if (Other != None)
		{
			LastHitLocation=HitLocation;
			// Water
			if (bWallHitter && ((FluidSurfaceInfo(Other) != None) || ((PhysicsVolume(Other) != None) && PhysicsVolume(Other).bWaterVolume)))
			{
				if (VSize(HitLocation - Start) > 1)
					WaterHitLoc=HitLocation;
				Start = HitLocation;
				End = Start + X * Dist;
				Weapon.bTraceWater=false;
				continue;
			}
			else
				LastHitLocation=HitLocation;
			// Got something interesting
			if (!Other.bWorldGeometry && Other != LastOther)
			{
				bIsCharging=True;
				for(i=0;i<SwipeHits.length;i++)
					if (SwipeHits[i].Victim == Other)
					{
						if(SwipeHits[i].Weight < Weight)
						{
							SwipeHits.Remove(i, 1);
							i--;
						}
						else
							break;
					}
				if (i>=SwipeHits.length)
				{
					SwipeHits.Length = SwipeHits.length + 1;
					SwipeHits[SwipeHits.length-1].Victim = Other;
					SwipeHits[SwipeHits.length-1].Weight = Weight;
					SwipeHits[SwipeHits.length-1].HitLoc = HitLocation;
					SwipeHits[SwipeHits.length-1].HitDir = X;
//					DoDamage(Other, HitLocation, InitialStart, X, 0);
					LastOther = Other;

					if (bWallHitter && Vehicle(Other) != None)
					{
//						bHitWall=true;
						bHitWall = ImpactEffect (HitLocation, HitNormal, HitMaterial, Other, WaterHitLoc);
					}
				}
				if (Mover(Other) == None)
					Break;
			}
			// Do impact effect
			if (Other.bWorldGeometry || Mover(Other) != None)
			{
//				bHitWall=true;
				if (bWallHitter)
				{
					bHitWall = ImpactEffect (HitLocation, HitNormal, HitMaterial, Other, WaterHitLoc);
					bIsCharging=True;
				}
				break;
			}
			// Still in the same guy
			if (Other == Instigator || Other == LastOther)
			{
				Start = HitLocation + (X * Other.CollisionRadius * 2);
				End = Start + X * Dist;
				continue;
			}
			break;
		}
		else
			break;
	}
	// Never hit a wall, so just tell the attachment to spawn muzzle flashes and play anims, etc
	if (!bHitWall && bWallHitter)
		NoHitEffect(X, InitialStart, LastHitLocation, WaterHitLoc);
	Weapon.bTraceWater=false;
}

simulated function ModeTick(float DT)
{
	Super.ModeTick(DT);
	Weapon.SoundPitch = 32 + NEXPlasEdge(Weapon).HeatLevel*12;
	if (bIsCharging)
		RailPower = FMin(RailPower + 4*DT, 1);

    if (RailPower + 0.05 >= 1)
    {
		if (Weapon.Role == ROLE_Authority && !NEXPlasEdge(Weapon).bPoweredDown)
			NEXPlasEdge(BW).AddHeat(1.05);
		bIsCharging=False;
	  	RailPower=0;
    }
}

function DoFireEffect()
{
	Super.DoFireEffect();
	if (!NEXPlasEdge(Weapon).bPoweredDown)
		NEXPlasEdge(Weapon).AddHeat(1.05);
}

defaultproperties
{
     PunchSound=Sound'BallisticSounds3.M763.M763Swing'
     SliceAnims(0)="Chop1"
     SliceAnims(1)="Chop2"
     SliceAnims(2)="Chop3"
     SliceAnims(3)="Chop4"
     Damage=35
     DamageHead=65
     DamageLimb=20
     DamageType=Class'BWBP_SKC_Fix.DTNEXSlash'
     DamageTypeHead=Class'BWBP_SKC_Fix.DTNEXSlashHead'
     DamageTypeArm=Class'BWBP_SKC_Fix.DTNEXSlashLimb'
     KickForce=100
     HookStopFactor=1.700000
     HookPullForce=100.000000
     BallisticFireSound=(Sound=SoundGroup'BWBP_SKC_Sounds.NEX.NEX-Slash',Radius=32.000000,Volume=2.200000,bAtten=True)
     bAISilent=True
//     bWaitForRelease=True
     FireAnim="Chop1"
     FireAnimRate=0.700000
     FireRate=0.500000
     AmmoClass=Class'BWBP_SKC_Fix.Ammo_NEXCells'
     AmmoPerFire=0
     ShakeRotMag=(X=64.000000,Y=512.000000)
     ShakeRotRate=(X=3000.000000,Y=3000.000000,Z=3000.000000)
     ShakeRotTime=2.500000
     BotRefireRate=0.800000
     WarnTargetPct=0.100000
}
