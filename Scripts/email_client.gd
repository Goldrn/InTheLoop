extends CanvasLayer

@export_file("*.json") var emails_file
var emails

@onready var email_list = $"email list scroller/email list"
@onready var email_bodys = $"email bodys scroller/email bodys"
@onready var word_bank = $"word bank background/word bank"

var email_bg_obj = preload("res://Scenes/Ui/email_bg.tscn")
var email_bg_reply_obj = preload("res://Scenes/Ui/email_bg_reply.tscn")
var email_bg_reply_user_obj = preload("res://Scenes/Ui/email_bg_reply_user.tscn")
var word_bg_obj = preload("res://Scenes/Ui/word_for_bank.tscn")

var reply_box: Node

func _ready() -> void:
	emails = load_emails()
	for email in emails:
		make_preview(emails[email])
	SignalBus.open_email.connect(open_email)
	SignalBus.word_button_pressed.connect(button_pressed)

func load_emails():
	if FileAccess.file_exists(emails_file):
		var file = FileAccess.open(emails_file, FileAccess.READ)
		return JSON.parse_string(file.get_as_text())
		
func make_preview(email_obj):
	var preview_obj = load("res://Scenes/Ui/email_preview.tscn").instantiate()
	email_list.add_child(preview_obj)
	var preview_label = preview_obj.find_child("email preview text")
	preview_label.text = email_obj["sender"] + "\n" + email_obj["subject"]
	preview_obj.email_object_holder = email_obj

func open_email(email_obj):
	for child in email_bodys.get_children():
		email_bodys.remove_child(child)
	var first_email = email_bg_obj.instantiate()
	email_bodys.add_child(first_email)
	first_email.set_focus_mode(1)
	first_email.grab_focus()
	var OG_Sender = first_email.find_child("Sender")
	var OG_Recipients = first_email.find_child("Recipients")
	var OG_Subject = first_email.find_child("Subject")
	var OG_Body = first_email.find_child("Body")
	OG_Sender.text = email_obj["sender"]
	OG_Recipients.text = email_obj["recipients"]
	OG_Subject.text = email_obj["subject"]
	OG_Body.text = email_obj["body"]
	var replys = email_obj["replys"]
	if replys.size() != 0:
		for reply in replys:
			var reply_bg = email_bg_reply_obj.instantiate()
			email_bodys.add_child(reply_bg)
			var RP_Sender = reply_bg.find_child("Sender")
			var RP_Recipients = reply_bg.find_child("Recipients")
			var RP_Subject = reply_bg.find_child("Subject")
			var RP_Body = reply_bg.find_child("Body")
			RP_Sender.text = reply["sender"]
			RP_Body.text = reply["body"]
	var user_reply_bg = email_bg_reply_user_obj.instantiate()
	email_bodys.add_child(user_reply_bg)
	var URP_Body = user_reply_bg.find_child("Body")
	reply_box = URP_Body
	URP_Body.text = "click words in word bank to write your reply"
	make_words(email_obj["words"], Globals.known_words)

func make_words(email_words, known_words):
	for word_obj in word_bank.get_children():
		word_bank.remove_child(word_obj)
	for word in email_words:
		var current_word_bg = word_bg_obj.instantiate()
		word_bank.add_child(current_word_bg)
		current_word_bg.find_child("button_text").text = word
		current_word_bg.text = word
		if known_words.has(word) and known_words[word] == "good":
			current_word_bg.modulate = Globals.good_word
		elif known_words.has(word) and known_words[word] == "bad":
			current_word_bg.modulate = Globals.bad_word
		else:
			current_word_bg.modulate = Globals.unknown_word

func button_pressed(word):
	if reply_box.text == "click words in word bank to write your reply":
		reply_box.text = ""
		reply_box.set_focus_mode(1)
		reply_box.grab_focus()
		reply_box.text = reply_box.text + word + " "
	else:
		reply_box.text = reply_box.text + word + " "
