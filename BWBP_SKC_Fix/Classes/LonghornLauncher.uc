//=============================================================================
// LonghornLauncher.
//
// Lever Action Grenade Launcher - Fires cluster grenades. Alt fire simply shoots
// cluster. Shooting in the air will make it rain down with increased damage.
// Primary fire can be held to remotely detonate
//
// by Marc "Sergeant_Kelly"
//=============================================================================
class LonghornLauncher extends BallisticWeapon;

var	  bool		bScopeCock;
var	  bool		bGunCocked;
var	  bool		bQuickFire;

var   bool      bWasQuick;
var   float     LonghornHeldTime;
var   float     LonghornTimer;

var() Name	Shells[4];


simulated function AltFire(float F)	{	FirePressed(F);	}

simulated function SetScopeBehavior()
{
	super.SetScopeBehavior();
	if (bScopeView)
	{
	    BFireMode[0].XInaccuracy *= 0.75;
	    BFireMode[0].YInaccuracy *= 0.75;
	    BFireMode[1].XInaccuracy *= 0.75;
	    BFireMode[1].YInaccuracy *= 0.75;
        FireMode[0].FireAnim='SightFire';
        FireMode[1].FireAnim='SightFire';
	}
	
	else
	{
	    BFireMode[0].XInaccuracy = BFireMode[0].default.XInaccuracy;
	    BFireMode[0].YInaccuracy = BFireMode[0].default.YInaccuracy;
	    BFireMode[1].XInaccuracy = BFireMode[1].default.XInaccuracy;
	    BFireMode[1].YInaccuracy = BFireMode[1].default.YInaccuracy;
	    CockAnim='Cock1';
	    FireMode[0].FireAnim='Fire';
	    FireMode[1].FireAnim='Fire';
    }
}

// Prepare to reload, set reload state, start anims. Called on client and server
simulated function CommonStartReload (optional byte i)
{
	local int m;
	if (ClientState == WS_BringUp)
		ClientState = WS_ReadyToFire;
	ReloadState = RS_StartShovel;
	PlayReload();

	if (bScopeView && Instigator.IsLocallyControlled())
		TemporaryScopeDown(Default.SightingTime*Default.SightingTimeScale);
	for (m=0; m < NUM_FIRE_MODES; m++)
		if (BFireMode[m] != None)
			BFireMode[m].ReloadingGun(i);

	if (bCockAfterReload)
		bNeedCock=true;
	if (bCockOnEmpty && MagAmmo < 1)
		bNeedCock=true;
	bNeedReload=false;
}

simulated function PlayReload()
{

	if (SightingState != SS_None)
		TemporaryScopeDown(0.5);
    if (MagAmmo < 1 && Ammo[0].AmmoAmount >= default.MagAmmo)
    {
       ShovelIncrement=default.MagAmmo;
       ReloadAnim='ReloadFull';
       bCanSkipReload=False;
    }
    else
    {
       ShovelIncrement=1;
       ReloadAnim='ReloadSingle';
       bCanSkipReload=True;
    }
	
	SafePlayAnim(StartShovelAnim, ReloadAnimRate, , 0, "RELOAD");
}

simulated function PlayCocking(optional byte Type)
{
	if (Type == 2 && HasAnim(CockAnimPostReload))
		SafePlayAnim(CockAnimPostReload, CockAnimRate, 0.2, , "RELOAD");
	else
		SafePlayAnim(CockAnim, CockAnimRate, 0.2, , "RELOAD");

	if (SightingState != SS_None && Type != 1 && !bScopeCock)
		TemporaryScopeDown(0.5);
}

simulated function LonghornFired()
{
    local float r;
    
	bGunCocked = false;
    r=FRand();
    
	if (bScopeView)
     	{
		bScopeCock=True;
 		if (r < 0.50)
            		CockAnim='SlowCocking1';
         	else
            		CockAnim='SlowCocking2';
	}
	
     	else
     	{
         	if (r < 0.50)
         		CockAnim='Cock1';
         	else
            		CockAnim='Cock2';
	}
	 
	SetBoneRotation('Hammer', rot(0,0,0));
}

