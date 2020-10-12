//=============================================================================
// Defib Fists Secondary.
//
// Devastating uppercut which can also heal allies.
// by Casey "Xavious" Johnson and Azarael
//=============================================================================
class DefibFistsSecondaryFire extends BallisticMeleeFire;

var bool bCharged;

simulated function bool HasAmmo()
{
	return true;
}

function DoDamage (Actor Other, vector HitLocation, vector TraceStart, vector Dir, int PenetrateCount, int WallCount, optional vector WaterHitLocation)
{
	local vector UpwardsKnock;
	local BallisticPawn Target;
	local int PrevHealth;
	
	UpwardsKnock.Z=450;
	Target=BallisticPawn(Other);
	if(IsValidHealTarget(Target))
	{
		PrevHealth = Target.Health;
		Target.GiveHealth(40, Target.HealthMax);
		DefibFists(Weapon).PointsHealed += Target.Health - PrevHealth;
		return;
	}
	super.DoDamage(Other, HitLocation, TraceStart, Dir, PenetrateCount, WallCount, WaterHitLocation);
	
	if (Pawn(Other) != None)
		Pawn(Other).AddVelocity(UpwardsKnock);
}

function DoFireEffect()
{
	if (DefibFists(Weapon).bRanOnce)
	{
		DefibFists(Weapon).Explode();
	}
	if (DefibFists(Weapon).ElectroCharge >= 95)
	{
		DefibFists(Weapon).ElectroShockWave(20, 350, class'DTShockGauntlet', 100000, Instigator.Location);
		DefibFists(Weapon).ElectroCharge -= 95;
		DefibFistsAttachment(Weapon.ThirdPersonActor).DoWave(true);
	}
	Super(BallisticMeleeFire).DoFireEffect();
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

	return (Target.Controller!=None&&Instigator.Controller.SameTeamAs(Target.Controller));
}

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
				if (DefibFists(Weapon).ElectroCharge >= 95)
					Instigator.TakeDamage(0, Instigator, HitLocation, X*-10000, DamageType);
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

function StartBerserk()
{
    	FireRate = 0.7;
		Damage = 325;
		DamageHead = 425;
		DamageLimb = 150;
	      DamageType=Class'BWBP_SKC_Fix.DTBERSERK';
    	      DamageTypeHead=Class'BWBP_SKC_Fix.DTBERSERK';
    		DamageTypeArm=Class'BWBP_SKC_Fix.DTBERSERK';
    FireAnimRate = 2.0;
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
     SwipePoints(0)=(offset=(Pitch=0,Yaw=3000))
     SwipePoints(1)=(offset=(Pitch=0,Yaw=1500))
     SwipePoints(2)=(offset=(Pitch=0,Yaw=0))
     SwipePoints(3)=(Weight=4,offset=(Yaw=-1500))
     SwipePoints(4)=(Weight=2,offset=(Pitch=0,Yaw=3000))
     WallHitPoint=2
     NumSwipePoints=5
     TraceRange=(Min=100.000000,Max=100.000000)
     Damage=65
     DamageHead=120
     DamageLimb=60
     DamageType=Class'BWBP_SKC_Fix.DTShockGauntletAlt'
     DamageTypeHead=Class'BWBP_SKC_Fix.DTShockGauntletAlt'
     DamageTypeArm=Class'BWBP_SKC_Fix.DTShockGauntletAlt'
     KICKFORCE=40000
     BallisticFireSound=(Sound=SoundGroup'BWAddPack-RS-Sounds.MRS38.RSS-ElectroSwing',Radius=32.000000,bAtten=True)
     bAISilent=True
     bFireOnRelease=False
	 bUseWeaponMag=False
     PreFireAnim="UppercutPrep"	 
     FireAnim="Uppercut"
     FireAnimRate=1.500000
     FireRate=1.100000
     AmmoClass=Class'BWBP_SKC_Fix.Ammo_DefibCharge'
     AmmoPerFire=0
     ShakeRotMag=(X=64.000000,Y=384.000000)
     ShakeRotRate=(X=3500.000000,Y=3500.000000,Z=3500.000000)
     ShakeRotTime=2.000000
     BotRefireRate=0.800000
     WarnTargetPct=0.050000
}
