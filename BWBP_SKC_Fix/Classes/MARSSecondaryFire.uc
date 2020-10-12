class MARSSecondaryFire extends BallisticFire;

simulated event ModeDoFire()
{
    if (!Instigator.IsLocallyControlled())
    	return;
	if (AllowFire())
		MARSAssaultRifle(Weapon).WeaponSpecial();
}

defaultproperties
{
     bUseWeaponMag=False
     bAISilent=True
     bWaitForRelease=True
     bModeExclusive=False
     FireRate=0.700000
     AmmoClass=Class'BallisticFix.Ammo_9mm'
     AmmoPerFire=0
     BotRefireRate=0.300000
}
