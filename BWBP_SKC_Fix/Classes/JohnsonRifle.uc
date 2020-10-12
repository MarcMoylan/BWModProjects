//=============================================================================
// JohnsonRifle.
//
// Custom made rifle with bleed inflicting stakes as primary and a chainsaw as secondary
//
// by Marc "Sgt Kelly" Moylan.
// Copyright(c) 2020 Sarge. All Rights Reserved.
//=============================================================================
class JohnsonRifle extends BallisticWeapon;

var float BladeAlpha;
var float DesiredBladeAlpha;
var float BladeShiftSpeed;

var ChainsawPanner ChainsawPanner;
var float ChainSpeed;

var bool bLatchedOn;

simulated event WeaponTick(float DT)
{
	local float AccelLimit;
	super.WeaponTick(DT);

	if (Role == ROLE_Authority)
	{
        if (FireMode[0].IsFiring())
    	{
    		DesiredBladeAlpha = 0;
    		BladeShiftSpeed = 4; //4

    		if (BladeAlpha <= 0)
    		{
    			if (bLatchedOn && ChainSpeed != 1.5)
    			{
    				AccelLimit = (0.5 + 4.0*(ChainSpeed/2))*DT;
    				ChainSpeed += FClamp(1.5 - ChainSpeed, -AccelLimit, AccelLimit);
    			}
    			else if (!bLatchedOn && ChainSpeed != 2)
    			{
    				AccelLimit = (0.5 + /*2.0*(*/ChainSpeed/*/2)*/)*DT;
    				ChainSpeed += FClamp(2 - ChainSpeed, -AccelLimit, AccelLimit);
    			}
    		}
    	}

        if (FireMode[1].IsFiring())
    	{
    		DesiredBladeAlpha = 0;
    		BladeShiftSpeed = 4;

    		if (BladeAlpha <= 0)
    		{
    			if (bLatchedOn && ChainSpeed != 1.5)
    			{
    				AccelLimit = (0.5 + 4.0*(ChainSpeed/2))*DT;
    				ChainSpeed += FClamp(3.5 - ChainSpeed, -AccelLimit, AccelLimit);
    			}
    			else if (!bLatchedOn && ChainSpeed != 2)
    			{
    				AccelLimit = (0.5 + /*2.0*(*/ChainSpeed/*/2)*/)*DT;
    				ChainSpeed += FClamp(5 - ChainSpeed, -AccelLimit, AccelLimit);
    			}
    		}
    	}

	if (DesiredBladeAlpha == 0)
		SoundPitch = 32 + 32 * ChainSpeed;
	else
		SoundPitch = default.SoundPitch;

	if (ChainsawPanner!=None)
		ChainsawPanner.PanRate = -ChainSpeed;
    }
	
	if (!Instigator.IsLocallyControlled())
		return;
}

simulated function PlayIdle()
{
	super.PlayIdle();
	if (ChainSpeed <=0)
	{
		DesiredBladeAlpha = 1;
		BladeShiftSpeed = 3;
	}
}

simulated function bool PutDown()
{
	if (super.PutDown())
	{
		DesiredBladeAlpha = 0;
		BladeShiftSpeed = 3;
//		SetBladesOpen(1);
		return true;
	}
	return false;
}

simulated function Destroyed()
{
 	if (ChainsawPanner!=None)
 		level.ObjectPool.FreeObject(ChainsawPanner);
	super.Destroyed();
}

simulated function float RateSelf()
{
	if (PlayerController(Instigator.Controller) != None && Ammo[0].AmmoAmount < 1 && MagAmmo < 1)
		CurrentRating = Super.RateSelf() * 0.2;
	else
		return Super.RateSelf();
	return CurrentRating;
}

// AI Interface =====
// choose between regular or alt-fire
function byte BestMode()
{
	local Bot B;
	local float Dist;
	local Vector Dir;

	B = Bot(Instigator.Controller);
	if ( (B == None) || (B.Enemy == None) )
		return 0;

	Dir = Instigator.Location - B.Enemy.Location;
	Dist = VSize(Dir);

	if (Dist > 250)
		return 0;
	if (Dist < FireMode[1].MaxRange() && FRand() > 0.3)
		return 1;
	if (vector(B.Enemy.Rotation) dot Normal(Dir) < 0.0 && (VSize(B.Enemy.Velocity) < 100 || Normal(B.Enemy.Velocity) dot Normal(Instigator.Velocity) < 0.5))
		return 1;
	return Rand(2);
}

function float GetAIRating()
{
	local Bot B;
	local float Result, Dist;
	local vector Dir;

	B = Bot(Instigator.Controller);
	if ( (B == None) || (B.Enemy == None) )
		return Super.GetAIRating();

	Dir = B.Enemy.Location - Instigator.Location;
	Dist = VSize(Dir);

	Result = Super.GetAIRating();
	if (!HasMagAmmo(0) && Ammo[0].AmmoAmount < 1)
	{
		if (Dist > 400)
			return 0;
		return Result / (1+(Dist/400));
	}
	// Enemy too far away
	if (Dist > 1000)
		Result -= (Dist-1000) / 2000;
	// If the enemy has a knife too, a gun looks better
	if (B.Enemy.Weapon != None && B.Enemy.Weapon.bMeleeWeapon)
		Result += 0.1 * B.Skill;
	// Sniper bad, very bad
	else if (B.Enemy.Weapon != None && B.Enemy.Weapon.bSniping && Dist > 500)
		Result -= 0.3;
	Result += 1 - Dist / 1000;

	return Result;
}

// tells bot whether to charge or back off while using this weapon
function float SuggestAttackStyle()
{
	if (AIController(Instigator.Controller) == None)
		return 0.5;
	return AIController(Instigator.Controller).Skill / 7;
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
	Result *= (1 - (Dist/4000));
    return FClamp(Result, -1.0, -0.3);
}
// End AI Stuff =====

