SMODS.Joker{ --mace
    key = "mace",
    config = {
        extra = {
        }
    },
    loc_txt = {
        ['name'] = 'Mace',
        ['text'] = {
            [1] = 'This Joker gives {X:red,C:white}XMult{}',
            [2] = 'equals the {C:attention}rank difference{} between',
            [3] = 'the {C:attention}highest{} and {C:attention}lowest{} scoring card',
            [4] = 'contained in played hand'
        },
        ['unlock'] = {
            [1] = 'Unlocked by default.'
        }
    },
    pos = {
        x = 2,
        y = 10 -- WHHAT LMFAO
    },
    display_size = {
        w = 71 * 1, 
        h = 95 * 1
    },
    cost = 6,
    rarity = 2,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    unlocked = true,
    discovered = true,
    atlas = 'CustomJokers',

    calculate = function(self, card, context)
        if context.joker_main then
            local low, high = context.scoring_hand[1].base.nominal, context.scoring_hand[1].base.nominal
            for k, v in ipairs(context.scoring_hand) do
                if v.base.nominal < low then
                    low = v.base.nominal
                elseif v.base.nominal > high then
                    high = v.base.nominal
                end
            end
            if high - low > 0 then
                return {
                    Xmult = lenient_bignum((high - low) or 0)
                }
            else
                return {
                    Xmult = 0,
                    card_eval_status_text(card, "extra", nil, nil, nil, { message = "X0 Mult", colour = G.C.RED })
                }
            end
        end
    end

}

SMODS.Joker{ --Trident
    key = "trident",
    config = {
        extra = {
            levels0 = 3
        }
    },
    loc_txt = {
        ['name'] = 'Trident',
        ['text'] = {
            [1] = 'Increase level of',
            [2] = 'played {C:attention}poker hand{} by 3',
            [3] = 'if played hand contains',
            [4] = '{C:attention}Three of a Kind{}'
        },
        ['unlock'] = {
            [1] = 'Unlocked by default.'
        }
    },
    pos = {
        x = 1,
        y = 10
    },
    display_size = {
        w = 71 * 1, 
        h = 95 * 1
    },
    cost = 6,
    rarity = 2,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    unlocked = true,
    discovered = true,
    atlas = 'CustomJokers',
    
    calculate = function(self, card, context)
        if context.cardarea == G.jokers and context.before  then
            if next(context.poker_hands["Three of a Kind"]) then
                local target_hand = (context.scoring_name or "High Card")
                level_up_hand(card, target_hand, true, 3)
                return {
                    message = localize('k_level_up_ex')
                }
            end
        end
    end
}
SMODS.Joker{ --toolsmith
    key = "toolsmith",
    config = {
        extra = {
            mult_mod = 2,
            mult = 0
        }
    },
    loc_txt = {
        ['name'] = 'Toolsmith',
        ['text'] = {
            [1] = 'This Joker gains {C:red}+#1#{} Mult',
            [2] = 'when an item is bought from shop',
            [3] = '{C:inactive}(Currently{} {C:red}+#2#{} {C:inactive}Mult){}'
        },
        ['unlock'] = {
            [1] = 'Unlocked by default.'
        }
    },
    pos = {
        x = 3,
        y = 12
    },
    display_size = {
        w = 71 * 1, 
        h = 95 * 1
    },
    cost = 4,
    rarity = 1,
    blueprint_compat = true,
    demicoloncompat = true,
    eternal_compat = true,
    perishable_compat = false,
    unlocked = true,
    discovered = true,
    atlas = 'CustomJokers',
    
    loc_vars = function(self, info_queue, card)
        
        return {vars = {card.ability.extra.mult_mod, card.ability.extra.mult}}
    end,
    
    calculate = function(self, card, context)
        if ((context.buying_card and not (context.card == card)) or context.open_booster) and not context.blueprint then
            return {
                func = function()
                    card.ability.extra.mult = (card.ability.extra.mult) + card.ability.extra.mult_mod
                    return true
                end,
                message = localize('k_upgrade_ex')
            }
        end
        if context.cardarea == G.jokers and context.joker_main  then
            return {
                mult = card.ability.extra.mult
            }
        end
        if context.forcetrigger then
            card.ability.extra.mult = (card.ability.extra.mult) + card.ability.extra.mult_mod
            return {
                mult = card.ability.extra.mult
            }
        end
    end
}

