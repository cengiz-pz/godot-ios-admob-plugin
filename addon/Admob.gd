#
# © 2024-present https://github.com/cengiz-pz
#

@tool
class_name Admob
extends Node

signal initialization_completed(status_data: InitializationStatus)
signal banner_ad_loaded(ad_id: String)
signal banner_ad_failed_to_load(ad_id: String, error_data: LoadAdError)
signal banner_ad_refreshed(ad_id: String)
signal banner_ad_clicked(ad_id: String)
signal banner_ad_impression(ad_id: String)
signal banner_ad_opened(ad_id: String)
signal banner_ad_closed(ad_id: String)
signal interstitial_ad_loaded(ad_id: String)
signal interstitial_ad_failed_to_load(ad_id: String, error_data: LoadAdError)
signal interstitial_ad_refreshed(ad_id: String)
signal interstitial_ad_impression(ad_id: String)
signal interstitial_ad_clicked(ad_id: String)
signal interstitial_ad_showed_full_screen_content(ad_id: String)
signal interstitial_ad_failed_to_show_full_screen_content(ad_id: String, error_data: AdError)
signal interstitial_ad_dismissed_full_screen_content(ad_id: String)
signal rewarded_ad_loaded(ad_id: String)
signal rewarded_ad_failed_to_load(ad_id: String, error_data: LoadAdError)
signal rewarded_ad_impression(ad_id: String)
signal rewarded_ad_clicked(ad_id: String)
signal rewarded_ad_showed_full_screen_content(ad_id: String)
signal rewarded_ad_failed_to_show_full_screen_content(ad_id: String, error_data: AdError)
signal rewarded_ad_dismissed_full_screen_content(ad_id: String)
signal rewarded_ad_user_earned_reward(ad_id: String, reward_data: RewardItem)
signal rewarded_interstitial_ad_loaded(ad_id: String)
signal rewarded_interstitial_ad_failed_to_load(ad_id: String, error_data: LoadAdError)
signal rewarded_interstitial_ad_impression(ad_id: String)
signal rewarded_interstitial_ad_clicked(ad_id: String)
signal rewarded_interstitial_ad_showed_full_screen_content(ad_id: String)
signal rewarded_interstitial_ad_failed_to_show_full_screen_content(ad_id: String, error_data: AdError)
signal rewarded_interstitial_ad_dismissed_full_screen_content(ad_id: String)
signal rewarded_interstitial_ad_user_earned_reward(ad_id: String, reward_data: RewardItem)
signal consent_form_loaded
signal consent_form_dismissed(error_data: FormError)
signal consent_form_failed_to_load(error_data: FormError)
signal consent_info_updated
signal consent_info_update_failed(error_data: FormError)

const PLUGIN_SINGLETON_NAME: String = "AdmobPlugin"

@export_category("General")
@export var is_real: bool: set = set_is_real
@export var max_ad_content_rating: AdmobConfig.ContentRating = AdmobConfig.ContentRating.G: set = set_max_ad_content_rating
@export var child_directed: AdmobConfig.TagForChildDirectedTreatment = AdmobConfig.TagForChildDirectedTreatment.UNSPECIFIED: set = set_child_directed
@export var under_age_of_consent: AdmobConfig.TagForUnderAgeOfConsent = AdmobConfig.TagForUnderAgeOfConsent.UNSPECIFIED: set = set_under_age_of_consent
@export var first_party_id_enabled: bool = true: set = set_first_party_id_enabled
@export var personalization_state: AdmobConfig.PersonalizationState = AdmobConfig.PersonalizationState.DEFAULT: set = set_personalization_state
@export var request_agent: String = PLUGIN_SINGLETON_NAME: set = set_request_agent

@export_category("Banner")
@export var banner_position: LoadAdRequest.AdPosition = LoadAdRequest.AdPosition.TOP: set = set_banner_position
@export var banner_size: LoadAdRequest.AdSize = LoadAdRequest.AdSize.BANNER: set = set_banner_size