simulated function Notify_CockStart()
{
	if (ReloadState == RS_None)
		return;
	if (ReloadState == RS_EndShovel)
		PlayOwnedSound(ClipHitSound.Sound,ClipHitSound.Slot,ClipHitSound.Volume,ClipHitSound.bNoOverride,ClipHitSound.Radius,ClipHitSound.Pitch,ClipHitSound.bAtten);
	else
		PlayOwnedSound(CockSound.Sound,CockSound.Slot,CockSound.Volume,CockSound.bNoOverride,CockSound.Radius,CockSound.Pitch,CockSound.bAtten);
	bGunCocked=true;
	bNeedCock=false;
	bScopeCock=false;
}

simulated function bool PutDown()
{
	if (super.PutDown())
	{
		if (Instigator.IsLocallyControlled())
		{
			bGunCocked=false;
			SetBoneRotation('Hammer', rot(0,0,0));
		}
		return true;
	}
	return false;
}

simulated function BringUp(optional Weapon PrevWeapon)
{
	if (MagAmmo - BFireMode[0].ConsumedLoad < 1)
	{
		SetBoneScale(0,0.0,Shells[0]);
		SetBoneScale(1,0.0,Shells[1]);
		SetBoneScale(2,0.0,Shells[2]);
		SetBoneScale(3,0.0,Shells[3]);
	}

	Super.BringUp(PrevWeapon);
}

simulated event AnimEnd (int Channel)
{
    local name Anim;
    local float Frame, Rate;

    GetAnimParams(0, Anim, Frame, Rate);

	if (bGunCocked && Anim == CockAnim || Anim == EndShovelAnim)
	{
		SetBoneRotation('Hammer', rot(0,7282,0));
		IdleTweenTime=0.00;
	}
	Super.AnimEnd(Channel);
	IdleTweenTime = default.IdleTweenTime;
}

simulated function AnimEnded (int Channel, name anim, float frame, float rate)
{
	if (Anim == ZoomInAnim)
	{
		SightingState = SS_Active;
		ScopeUpAnimEnd();
		return;
	}
	else if (Anim == ZoomOutAnim)
	{
		SightingState = SS_None;
		ScopeDownAnimEnd();
		return;
	}

	if (anim == FireMode[0].FireAnim || (FireMode[1] != None && anim == FireMode[1].FireAnim))
		bPreventReload=false;

	// Modified stuff from Engine.Weapon
	if (ClientState == WS_ReadyToFire && ReloadState == RS_None)
    {
        if (anim == FireMode[0].FireAnim && HasAnim(FireMode[0].FireEndAnim)) // rocket hack
			SafePlayAnim(FireMode[0].FireEndAnim, FireMode[0].FireEndAnimRate, 0.0);
        else if (FireMode[1]!=None && anim== FireMode[1].FireAnim && HasAnim(FireMode[1].FireEndAnim))
            SafePlayAnim(FireMode[1].FireEndAnim, FireMode[1].FireEndAnimRate, 0.0);
        else if ((FireMode[0] == None || !FireMode[0].bIsFiring) && (FireMode[1] == None || !FireMode[1].bIsFiring))
        {
			bPreventReload=false;
            PlayIdle();
        }
    }
	// End stuff from Engine.Weapon

	// Start Shovel ended, move on to Shovel loop
	if (ReloadState == RS_StartShovel)
	{
		ReloadState = RS_Shovel;
		PlayShovelLoop();
		return;
	}
	// Shovel loop ended, start it again
	if (ReloadState == RS_PostShellIn)
	{
		if (MagAmmo >= default.MagAmmo || Ammo[0].AmmoAmount < 1)
		{
			PlayShovelEnd();
			ReloadState = RS_EndShovel;
			return;
		}
		ReloadState = RS_Shovel;
		PlayShovelLoop();
		return;
	}
	// End of reloading, either cock the gun or go to idle
	if (ReloadState == RS_PostClipIn || ReloadState == RS_EndShovel)
	{
		if (bNeedCock && MagAmmo > 0)
			CommonCockGun();
		else
		{
			bNeedCock=false;
			ReloadState = RS_None;
			ReloadFinished();
			PlayIdle();
			ReAim(0.05);
		}
		return;
	}
	//Cock anim ended, goto idle
	if (ReloadState == RS_Cocking)
	{
		bNeedCock=false;
		ReloadState = RS_None;
		ReloadFinished();
		PlayIdle();
		ReAim(0.05);
	}

}