SMODS.Joker{ --fletcher
    key = "fletcher",
    config = {
        extra = {
            req = 4,
            played = 0,
            money = 4,
            cardsinhand = 0
        }
    },
    loc_txt = {
        ['name'] = 'Fletcher',
        ['text'] = {
            [1] = 'Earns {C:gold}$#3#{}',
            [2] = 'every {C:attention}#1#{} cards played and scored {C:inactive}(#2#){}'
        },
        ['unlock'] = {
            [1] = 'Unlocked by default.'
        }
    },
    pos = {
        x = 7,
        y = 11
    },
    display_size = {
        w = 71 * 1, 
        h = 95 * 1
    },
    cost = 4,
    rarity = 1,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    unlocked = true,
    discovered = true,
    atlas = 'CustomJokers',
    
    loc_vars = function(self, info_queue, card)
        
        return {vars = {card.ability.extra.req, card.ability.extra.played, card.ability.extra.money, (#(G.hand and G.hand.cards or {}) or 0)}}
    end,
    
    calculate = function(self, card, context)
        if context.before and context.cardarea == G.jokers  and not context.blueprint then
            return {
                func = function()
                    card.ability.extra.played = (card.ability.extra.played) + #context.scoring_hand
                    return true
                end
            }
        end
        if context.cardarea == G.jokers and context.joker_main  then
            if to_big(card.ability.extra.played) >= to_big(card.ability.extra.req) then
                local dollar = math.floor(card.ability.extra.played / card.ability.extra.req)
                return {
                    func = function()
                        ease_dollars(dollar * card.ability.extra.money)
                        card.ability.extra.played = card.ability.extra.played - (dollar * card.ability.extra.req)
                    return true
                    end,
                    card_eval_status_text(context.blueprint_card or card, 'extra', nil, nil, nil, {message = "$"..tostring(dollar * card.ability.extra.money), colour = G.C.MONEY})
                }
            end
        end
    end
}


SMODS.Joker{ --farmer
    key = "farmer",
    config = {
        extra = {
            discount_amount = '2'
        }
    },
    loc_txt = {
        ['name'] = 'Farmer',
        ['text'] = {
            [1] = 'All consumables in shop are free'
        },
        ['unlock'] = {
            [1] = 'Unlocked by default.'
        }
    },
    pos = {
        x = 8,
        y = 11
    },
    display_size = {
        w = 71 * 1, 
        h = 95 * 1
    },
    cost = 4,
    rarity = 1,
    blueprint_compat = false,
    eternal_compat = true,
    perishable_compat = true,
    unlocked = true,
    discovered = true,
    atlas = 'CustomJokers',
    
    calculate = function(self, card, context)
    end,
    
    add_to_deck = function(self, card, from_debuff)
        G.E_MANAGER:add_event(Event({
            func = function()
                for k, v in pairs(G.I.CARD) do
                if v.set_cost then v:set_cost() end
                end
                return true
            end
        }))
    end,
    
    remove_from_deck = function(self, card, from_debuff)
        G.E_MANAGER:add_event(Event({
            func = function()
                for k, v in pairs(G.I.CARD) do
                if v.set_cost then v:set_cost() end
                end
                return true
            end
        }))
    end
} 
      
local card_set_cost_ref = Card.set_cost
function Card:set_cost()
    card_set_cost_ref(self)
    
    if next(SMODS.find_card("j_ssr_farmer")) then
        if (self.ability.set == 'Tarot' or self.ability.set == 'Planet' or self.ability.set == 'Spectral') then
            self.cost = 0
        end
    end
    
    self.sell_cost = math.max(1, math.floor(self.cost / 2)) + (self.ability.extra_value or 0)
    self.sell_cost_label = self.facing == 'back' and '?' or self.sell_cost
end


SMODS.Joker{ --cartographer
    key = "cartographer",
    config = {
        extra = {
        }
    },
    loc_txt = {
        ['name'] = 'Cartographer',
        ['text'] = {
            [1] = '{C:attention}+2{} Shop Slots,',
            [2] = '{C:attention}+1{} Booster and Voucher Slots'
        },
        ['unlock'] = {
            [1] = 'Unlocked by default.'
        }
    },
    pos = {
        x = 0,
        y = 12
    },
    display_size = {
        w = 71 * 1, 
        h = 95 * 1
    },
    cost = 4,
    rarity = 1,
    blueprint_compat = true,
    demicoloncompat = true,
    eternal_compat = true,
    perishable_compat = true,
    unlocked = true,
    discovered = true,
    atlas = 'CustomJokers',
    
    calculate = function(self, card, context)
        if context.forcetrigger then
            SMODS.change_voucher_limit(1)
            SMODS.change_booster_limit(1)
            change_shop_size(2)
        end
    end,
    
    add_to_deck = function(self, card, from_debuff)
        SMODS.change_voucher_limit(1)
        SMODS.change_booster_limit(1)
        change_shop_size(2)
    end,
    
    remove_from_deck = function(self, card, from_debuff)
        SMODS.change_voucher_limit(-1)
        SMODS.change_booster_limit(-1)
        change_shop_size(-2)
    end
}

SMODS.Joker{ --armorsmith
    key = "armorsmith",
    config = {
        extra = {
            xmult_mod = 0.1,
            xmult = 1
        }
    },
    loc_txt = {
        ['name'] = 'Armorsmith',
        ['text'] = {
            [1] = 'This Joker gains {X:red,C:white}X#1#{} Mult',
            [2] = 'for each card bought in shop',
            [3] = '{C:inactive}(Currently {}{X:red,C:white}X#2#{}{C:inactive} Mult){}'
        },
        ['unlock'] = {
            [1] = 'Unlocked by default.'
        }
    },
    pos = {
        x = 9,
        y = 11
    },
    display_size = {
        w = 71 * 1, 
        h = 95 * 1
    },
    cost = 7,
    rarity = 2,
    blueprint_compat = true,
    demicoloncompat = true,
    eternal_compat = true,
    perishable_compat = false,
    unlocked = true,
    discovered = true,
    atlas = 'CustomJokers',
    
    loc_vars = function(self, info_queue, card)
        
        return {vars = {card.ability.extra.xmult_mod, card.ability.extra.xmult}}
    end,
    
    calculate = function(self, card, context)
        if context.buying_card  and not context.blueprint and not (context.card == card) then
            return {
                func = function()
                    card.ability.extra.xmult = (card.ability.extra.xmult) + card.ability.extra.xmult_mod
                    return true
                end,
                message = localize('k_upgrade_ex')
            }
        end
        if context.cardarea == G.jokers and context.joker_main  then
            return {
                Xmult = card.ability.extra.xmult
            }
        end
        if context.forcetrigger then
            card.ability.extra.xmult = (card.ability.extra.xmult) + card.ability.extra.xmult_mod
            return {
                Xmult = card.ability.extra.xmult
            }
        end
    end
}
SMODS.Joker{ --librarian
    key = "librarian",
    config = {
        extra = {
            odds = 3
        }
    },
    loc_txt = {
        ['name'] = 'Librarian',
        ['text'] = {
            [1] = 'When shop is rerolled,',
            [2] = '{C:green}#1# in #2#{} chance to create',
            [3] = 'an {C:spectral}Ethereal Tag{}'
        },
        ['unlock'] = {
            [1] = 'Unlocked by default.'
        }
    },
    pos = {
        x = 2,
        y = 12
    },
    display_size = {
        w = 71 * 1, 
        h = 95 * 1
    },
    cost = 8,
    rarity = 2,
    blueprint_compat = true,
    demicoloncompat = true,
    eternal_compat = true,
    perishable_compat = true,
    unlocked = true,
    discovered = true,
    atlas = 'CustomJokers',
    
    loc_vars = function(self, info_queue, card)
        
        local new_numerator, new_denominator = SMODS.get_probability_vars(card, 1, card.ability.extra.odds, 'j_ssr_librarian') 
        return {vars = {new_numerator, new_denominator}}
    end,
    
    calculate = function(self, card, context)
        if context.reroll_shop  then
            if true then
                if SMODS.pseudorandom_probability(card, 'group_0_7cec881a', 1, card.ability.extra.odds, 'j_ssr_librarian', false) then
                    SMODS.calculate_effect({func = function()
                        G.E_MANAGER:add_event(Event({
                            func = function()
                                local tag = Tag("tag_ethereal")
                                tag:set_ability()
                                add_tag(tag)
                                play_sound('holo1', 1.2 + math.random() * 0.1, 0.4)
                                return true
                            end
                        }))
                        delay(0.6)
                        card_eval_status_text(context.blueprint_card or card, 'extra', nil, nil, nil, {message = localize('k_plus_spectral'), colour = G.C.SECONDARY_SET.Spectral})
                        return true
                    end}, card)
                end
            end
        end
        if context.forcetrigger then
                for i = 1, math.min(1, G.consumeables.config.card_limit - #G.consumeables.cards) do
                        G.E_MANAGER:add_event(Event({
                            func = function()
                                local tag = Tag("tag_ethereal")
                                tag:set_ability()
                                add_tag(tag)
                                play_sound('holo1', 1.2 + math.random() * 0.1, 0.4)
                                return true
                            end
                        }))
                end
                delay(0.6)
                card_eval_status_text(context.blueprint_card or card, 'extra', nil, nil, nil, {message = localize('k_plus_spectral'), colour = G.C.SECONDARY_SET.Spectral})
                return true
        end
    end
}
SMODS.Joker{ --cleric
    key = "cleric",
    config = {
        extra = {
            xmult = 1,
            xmult_mod = 0.32
        }
    },
    loc_txt = {
        ['name'] = 'Cleric',
        ['text'] = {
            [1] = 'This Joker gains {X:red,C:white}X#2#{} Mult',
            [2] = 'per scoring {C:attention}Mult Card{} played,',
            [3] = 'and destroy all scoring {C:attention}Mult Cards{} afterwards',
            [4] = '{C:inactive}(Currently{} {X:red,C:white}X#1#{} {C:inactive}Mult){}'
        },
        ['unlock'] = {
            [1] = 'Unlocked by default.'
        }
    },
    pos = {
        x = 1,
        y = 12
    },
    display_size = {
        w = 71 * 1, 
        h = 95 * 1
    },
    cost = 6,
    rarity = 2,
    blueprint_compat = true,
    demicoloncompat = true,
    eternal_compat = true,
    perishable_compat = false,
    unlocked = true,
    discovered = true,
    atlas = 'CustomJokers',
    
    loc_vars = function(self, info_queue, card)
        
        return {vars = {card.ability.extra.xmult, card.ability.extra.xmult_mod}}
    end,
    
    calculate = function(self, card, context)
        if context.destroy_card and context.destroy_card.should_destroy  then
            return { remove = true }
        end
        if context.individual and context.cardarea == G.play  and not context.blueprint then
            context.other_card.should_destroy = false
            if SMODS.get_enhancements(context.other_card)["m_mult"] == true then
                context.other_card.should_destroy = true
                card.ability.extra.xmult = (card.ability.extra.xmult) + card.ability.extra.xmult_mod
            end
        end
        if context.cardarea == G.jokers and context.joker_main or context.forcetrigger then
            return {
                Xmult = card.ability.extra.xmult
            }
        end
    end
}


SMODS.Joker{ --nitwit
    key = "nitwit",
    config = {
        extra = {
        }
    },
    loc_txt = {
        ['name'] = 'Nitwit',
        ['text'] = {
            [1] = 'insert text here'
        },
        ['unlock'] = {
            [1] = 'Unlocked by default.'
        }
    },
    pos = {
        x = 4,
        y = 12
    },
    display_size = {
        w = 71 * 1, 
        h = 95 * 1
    },
    cost = 10,
    rarity = 3,
    blueprint_compat = false,
    eternal_compat = false,
    perishable_compat = false,
    unlocked = true,
    discovered = true,
    atlas = 'CustomJokers',
    
    calculate = function(self, card, context)
        if context.cardarea == G.jokers and context.before and not context.blueprint then
            local created_joker = false
            if #G.jokers.cards + G.GAME.joker_buffer < G.jokers.config.card_limit then
                created_joker = true
				local spawnamount = G.jokers.config.card_limit - (#G.jokers.cards + G.GAME.joker_buffer) -- cryptid is a goated mod
				G.GAME.joker_buffer = G.GAME.joker_buffer + spawnamount
				G.E_MANAGER:add_event(Event({
					func = function()
						for i = 1, spawnamount do
							local card = create_card("Joker", G.jokers, nil, nil, nil, nil, "j_ssr_nitwit")
							card:add_to_deck()
							G.jokers:emplace(card)
							G.GAME.joker_buffer = 0
						end
						return true
					end,
				}))
            end
            return {
                message = created_joker and localize('k_plus_joker') or nil
            }
        end
    end
}

-- hostile mobs

SMODS.Joker{ --zombie
    key = "zombie",
    config = {
        extra = {
        }
    },
    loc_txt = {
        ['name'] = 'Zombie',
        ['text'] = {
            [1] = 'When this card is sold,',
            [2] = 'create 2 {C:dark_edition}Negative{} {C:attention}Empress{}{C:tarot} Tarots{}'
        },
        ['unlock'] = {
            [1] = 'Unlocked by default.'
        }
    },
    pos = {
        x = 3,
        y = 10
    },
    display_size = {
        w = 71 * 1, 
        h = 95 * 1
    },
    cost = 4,
    rarity = 1,
    blueprint_compat = true,
    demicoloncompat = true,
    eternal_compat = false,
    perishable_compat = true,
    unlocked = true,
    discovered = true,
    atlas = 'CustomJokers',
    
    calculate = function(self, card, context)
        if context.selling_self or context.forcetrigger then
            return {
                func = function()
                    
                    for i = 1, math.min(2, G.consumeables.config.card_limit - #G.consumeables.cards) do
                        G.E_MANAGER:add_event(Event({
                            trigger = 'after',
                            delay = 0.4,
                            func = function()
                                play_sound('timpani')
                                SMODS.add_card({ set = 'Tarot', edition = 'e_negative', key = 'c_empress'})                            
                                card:juice_up(0.3, 0.5)
                                return true
                            end
                        }))
                    end
                    delay(0.6)
                    
                    if created_consumable then
                        card_eval_status_text(context.blueprint_card or card, 'extra', nil, nil, nil, {message = localize('k_plus_tarot'), colour = G.C.PURPLE})
                    end
                    return true
                end
            }
        end
    end
}

SMODS.Joker{ --creeper
    key = "creeper",
    config = {
    },
    loc_txt = {
        ['name'] = 'Creeper',
        ['text'] = {
            [1] = 'Sell this Joker to',
            [2] = '{C:red}destory{} all cards held in hand',
            [3] = 'and reduce Blind requirement by {C:attention}67%{}'
        },
        ['unlock'] = {
            [1] = 'Unlocked by default.'
        }
    },
    pos = {
        x = 4,
        y = 10
    },
    display_size = {
        w = 71 * 1, 
        h = 95 * 1
    },
    cost = 5,
    rarity = 1,
    blueprint_compat = true,
    eternal_compat = false,
    perishable_compat = true,
    unlocked = true,
    discovered = true,
    atlas = 'CustomJokers',
    
    calculate = function(self, card, context)
        if context.selling_self  and not context.blueprint then
                return {
                    func = function()
            G.E_MANAGER:add_event(Event({
                func = function()
                    G.hand_text_area.blind_chips:juice_up()
                    G.hand_text_area.game_chips:juice_up()
                    play_sound('tarot1')
                    card:start_dissolve()
                    return true
                end
            }))
            local destroyed_cards = {}
            for k, v in ipairs(G.hand.cards) do
                destroyed_cards[#destroyed_cards+1] = v
            end
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.1,
                func = function() 
                    for i=#destroyed_cards, 1, -1 do
                        local card = destroyed_cards[i]
                        if card.ability.name == 'Glass Card' then 
                            card:shatter()
                        else
                            card:start_dissolve(nil, i == #destroyed_cards)
                        end
                    end
                    return true
                end
            }))
            if G.GAME.blind.in_blind then
                card_eval_status_text(context.blueprint_card or card, 'extra', nil, nil, nil, {message = 'Boom', colour = G.C.GREEN})
                G.GAME.blind.chips = G.GAME.blind.chips * 0.33
                G.GAME.blind.chip_text = number_format(G.GAME.blind.chips)
                G.HUD_blind:recalculate()
                return true
            end
            return true
            end
            }
        end
    end
}
SMODS.Joker{ --skeleton
    key = "skeleton",
    config = {
        extra = {
            mult = 15,
            scored = 0
        }
    },
    loc_txt = {
        ['name'] = 'Skeleton',
        ['text'] = {
            [1] = '{C:red}+#1#{} Mult every 3 cards scored',
            [2] = '{C:inactive}(#2#/3){}'
        },
        ['unlock'] = {
            [1] = 'Unlocked by default.'
        }
    },
    pos = {
        x = 6,
        y = 10
    },
    display_size = {
        w = 71 * 1, 
        h = 95 * 1
    },
    cost = 4,
    rarity = 1,
    blueprint_compat = true,
    demicoloncompat = true,
    eternal_compat = true,
    perishable_compat = true,
    unlocked = true,
    discovered = true,
    atlas = 'CustomJokers',
    
    loc_vars = function(self, info_queue, card)
        
        return {vars = {card.ability.extra.mult, card.ability.extra.scored}}
    end,
    
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play  then
            if to_big((card.ability.extra.scored or 0)) < to_big(2) then
                card.ability.extra.scored = (card.ability.extra.scored) + 1
            else
                card.ability.extra.scored = 0
                return {
                    mult = card.ability.extra.mult
                }
            end
        end
        if context.forcetrigger then
            return {
                mult = card.ability.extra.mult
            }
        end
    end
}
SMODS.Joker{ --babyzombie
    key = "babyzombie",
    config = {
        extra = {
            odds = 2,
        }
    },
    loc_txt = {
        ['name'] = 'Baby Zombie',
        ['text'] = {
            [1] = 'Each scoring card has',
            [2] = '{C:green}#1# in #2#{} chance to retrigger twice'
        },
        ['unlock'] = {
            [1] = 'Unlocked by default.'
        }
    },
    pos = {
        x = 5,
        y = 10
    },
    display_size = {
        w = 71 * 0.6, 
        h = 95 * 0.6
    },
    cost = 5,
    rarity = 1,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    unlocked = true,
    discovered = true,
    atlas = 'CustomJokers',
    
    loc_vars = function(self, info_queue, card)
        
        local new_numerator, new_denominator = SMODS.get_probability_vars(card, 1, card.ability.extra.odds, 'j_ssr_babyzombie') 
        return {vars = {new_numerator, new_denominator}}
    end,
    
    calculate = function(self, card, context)
        if context.repetition and context.cardarea == G.play then
            if SMODS.pseudorandom_probability(card, 'group_0_51a47a35', 1, card.ability.extra.odds, 'j_ssr_babyzombie', false) then
                return {
                    repetitions = 2,
                    message = localize('k_again_ex')
                }
            end
        end
    end
}
SMODS.Joker{ --spider
    key = "spider",
    config = {
        extra = {
            pb_x_chips = 0.16,
            perma_x_chips = 0
        }
    },
    loc_txt = {
        ['name'] = 'Spider',
        ['text'] = {
            [1] = 'Each played {C:attention}8{} permanently',
            [2] = 'gains {X:blue,C:white}X#1#{} Chips when scored'
        },
        ['unlock'] = {
            [1] = 'Unlocked by default.'
        }
    },
    pos = {
        x = 9,
        y = 10
    },
    display_size = {
        w = 71 * 1, 
        h = 95 * 1
    },
    cost = 4,
    rarity = 1,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    unlocked = true,
    discovered = true,
    atlas = 'CustomJokers',
    
    loc_vars = function(self, info_queue, card)
        
        return {vars = {card.ability.extra.pb_x_chips}}
    end,
    
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play  then
            if context.other_card:get_id() == 8 then
                context.other_card.ability.perma_x_chips = context.other_card.ability.perma_x_chips or 0
                context.other_card.ability.perma_x_chips = context.other_card.ability.perma_x_chips + card.ability.extra.pb_x_chips
                return {
                    extra = { message = localize('k_upgrade_ex'), colour = G.C.CHIPS }, card = card
                }
            end
        end
    end
}
SMODS.Joker{ --witch
    key = "witch",
    config = {
        extra = {
            played = 0,
            req = 2
        }
    },
    loc_txt = {
        ['name'] = 'Witch',
        ['text'] = {
            [1] = 'Create a random {C:tarot}Tarot{}',
            [2] = 'for every {C:attention}#2#{} hands played {C:inactive}(#1#){}',
        },
        ['unlock'] = {
            [1] = 'Unlocked by default.'
        }
    },
    pos = {
        x = 7,
        y = 10
    },
    display_size = {
        w = 71 * 1, 
        h = 95 * 1
    },
    cost = 6,
    rarity = 2,
    blueprint_compat = true,
    demicoloncompat = true,
    eternal_compat = true,
    perishable_compat = true,
    unlocked = true,
    discovered = true,
    atlas = 'CustomJokers',
    
    loc_vars = function(self, info_queue, card)
        
        return {vars = {card.ability.extra.played, card.ability.extra.req}}
    end,
    
    calculate = function(self, card, context)
        if context.cardarea == G.jokers and context.joker_main or context.forcetrigger then
            if to_big(card.ability.extra.played) < to_big(card.ability.extra.req - 1) then
                if not context.blueprint then
                    card.ability.extra.played = (card.ability.extra.played) + 1
                end
            elseif to_big(card.ability.extra.played) >= to_big(card.ability.extra.req - 1) then
                card.ability.extra.played = (card.ability.extra.played) + 1
                for i = 1, math.min(1, G.consumeables.config.card_limit - #G.consumeables.cards) do
                    G.E_MANAGER:add_event(Event({
                        trigger = 'after',
                        delay = 0.4,
                        func = function()
                            play_sound('timpani')
                            SMODS.add_card({ set = 'Tarot', })                            
                            card:juice_up(0.3, 0.5)
                            return true
                        end
                    }))
                end
                card_eval_status_text(context.blueprint_card or card, 'extra', nil, nil, nil, {message = localize('k_plus_tarot'), colour = G.C.PURPLE})
                delay(0.6)
            end
        end
        if context.after and context.cardarea == G.jokers  and not context.blueprint then
            if to_big(card.ability.extra.played) >= to_big(card.ability.extra.req) then
                return {
                    func = function()
                        card.ability.extra.played = 0
                        return true
                    end
                }
            end
        end
    end
}

SMODS.Joker{ --enderman
    key = "enderman",
    config = {
        extra = {
            xmult = 1,
            xmult_mod = 0.15
        }
    },
    loc_txt = {
        ['name'] = 'Enderman',
        ['text'] = {
            [1] = 'Convert each remaining discards',
            [2] = 'into {X:red,C:white}X#2#{} Mult on first hand of the round',
            [3] = '{C:inactive}(Currently {}{X:red,C:white}X#1#{}{C:inactive} Mult){}'
        },
        ['unlock'] = {
            [1] = 'Unlocked by default.'
        }
    },
    pos = {
        x = 8,
        y = 10
    },
    display_size = {
        w = 71 * 1, 
        h = 95 * 1
    },
    cost = 6,
    rarity = 2,
    blueprint_compat = true,
    demicoloncompat = true,
    eternal_compat = true,
    perishable_compat = false,
    unlocked = true,
    discovered = true,
    atlas = 'CustomJokers',
    
    loc_vars = function(self, info_queue, card)
        
        return {vars = {card.ability.extra.xmult, card.ability.extra.xmult_mod}}
    end,
    
    calculate = function(self, card, context)
        if context.before and context.cardarea == G.jokers  and not context.blueprint then
            if G.GAME.current_round.hands_played == 0 then
                return {
                    func = function()
                        card.ability.extra.xmult = card.ability.extra.xmult + (G.GAME.current_round.discards_left or 0) * card.ability.extra.xmult_mod
                        return true
                    end,
                    extra = {
                        
                        func = function()
                            card_eval_status_text(context.blueprint_card or card, 'extra', nil, nil, nil, {message = tostring(card.ability.extra.xmult), colour = G.C.BLUE})
                            G.GAME.current_round.discards_left = 0
                            return true
                        end,
                        colour = G.C.GREEN
                    }
                }
            end
        end
        if context.cardarea == G.jokers and context.joker_main or context.forcetrigger then
            return {
                Xmult = card.ability.extra.xmult
            }
        end
    end
}

SMODS.Joker{ --guardian
    key = "guardian",
    config = {
        extra = {
            xmult = 1.8
        }
    },
    loc_txt = {
        ['name'] = 'Guardian',
        ['text'] = {
            [1] = 'Each played {C:attention}3, 6, 9{}',
            [2] = 'gives {X:red,C:white}X#1#{} Mult when scored'
        },
        ['unlock'] = {
            [1] = ''
        }
    },
    pos = {
        x = 0,
        y = 11
    },
    display_size = {
        w = 71 * 1, 
        h = 95 * 1
    },
    cost = 6,
    rarity = 2,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    unlocked = true,
    discovered = true,
    atlas = 'CustomJokers',

    loc_vars = function(self, info_queue, card)
        
        return {vars = {card.ability.extra.xmult}}
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            if (context.other_card:get_id() == 3 or context.other_card:get_id() == 6 or context.other_card:get_id() == 9) then
                return {
                    Xmult = card.ability.extra.xmult
                }
            end
        end
        if context.forcetrigger then
            return {
                Xmult = card.ability.extra.xmult
            }
        end
    end
}
SMODS.Joker{ --elderguardian
    key = "elderguardian",
    config = {
        extra = {
            money = 8
        }
    },
    loc_txt = {
        ['name'] = 'Elder Guardian',
        ['text'] = {
            [1] = 'Each played {C:attention}3, 6, 9{}',
            [2] = 'gives {C:money}+$#1#{} when scored'
        },
        ['unlock'] = {
            [1] = 'Unlocked by default.'
        }
    },
    pos = {
        x = 1,
        y = 11
    },
    display_size = {
        w = 71 * 1, 
        h = 95 * 1
    },
    cost = 7,
    rarity = 3,
    blueprint_compat = true,
    demicoloncompat = true,
    eternal_compat = true,
    perishable_compat = true,
    unlocked = true,
    discovered = true,
    atlas = 'CustomJokers',
    
    loc_vars = function(self, info_queue, card)
        
        return {vars = {card.ability.extra.money}}
    end,
    
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play  then
            if (context.other_card:get_id() == 3) or (context.other_card:get_id() == 6) or (context.other_card:get_id() == 9) then
                return {
                    
                    func = function()
                        
                        local current_dollars = G.GAME.dollars
                        local target_dollars = G.GAME.dollars + card.ability.extra.money
                        local dollar_value = target_dollars - current_dollars
                        ease_dollars(dollar_value)
                        card_eval_status_text(context.other_card or card, 'extra', nil, nil, nil, {message = "$"..tostring(card.ability.extra.money), colour = G.C.MONEY})
                        return true
                    end
                }
            end
        end
        if context.forcetrigger then
            return {
                dollars = card.ability.extra.money
            }
        end
    end
}
SMODS.Joker{ --Piglin
    key = "piglin",
    config = {
        extra = {
            tarot = 0
        }
    },
    loc_txt = {
        ['name'] = 'Piglin',
        ['text'] = {
            [1] = 'Grant a {C:dark_edition}Negative{} {C:tarot}Tarot{} if played hand',
            [2] = 'contains a scoring {C:attention}Gold Card{}'
        },
        ['unlock'] = {
            [1] = 'Unlocked by default.'
        }
    },
    pos = {
        x = 0,
        y = 7
    },
    display_size = {
        w = 71 * 1, 
        h = 95 * 1
    },
    cost = 3,
    rarity = 1,
    blueprint_compat = true,
    demicoloncompat = true,
    eternal_compat = true,
    perishable_compat = true,
    enhancement_gate = 'm_gold',
    unlocked = true,
    discovered = true,
    atlas = 'CustomJokers',
    
    loc_vars = function(self, info_queue, card)
        
        return {vars = {card.ability.extra.tarot}}
    end,
    
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play  and not context.blueprint then
            if (SMODS.get_enhancements(context.other_card)["m_gold"] == true and to_big((card.ability.extra.tarot or 0)) < to_big(1)) then
                card.ability.extra.tarot = 1
            end
        end
        if context.cardarea == G.jokers and context.joker_main  then
            if to_big(card.ability.extra.tarot) > to_big(0) then
                for i = 1, math.min(1, G.consumeables.config.card_limit - #G.consumeables.cards) do
                    G.E_MANAGER:add_event(Event({
                        trigger = 'after',
                        delay = 0.4,
                        func = function()
                            play_sound('timpani')
                            SMODS.add_card({ set = 'Tarot', edition = 'e_negative'})                            
                            card:juice_up(0.3, 0.5)
                            return true
                        end
                    }))
                end
                delay(0.6)
                return {
                    message = created_consumable and localize('k_plus_tarot') or nil
                }
            end
        end
        if context.after and context.cardarea == G.jokers  and not context.blueprint then
            return {
                func = function()
                    card.ability.extra.tarot = 0
                    return true
                end
            }
        end
        if context.forcetrigger then
            for i = 1, math.min(1, G.consumeables.config.card_limit - #G.consumeables.cards) do
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.4,
                    func = function()
                        play_sound('timpani')
                        SMODS.add_card({ set = 'Tarot', edition = 'e_negative'})                            
                        card:juice_up(0.3, 0.5)
                        return true
                    end
                }))
            end
        end
    end
}
SMODS.Joker{ --zombiepigman
    key = "zombiepigman",
    config = {
        extra = {
        }
    },
    loc_txt = {
        ['name'] = 'Zombified Piglin',
        ['text'] = {
            [1] = 'When this card is sold,',
            [2] = 'create a {C:dark_edition}Negative{} {C:attention}Devil{} and a {C:dark_edition}Negative{} {C:attention}Empress{}'
        },
        ['unlock'] = {
            [1] = 'Unlocked by default.'
        }
    },
    pos = {
        x = 2,
        y = 11
    },
    display_size = {
        w = 71 * 1, 
        h = 95 * 1
    },
    cost = 6,
    rarity = 1,
    blueprint_compat = true,
    demicoloncompat = true,
    eternal_compat = false,
    perishable_compat = true,
    unlocked = true,
    discovered = true,
    atlas = 'CustomJokers',
    
    calculate = function(self, card, context)
        if context.selling_self  and not context.blueprint or context.forcetrigger then
            return {
                func = function()
                    
                    for i = 1, math.min(1, G.consumeables.config.card_limit - #G.consumeables.cards) do
                        G.E_MANAGER:add_event(Event({
                            trigger = 'after',
                            delay = 0.4,
                            func = function()
                                play_sound('timpani')
                                SMODS.add_card({ set = 'Tarot', key = 'c_devil', edition = 'e_negative'})                            
                                card:juice_up(0.3, 0.5)
                                return true
                            end
                        }))
                    end
                    delay(0.6)
                    return true
                end,
                extra = {
                    func = function()
                        
                        for i = 1, math.min(1, G.consumeables.config.card_limit - #G.consumeables.cards) do
                            G.E_MANAGER:add_event(Event({
                                trigger = 'after',
                                delay = 0.4,
                                func = function()
                                    play_sound('timpani')
                                    SMODS.add_card({ set = 'Tarot', key = 'c_empress', edition = 'e_negative'})                            
                                    card:juice_up(0.3, 0.5)
                                    return true
                                end
                            }))
                        end
                        delay(0.6)
                        return true
                    end,
                    colour = G.C.PURPLE
                }
            }
        end
    end
}
SMODS.Joker{ --hoglin
    key = "hoglin",
    config = {
        extra = {
        }
    },
    loc_txt = {
        ['name'] = 'Hoglin',
        ['text'] = {
            [1] = 'If played hand is {C:attention}exactly 1{} card,',
            [2] = 'increase rank of this card by {C:attention}2{}',
            [3] = 'each time it is scored'
        },
        ['unlock'] = {
            [1] = 'Unlocked by default.'
        }
    },
    pos = {
        x = 3,
        y = 11
    },
    display_size = {
        w = 71 * 1, 
        h = 95 * 1
    },
    cost = 3,
    rarity = 1,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    unlocked = true,
    discovered = true,
    atlas = 'CustomJokers',
    
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play  then
            if to_big(#context.full_hand) == to_big(1) then
                for i = 1, 1 do
                    G.E_MANAGER:add_event(Event({
                        trigger = 'after',
                        delay = 0.4,
                        func = function()
                            if G.consumeables.config.card_limit > #G.consumeables.cards + G.GAME.consumeable_buffer then
                                G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
                            end
                            
                            play_sound('timpani')
                            SMODS.add_card({ set = 'Tarot', edition = 'e_negative', key = 'c_strength'})                            
                            card:juice_up(0.3, 0.5)
                            return true
                        end
                    }))
                end
                delay(0.6)
                return {
                    message = created_consumable and localize('k_plus_tarot') or nil
                }
            end
        end
    end
}
SMODS.Joker{ --Piglin Brute
    key = "piglinbrute",
    config = {
        extra = {
            mult = 1,
            scale = 50
        }
    },
    loc_txt = {
        ['name'] = 'Piglin Brute',
        ['text'] = {
            [1] = 'This Joker gains {X:red,C:white}X#2#{} Mult',
            [2] = 'if played hand contains',
            [3] = 'a {C:attention}Straight Flush{}',
            [4] = '{C:inactive}(Currently {}{X:red,C:white}X#1#{}{C:inactive} Mult){}'
        },
        ['unlock'] = {
            [1] = 'Unlocked by default.'
        }
    },
    pos = {
        x = 1,
        y = 7
    },
    display_size = {
        w = 71 * 1, 
        h = 95 * 1
    },
    cost = 6,
    rarity = 2,
    blueprint_compat = true,
    demicoloncompat = true,
    eternal_compat = true,
    perishable_compat = false,
    unlocked = true,
    discovered = true,
    atlas = 'CustomJokers',
    
    loc_vars = function(self, info_queue, card)
        
        return {vars = {card.ability.extra.mult, card.ability.extra.scale}}
    end,
    
    calculate = function(self, card, context)
        if context.before and context.cardarea == G.jokers  and not context.blueprint then
            if next(context.poker_hands["Straight Flush"]) then
                return {
                    func = function()
                        card.ability.extra.mult = (card.ability.extra.mult) + card.ability.extra.scale
                        return true
                    end,
                    message = localize('k_upgrade_ex')
                }
            end
        end
        if context.cardarea == G.jokers and context.joker_main then
            return {
                Xmult = card.ability.extra.mult
            }
        end
        if context.forcetrigger then
            return {
                func = function()
                    card.ability.extra.mult = (card.ability.extra.mult) + card.ability.extra.scale
                    Xmult = card.ability.extra.mult
                    return true
                end
            }
        end
    end
}
SMODS.Joker{ --witherskeleton
    key = "witherskeleton",
    config = {
        extra = {
        }
    },
    loc_txt = {
        ['name'] = 'Wither Skeleton',
        ['text'] = {
            [1] = 'All cards count as {C:spades}Spades{},',
            [2] = 'Convert each played and',
            [3] = 'scoring cards into {C:spades}Spades{}'
        },
        ['unlock'] = {
            [1] = 'Unlocked by default.'
        }
    },
    pos = {
        x = 4,
        y = 11
    },
    display_size = {
        w = 71 * 1, 
        h = 95 * 1
    },
    cost = 5,
    rarity = 2,
    blueprint_compat = false,
    eternal_compat = true,
    perishable_compat = true,
    unlocked = true,
    discovered = true,
    atlas = 'CustomJokers',
    
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play  and not context.blueprint then
                local scored_card = context.other_card
                G.E_MANAGER:add_event(Event({
                    func = function()
                        assert(SMODS.change_base(scored_card, "Spades", nil))
                        return true
                    end
                }))
        end
    end
}
local card_is_suit_ref = Card.is_suit
function Card:is_suit(suit, bypass_debuff, flush_calc)
    local ret = card_is_suit_ref(self, suit, bypass_debuff, flush_calc)
    if not ret and not SMODS.has_no_suit(self) then
        if next(SMODS.find_card("j_ssr_witherskeleton")) then
            -- If checking for Spades and card is non-Spades, return true
            if suit == "Spades" and (self.base.suit == "Hearts" or self.base.suit == "Clubs" or self.base.suit == "Diamonds") then
                ret = true
            end
        end
    end
    return ret
end

SMODS.Joker{ --blaze
    key = "blaze",
    config = {
    },
    loc_txt = {
        ['name'] = 'Blaze',
        ['text'] = {
            [1] = 'if played hand contains a {C:attention}Three of a Kind{},',
            [2] = 'create an {C:attention}Immolate{}' -- oops! all 3oak synergies
        },
        ['unlock'] = {
            [1] = 'Unlocked by default.'
        }
    },
    pos = {
        x = 5, 
        y = 11
    },
    display_size = {
        w = 71 * 1, 
        h = 95 * 1
    },
    cost = 6,
    rarity = 2,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    unlocked = true,
    discovered = true,
    atlas = 'CustomJokers',
    
    calculate = function(self, card, context)
        if context.cardarea == G.jokers and context.joker_main  then
            if next(context.poker_hands["Three of a Kind"]) then
                    for i = 1, math.min(1, G.consumeables.config.card_limit - #G.consumeables.cards) do
                        G.E_MANAGER:add_event(Event({
                            trigger = 'after',
                            delay = 0.4,
                            func = function()
                                play_sound('timpani')
                                SMODS.add_card({ set = 'Spectral', key = 'c_immolate'})                            
                                card:juice_up(0.3, 0.5)
                                return true
                            end
                        }))
                    end
                    card_eval_status_text(context.blueprint_card or card, 'extra', nil, nil, nil, {message = created_consumable and localize('k_plus_spectral') or nil, colour = G.C.SECONDARY_SET.Spectral})
                end
            end
    end
}
SMODS.Joker{ --shulker
    key = "shulker",
    config = {
        extra = {
        }
    },
    loc_txt = {
        ['name'] = 'Shulker',
        ['text'] = {
            [1] = 'At the end of shop,',
            [2] = 'turns all held consumables',
            [3] = 'into {C:dark_edition}Negative{} Edition'
        },
        ['unlock'] = {
            [1] = 'Unlocked by default.'
        }
    },
    pos = {
        x = 6,
        y = 11
    },
    display_size = {
        w = 71 * 1, 
        h = 95 * 1
    },
    cost = 6,
    rarity = 3,
    blueprint_compat = false,
    eternal_compat = true,
    perishable_compat = true,
    unlocked = true,
    discovered = true,
    atlas = 'CustomJokers',
    
    calculate = function(self, card, context)
        if context.ending_shop  and not context.blueprint then
			for i, v in pairs(G.consumeables.cards) do
				if not v.edition or not v.edition.negative then
                G.E_MANAGER:add_event(Event({
                    func = function()
                        local card = v
                        card:set_edition("e_negative", true)
                        card:add_to_deck()
                        return true
                    end
                }))
				end
			end
			for i, v in pairs(G.jokers) do
				if not v.edition or not v.edition.negative then
                G.E_MANAGER:add_event(Event({
                    func = function()
                        local card = v
                        card:set_edition("e_negative", true)
                        card:add_to_deck()
                        return true
                    end
                }))
				end
			end
        end
    end
}

-- misc

SMODS.Joker{ --Cobblestone Generator
    key = "cobble",
    config = {
        extra = {
            chipsmod = 8,
            chips = 0
        }
    },
    loc_txt = {
        ['name'] = 'Cobblestone Generator',
        ['text'] = {
            [1] = 'This Joker gains {C:blue}+#1#{} Chips',
            [2] = 'if played hand contains both scoring',
            [3] = '{C:diamonds}light suited{} and {C:clubs}dark suited{} cards',
            [4] = '{C:inactive}(Currently {}{C:blue}+#2#{}{C:inactive} Chips){}'
        },
        ['unlock'] = {
            [1] = 'Unlocked by default.'
        }
    },
    pos = {
        x = 0,
        y = 10
    },
    display_size = {
        w = 71 * 1, 
        h = 95 * 1
    },
    cost = 2,
    rarity = 1,
    blueprint_compat = true,
    demicoloncompat = true,
    eternal_compat = true,
    perishable_compat = false,
    unlocked = true,
    discovered = true,
    atlas = 'CustomJokers',
    
    loc_vars = function(self, info_queue, card)
        
        return {vars = {card.ability.extra.chipsmod, card.ability.extra.chips}}
    end,
    
    calculate = function(self, card, context)
        if context.before and context.cardarea == G.jokers  and not context.blueprint then
            if ((function()
                local count = 0
                for _, playing_card in pairs(context.scoring_hand or {}) do
                    if playing_card:is_suit("Spades") or playing_card:is_suit("Clubs") then
                        count = count + 1
                    end
                end
                return count >= 1
            end)() and (function()
                local count = 0
                for _, playing_card in pairs(context.scoring_hand or {}) do
                    if playing_card:is_suit("Hearts") or playing_card:is_suit("Diamonds") then
                        count = count + 1
                    end
                end
                return count >= 1
            end)()) then
                return {
                    func = function()
                        card.ability.extra.chips = (card.ability.extra.chips) + card.ability.extra.chipsmod
                        return true
                    end,
                message = localize('k_upgrade_ex')
                }
            end
        end
        if context.cardarea == G.jokers and context.joker_main  then
            return {
                chips = card.ability.extra.chips
            }
        end
        if context.forcetrigger then
            card.ability.extra.chips = (card.ability.extra.chips) + card.ability.extra.chipsmod
            return {
                chips = card.ability.extra.chips
            }
        end
    end
}


SMODS.Joker{ --Low Tier 1
    key = "lowtier1",
    config = {
        extra = {
            repetitions0 = 3
        }
    },
    loc_txt = {
        ['name'] = 'Low Tier 1',
        ['text'] = {
            [1] = 'Retrigger each played {C:attention}Ace{} 3x'
        },
        ['unlock'] = {
            [1] = 'Unlocked by default.'
        }
    },
    pos = {
        x = 1,
        y = 13
    },
    display_size = {
        w = 71 * 1, 
        h = 95 * 1
    },
    cost = 6,
    rarity = 2,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    unlocked = true,
    discovered = true,
    atlas = 'CustomJokers',
    
    calculate = function(self, card, context)
        if context.repetition and context.cardarea == G.play  then
            if context.other_card:get_id() == 14 then
                return {
                    repetitions = 3,
                    message = localize('k_again_ex')
                }
            end
        end
    end
}

SMODS.Joker{ --High Tier 1
    key = "hightier1",
    config = {
        extra = {
            chips0 = 50,
            mult0 = 10,
            xmult0 = 1.5
        }
    },
    loc_txt = {
        ['name'] = 'High Tier 1',
        ['text'] = {
            [1] = 'Each played {C:attention}Ace{} counts as having',
            [2] = 'all non {C:dark_edition}Negative{} vanilla editions',
            [3] = 'and all vanilla seals'
        },
        ['unlock'] = {
            [1] = 'Unlocked by default.'
        }
    },
    pos = {
        x = 2,
        y = 13
    },
    display_size = {
        w = 71 * 1, 
        h = 95 * 1
    },
    cost = 8,
    rarity = 3,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    unlocked = true,
    discovered = true,
    atlas = 'CustomJokers',
    
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play  then
            if context.other_card:get_id() == 14 then
                return {
                    chips = 50,
                    extra = {
                        mult = 10,
                        extra = {
                            Xmult = 1.5,
                            extra = {
                                p_dollars = 3
                            }
                        }
                    }
                }
            end
        elseif context.discard and context.other_card:get_id() == 14 and #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit and not context.blueprint then
            G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
            G.E_MANAGER:add_event(Event({
                trigger = 'before',
                delay = 0.0,
                func = (function()
                    local card = create_card('Tarot',G.consumeables, nil, nil, nil, nil, nil, '8ba')
                    card:add_to_deck()
                    G.consumeables:emplace(card)
                    G.GAME.consumeable_buffer = 0
                    return true
                end)
            }))
            card_eval_status_text(context.other_card, 'extra', nil, nil, nil, {message = localize('k_plus_tarot'), colour = G.C.PURPLE})
        elseif context.end_of_round and context.cardarea == G.hand and context.other_card:get_id() == 14 and not context.other_card.debuff and not context.blueprint then
            for i = 0, 1 do
                if #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
                    G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
                    G.E_MANAGER:add_event(Event({
                        trigger = 'before',
                        delay = 0.0,
                        func = (function()
                            if G.GAME.last_hand_played then
                                local _planet = 0
                                for k, v in pairs(G.P_CENTER_POOLS.Planet) do
                                    if v.config.hand_type == G.GAME.last_hand_played then
                                        _planet = v.key
                                    end
                                end
                                local card = create_card('Planet',G.consumeables, nil, nil, nil, nil, _planet, 'blusl')
                                card:add_to_deck()
                                G.consumeables:emplace(card)
                                G.GAME.consumeable_buffer = 0
                            end
                            return true
                        end)
                    }))
                    card_eval_status_text(context.other_card, 'extra', nil, nil, nil, {message = localize('k_plus_planet'), colour = G.C.SECONDARY_SET.Planet})
                end
            end
        elseif context.repetition and context.other_card:get_id() == 14 and (context.cardarea == G.play or context.cardarea == G.hand) and not context.blueprint then
            return {
                message = localize('k_again_ex'),
                repetitions = 1
            }
        end  -- bloonlatro goated mod
    end
}

SMODS.Joker{ --Solo
    key = "solo",
    config = {
        extra = {
            xmult_mod = 0.1,
            xmult = 1
        }
    },
    loc_txt = {
        ['name'] = '1v1',
        ['text'] = {
            [1] = 'This Joker gains {X:red,C:white}X#1#{} Mult',
            [2] = 'if played hand is {C:attention}High Card{}',
            [3] = '{C:inactive}(Currently {}{X:red,C:white}X#2#{}{C:inactive} Mult){}'
        },
        ['unlock'] = {
            [1] = 'Unlocked by default.'
        }
    },
    pos = {
        x = 5,
        y = 12
    },
    display_size = {
        w = 71 * 1, 
        h = 95 * 1
    },
    cost = 4,
    rarity = 1,
    blueprint_compat = true,
    demicoloncomapt = true,
    eternal_compat = true,
    perishable_compat = false,
    unlocked = true,
    discovered = true,
    atlas = 'CustomJokers',
    
    loc_vars = function(self, info_queue, card)
        
        return {vars = {card.ability.extra.xmult_mod, card.ability.extra.xmult}}
    end,
    
    calculate = function(self, card, context)
        if context.before and context.cardarea == G.jokers  and not context.blueprint then
            if context.scoring_name == "High Card" then
                return {
                    func = function()
                        card.ability.extra.xmult = (card.ability.extra.xmult) + card.ability.extra.xmult_mod
                        return true
                    end,
                    message = localize('k_upgrade_ex')
                }
            end
        end
        if context.cardarea == G.jokers and context.joker_main  then
            return {
                Xmult = card.ability.extra.xmult
            }
        end
        if context.forcetrigger then
            card.ability.extra.xmult = (card.ability.extra.xmult) + card.ability.extra.xmult_mod
            return {
                Xmult = card.ability.extra.xmult
            }
        end
    end
}


SMODS.Joker{ --Party
    key = "party",
    config = {
        extra = {
            chips = 0,
            jokercount = 0
        }
    },
    loc_txt = {
        ['name'] = 'Party',
        ['text'] = {
            [1] = 'If the total amount of played and scoring cards',
            [2] = '{C:attention}exceeds{} that of owned Jokers,',
            [3] = 'This Joker gains {C:blue}5x{} the amount of',
            [4] = 'owned Jokers to {C:blue}Chips{}',
            [5] = '{C:inactive}(Currently {}{C:blue}+#1#{}{C:inactive} Chips){}'
        },
        ['unlock'] = {
            [1] = 'Unlocked by default.'
        }
    },
    pos = {
        x = 6,
        y = 12
    },
    display_size = {
        w = 71 * 1, 
        h = 95 * 1
    },
    cost = 4,
    rarity = 1,
    blueprint_compat = true,
    demicoloncompat = true,
    eternal_compat = true,
    perishable_compat = false,
    unlocked = true,
    discovered = true,
    atlas = 'CustomJokers',
    
    loc_vars = function(self, info_queue, card)
        
        return {vars = {card.ability.extra.chips, #(G.jokers and (G.jokers and G.jokers.cards or {}) or {})}}
    end,
    
    calculate = function(self, card, context)
        if context.before and context.cardarea == G.jokers  and not context.blueprint then
            if to_big(#context.scoring_hand) > to_big(#(G.jokers and G.jokers.cards or {})) then
                return {
                    func = function()
                        card.ability.extra.chips = (card.ability.extra.chips) + (#(G.jokers and G.jokers.cards or {})) * 5
                        return true
                    end,
                    message = localize('k_upgrade_ex')
                }
            end
        end
        if context.cardarea == G.jokers and context.joker_main  then
            return {
                chips = card.ability.extra.chips
            }
        end
        if context.forcetrigger then
            card.ability.extra.chips = (card.ability.extra.chips) + (#(G.jokers and G.jokers.cards or {})) * 5
            return {
                chips = card.ability.extra.chips
            }
        end
    end
}