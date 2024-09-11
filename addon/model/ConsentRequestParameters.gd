#
# © 2024-present https://github.com/cengiz-pz
#

class_name ConsentRequestParameters extends RefCounted

enum DebugGeography {
	DEBUG_GEOGRAPHY_DISABLED = 0,
	DEBUG_GEOGRAPHY_EEA = 1,
	DEBUG_GEOGRAPHY_NOT_EEA = 2
}

const IS_REAL_PROPERTY: String = "is_real"
const TAG_FOR_UNDER_AGE_OF_CONSENT_PROPERTY: String = "tag_for_under_age_of_consent"
const DEBUG_GEOGRAPHY_PROPERTY: String = "debug_geography"

var _data: Dictionary
var _device_ids: Array


func _init():
	_data = {}
	_device_ids = []


func set_is_real(a_value: bool) -> ConsentRequestParameters:
	_data[IS_REAL_PROPERTY] = a_value

	return self


func set_tag_for_under_age_of_consent(a_value: bool) -> ConsentRequestParameters:
	_data[TAG_FOR_UNDER_AGE_OF_CONSENT_PROPERTY] = a_value

	return self


func set_debug_geography(a_value: DebugGeography) -> ConsentRequestParameters:
	_data[DEBUG_GEOGRAPHY_PROPERTY] = a_value

	return self


func add_test_device_hashed_id(a_value: String) -> ConsentRequestParameters:
	_device_ids.append(a_value)

	return self


func get_raw_data() -> Dictionary:
	return _data


func get_device_ids() -> Array:
	return _device_ids