@export_category("Ad Unit IDs")
@export_group("Debug IDs", "debug_")
@export var debug_application_id: String
@export var debug_banner_id: String
@export var debug_interstitial_id: String
@export var debug_rewarded_id: String
@export var debug_rewarded_interstitial_id: String

@export_group("Real IDs", "real_")
@export var real_application_id: String
@export var real_banner_id: String
@export var real_interstitial_id: String
@export var real_rewarded_id: String
@export var real_rewarded_interstitial_id: String

@export_group("Cache")
@export_range(1,100) var max_banner_ad_cache: int = 1: set = set_max_banner_ad_cache
@export_range(1,100) var max_interstitial_ad_cache: int = 1: set = set_max_interstitial_ad_cache
@export_range(1,100) var max_rewarded_ad_cache: int = 1: set = set_max_rewarded_ad_cache
@export_range(1,100) var max_rewarded_interstitial_ad_cache: int = 1: set = set_max_rewarded_interstitial_ad_cache

@onready var _banner_id: String = real_banner_id if is_real else debug_banner_id
@onready var _interstitial_id: String = real_interstitial_id if is_real else debug_interstitial_id
@onready var _rewarded_id: String = real_rewarded_id if is_real else debug_rewarded_id
@onready var _rewarded_interstitial_id: String = real_rewarded_interstitial_id if is_real else debug_rewarded_interstitial_id

var _plugin_singleton: Object

var _active_banner_ads: Array
var _active_interstitial_ads: Array
var _active_rewarded_ads: Array
var _active_rewarded_interstitial_ads: Array


func _init() -> void:
	_active_banner_ads = []
	_active_interstitial_ads = []
	_active_rewarded_ads = []
	_active_rewarded_interstitial_ads = []


func _ready() -> void:
	_update_plugin()


func _notification(a_what: int) -> void:
	if a_what == NOTIFICATION_APPLICATION_RESUMED:
		_update_plugin()


func _update_plugin() -> void:
	if _plugin_singleton == null:
		if Engine.has_singleton(PLUGIN_SINGLETON_NAME):
			_plugin_singleton = Engine.get_singleton(PLUGIN_SINGLETON_NAME)
			_connect_signals()
		else:
			printerr("%s singleton not found!" % PLUGIN_SINGLETON_NAME)