// Animation notify for when the clip is pulled out - grens are all visible
simulated function Notify_GrenVisible() //We can see these now
{
	SetBoneScale(0,1.0,Shells[0]);
	SetBoneScale(1,1.0,Shells[1]);
	SetBoneScale(2,1.0,Shells[2]);
	SetBoneScale(3,1.0,Shells[3]);
}
simulated function Notify_GrenVisiblePart() //Show gren 4
{
	SetBoneScale(3,1.0,Shells[3]);
}
simulated function Notify_GrenHide()
{
	if (MagAmmo <= 1)
	{
		SetBoneScale(0,0.0,Shells[0]);
		SetBoneScale(1,0.0,Shells[1]);
		SetBoneScale(2,0.0,Shells[2]);
		SetBoneScale(3,0.0,Shells[3]);
	}
}
simulated function UpdateBones()
{
	local int i;
	
	for(i=3; i>=MagAmmo; i--)
		SetBoneScale(i, 0.0, Shells[i]);
	for(i=0; i<MagAmmo && i<4; i++)
		SetBoneScale(i, 1.0, Shells[i]);
}

// AI Interface =====
function byte BestMode()
{
	local Bot B;
	local float Dist;

	B = Bot(Instigator.Controller);
	if ( (B == None) || (B.Enemy == None) )
		return 0;

	Dist = VSize(B.Enemy.Location - Instigator.Location);

	if (Dist < FireMode[1].MaxRange())
		return 1;
	if (Dist < FireMode[1].MaxRange() * 2 && FRand() > 0.5)
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
		return Super.GetAIRating();

	Dir = B.Enemy.Location - Instigator.Location;
	Dist = VSize(Dir);

	Result = Super.GetAIRating();
	if (Dist > 4000)
		Result -= 0.35;
	if (Dist > 1500)
		Result += 0.15;

	return Result;
}

// tells bot whether to charge or back off while using this weapon
function float SuggestAttackStyle()	{	return 0.25;	}
// tells bot whether to charge or back off while defending against this weapon
function float SuggestDefenseStyle()	{	return 0.0;	}
// End AI Stuff =====

simulated function float ChargeBar()
{
	return LonghornPrimaryFire(FireMode[0]).HoldTime / 0.35;
}

