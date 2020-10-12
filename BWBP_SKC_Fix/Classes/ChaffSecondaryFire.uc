//=============================================================================
// ChaffSecondaryFire.
//
// Melee attack for grnade. Hit dem when primed for bomz
//=============================================================================
class ChaffSecondaryFire extends BallisticMeleeFire;

function PlayPreFire()
{
	Weapon.SetBoneScale (0, 1.0, ChaffGrenadeWeapon(Weapon).GrenadeBone);
	Weapon.SetBoneScale (1, 1.0, ChaffGrenadeWeapon(Weapon).GrenadeBone2);
	if (ChaffGrenadeWeapon(Weapon).bPrimed)
	{
     	PreFireAnim='PrepSmackPrimed';
     	FireAnim='SmackPrimed';
	}
	else
	{
     	PreFireAnim='PrepSmack';
     	FireAnim='Smack';
	}
	Weapon.PlayAnim(PreFireAnim, PreFireAnimRate, TweenTime);
}

// Do the trace to find out where bullet really goes
function MeleeDoTrace (Vector InitialStart, Rotator Dir, bool bWallHitter, int Weight)
{
	local int						i;
	local Vector				End, X, HitLocation, HitNormal, Start, WaterHitLoc, LastHitLocation;
	local Material				HitMaterial;
	local float					Dist;
	local Actor					Other, LastOther;
	local bool					bHitWall;

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

				if (ChaffGrenadeWeapon(BW).bPrimed)
				{
					ChaffGrenadeWeapon(BW).ExplodeInHand();
					break;
				}
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
					if (ChaffGrenadeWeapon(BW).bPrimed)
						ChaffGrenadeWeapon(BW).ExplodeInHand();
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

simulated event ModeDoFire()
{
	super.ModeDoFire();
	BW.GunLength = BW.default.GunLength;
}
simulated event ModeHoldFire()
{
	super.ModeHoldFire();
	BW.GunLength=1;
}

defaultproperties
{
     AmmoClass=Class'BWBP_SKC_Fix.Ammo_Chaff'
     AmmoPerFire=0
     bAISilent=True
     BallisticFireSound=(Sound=Sound'BallisticSounds3.M763.M763Swing',Radius=32.000000,Pitch=0.800000,bAtten=True)
     bFireOnRelease=True
     bIgnoreReload=True
     BotRefireRate=0.900000
     bReleaseFireOnDie=False
     bUseWeaponMag=False
     Damage=30
     DamageHead=50
     DamageLimb=25
     DamageType=Class'BWBP_SKC_Fix.DTChaffSmack'
     DamageTypeArm=Class'BWBP_SKC_Fix.DTChaffSmack'
     DamageTypeHead=Class'BWBP_SKC_Fix.DTChaffSmack'
     FireAnim="Smack"
     FireAnimRate=1.500000
     FireRate=0.700000
     PreFireAnim="PrepSmack"
     PreFireAnimRate=2.000000
     ScopeDownOn=SDO_PreFire
     ShakeOffsetMag=(X=5.000000)
     ShakeOffsetRate=(X=-1000.000000)
     ShakeOffsetTime=1.000000
     ShakeRotTime=1.000000
     SwipePoints(0)=(Weight=6,offset=(Pitch=6000,Yaw=4000))
     SwipePoints(1)=(Weight=5,offset=(Pitch=4500,Yaw=3000))
     SwipePoints(2)=(Weight=4,offset=(Pitch=3000))
     SwipePoints(3)=(Weight=3,offset=(Pitch=1500,Yaw=1000))
     SwipePoints(4)=(Weight=2,offset=(Pitch=0,Yaw=0))
     SwipePoints(5)=(Weight=1,offset=(Pitch=-1500,Yaw=-1500))
     SwipePoints(6)=(offset=(Yaw=-3000))
     TweenTime=0.000000
     WallHitPoint=4
     WarnTargetPct=0.050000
}
