extends Node

var log_file_path: String  # Stores the current log file path
var max_log_files = 5  # Maximum number of log files to keep (optional cleanup)
var debug_enabled = true

func _ready():
	var timestamp = Time.get_datetime_string_from_system().replace(":", "-").replace(" ", "_")
	log_file_path = "res://LogFiles/log_" + timestamp + ".txt"
	
	# Create the log file and write the startup message
	var file = FileAccess.open(log_file_path, FileAccess.WRITE)
	if file:
		file.store_line("[INFO] Game started at: " + Time.get_time_string_from_system())
		file.close()
	
	debug_enabled = GlobalSettings.debug_mode
	
	if debug_enabled:
		print("Debugger initialized. Logging to:", log_file_path)
	clean_old_logs()  # (Optional) Remove old log files

func log(message: String, level: String = "INFO"):
	var timestamped_message = "[" + level + "] " + Time.get_time_string_from_system() + " - " + message
	
	# Print to console
	if debug_enabled:
		print(timestamped_message)
	
	# Append to the log file
	var file = FileAccess.open(log_file_path, FileAccess.READ_WRITE)
	if file:
		file.seek_end()
		file.store_line(timestamped_message)
		file.close()

# (Optional) Limit stored logs to avoid excessive file buildup
func clean_old_logs():
	var dir = DirAccess.open("user://")
	if dir:
		var log_files = []
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.begins_with("log_") and file_name.ends_with(".txt"):
				log_files.append(file_name)
			file_name = dir.get_next()
		
		log_files.sort()  # Sort by name (older logs first)
		while log_files.size() > max_log_files:
			dir.remove(log_files.pop_front())  # Delete the oldest log file

func log_warning(message: String):
	self.log(message, "WARNING")

func log_error(message: String):
	self.log(message, "ERROR")