func _connect_signals() -> void:
	_plugin_singleton.connect("initialization_completed", _on_initialization_completed)
	_plugin_singleton.connect("banner_ad_loaded", _on_banner_ad_loaded)
	_plugin_singleton.connect("banner_ad_failed_to_load", _on_banner_ad_failed_to_load)
	_plugin_singleton.connect("banner_ad_refreshed", _on_banner_ad_refreshed)
	_plugin_singleton.connect("banner_ad_clicked", _on_banner_ad_clicked)
	_plugin_singleton.connect("banner_ad_impression", _on_banner_ad_impression)
	_plugin_singleton.connect("banner_ad_opened", _on_banner_ad_opened)
	_plugin_singleton.connect("banner_ad_closed", _on_banner_ad_closed)
	_plugin_singleton.connect("interstitial_ad_loaded", _on_interstitial_ad_loaded)
	_plugin_singleton.connect("interstitial_ad_failed_to_load", _on_interstitial_ad_failed_to_load)
	_plugin_singleton.connect("interstitial_ad_refreshed", _on_interstitial_ad_refreshed)
	_plugin_singleton.connect("interstitial_ad_impression", _on_interstitial_ad_impression)
	_plugin_singleton.connect("interstitial_ad_clicked", _on_interstitial_ad_clicked)
	_plugin_singleton.connect("interstitial_ad_showed_full_screen_content", _on_interstitial_ad_showed_full_screen_content)
	_plugin_singleton.connect("interstitial_ad_failed_to_show_full_screen_content", _on_interstitial_ad_failed_to_show_full_screen_content)
	_plugin_singleton.connect("interstitial_ad_dismissed_full_screen_content", _on_interstitial_ad_dismissed_full_screen_content)
	_plugin_singleton.connect("rewarded_ad_loaded", _on_rewarded_ad_loaded)
	_plugin_singleton.connect("rewarded_ad_failed_to_load", _on_rewarded_ad_failed_to_load)
	_plugin_singleton.connect("rewarded_ad_impression", _on_rewarded_ad_impression)
	_plugin_singleton.connect("rewarded_ad_clicked", _on_rewarded_ad_clicked)
	_plugin_singleton.connect("rewarded_ad_showed_full_screen_content", _on_rewarded_ad_showed_full_screen_content)
	_plugin_singleton.connect("rewarded_ad_failed_to_show_full_screen_content", _on_rewarded_ad_failed_to_show_full_screen_content)
	_plugin_singleton.connect("rewarded_ad_dismissed_full_screen_content", _on_rewarded_ad_dismissed_full_screen_content)
	_plugin_singleton.connect("rewarded_ad_user_earned_reward", _on_rewarded_ad_user_earned_reward)
	_plugin_singleton.connect("rewarded_interstitial_ad_loaded", _on_rewarded_interstitial_ad_loaded)
	_plugin_singleton.connect("rewarded_interstitial_ad_failed_to_load", _on_rewarded_interstitial_ad_failed_to_load)
	_plugin_singleton.connect("rewarded_interstitial_ad_impression", _on_rewarded_interstitial_ad_impression)
	_plugin_singleton.connect("rewarded_interstitial_ad_clicked", _on_rewarded_interstitial_ad_clicked)
	_plugin_singleton.connect("rewarded_interstitial_ad_showed_full_screen_content", _on_rewarded_interstitial_ad_showed_full_screen_content)
	_plugin_singleton.connect("rewarded_interstitial_ad_failed_to_show_full_screen_content", _on_rewarded_interstitial_ad_failed_to_show_full_screen_content)
	_plugin_singleton.connect("rewarded_interstitial_ad_dismissed_full_screen_content", _on_rewarded_interstitial_ad_dismissed_full_screen_content)
	_plugin_singleton.connect("rewarded_interstitial_ad_user_earned_reward", _on_rewarded_interstitial_ad_user_earned_reward)
	_plugin_singleton.connect("consent_form_loaded", _on_consent_form_loaded)
	_plugin_singleton.connect("consent_form_dismissed", _on_consent_form_dismissed)
	_plugin_singleton.connect("consent_form_failed_to_load", _on_consent_form_failed_to_load)
	_plugin_singleton.connect("consent_info_updated", _on_consent_info_updated)
	_plugin_singleton.connect("consent_info_update_failed", _on_consent_info_update_failed)


func initialize() -> void:
	if _plugin_singleton == null:
		printerr("%s plugin not initialized" % PLUGIN_SINGLETON_NAME)
	else:
		_plugin_singleton.initialize()


func set_is_real(a_value: bool) -> void:
	is_real = a_value


func set_max_ad_content_rating(a_value: AdmobConfig.ContentRating) -> void:
	max_ad_content_rating = a_value


func set_child_directed(a_value: AdmobConfig.TagForChildDirectedTreatment) -> void:
	child_directed = a_value


func set_under_age_of_consent(a_value: AdmobConfig.TagForUnderAgeOfConsent) -> void:
	under_age_of_consent = a_value


func set_first_party_id_enabled(a_value: bool) -> void:
	first_party_id_enabled = a_value


func set_personalization_state(a_value: AdmobConfig.PersonalizationState) -> void:
	personalization_state = a_value


func set_request_agent(a_value: String) -> void:
	request_agent = a_value


func set_banner_position(a_value: LoadAdRequest.AdPosition) -> void:
	banner_position = a_value


func set_banner_size(a_value: LoadAdRequest.AdSize) -> void:
	banner_size = a_value


func set_max_banner_ad_cache(a_value: int) -> void:
	max_banner_ad_cache = a_value


func set_max_interstitial_ad_cache(a_value: int) -> void:
	max_interstitial_ad_cache = a_value