defaultproperties
{
     PlayerSpeedFactor=1.050000
     TeamSkins(0)=(RedTex=Shader'BallisticWeapons2.Hands.RedHand-Shiny',BlueTex=Shader'BallisticWeapons2.Hands.BlueHand-Shiny')
     AIReloadTime=1.000000
     BigIconMaterial=Texture'BWBP_SKC_Tex.M30A2.BigIcon_M30A2'
     BallisticInventoryGroup=6
     SightFXClass=Class'BallisticFix.M50SightLEDs'
     BCRepClass=Class'BallisticFix.BallisticReplicationInfo'
     bWT_Bullet=True
     SpecialInfo(0)=(Info="320.0;25.0;1.0;110.0;0.8;0.5;0.0")
     BringUpSound=(Sound=Sound'BallisticSounds2.M50.M50Pullout')
     PutDownSound=(Sound=Sound'BallisticSounds2.M50.M50Putaway')
     MagAmmo=9
     InventorySize=40
     CockAnimPostReload="ReloadEndCock"
     CockSound=(Sound=Sound'BWBP_SKC_SoundsExp.M780.M780-Cock')
     ClipHitSound=(Sound=Sound'BallisticSounds2.M50.M50ClipHit')
     ClipOutSound=(Sound=Sound'BallisticSounds2.M50.M50ClipOut')
     ClipInSound=(Sound=Sound'BallisticSounds2.M50.M50ClipIn')
     ClipInFrame=0.650000
     bNeedCock=True
     WeaponModes(0)=(ModeName="Semi-Automatic")
     CurrentWeaponMode=2
     bNoCrosshairInScope=true
     FullZoomFOV=45.000000
     bNoMeshInScope=False
     SightPivot=(Pitch=16)
     SightOffset=(X=-1.000000,Y=20.280000,Z=18.550000)
     SightDisplayFOV=20.000000
     CrosshairCfg=(Pic1=Texture'BallisticUI2.Crosshairs.M353OutA',Pic2=Texture'BallisticUI2.Crosshairs.M50InA',USize1=256,VSize1=256,USize2=256,VSize2=256,Color1=(B=0,G=0,R=255,A=197),Color2=(B=0,G=255,R=255,A=255),StartSize1=79,StartSize2=55)
     CrouchAimFactor=0.500000
	      AimAdjustTime=0.600000
     ViewAimFactor=0.300000
     ViewRecoilFactor=0.300000
     ChaosDeclineTime=1.000000
//     ChaosTurnThreshold=200000.000000
     ChaosSpeedThreshold=800.000000
     RecoilYawFactor=0.450000
     RecoilPitchFactor=1.000000
     RecoilXFactor=0.700000
     RecoilYFactor=0.700000
	RecoilMax=1600
     RecoilDeclineTime=0.700000
     RecoilDeclineDelay=0.100000
     AimSpread=(X=(Min=-128.000000,Max=128.000000),Y=(Min=-128.000000,Max=128.000000))
     ChaosAimSpread=(X=(Min=-1024.000000,Max=1024.000000),Y=(Min=-1024.000000,Max=1024.000000))
     SprintOffSet=(Pitch=-1000,Yaw=-2048)
     RecoilXCurve=(Points=(,(InVal=0.200000,OutVal=0.100000),(InVal=1.000000,OutVal=1.000000)))
     RecoilYCurve=(Points=(,(InVal=0.200000,OutVal=0.100000),(InVal=1.000000,OutVal=1.000000)))
     FireModeClass(0)=Class'BWBP_SKC_Fix.JohnsonPrimaryFire'
     FireModeClass(1)=Class'BWBP_SKC_Fix.JohnsonSecondaryFire'
     PutDownTime=0.700000
     SelectForce="SwitchToAssaultRifle"
     AIRating=0.600000
     CurrentRating=0.600000
     Description="'Hell Shredder' Stake Rifle||Manufacturer: Enravion Combat Solutions|Primary: Accurate Rifle Fire|Secondary: Charged Gauss Fire|Special: Laser Dot||A further improvement on their crowning achievement, the M30A1 is the long range version of the famed rifle. With a forward mounted laser sight and heavy 7.62 rifle rounds, the M30A1 Tactical Rifle can accurately snipe targets at any distance. In order to compensate for the slower firing speed and increased recoil, Enravion added a secondary gauss projectile accelerator to the barrel. By simply depressing the trigger twice in quick succession, the user can activate the system and propel the bullet at a much higher velocity through the armor and flesh of unsuspecting victims. (With regards to a 2 second recharge time.) The A1 comes equipped with a mounted camera sight for increased accuracy."
     Priority=65
     CustomCrossHairTextureName="Crosshairs.HUD.Crosshair_Cross1"
     InventoryGroup=9
     PickupClass=Class'BWBP_SKC_Fix.JohnsonPickup'
     PlayerViewOffset=(X=-15.000000,Y=-2.000000,Z=-17.000000)
     BobDamping=2.000000
     AttachmentClass=Class'BWBP_SKC_Fix.JohnsonAttachment'
     IconMaterial=Texture'BWBP_SKC_Tex.M30A2.SmallIcon_M30A2'
     IconCoords=(X2=127,Y2=31)
     ItemName="'Hell Shredder' Stake Rifle"
     LightType=LT_Pulse
     LightEffect=LE_NonIncidence
     LightHue=30
     LightSaturation=150
     LightBrightness=150.000000
     LightRadius=4.000000
     Mesh=SkeletalMesh'BWBP_SKC_AnimExp.Johnson_FP'
     DrawScale=0.600000

}