defaultproperties
{
     bShowChargingBar=True
     TeamSkins(0)=(RedTex=Shader'BallisticWeapons2.Hands.RedHand-Shiny',BlueTex=Shader'BallisticWeapons2.Hands.BlueHand-Shiny')
     BigIconMaterial=Texture'BWBP_SKC_TexExp.Longhorn.BigIcon_LHorn'
     BallisticInventoryGroup=8
     BCRepClass=Class'BallisticFix.BallisticReplicationInfo'
     bWT_Hazardous=True
     bWT_Splash=True
     bWT_Grenade=True
     Shells(0)="GrenadeA"
     Shells(1)="GrenadeB"
     Shells(2)="GrenadeC"
     Shells(3)="GrenadeD"
     //HandgunGroup=1
     SpecialInfo(0)=(Info="240.0;25.0;0.6;50.0;1.0;0.5;-999.0")
     BringUpSound=(Sound=Sound'BWBP_SKC_Sounds.Bulldog.Bulldog-Pullout')
     PutDownSound=(Sound=Sound'BWBP_SKC_Sounds.Bulldog.Bulldog-Putaway')
     ClipHitSound=(Sound=Sound'BWBP_SKC_SoundsExp.Longhorn.Longhorn-CockShut',Volume=1.000000)
     ClipOutSound=(Sound=Sound'BWBP_SKC_SoundsExp.Longhorn.Longhorn-CockOpen')
     MagAmmo=4
     ShovelIncrement=1
     CockAnimRate=1.00
     CockSound=(Sound=Sound'BWBP_SKC_SoundsExp.Longhorn.Longhorn-CockAlt',Volume=0.950000)
     ReloadAnim="ReloadSingle"
     ReloadAnimRate=1.00
     ClipInSound=(Sound=SoundGroup'BWBP4-Sounds.Marlin.Mar-ShellIn')
     ClipInFrame=0.650000
     bCockOnEmpty=False
     bNeedCock=True
     bCanSkipReload=True
     bShovelLoad=True
     StartShovelAnim="ReloadStart"
     EndShovelAnim="ReloadEnd"
     CockAnim="Cock1"
     WeaponModes(0)=(ModeName="Single Fire")
     WeaponModes(1)=(bUnavailable=True)
     WeaponModes(2)=(bUnavailable=True)
     CurrentWeaponMode=0
     FullZoomFOV=70.000000
     SightPivot=(Pitch=150)
     SightOffset=(Y=19.60,Z=26.40)
     CrosshairCfg=(Pic1=Texture'BallisticUI2.Crosshairs.NRP57InA',pic2=Texture'BallisticUI2.Crosshairs.Misc7',USize1=256,VSize1=256,USize2=256,VSize2=256,Color1=(B=0,G=0,R=255,A=138),Color2=(B=0,G=255,R=255,A=255),StartSize1=137,StartSize2=32)
     CrouchAimFactor=0.300000
     SprintOffSet=(Pitch=-1000,Yaw=-2048)
     JumpOffSet=(Pitch=1000)
     JumpChaos=0.200000
     FallingChaos=0.100000
     SprintChaos=0.200000
     AimSpread=(X=(Min=-8.000000,Max=8.000000),Y=(Min=-8.000000,Max=8.000000))
     ViewAimFactor=0.200000
     ViewRecoilFactor=0.300000
     ChaosDeclineTime=1.000000
     ChaosTurnThreshold=200000.000000
     ChaosSpeedThreshold=800.000000
     RecoilYawFactor=0.100000
     RecoilXFactor=0.200000
     RecoilYFactor=0.200000
     RecoilMax=3072.000000
     RecoilDeclineTime=1.000000
     RecoilDeclineDelay=0.100000
     FireModeClass(0)=Class'BWBP_SKC_Fix.LongHornPrimaryFire'
     FireModeClass(1)=Class'BWBP_SKC_Fix.LongHornSecondaryFire'
     SelectForce="SwitchToAssaultRifle"
     AIRating=0.600000
     CurrentRating=0.600000
     Description="Longhorn Lever-Action Repeater|Manufacturer: Redwood Firearms|Primary: Cluster Round|Secondary: Split Cluster Round|| The longhorn is a large caliber lever-action rifle capable of firing everything from solid slugs to fragmentation grenades. This heavy duty hunting rifle first entered combat with the UTC Silver Ranger Division based in New Arizona. Outnumbered and outgunned, they had lost the battle of Phoenix Dam to the rebelling separatist groups. As the hostiles marched towards the colony's atmospheric stabilizer, they were continually dogged by the Rangers who had armed themselves with Longhorns filled with explosives and shrapnel. The lever-action launcher was easy to use and reliable and the rangers inflicted heavy casualties on the separatists before the stabilizer was lost and the colony compromised. Today, it is still in use with the Silver Rangers and is often loaded with powerful X2 SMRT Tandem-Cluster Grenades. The modern SMRT grenades can be fired on impact mode, scatter shot mode, remote mode, and artillery mode depending on the soldier's situation."
     Priority=145
     CustomCrossHairTextureName="Crosshairs.HUD.Crosshair_Cross1"
     InventoryGroup=9
     PickupClass=Class'BWBP_SKC_Fix.LonghornPickup'
     PlayerViewOffset=(X=-30.000000,Y=5.000000,Z=-20.000000)
     BobDamping=1.800000
     AttachmentClass=Class'BWBP_SKC_Fix.LonghornAttachment'
     IconMaterial=Texture'BWBP_SKC_TexExp.Longhorn.SmallIcon_LHorn'
     IconCoords=(X2=127,Y2=31)
     ItemName="Longhorn Repeater"
     LightType=LT_Pulse
     LightEffect=LE_NonIncidence
     LightHue=30
     LightSaturation=150
     LightBrightness=150.000000
     LightRadius=5.000000
     Mesh=SkeletalMesh'BWBP_SKC_AnimExp.Longhorn_FP'
     DrawScale=0.900000
     PutDownTime=1.000000
     BringUpTime=1.150000
     SelectAnimRate=0.850000
}
