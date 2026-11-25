class_name FollowRouteCommand
extends Resource


func get_waypoint(route: AisleRoute, index: int) -> Marker3D:
	if index < 0 or index >= route.waypoints.size():
		return null
	return route.waypoints[index]


func should_browse(route: AisleRoute, index: int) -> bool:
	return route.is_browsing_leg(index)


func get_browse_trigger_distance(from: Vector3, to: Vector3) -> float:
	var offset := to - from
	offset.y = 0.0
	return offset.length() * randf_range(0.30, 0.70)
