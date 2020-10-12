//==============================================================================
// Unarmed attack style 1, "Brawling" FIXME
//
// Just an unarmed attack style using various punches. Nothing complicated, just
// some quick jabs for primary fire and a powerful haymaker or uppercut for alt
// fire, which should be useful for knocking the enemy back.
//
// by Casey "Xavious" Johnson
//==============================================================================
class DefibFists extends BallisticMeleeWeapon;

var() int			ElectroCharge;
var() float			DeflectionAmount;
var() float			PulseCharge;
var() float			PulseInterval;
var	float 		LastPulse;
var	float 		LastRecharge;
var	Actor		LSparks;
var	Actor		RSparks;
var	float			PointsHealed;	// Counter to keep track of points healed, will not exceed 50 x HealRatio (will not regenerate more than 50HP before healing again)
var()	float			HealRatio;		// How many points medic must heal for every 1 HP regenerated
var	float			LastRegen;
var() Sound		PulseSound;	
var	bool			bSetAmbient;
var class<DamageType> PulseDamageType;

var float	FlashF;
var vector	FlashV;
var   actor			RampageGlow;
var   bool			bMeatVision;
var	bool			bRanOnce;		// Set up for one time only berserk code. Temporary fix.
var() BUtil.FullSound	RampageOnSound;	// SUPER FISTS
var() BUtil.FullSound	RampageOffSound;	// Pansy fists
var() Sound		RampageSound;		// Sound to play when berserking
var() Sound		OverHeatSound;


simulated function bool HasAmmo()
{
    return true;
}

simulated function Explode()
{
	PlaySound(OverHeatSound,,12.7,,2048);
	class'IM_XMExplosion'.static.StartSpawn(Location, vect(0,0,1), 0, self);
	HurtRadius(1000, 1536, class'DT_BFGExplode', 8000, location);
	Destroy();

}


function StartBerserk()
{
	Rampage();
}
function StopBerserk()
{
     		BallisticInstantFire(FireMode[0]).FireRate = BallisticInstantFire(FireMode[0]).default.FireRate;
		BallisticInstantFire(FireMode[0]).Damage = BallisticInstantFire(FireMode[0]).default.damage;
		BallisticInstantFire(FireMode[0]).DamageHead = BallisticInstantFire(FireMode[0]).default.damagehead;
		BallisticInstantFire(FireMode[0]).DamageLimb = BallisticInstantFire(FireMode[0]).default.damagelimb;
     		BallisticInstantFire(FireMode[0]).DamageType = BallisticInstantFire(FireMode[0]).default.DamageType;
     		BallisticInstantFire(FireMode[0]).DamageTypeHead = BallisticInstantFire(FireMode[0]).default.DamageTypeHead;
     		BallisticInstantFire(FireMode[0]).DamageTypeArm = BallisticInstantFire(FireMode[0]).default.DamageTypeArm;
    		BallisticInstantFire(FireMode[0]).FireAnimRate = BallisticInstantFire(FireMode[0]).default.FireAnimRate;

     		BallisticInstantFire(FireMode[1]).FireRate = BallisticInstantFire(FireMode[1]).default.FireRate;
		BallisticInstantFire(FireMode[1]).Damage = BallisticInstantFire(FireMode[1]).default.damage;
		BallisticInstantFire(FireMode[1]).DamageHead = BallisticInstantFire(FireMode[1]).default.damagehead;
		BallisticInstantFire(FireMode[1]).DamageLimb = BallisticInstantFire(FireMode[1]).default.damagelimb;
     		BallisticInstantFire(FireMode[1]).DamageType = BallisticInstantFire(FireMode[1]).default.DamageType;
     		BallisticInstantFire(FireMode[1]).DamageTypeHead = BallisticInstantFire(FireMode[1]).default.DamageTypeHead;
     		BallisticInstantFire(FireMode[1]).DamageTypeArm = BallisticInstantFire(FireMode[1]).default.DamageTypeArm;
    		BallisticInstantFire(FireMode[1]).FireAnimRate = BallisticInstantFire(FireMode[1]).default.FireAnimRate;
		
	WeaponModes[0].bUnavailable=false;
	WeaponModes[1].bUnavailable=true;
    	class'BUtil'.static.PlayFullSound(self, RampageOffSound);
	if (CurrentWeaponMode == 1)
		CurrentWeaponMode=0;
    	bRanOnce=false;

	DefibFistsPrimaryFire(FireMode[1]).TraceRange.Min = DefibFistsPrimaryFire(FireMode[1]).default.TraceRange.Min;
	DefibFistsPrimaryFire(FireMode[1]).TraceRange.Max = DefibFistsPrimaryFire(FireMode[1]).default.TraceRange.Max;
	DefibFistsSecondaryFire(FireMode[1]).TraceRange.Min = DefibFistsSecondaryFire(FireMode[1]).default.TraceRange.Min;
	DefibFistsSecondaryFire(FireMode[1]).TraceRange.Max = DefibFistsSecondaryFire(FireMode[1]).default.TraceRange.Max;


}


