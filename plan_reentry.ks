parameter desired_pe is 40000.

run once "logging".
run once "util".

log_message("=== plan_reentry ===").

run "remove_all_nodes".

local orbitpatch is ship:orbit.
local time_to_patch is 0.
until orbitpatch:body:name="kerbin" {
    if (orbitpatch:hasnextpatch) {
        set time_to_patch to orbitpatch:nextpatcheta.
        set orbitpatch to orbitpatch:nextpatch.
    } else {
        log_error("KERBIN NOT FOUND ON FLIGHT PATH!").
        break.
    }
}

local time_past_epoch is time:seconds + time_to_patch - orbitpatch:epoch.
local additional_periods is time_past_epoch / orbitpatch:period.
local additional_mean_anomaly is 360 * (additional_periods - floor(additional_periods)).
local mean_anomaly_at_transition is mod(orbitpatch:meananomalyatepoch + additional_mean_anomaly, 360).

local mean_anomaly_to_next_apoapsis is mod(540 - mean_anomaly_at_transition, 360).
local additional_time_to_next_apoapsis is mean_anomaly_to_next_apoapsis / 360 * orbitpatch:period.

local total_time_to_node is time_to_patch + additional_time_to_next_apoapsis.

log_debug("time to patch: " + format_time(time_to_patch)).
log_debug("time past epoch: " + format_time(time_past_epoch)).
log_debug("additional periods: " + additional_periods).
log_debug("additional mean anomaly: " + additional_mean_anomaly).
log_debug("mean anomaly at transition: " + mean_anomaly_at_transition).
log_debug("mean anomaly to next ap: " + mean_anomaly_to_next_apoapsis).
log_debug("additional time to next ap: " + format_time(additional_time_to_next_apoapsis)).
log_debug("total time to node: " + format_time(total_time_to_node)).

// TODO: if your transition to this orbit patch is close enough to apoapsis,
// just do the burn immediately instead of waiting to AP.

// TODO: if the kerbin patch doesn't have an apoapsis, plan a radial-in burn to reduce PE

local speed_at_ap is get_orbital_speed_at_altitude(orbitpatch:apoapsis, orbitpatch:semimajoraxis, orbitpatch:body).
local desired_sma is (orbitpatch:apoapsis + 2 * orbitpatch:body:radius + desired_pe)/2.
local desired_speed_at_ap is get_orbital_speed_at_altitude(orbitpatch:apoapsis, desired_sma, orbitpatch:body).
log_debug("speed at ap: " + speed_at_ap).
log_debug("desired speed: " + desired_speed_at_ap).
add node(time:seconds + total_time_to_node, 0, 0, desired_speed_at_ap - speed_at_ap).
