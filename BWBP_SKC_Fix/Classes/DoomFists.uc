//==============================================================================
// Unarmed attack style 1, "Brawling" FIXME
//
// Just an unarmed attack style using various punches. Nothing complicated, just
// some quick jabs for primary fire and a powerful haymaker or uppercut for alt
// fire, which should be useful for knocking the enemy back.
//
// by Casey "Xavious" Johnson
//==============================================================================
class DoomFists extends BallisticMeleeWeapon;

var float	FlashF;
var vector	FlashV;
var   actor			RampageGlow;
var   bool			bMeatVision;
var	bool			bRanOnce;		// Set up for one time only berserk code. Temporary fix.
var() BUtil.FullSound	RampageOnSound;	// SUPER FISTS
var() BUtil.FullSound	RampageOffSound;	// Pansy fists
var() Sound		RampageSound;		// Sound to play when berserking



var MotionBlur			MBlur;


simulated function bool HasAmmo()
  {
    return true;
  }

function StartBerserk()
	{
	local PlayerController PC;
		Instigator.AmbientSound = RampageSound;
		Instigator.SoundVolume = 230;
		bMeatVision=true;
		Rampage();

		if (level.NetMode != NM_DedicatedServer)
		{
			if (RampageGlow != None)
				RampageGlow.Destroy();
	    		if (Instigator.IsLocallyControlled() && level.DetailMode >= DM_SuperHigh && class'BallisticMod'.default.EffectsDetailMode >= 2)
    			{
    				RampageGlow = None;
				class'BUtil'.static.InitMuzzleFlash (RampageGlow, class'RSDarkRampageGlow', DrawScale, self, 'rightwrist');

			}
		}
		if (Instigator !=None && Instigator.IsLocallyControlled() && Instigator.Controller != None && PlayerController(Instigator.Controller) != None && class'BallisticMod'.default.bUseMotionBlur)
		{
			PC = PlayerController(Instigator.Controller);

//			for (i=0;i<PC.CameraEffects.length;i++)
//				if (MotionBlur(PC.CameraEffects[i]) != None)	{
//					MBlur = MotionBlur(PC.CameraEffects[i]);
//					break;										}

//			if (MBlur == None)
//				MBlur = new class'MotionBlur';

//			class'BC_MotionBlurActor'.static.DoMotionBlur(PlayerController(Instigator.Controller), 1, 40);

//			MBlur.BlurAlpha = 128;

//			if (PC.CameraEffects.length < 1 || PC.CameraEffects[PC.CameraEffects.length-1] != MBlur)
//				PC.AddCameraEffect(MBlur,true);
		}

	}
function StopBerserk()
	{
     		BallisticInstantFire(FireMode[0]).FireRate = BallisticInstantFire(FireMode[0]).default.FireRate;
		BallisticInstantFire(FireMode[0]).Damage = BallisticInstantFire(FireMode[0]).default.damage;
		BallisticInstantFire(FireMode[0]).DamageHead = BallisticInstantFire(FireMode[0]).default.damagehead;
		BallisticInstantFire(FireMode[0]).DamageLimb = BallisticInstantFire(FireMode[0]).default.damagelimb;
     		BallisticInstantFire(FireMode[0]).DamageType=Class'BWBP_SKC_Fix.DTBrawling';
     		BallisticInstantFire(FireMode[0]).DamageTypeHead=Class'BWBP_SKC_Fix.DTBrawlingHead';
     		BallisticInstantFire(FireMode[0]).DamageTypeArm=Class'BWBP_SKC_Fix.DTBrawlingLimb';
    		BallisticInstantFire(FireMode[0]).FireAnimRate = BallisticInstantFire(FireMode[0]).default.FireAnimRate;

     		BallisticInstantFire(FireMode[1]).FireRate = BallisticInstantFire(FireMode[1]).default.FireRate;
		BallisticInstantFire(FireMode[1]).Damage = BallisticInstantFire(FireMode[1]).default.damage;
		BallisticInstantFire(FireMode[1]).DamageHead = BallisticInstantFire(FireMode[1]).default.damagehead;
		BallisticInstantFire(FireMode[1]).DamageLimb = BallisticInstantFire(FireMode[1]).default.damagelimb;
     		BallisticInstantFire(FireMode[1]).DamageType=Class'BWBP_SKC_Fix.DTBrawling';
     		BallisticInstantFire(FireMode[1]).DamageTypeHead=Class'BWBP_SKC_Fix.DTBrawlingHead';
     		BallisticInstantFire(FireMode[1]).DamageTypeArm=Class'BWBP_SKC_Fix.DTBrawlingLimb';
    		BallisticInstantFire(FireMode[1]).FireAnimRate = BallisticInstantFire(FireMode[1]).default.FireAnimRate;
		WeaponModes[0].bUnavailable=false;
		WeaponModes[1].bUnavailable=true;
    		class'BUtil'.static.PlayFullSound(self, RampageOffSound);
		bMeatVision=False;
		Instigator.AmbientSound = UsedAmbientSound;
		Instigator.SoundVolume = default.SoundVolume;
		if (CurrentWeaponMode == 1)
			CurrentWeaponMode=0;
	Instigator.GroundSpeed /= 1.2;
    bRanOnce=false;

	DoomFistsPrimaryFire(FireMode[1]).TraceRange.Min = DoomFistsPrimaryFire(FireMode[1]).default.TraceRange.Min;
	DoomFistsPrimaryFire(FireMode[1]).TraceRange.Max = DoomFistsPrimaryFire(FireMode[1]).default.TraceRange.Max;
	DoomFistsSecondaryFire(FireMode[1]).TraceRange.Min = DoomFistsSecondaryFire(FireMode[1]).default.TraceRange.Min;
	DoomFistsSecondaryFire(FireMode[1]).TraceRange.Max = DoomFistsSecondaryFire(FireMode[1]).default.TraceRange.Max;

	if (RampageGlow != None)
		RampageGlow.Destroy();

	if (MBlur != None)
		PlayerController(Instigator.Controller).RemoveCameraEffect(MBlur);
}