simulated function Rampage()
{
	if (!bRanOnce)
	{
		WeaponModes[0].bUnavailable=true;
		WeaponModes[1].bUnavailable=false;
		if (CurrentWeaponMode == 0)
			CurrentWeaponMode=1;
    		BallisticInstantFire(FireMode[0]).FireRate = 0.45;
		BallisticInstantFire(FireMode[0]).Damage = 150;
		BallisticInstantFire(FireMode[0]).DamageHead = 275;
		BallisticInstantFire(FireMode[0]).DamageLimb= 90;
	        BallisticInstantFire(FireMode[0]).DamageType=Class'BWBP_SKC_Fix.DTBERSERK';
    	        BallisticInstantFire(FireMode[0]).DamageTypeHead=Class'BWBP_SKC_Fix.DTBERSERK';
    		BallisticInstantFire(FireMode[0]).DamageTypeArm=Class'BWBP_SKC_Fix.DTBERSERK';
    		BallisticInstantFire(FireMode[1]).FireRate = 0.7;
		BallisticInstantFire(FireMode[1]).Damage = 325;
		BallisticInstantFire(FireMode[1]).DamageHead = 425;
		BallisticInstantFire(FireMode[1]).DamageLimb = 150;
	        BallisticInstantFire(FireMode[1]).DamageType=Class'BWBP_SKC_Fix.DTBERSERK';
    	        BallisticInstantFire(FireMode[1]).DamageTypeHead=Class'BWBP_SKC_Fix.DTBERSERK';
    		BallisticInstantFire(FireMode[1]).DamageTypeArm=Class'BWBP_SKC_Fix.DTBERSERK';
    		BallisticInstantFire(FireMode[1]).FireAnimRate = 2.0;
    		BallisticInstantFire(FireMode[0]).FireAnimRate = 2;
		DoomFistsPrimaryFire(FireMode[1]).TraceRange.Min *= 1.05;
		DoomFistsPrimaryFire(FireMode[1]).TraceRange.Max *= 1.05;
		DoomFistsSecondaryFire(FireMode[1]).TraceRange.Min *= 1.05;
		DoomFistsSecondaryFire(FireMode[1]).TraceRange.Max *= 1.05;
		class'BUtil'.static.PlayFullSound(self, RampageOnSound);
	}
	bRanOnce=true;


}
  
simulated function BringUp(optional Weapon PrevWeapon)
{
	Super.BringUp(PrevWeapon);

	if (LSparks != None)
		LSparks.Destroy();
	if (RSparks != None)
		RSparks.Destroy();
	if (Instigator.IsLocallyControlled() && level.DetailMode == DM_SuperHigh && class'BallisticMod'.default.EffectsDetailMode >= 2)
    	{
    		LSparks = None;
			class'BUtil'.static.InitMuzzleFlash (LSparks, class'DefibFistsTazerEffect', DrawScale, self, 'LElectrode');
    		RSparks = None;
			class'BUtil'.static.InitMuzzleFlash (RSparks, class'DefibFistsTazerEffect', DrawScale, self, 'RElectrode');		
	}
	
	//bMedicVision = True;	// MedicVision
}

simulated event Destroyed()
{
	if (bBerserk)
	{
        	bRanOnce=false;
	}

	if (LSparks != None)
		LSparks.Destroy();
	if (RSparks != None)
		RSparks.Destroy();		
	super.Destroyed();
}

simulated event Tick (float DT)
{
	super.Tick(DT);
	
	if (Level.NetMode == NM_Client)
		return;
		
	if (ElectroCharge < default.ElectroCharge && !bBlocked && Level.TimeSeconds > LastRecharge)
	{
		ElectroCharge = Min(100, ElectroCharge + 7);
		LastRecharge = Level.TimeSeconds + 0.5;
	}
	MagAmmo = ElectroCharge;
}