func set_max_rewarded_ad_cache(a_value: int) -> void:
	max_rewarded_ad_cache = a_value


func set_max_rewarded_interstitial_ad_cache(a_value: int) -> void:
	max_rewarded_interstitial_ad_cache = a_value


func configure_ads() -> void:
	if _plugin_singleton != null:
		_plugin_singleton.set_request_configuration(AdmobConfig.new()
					.set_is_real(is_real)
					.set_max_ad_content_rating(max_ad_content_rating)
					.set_child_directed_treatment(child_directed)
					.set_under_age_of_consent(under_age_of_consent)
					.set_first_party_id_enabled(first_party_id_enabled)
					.set_personalization_state(personalization_state)
					.get_raw_data())
	else:
		printerr("%s plugin not initialized" % PLUGIN_SINGLETON_NAME)


func load_banner_ad() -> void:
	if _plugin_singleton != null:
		_plugin_singleton.load_banner_ad(LoadAdRequest.new()
					.set_ad_unit_id(_banner_id)
					.set_ad_position(banner_position)
					.set_ad_size(banner_size)
					.set_request_agent(request_agent)
					.get_raw_data())
	else:
		printerr("%s plugin not initialized" % PLUGIN_SINGLETON_NAME)


func is_banner_ad_loaded() -> bool:
	if _plugin_singleton != null:
		return _active_banner_ads.is_empty() == false
	else:
		printerr("%s plugin not initialized" % PLUGIN_SINGLETON_NAME)

	return false


func show_banner_ad(a_ad_id: String = "") -> void:
	if _plugin_singleton == null:
		printerr("%s plugin not initialized" % PLUGIN_SINGLETON_NAME)
	else:
		if a_ad_id.is_empty():
			if _active_banner_ads.is_empty():
				printerr("Cannot show banner ad. No banner ads loaded.")
			else:
				_plugin_singleton.show_banner_ad(_active_banner_ads[0])	# show last ad to load
		else:
			if _active_banner_ads.has(a_ad_id):
				_plugin_singleton.show_banner_ad(a_ad_id)
			else:
				printerr("Cannot show banner. Ad with ID '%s' not found." % a_ad_id)


func hide_banner_ad(a_ad_id: String = "") -> void:
	if _plugin_singleton == null:
		printerr("%s plugin not initialized" % PLUGIN_SINGLETON_NAME)
	else:
		if a_ad_id.is_empty():
			if _active_banner_ads.is_empty():
				printerr("Cannot hide banner ad. No banner ads loaded.")
			else:
				_plugin_singleton.hide_banner_ad(_active_banner_ads[0])	# hide last ad to load
		else:
			if _active_banner_ads.has(a_ad_id):
				_plugin_singleton.hide_banner_ad(a_ad_id)
			else:
				printerr("Cannot hide banner. Ad with ID '%s' not found." % a_ad_id)


func remove_banner_ad(a_ad_id: String = "") -> void:
	if _plugin_singleton == null:
		printerr("%s plugin not initialized" % PLUGIN_SINGLETON_NAME)
	else:
		if a_ad_id.is_empty():
			if _active_banner_ads.is_empty():
				printerr("Cannot remove banner ad. No banner ads loaded.")
			else:
				_plugin_singleton.remove_banner_ad(_active_banner_ads[0])	# remove last ad to load
				_active_banner_ads.remove_at(0)
		else:
			if _active_banner_ads.has(a_ad_id):
				_active_banner_ads.erase(a_ad_id)
				_plugin_singleton.remove_banner_ad(a_ad_id)
			else:
				printerr("Cannot remove banner ad. Ad with ID '%s' not found." % a_ad_id)


func get_banner_dimension(a_ad_id: String = "") -> Vector2:
	if _plugin_singleton == null:
		printerr("%s plugin not initialized" % PLUGIN_SINGLETON_NAME)
	else:
		if a_ad_id.is_empty():
			if _active_banner_ads.is_empty():
				printerr("Cannot get banner ad dimensions. No banner ads loaded.")
			else:
				var last_loaded_banner_ad_id = _active_banner_ads[0]
				return Vector2(_plugin_singleton.get_banner_width(last_loaded_banner_ad_id),
							_plugin_singleton.get_banner_height(last_loaded_banner_ad_id))

	return Vector2.ZERO