simulated function Rampage()
{
	if (!bRanOnce)
	{
		WeaponModes[0].bUnavailable=true;
		WeaponModes[1].bUnavailable=false;
		if (CurrentWeaponMode == 0)
			CurrentWeaponMode=1;
		Instigator.GroundSpeed *= 1.2;
    		BallisticInstantFire(FireMode[0]).FireRate = 0.4;
		BallisticInstantFire(FireMode[0]).Damage = 135;
		BallisticInstantFire(FireMode[0]).DamageHead = 275;
		BallisticInstantFire(FireMode[0]).DamageLimb = 70;
	      BallisticInstantFire(FireMode[0]).DamageType=Class'BWBP_SKC_Fix.DTBERSERK';
    	      BallisticInstantFire(FireMode[0]).DamageTypeHead=Class'BWBP_SKC_Fix.DTBERSERK';
    		BallisticInstantFire(FireMode[0]).DamageTypeArm=Class'BWBP_SKC_Fix.DTBERSERK';
    		BallisticInstantFire(FireMode[1]).FireRate = 0.6;
		BallisticInstantFire(FireMode[1]).Damage = 300;
		BallisticInstantFire(FireMode[1]).DamageHead = 325;
		BallisticInstantFire(FireMode[1]).DamageLimb = 135;
	      BallisticInstantFire(FireMode[1]).DamageType=Class'BWBP_SKC_Fix.DTBERSERK';
    	      BallisticInstantFire(FireMode[1]).DamageTypeHead=Class'BWBP_SKC_Fix.DTBERSERK';
    		BallisticInstantFire(FireMode[1]).DamageTypeArm=Class'BWBP_SKC_Fix.DTBERSERK';
    		BallisticInstantFire(FireMode[1]).FireAnimRate = 1.6;
    		BallisticInstantFire(FireMode[0]).FireAnimRate = 2;
		DoomFistsPrimaryFire(FireMode[1]).TraceRange.Min *= 1.05;
		DoomFistsPrimaryFire(FireMode[1]).TraceRange.Max *= 1.05;
		DoomFistsSecondaryFire(FireMode[1]).TraceRange.Min *= 1.05;
		DoomFistsSecondaryFire(FireMode[1]).TraceRange.Max *= 1.05;
		class'BC_MotionBlurActor'.static.DoMotionBlur(PlayerController(Instigator.Controller), 1, 40);
		class'BUtil'.static.PlayFullSound(self, RampageOnSound);
	}
	bRanOnce=true;


}


simulated function float GetModifiedJumpZ(Pawn P)
{
	if (bBerserk)
		return super.GetModifiedJumpZ(P) * 1.5;

	return super.GetModifiedJumpZ(P);
}

simulated event RenderOverlays (Canvas Canvas)
{

	Super(Weapon).RenderOverlays(Canvas);

	if (bMeatVision)
		DrawMeatVisionMode(Canvas);
}

simulated event WeaponTick(float DT)
{
	super.WeaponTick(DT);

	if (bMeatVision)
	{
//		class'BUtil'.static.PlayFullSound(self, RampageOnSound);
		class'BC_MotionBlurActor'.static.DoMotionBlur(PlayerController(Instigator.Controller), 2, 40);
//		Instigator.AmbientSound = RampageSound;
//		Instigator.SoundVolume = 230;
//		Instigator.GroundSpeed *= 1.2;

	}
	else
	{
		Instigator.AmbientSound = UsedAmbientSound;
		Instigator.SoundVolume = default.SoundVolume;
	}
}


// draws red blob that moves, scanline, and target boxes.
simulated event DrawMeatVisionMode (Canvas C)
{
	// Draw RED BLOOD
      C.Style = ERenderStyle.STY_Alpha;
	C.SetPos(C.OrgX, C.OrgY);
	C.DrawTile(Texture'BWBP_SKC_Tex.Berserk.BerserkOverlay', C.SizeX, C.SizeY, 0, 0, 1024, 1024);

}