simulated event WeaponTick(float DT)
{
	super.WeaponTick(DT);

	if (Level.NetMode == NM_Client)
		return;
		
	if (Level.TimeSeconds > LastPulse)
	{
		if (bBlocked && ElectroCharge >= PulseCharge && !IsFiring())
		{
			if (!bSetAmbient)
			{
				bPlayAmbient(True);
				bSetAmbient = True;
			}
			
			ElectroPulseWave(5, 350, class'DTShockGauntlet', 10000, Instigator.Location);
			LastPulse = Level.TimeSeconds + PulseInterval;
			ElectroCharge -= PulseCharge;			
			DefibFistsAttachment(ThirdPersonActor).DoWave(false);
		}
		
		else if (bSetAmbient)
		{
			bPlayAmbient(False);
			bSetAmbient = False;
		}		
	}
	
	if (Level.TimeSeconds > LastRegen)
	{
		LastRegen = Level.TimeSeconds + 0.50;		
		if (PointsHealed >= HealRatio && Instigator.Health < Instigator.HealthMax * 1.20)
		{
			if (PointsHealed > 250)
				PointsHealed = 250;	
			Instigator.Health++;
			PointsHealed -= HealRatio;
		}
	}
}	


simulated function bPlayAmbient( bool bPulseOn)
{
	if (bPulseOn)
	{
		Instigator.AmbientSound = PulseSound;
		Instigator.SoundVolume = 128;
	}
	else
	{
		Instigator.AmbientSound = None;
		Instigator.SoundVolume = 0;
	}		
}
	
function ElectroPulseWave( float DamageAmount, float DamageRadius, class<DamageType> DamageType, float Momentum, vector ShockWaveStart)
{
	local actor Victims;
	local float damageScale, dist;
	local vector dir, NewMomentum;
	local BallisticPawn PulseTarget;
	local int PrevHealth;

	if( bHurtEntry )
		return;

	bHurtEntry = true;
	foreach VisibleCollidingActors( class 'Actor', Victims, DamageRadius, ShockWaveStart )
	{
		// don't let blast damage affect fluid - VisibleCollisingActors doesn't really work for them - jag
		if(Victims != Self && (Victims.Role == ROLE_Authority) && Victims.bCanBeDamaged && (!Victims.IsA('FluidSurfaceInfo')) && Victims != Instigator)
		{
			NewMomentum = damageScale * Momentum * dir;
			PulseTarget=BallisticPawn(Victims);
			if(IsValidHealTarget(PulseTarget))
			{
				PrevHealth = PulseTarget.Health;			
				DamageAmount = 0;
				PulseTarget.GiveHealth(7, PulseTarget.HealthMax);
				PointsHealed += PulseTarget.Health - PrevHealth;						
				NewMomentum.X = 0;
				NewMomentum.Y = 0;
				NewMomentum.Z = 0;
			}
			else
			{
				dir = Victims.Location - ShockWaveStart;
				dist = FMax(1,VSize(dir));
				dir = dir/dist;
				damageScale = 1 - FMax(0,(dist - Victims.CollisionRadius)/DamageRadius);
				class'BallisticDamageType'.static.GenericHurt
				(
					Victims,
					damageScale * DamageAmount,
					Instigator,
					Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,
					/*damageScale * Momentum * dir*/NewMomentum,
					PulseDamageType
				);
			}
		}
	}
	bHurtEntry = false;
}

function ElectroShockWave( float DamageAmount, float DamageRadius, class<DamageType> DamageType, float Momentum, vector ShockWaveStart)
{
	local actor Victims;
	local float damageScale, dist;
	local vector dir, NewMomentum;
	local BallisticPawn ShockTarget;
	local int PrevHealth;

	if( bHurtEntry )
		return;

	bHurtEntry = true;
	foreach VisibleCollidingActors( class 'Actor', Victims, DamageRadius, ShockWaveStart )
	{
		// don't let blast damage affect fluid - VisibleCollisingActors doesn't really work for them - jag
		if(Victims != Self && (Victims.Role == ROLE_Authority) && Victims.bCanBeDamaged && (!Victims.IsA('FluidSurfaceInfo')) && Victims != Instigator)
		{
			NewMomentum = damageScale * Momentum * dir;
			NewMomentum.Z += 10000;
				ShockTarget=BallisticPawn(Victims);
			if(IsValidHealTarget(ShockTarget))
			{
				PrevHealth = ShockTarget.Health;
				DamageAmount = 0;
				ShockTarget.GiveHealth(30, ShockTarget.HealthMax);
				PointsHealed += ShockTarget.Health - PrevHealth;	
				NewMomentum.X = 0;
				NewMomentum.Y = 0;
				NewMomentum.Z = 0;
			}
			else
			{
				dir = Victims.Location - ShockWaveStart;
				dist = FMax(1,VSize(dir));
				dir = dir/dist;
				damageScale = 1 - FMax(0,(dist - Victims.CollisionRadius)/DamageRadius);
				if (Pawn(Victims)==None)
					DamageAmount*=3;
				class'BallisticDamageType'.static.GenericHurt
				(
					Victims,
					damageScale * DamageAmount,
					Instigator,
					Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,
					/*damageScale * Momentum * dir*/NewMomentum,
					DamageType
				);
			}
		}
	}
	bHurtEntry = false;
}