func get_banner_dimension_in_pixels(a_ad_id: String = "") -> Vector2:
	if _plugin_singleton == null:
		printerr("%s plugin not initialized" % PLUGIN_SINGLETON_NAME)
	else:
		if a_ad_id.is_empty():
			if _active_banner_ads.is_empty():
				printerr("Cannot get banner ad dimensions. No banner ads loaded.")
			else:
				var last_loaded_banner_ad_id = _active_banner_ads[0]
				return Vector2(_plugin_singleton.get_banner_width_in_pixels(last_loaded_banner_ad_id),
							_plugin_singleton.get_banner_height_in_pixels(last_loaded_banner_ad_id))

	return Vector2.ZERO


func load_interstitial_ad() -> void:
	if _plugin_singleton != null:
		_plugin_singleton.load_interstitial_ad(LoadAdRequest.new()
					.set_ad_unit_id(_interstitial_id)
					.set_request_agent(request_agent)
					.get_raw_data())
	else:
		printerr("%s plugin not initialized" % PLUGIN_SINGLETON_NAME)


func is_interstitial_ad_loaded() -> bool:
	if _plugin_singleton != null:
		return _active_interstitial_ads.is_empty() == false
	else:
		printerr("%s plugin not initialized" % PLUGIN_SINGLETON_NAME)

	return false


func show_interstitial_ad(a_ad_id: String = "") -> void:
	if _plugin_singleton == null:
		printerr("%s plugin not initialized" % PLUGIN_SINGLETON_NAME)
	else:
		if a_ad_id.is_empty():
			if _active_interstitial_ads.is_empty():
				printerr("Cannot show interstitial ad. No interstitial ads loaded.")
			else:
				_plugin_singleton.show_interstitial_ad(_active_interstitial_ads[0])	# show last ad to load
		else:
			_plugin_singleton.show_interstitial_ad(a_ad_id)


func remove_interstitial_ad(a_ad_id: String) -> void:
	if _plugin_singleton == null:
		printerr("%s plugin not initialized" % PLUGIN_SINGLETON_NAME)
	else:
		if _active_interstitial_ads.has(a_ad_id):
			_active_interstitial_ads.erase(a_ad_id)
			_plugin_singleton.remove_interstitial_ad(a_ad_id)
		else:
			printerr("Cannot remove interstitial ad. Ad with ID '%s' not found." % a_ad_id)


func load_rewarded_ad() -> void:
	if _plugin_singleton != null:
		_plugin_singleton.load_rewarded_ad(LoadAdRequest.new()
					.set_ad_unit_id(_rewarded_id)
					.set_request_agent(request_agent)
					.get_raw_data())
	else:
		printerr("%s plugin not initialized" % PLUGIN_SINGLETON_NAME)


func is_rewarded_ad_loaded() -> bool:
	if _plugin_singleton != null:
		return _active_rewarded_ads.is_empty() == false
	else:
		printerr("%s plugin not initialized" % PLUGIN_SINGLETON_NAME)

	return false


func show_rewarded_ad(a_ad_id: String = "") -> void:
	if _plugin_singleton == null:
		printerr("%s plugin not initialized" % PLUGIN_SINGLETON_NAME)
	else:
		if a_ad_id.is_empty():
			if _active_rewarded_ads.is_empty():
				printerr("Cannot show rewarded ad. No rewarded ads loaded.")
			else:
				_plugin_singleton.show_rewarded_ad(_active_rewarded_ads[0])	# show last ad to load
		else:
			_plugin_singleton.show_rewarded_ad(a_ad_id)