function AdjustPlayerDamage( out int Damage, Pawn InstigatedBy, Vector HitLocation, out Vector Momentum, class<DamageType> DamageType)
{
	if (bRanOnce)
		Damage *= 0.4;

	super.AdjustPlayerDamage(Damage, InstigatedBy, HitLocation, Momentum, DamageType);
}

simulated function BringUp(optional Weapon PrevWeapon)
{

	super.BringUp(PrevWeapon);

	if (!bBerserk)
	{
		AmbientSound = None;
		Instigator.AmbientSound = UsedAmbientSound;
		Instigator.SoundVolume = default.SoundVolume;
		Instigator.SoundPitch = default.SoundPitch;
		Instigator.SoundRadius = default.SoundRadius;
		Instigator.bFullVolume = true;
	}


}
simulated function bool PutDown()
{
	if (super.PutDown())
	{
		if (bBerserk)
		{
			Instigator.GroundSpeed /= 1.2;
			bRanOnce=false;
		}
		Instigator.AmbientSound = None;
		Instigator.SoundVolume = Instigator.default.SoundVolume;
		Instigator.SoundPitch = Instigator.default.SoundPitch;
		Instigator.SoundRadius = Instigator.default.SoundRadius;
		Instigator.bFullVolume = Instigator.default.bFullVolume;
		return true;
	}
	return false;
}


simulated function Destroyed()
{
//	if (bOnRampage)
//		EndRampage();

	if (RampageGlow != None)
		RampageGlow.Destroy();

	if (bBerserk)
	{
        bRanOnce=false;
		Instigator.GroundSpeed /= 1.2;
	}

	if (Instigator.AmbientSound == RampageSound)
	{
		Instigator.AmbientSound = None;
		Instigator.SoundVolume = Instigator.default.SoundVolume;
		Instigator.SoundPitch = Instigator.default.SoundPitch;
		Instigator.SoundRadius = Instigator.default.SoundRadius;
		Instigator.bFullVolume = Instigator.default.bFullVolume;
	}


	if (MBlur != None)
		PlayerController(Instigator.Controller).RemoveCameraEffect(MBlur);

	super.Destroyed();
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
     RampageOnSound=(Sound=Sound'BWBP_SKC_Sounds.Berserk.Berserk-On',Volume=1.000000,Pitch=0.900000)
     RampageSound=Sound'BWBP_SKC_Sounds.Berserk.Berserk-Idle'
     RampageOffSound=(Sound=Sound'BWBP_SKC_Sounds.Berserk.Berserk-Off',Volume=1.000000,Pitch=0.900000)
     FlashV=(X=2000.000000,Y=700.000000,Z=700.000000)
     TeamSkins(0)=(RedTex=Shader'BallisticWeapons2.Hands.RedHand-Shiny',BlueTex=Shader'BallisticWeapons2.Hands.BlueHand-Shiny')
     PlayerSpeedFactor=1.350000
     BigIconMaterial=Texture'BWBP_SKC_Tex.Berserk.BigIcon_Glove'
     BCRepClass=Class'BallisticFix.BallisticReplicationInfo'
     InventorySize=5
     SpecialInfo(0)=(Info="0.0;-999.0;-999.0;-1.0;-999.0;-999.0;-999.0")
     MagAmmo=1
     bNoMag=True
     bOldCrosshairs=True
     WeaponModes(0)=(ModeName=" ")
     WeaponModes(1)=(ModeName="KILL!",ModeID="WM_FullAuto")
     GunLength=0.000000
     bAimDisabled=True
     FireModeClass(0)=Class'BWBP_SKC_Fix.DoomFistsPrimaryFire'
     FireModeClass(1)=Class'BWBP_SKC_Fix.DoomFistsSecondaryFire'
     PutDownTime=0.200000
     BringUpTime=0.100000
     PutDownAnimRate=3.000000
     SelectForce="SwitchToAssaultRifle"
     AIRating=0.200000
     CurrentRating=0.200000
     bMeleeWeapon=True
     bCanThrow=False
     Description="Your fists. Go get some bloody knuckles."
     DisplayFOV=65.000000
     Priority=1
     CenteredOffsetY=7.000000
     CenteredRoll=0
     CustomCrossHairTextureName="Crosshairs.HUD.Crosshair_Cross1"
     GroupOffset=1
     PickupClass=Class'BWBP_SKC_Fix.DoomFistsPickup'
     PlayerViewOffset=(X=-40.000000,Y=-1.000000,Z=-8.000000)
     PlayerViewPivot=(Yaw=-32768)
     BobDamping=1.700000
     AttachmentClass=Class'BWBP_SKC_Fix.DoomFistsAttachment'
     IconMaterial=Texture'BWBP_SKC_Tex.Berserk.SmallIcon_Glove'
     IconCoords=(X2=127,Y2=31)
     ItemName="Fists"
     Mesh=SkeletalMesh'BWBP_SKC_Anim.Fists'
     DrawScale=0.800000
     bFullVolume=True
     SoundVolume=64
     SoundRadius=128.000000
}
