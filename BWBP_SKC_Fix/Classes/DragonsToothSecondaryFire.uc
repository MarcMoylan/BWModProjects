//=============================================================================
// DragonsToothSecondaryFire.
//
// Lunge attack for the Dragons Tooth Sword. Does 100 damage regardless of area.
// Good for quick take downs, but bad against armored or healthier foes.
//
// REDACTED: Now is a double swipe.
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class DragonsToothSecondaryFire extends BallisticMeleeFire;

var   float RailPower;
var bool	bIsCharging;
var() Array<name> SliceAnims;
var int SliceAnim;


simulated function bool HasAmmo()
{
	return true;
}

function float MaxRange()
{
	return TraceRange.Max;
}



simulated event ModeDoFire()
{
    if (!AllowFire())
	  return;

	bIsCharging=True;
	FireAnim = SliceAnims[SliceAnim];
	SliceAnim++;
	if (SliceAnim >= SliceAnims.Length)
		SliceAnim = 0;

	Super.ModeDoFire();


}

simulated function ModeTick(float DT)
{
	Super.ModeTick(DT);
        if (bIsCharging)
        {

            	RailPower = FMin(RailPower + 2.0*DT, 1);
        }
    
    if (RailPower + 0.05 >= 1)
    {
        	DoFireEffect();
		bIsCharging=False;
	  	RailPower=0;
    }

    if (!bIsFiring)
        return;

}


// Get aim then run trace...
function DoFireEffect()
{
    local Vector StartTrace;
    local Rotator Aim, PointAim;
    local int i;

	Aim = GetFireAim(StartTrace);
	Aim = Rotator(GetFireSpread() >> Aim);

	// Do trace for each point
	for	(i=0;i<NumSwipePoints;i++)
	{
		if (SwipePoints[i].Weight < 0)
			continue;
		PointAim = Rotator(Vector(SwipePoints[i].Offset) >> Aim);
		MeleeDoTrace(StartTrace, PointAim, i==WallHitPoint, SwipePoints[i].Weight);
	}
	// Do damage for each victim
	for (i=0;i<SwipeHits.length;i++)
		DoDamage(SwipeHits[i].Victim, SwipeHits[i].HitLoc, StartTrace, SwipeHits[i].HitDir, 0, 0);
	SwipeHits.Length = 0;

	Super(BallisticFire).DoFireEffect();

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
					bHitWall = ImpactEffect (HitLocation, HitNormal, HitMaterial, Other, WaterHitLoc);
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


defaultproperties
{
     SliceAnims(0)="MultiHit1"
     SliceAnims(1)="MultiHit2"
//     SliceAnims(2)="MultiHit3"
//     SliceAnims(3)="MultiHit4"
     SwipePoints(0)=(offset=(Pitch=0,Yaw=3000))
     SwipePoints(1)=(offset=(Pitch=0,Yaw=1500))
     SwipePoints(2)=(offset=(Pitch=0,Yaw=0))
     SwipePoints(3)=(Weight=4,offset=(Yaw=-1500))
     SwipePoints(4)=(Weight=2,offset=(Pitch=0,Yaw=3000))
     WallHitPoint=1
     NumSwipePoints=5
//     TraceRange=(Min=150.000000,Max=150.000000)
     Damage=115
     DamageHead=175
     DamageLimb=55
     DamageType=Class'BWBP_SKC_Fix.DT_DTSChest'
     DamageTypeHead=Class'BWBP_SKC_Fix.DT_DTSHead'
     DamageTypeArm=Class'BWBP_SKC_Fix.DT_DTSLimb'
     KickForce=200
     HookStopFactor=2.700000
     HookPullForce=150.000000
     bReleaseFireOnDie=False
     BallisticFireSound=(Sound=Sound'BWBP_SKC_Sounds.DTS.DragonsTooth-Swipe',Volume=5.500000,Radius=32.000000,bAtten=True)
     bAISilent=True
     bFireOnRelease=False
     FireAnim="Melee3"
     FireRate=1.600000
     FireAnimRate=0.850000
     AmmoClass=Class'BallisticFix.Ammo_Knife'
     AmmoPerFire=0
     ShakeRotMag=(X=32.000000,Y=256.000000)
     ShakeRotRate=(X=3000.000000,Y=3000.000000,Z=3000.000000)
     ShakeRotTime=2.000000
     BotRefireRate=0.800000
     WarnTargetPct=0.050000
}