function bool IsValidHealTarget(Pawn PulseTarget)
{
	if(PulseTarget==None||PulseTarget==Instigator)
		return False;

	if(PulseTarget.Health<=0)
		return False;

	if(!Level.Game.bTeamGame)
		return False;

	if(Vehicle(PulseTarget)!=None)
		return False;

	return (PulseTarget.Controller!=None&&Instigator.Controller.SameTeamAs(PulseTarget.Controller));
}

function AdjustPlayerDamage( out int Damage, Pawn InstigatedBy, Vector HitLocation, out Vector Momentum, class<DamageType> DamageType)
{
	if (bRanOnce)
		Damage *= 0.4;

	if (bBlocked && !IsFiring() && level.TimeSeconds > LastFireTime + 1 && class<BallisticDamageType>(DamageType) != None && 
		Normal(HitLocation-(Instigator.Location+Instigator.EyePosition())) Dot Vector(Instigator.GetViewRotation()) > 0.4)
	{
		if (class<BallisticDamageType>(DamageType).default.bCanBeBlocked)
			Damage = 0;
		else
		{
			if (ElectroCharge - Damage * 0.50 < 0)	
				ElectroCharge = Max(0, ElectroCharge-25);
			else
				ElectroCharge -= Damage * 0.50;
				
			if (Damage - DeflectionAmount < 0)
				Damage = 0;
			else
				Damage -= DeflectionAmount;
		}
		BallisticAttachment(ThirdPersonActor).UpdateBlockHit();		
	}
	super.AdjustPlayerDamage( Damage, InstigatedBy, HitLocation, Momentum, DamageType);
}

simulated function bool MayNeedReload(byte Mode, float Load)
{
	return false;
}

function ServerStartReload (optional byte i);

simulated function string GetHUDAmmoText(int Mode)
{
	return "";
}

simulated function float AmmoStatus(optional int Mode)
{
    return float(MagAmmo) / float(default.MagAmmo);
}

simulated function float ChargeBar()
{
	return FClamp(float(MagAmmo)/100, 0, 1);
}

// AI Interface =====
function bool CanAttack(Actor Other)
{
	return true;
}


// choose between regular or alt-fire
function byte BestMode()
{
	local Bot B;
	local float Result;

	B = Bot(Instigator.Controller);
	if ( (B == None) || (B.Enemy == None) )
		return 0;

	if (VSize(B.Enemy.Location - Instigator.Location) > FireMode[0].MaxRange()*1.5)
		return 1;
	Result = FRand();
	if (vector(B.Enemy.Rotation) dot Normal(Instigator.Location - B.Enemy.Location) < 0.0)
		Result += 0.3;
	else
		Result -= 0.3;

	if (Result > 0.5)
		return 1;
	return 0;
}

function float GetAIRating()
{
	local Bot B;
	local float Result, Dist;
	local vector Dir;

	B = Bot(Instigator.Controller);
	if ( (B == None) || (B.Enemy == None) )
		return AIRating;

	Dir = B.Enemy.Location - Instigator.Location;
	Dist = VSize(Dir);

	Result = AIRating;
	// Enemy too far away
	if (Dist > 1500)
		return 0.1;			// Enemy too far away
	// Better if we can get him in the back
	if (vector(B.Enemy.Rotation) dot Normal(Dir) < 0.0)
		Result += 0.08 * B.Skill;
	// If the enemy has a knife too, a gun looks better
	if (B.Enemy.Weapon != None && B.Enemy.Weapon.bMeleeWeapon)
		Result = FMax(0.0, Result *= 0.7 - (Dist/1000));
	// The further we are, the worse it is
	else
		Result = FMax(0.0, Result *= 1 - (Dist/1000));

	return Result;
}

// tells bot whether to charge or back off while using this weapon
function float SuggestAttackStyle()
{
	if (AIController(Instigator.Controller) == None)
		return 0.5;
	return AIController(Instigator.Controller).Skill / 4;
}