func remove_rewarded_ad(a_ad_id: String) -> void:
	if _plugin_singleton == null:
		printerr("%s plugin not initialized" % PLUGIN_SINGLETON_NAME)
	else:
		if _active_rewarded_ads.has(a_ad_id):
			_active_rewarded_ads.erase(a_ad_id)
			_plugin_singleton.remove_rewarded_ad(a_ad_id)
		else:
			printerr("Cannot remove rewarded ad. Ad with ID '%s' not found." % a_ad_id)


func load_rewarded_interstitial_ad() -> void:
	if _plugin_singleton != null:
		_plugin_singleton.load_rewarded_interstitial_ad(LoadAdRequest.new()
					.set_ad_unit_id(_rewarded_interstitial_id)
					.set_request_agent(request_agent)
					.get_raw_data())
	else:
		printerr("%s plugin not initialized" % PLUGIN_SINGLETON_NAME)


func is_rewarded_interstitial_ad_loaded() -> bool:
	if _plugin_singleton != null:
		return _active_rewarded_interstitial_ads.is_empty() == false
	else:
		printerr("%s plugin not initialized" % PLUGIN_SINGLETON_NAME)

	return false


func show_rewarded_interstitial_ad(a_ad_id: String = "") -> void:
	if _plugin_singleton == null:
		printerr("%s plugin not initialized" % PLUGIN_SINGLETON_NAME)
	else:
		if a_ad_id.is_empty():
			if _active_rewarded_interstitial_ads.is_empty():
				printerr("Cannot show rewarded interstitial ad. No rewarded interstitial ads loaded.")
			else:
				_plugin_singleton.show_rewarded_interstitial_ad(_active_rewarded_interstitial_ads[0])	# show last ad to load
		else:
			_plugin_singleton.show_rewarded_interstitial_ad(a_ad_id)


func remove_rewarded_interstitial_ad(a_ad_id: String) -> void:
	if _plugin_singleton == null:
		printerr("%s plugin not initialized" % PLUGIN_SINGLETON_NAME)
	else:
		if _active_rewarded_interstitial_ads.has(a_ad_id):
			_active_rewarded_interstitial_ads.erase(a_ad_id)
			_plugin_singleton.remove_rewarded_interstitial_ad(a_ad_id)
		else:
			printerr("Cannot remove rewarded interstitial ad. Ad with ID '%s' not found." % a_ad_id)


func load_consent_form() -> void:
	if _plugin_singleton == null:
		printerr("%s plugin not initialized" % PLUGIN_SINGLETON_NAME)
	else:
		_plugin_singleton.load_consent_form()


func show_consent_form() -> void:
	if _plugin_singleton == null:
		printerr("%s plugin not initialized" % PLUGIN_SINGLETON_NAME)
	else:
		_plugin_singleton.show_consent_form()


func get_consent_status() -> int:
	if _plugin_singleton == null:
		printerr("%s plugin not initialized" % PLUGIN_SINGLETON_NAME)
	else:
		return _plugin_singleton.get_consent_status()
	return 0; #TODO:


func is_consent_form_available() -> bool:
	if _plugin_singleton == null:
		printerr("%s plugin not initialized" % PLUGIN_SINGLETON_NAME)
	else:
		return _plugin_singleton.is_consent_form_available()
	return false


func update_consent_info(consentRequestParameters: ConsentRequestParameters) -> void:
	if _plugin_singleton == null:
		printerr("%s plugin not initialized" % PLUGIN_SINGLETON_NAME)
	else:
		consentRequestParameters.set_is_real(is_real)
		_plugin_singleton.update_consent_info(consentRequestParameters.get_raw_data())


func reset_consent_info() -> void:
	if _plugin_singleton == null:
		printerr("%s plugin not initialized" % PLUGIN_SINGLETON_NAME)
	else:
		_plugin_singleton.reset_consent_info()


func _on_initialization_completed(status_data: Dictionary) -> void:
	configure_ads()
	initialization_completed.emit(InitializationStatus.new(status_data))


