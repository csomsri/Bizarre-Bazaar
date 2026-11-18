# TODO:
	# print receit with the status report at the end of the shift

class_name PrintReceiptCommand
extends CutsceneCommand

func execute(ctx: CutsceneContext) -> void:
	# build lines printed on the receipt based on player stats
	var lines:Array[String]
	lines.append("BIZARRE BAZAAR")
	lines.append("NIGHT %d - SHIFT REPORT"  % ctx.shift)
	lines.append("Balance: $%d" % ctx.stats["balance"])
	lines.append("Thieves caught: %d" % ctx.stats["thieves_caught"])
	lines.append("Robbers defeated: %d" % ctx.stats["robbers_defeated"])
	lines.append("Boss trust: %d" %ctx.stats["boss_trust"])
	
	ctx.clock.print_receipt(lines)
	await ctx.clock.receipt_printed
	
func skip(ctx: CutsceneContext) -> void:
	ctx.clock.hide_receipt()