// tells bot whether to charge or back off while defending against this weapon
function float SuggestDefenseStyle()
{
	local Bot B;
	local float Result, Dist;

	B = Bot(Instigator.Controller);
	if ( (B == None) || (B.Enemy == None) )
		return -0.5;

	Dist = VSize(B.Enemy.Location - Instigator.Location);

	Result = -1 * (B.Skill / 6);
	Result *= (1 - (Dist/1500));
    return FClamp(Result, -1.0, -0.3);
}
// End AI Stuff =====

defaultproperties
{
     FlashF=0.300000
	 bShowChargingBar=True
	 DeflectionAmount=35
	 ElectroCharge=100
	 HealRatio=5
	 MagAmmo=100
	 PlayerJumpFactor=1.200000
	 PulseCharge=10
	 PulseInterval=0.5
	 PulseSound=Sound'BWBP2-Sounds2.LightningGun.LG-FireLoop'
     AIRating=0.200000
     AttachmentClass=Class'BWBP_SKC_Fix.DefibFistsAttachment'
     bAimDisabled=True
     bCanThrow=False
     BCRepClass=Class'BallisticFix.BallisticReplicationInfo'
     bFullVolume=True
     BigIconMaterial=Texture'BWBP_SKC_TexExp.Defist.BigIcon_DefibFists'
     bMeleeWeapon=True
     bNoMag=True
     BobDamping=1.700000
     BringUpTime=0.500000
     CenteredOffsetY=7.000000
     CenteredRoll=0
     CurrentRating=0.200000
     CustomCrossHairTextureName="Crosshairs.HUD.Crosshair_Cross1"
     Description="FMD H14 Combat Defibrillator||Manufacturer: UTC Defense Tech|Primary: Electric Jab|Secondary: Electric Uppercut|Special: Electric Dispersion Ring||When UTC troops stationed in medical bays around the galaxy asked for a lightweight and portable device to revive fallen troops, R&D teams came up with the FMD H14 Combat Defibrillator Unit. The H14 is a set of advanced defrillators worn around the hands, which are designed to bring portable resuscitation without sacrificing weight. However, live tests on the field quickly found that the H14 carried too much charge, so instead of saving lives, it just ended them. The H14s can still be used to charge and activate suit life-support systems, giving the user and his allies a small health boost. The H14 is now deployed as a force multiplier for select Berserker Squads, who make great use of its damage reducing dispersion field."
     DisplayFOV=65.000000
     DrawScale=0.600000
     FireModeClass(0)=Class'BWBP_SKC_Fix.DefibFistsPrimaryFire'
     FireModeClass(1)=Class'BWBP_SKC_Fix.DefibFistsSecondaryFire'
     FlashV=(X=2000.000000,Y=700.000000,Z=700.000000)
     GroupOffset=1
     GunLength=0.000000
     HudColor=(B=0,G=0,R=255)
     IconCoords=(X2=127,Y2=31)
     IconMaterial=Texture'BWBP_SKC_TexExp.Defist.Icon_DefibFists'
     InventorySize=5
     ItemName="FMD H14 Combat Defibrillator"
     Mesh=SkeletalMesh'BWBP_SKC_AnimExp.Defib_FP'
     OverheatSound=Sound'BWBP_SKC_Sounds.Misc.CXMS-Supercharge'
     PickupClass=Class'BWBP_SKC_Fix.DefibFistsPickup'
     PlayerSpeedFactor=1.200000
     PlayerViewOffset=(X=40.000000,Y=0.000000,Z=-10.000000)
     Priority=1
     PulseDamageType=class'DTShockGauntletPulse'
     PutDownAnimRate=1.000000
     PutDownTime=0.500000
     RampageOffSound=(Sound=Sound'BWBP_SKC_Sounds.Berserk.Berserk-Off',Volume=1.000000,Pitch=0.900000)
     RampageOnSound=(Sound=Sound'BWBP_SKC_Sounds.Berserk.Berserk-On',Volume=1.000000,Pitch=0.900000)
     RampageSound=Sound'BWBP_SKC_Sounds.Berserk.Berserk-Idle'
     SelectForce="SwitchToAssaultRifle"
     SoundRadius=128.000000
     SoundVolume=64
     SpecialInfo(0)=(Info="0.0;-999.0;-999.0;-1.0;-999.0;-999.0;-999.0")
     TeamSkins(0)=(RedTex=Shader'BallisticWeapons2.Hands.RedHand-Shiny',BlueTex=Shader'BallisticWeapons2.Hands.BlueHand-Shiny')
     WeaponModes(0)=(ModeName="Strikes")
     WeaponModes(1)=(ModeName="KILL!",ModeID="WM_FullAuto")
}