func _on_banner_ad_loaded(a_ad_id: String) -> void:
	_active_banner_ads.push_front(a_ad_id)
	while _active_banner_ads.size() > max_banner_ad_cache:
		print("%s: banner_ad cache size (%d) has exceeded maximum (%d)" % [PLUGIN_SINGLETON_NAME,
					_active_banner_ads.size(), max_banner_ad_cache])
		var removed_ad_id: String = _active_banner_ads.pop_back()
		_plugin_singleton.remove_banner_ad(removed_ad_id)
	banner_ad_loaded.emit(a_ad_id)


func _on_banner_ad_failed_to_load(a_ad_id: String, error_data: Dictionary) -> void:
	banner_ad_failed_to_load.emit(a_ad_id, LoadAdError.new(error_data))


func _on_banner_ad_refreshed(a_ad_id: String) -> void:
	banner_ad_refreshed.emit(a_ad_id)


func _on_banner_ad_impression(a_ad_id: String) -> void:
	banner_ad_impression.emit(a_ad_id)


func _on_banner_ad_clicked(a_ad_id: String) -> void:
	banner_ad_clicked.emit(a_ad_id)


func _on_banner_ad_opened(a_ad_id: String) -> void:
	banner_ad_opened.emit(a_ad_id)


func _on_banner_ad_closed(a_ad_id: String) -> void:
	banner_ad_closed.emit(a_ad_id)


func _on_interstitial_ad_loaded(a_ad_id: String) -> void:
	_active_interstitial_ads.push_front(a_ad_id)
	while _active_interstitial_ads.size() > max_interstitial_ad_cache:
		print("%s: interstitial_ad cache size (%d) has exceeded maximum (%d)" % [PLUGIN_SINGLETON_NAME,
					_active_interstitial_ads.size(), max_interstitial_ad_cache])
		var removed_ad_id: String = _active_interstitial_ads.pop_back()
		_plugin_singleton.remove_interstitial_ad(removed_ad_id)
	interstitial_ad_loaded.emit(a_ad_id)


func _on_interstitial_ad_failed_to_load(a_ad_id: String, error_data: Dictionary) -> void:
	interstitial_ad_failed_to_load.emit(a_ad_id, LoadAdError.new(error_data))


func _on_interstitial_ad_refreshed(a_ad_id: String) -> void:
	interstitial_ad_refreshed.emit(a_ad_id)


func _on_interstitial_ad_impression(a_ad_id: String) -> void:
	interstitial_ad_impression.emit(a_ad_id)



func _on_interstitial_ad_clicked(a_ad_id: String) -> void:
	interstitial_ad_clicked.emit(a_ad_id)


func _on_interstitial_ad_showed_full_screen_content(a_ad_id: String) -> void:
	interstitial_ad_showed_full_screen_content.emit(a_ad_id)


func _on_interstitial_ad_failed_to_show_full_screen_content(a_ad_id: String, error_data: Dictionary) -> void:
	interstitial_ad_failed_to_show_full_screen_content.emit(a_ad_id, AdError.new(error_data))


func _on_interstitial_ad_dismissed_full_screen_content(a_ad_id: String) -> void:
	interstitial_ad_dismissed_full_screen_content.emit(a_ad_id)


func _on_rewarded_ad_loaded(a_ad_id: String) -> void:
	_active_rewarded_ads.push_front(a_ad_id)
	while _active_rewarded_ads.size() > max_rewarded_ad_cache:
		print("%s: rewarded_ad cache size (%d) has exceeded maximum (%d)" % [PLUGIN_SINGLETON_NAME,
					_active_rewarded_ads.size(), max_rewarded_ad_cache])
		var removed_ad_id: String = _active_rewarded_ads.pop_back()
		_plugin_singleton.remove_rewarded_ad(removed_ad_id)
	rewarded_ad_loaded.emit(a_ad_id)


func _on_rewarded_ad_failed_to_load(a_ad_id: String, error_data: Dictionary) -> void:
	rewarded_ad_failed_to_load.emit(a_ad_id, LoadAdError.new(error_data))


func _on_rewarded_ad_impression(a_ad_id: String) -> void:
	rewarded_ad_impression.emit(a_ad_id)


