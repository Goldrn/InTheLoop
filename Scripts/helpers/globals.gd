extends Node

var safe_to_send_dialog_signal = true
var in_progress = false

var transparent = Color(1, 1, 1, 0)
var white = Color(1,1,1,1)
var good_word = Color(1,255,1,1)
var bad_word = Color(255,1,1,1)
var unknown_word = Color(0.5,0.5,0.5,1)
var known_words = {}
