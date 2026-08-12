SMODS.Consumable {
    key = 'sholstar',
    set = 'Planet',
    pos = { x = 1, y = 0 },
    config = { extra = {
        levels = 1
    } },
    loc_txt = {
        name = 'S O L',
        text = {
        [1] = 'Upgrade {C:attention}all Poker Hands{} by {C:attention}3{} levels', -- WOW!
    }
    },
    cost = 3,
    unlocked = true,
    discovered = true,
    hidden = false,
    can_repeat_soul = false,
    atlas = 'CustomConsumables',
	use = function(self, card, area, copier)
		local used_consumable = copier or card
			update_hand_text(
				{ sound = "button", volume = 0.7, pitch = 0.8, delay = 0.3 },
				{ handname = localize("k_all_hands"), chips = "...", mult = "...", level = "" }
			)
			G.E_MANAGER:add_event(Event({
				trigger = "after",
				delay = 0.2,
				func = function()
					play_sound("tarot1")
					used_consumable:juice_up(0.8, 0.5)
					G.TAROT_INTERRUPT_PULSE = true
					return true
				end,
			}))
			update_hand_text({ delay = 0 }, { mult = "+", StatusText = true })
			G.E_MANAGER:add_event(Event({
				trigger = "after",
				delay = 0.9,
				func = function()
					play_sound("tarot1")
					used_consumable:juice_up(0.8, 0.5)
					return true
				end,
			}))
			update_hand_text({ delay = 0 }, { chips = "+", StatusText = true })
			G.E_MANAGER:add_event(Event({
				trigger = "after",
				delay = 0.9,
				func = function()
					play_sound("tarot1")
					used_consumable:juice_up(0.8, 0.5)
					G.TAROT_INTERRUPT_PULSE = nil
					return true
				end,
			}))
			update_hand_text({ sound = "button", volume = 0.7, pitch = 0.9, delay = 0 }, { level = "+3" })
			delay(1.3)
			for k, v in pairs(G.GAME.hands) do
				level_up_hand(used_consumable, k, true, 3)
			end
			update_hand_text(
				{ sound = "button", volume = 0.7, pitch = 1.1, delay = 0 },
				{ mult = 0, chips = 0, handname = "", level = "" }
			)
        end,
    can_use = function(self, card)
        return true
    end
}
