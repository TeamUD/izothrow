modifier_physic_laws_armor = class({})

function modifier_physic_laws_armor:DeclareFunctions()
    return MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS
end

function modifier_physic_laws_armor:GetModifierPhysicalArmorBonus()
    return self:GetAbility():GetSpecialValueFor("bonus_armor")
end