func _on_rewarded_ad_clicked(a_ad_id: String) -> void:
	rewarded_ad_clicked.emit(a_ad_id)


func _on_rewarded_ad_showed_full_screen_content(a_ad_id: String) -> void:
	rewarded_ad_showed_full_screen_content.emit(a_ad_id)


func _on_rewarded_ad_failed_to_show_full_screen_content(a_ad_id: String, error_data: Dictionary) -> void:
	rewarded_ad_failed_to_show_full_screen_content.emit(a_ad_id, AdError.new(error_data))


func _on_rewarded_ad_dismissed_full_screen_content(a_ad_id: String) -> void:
	rewarded_ad_dismissed_full_screen_content.emit(a_ad_id)


func _on_rewarded_ad_user_earned_reward(a_ad_id: String, reward_data: Dictionary) -> void:
	rewarded_ad_user_earned_reward.emit(a_ad_id, RewardItem.new(reward_data))


func _on_rewarded_interstitial_ad_loaded(a_ad_id: String) -> void:
	_active_rewarded_interstitial_ads.push_front(a_ad_id)
	print("%s: rewarded_interstitial_ad cache size (%d) maximum size (%d)" % [PLUGIN_SINGLETON_NAME,
				_active_rewarded_interstitial_ads.size(), max_rewarded_interstitial_ad_cache])
	while _active_rewarded_interstitial_ads.size() > max_rewarded_interstitial_ad_cache:
		print("%s: rewarded_interstitial_ad cache size (%d) has exceeded maximum (%d)" % [PLUGIN_SINGLETON_NAME,
					_active_rewarded_interstitial_ads.size(), max_rewarded_interstitial_ad_cache])
		var removed_ad_id: String = _active_rewarded_interstitial_ads.pop_back()
		_plugin_singleton.remove_rewarded_interstitial_ad(removed_ad_id)
	rewarded_interstitial_ad_loaded.emit(a_ad_id)


func _on_rewarded_interstitial_ad_failed_to_load(a_ad_id: String, error_data: Dictionary) -> void:
	rewarded_interstitial_ad_failed_to_load.emit(a_ad_id, LoadAdError.new(error_data))


func _on_rewarded_interstitial_ad_impression(a_ad_id: String) -> void:
	rewarded_interstitial_ad_impression.emit(a_ad_id)


func _on_rewarded_interstitial_ad_clicked(a_ad_id: String) -> void:
	rewarded_interstitial_ad_clicked.emit(a_ad_id)


func _on_rewarded_interstitial_ad_showed_full_screen_content(a_ad_id: String) -> void:
	rewarded_interstitial_ad_showed_full_screen_content.emit(a_ad_id)


func _on_rewarded_interstitial_ad_failed_to_show_full_screen_content(a_ad_id: String, error_data: Dictionary) -> void:
	rewarded_interstitial_ad_failed_to_show_full_screen_content.emit(a_ad_id, AdError.new(error_data))


func _on_rewarded_interstitial_ad_dismissed_full_screen_content(a_ad_id: String) -> void:
	rewarded_interstitial_ad_dismissed_full_screen_content.emit(a_ad_id)


func _on_rewarded_interstitial_ad_user_earned_reward(a_ad_id: String, reward_data: Dictionary) -> void:
	rewarded_interstitial_ad_user_earned_reward.emit(a_ad_id, RewardItem.new(reward_data))


func _on_consent_form_loaded() -> void:
	consent_form_loaded.emit()


func _on_consent_form_dismissed(error_data: Dictionary) -> void:
	consent_form_dismissed.emit(FormError.new(error_data))


func _on_consent_form_failed_to_load(error_data: Dictionary) -> void:
	consent_form_failed_to_load.emit(FormError.new(error_data))


func _on_consent_info_updated() -> void:
	consent_info_updated.emit()


func _on_consent_info_update_failed(error_data: Dictionary) -> void:
	consent_info_update_failed.emit(FormError.new(error_data))
