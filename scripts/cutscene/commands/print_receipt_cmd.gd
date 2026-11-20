class_name PrintReceiptCommand
extends CutsceneCommand

const MAX_LINE_WIDTH := 30

func execute(ctx: CutsceneContext) -> void:
	# build lines printed on the receipt based on player stats
	var lines: Array[String] = [
		_center("BIZARRE BAZAAR"),
		_center("NIGHT %d SHIFT REPORT" %ctx.shift),
		_center("10:00 PM - 6:00 AM"),
		_divider(),
		_row("Balance", "$%d"%ctx.stats["balance"]),
		_row("Thieves caught", str(ctx.stats["thieves_caught"])),
		_row("Robbers defeated", str(ctx.stats["robbers_defeated"])),
		_row("Boss trust", str(ctx.stats["boss_trust"])+"%"),
		_divider(),
		_center("THANKS, SEE YA!"),
	]
	
	ctx.clock.print_receipt(lines)
	await ctx.clock.receipt_printed
	
func skip(ctx: CutsceneContext) -> void:
	ctx.clock.hide_receipt()

#helpers for printing end of shift report, organized as a receipt
# text: value (e.g. Boss trust: 70%)
func _row(text:String, val:String) -> String:
	return text.rpad(MAX_LINE_WIDTH - val.length()) + val
	
# centered title via adding 1/2 the gap to the left, e.g. Bizzare bazzar
func _center(text:String) -> String:
	var left := (MAX_LINE_WIDTH - text.length()) / 2
	return " ".repeat(left) + text
	
# dashed vidivider
func _divider() -> String:
	return "-".repeat(MAX_LINE_WIDTH)
