class_name ModalFactory
extends RefCounted
## ModalFactory - Helper functions for creating common modal patterns
## Week 16 Phase 4: Simplified modal creation
##
## Usage:
## ```gdscript
## # Simple alert
## ModalFactory.show_alert(self, "Success!", "Character created.", func(): print("OK"))
##
## # Confirmation dialog
## ModalFactory.show_confirmation(
##     self,
##     "Delete Character?",
##     "This cannot be undone.",
##     func(): _delete_character(),
##     func(): print("Cancelled")
## )
## ```


## Show a simple alert with single OK button
static func show_alert(
	parent: Node, title: String, message: String, on_ok: Callable = Callable()
) -> MobileModal:
	var modal = MobileModal.new()
	modal.modal_type = MobileModal.ModalType.ALERT
	modal.allow_tap_outside_dismiss = true
	modal.title_text = title
	modal.message_text = message

	# Parent FIRST (Godot 4 Parent-First Protocol - iOS safety)
	parent.add_child(modal)

	# Add OK button AFTER parenting (button_container exists after _ready())
	modal.add_primary_button(
		"OK",
		func():
			modal.dismiss()
			if on_ok.is_valid():
				on_ok.call()
	)

	modal.show_modal()
	return modal


## Show confirmation dialog with Cancel/Confirm buttons
static func show_confirmation(
	parent: Node,
	title: String,
	message: String,
	on_confirm: Callable,
	on_cancel: Callable = Callable(),
	confirm_text: String = "Confirm",
	cancel_text: String = "Cancel"
) -> MobileModal:
	var modal = MobileModal.new()
	modal.modal_type = MobileModal.ModalType.ALERT
	modal.allow_tap_outside_dismiss = false  # Force explicit choice
	modal.title_text = title
	modal.message_text = message

	# Parent FIRST (Godot 4 Parent-First Protocol - iOS safety)
	parent.add_child(modal)

	# Add Cancel button AFTER parenting (button_container exists after _ready())
	modal.add_secondary_button(
		cancel_text,
		func():
			modal.dismiss()
			if on_cancel.is_valid():
				on_cancel.call()
	)

	# Add Confirm button AFTER parenting
	modal.add_primary_button(
		confirm_text,
		func():
			modal.dismiss()
			if on_confirm.is_valid():
				on_confirm.call()
	)

	modal.show_modal()
	return modal


## Show destructive confirmation (delete, reset, etc.)
static func show_destructive_confirmation(
	parent: Node,
	title: String,
	message: String,
	on_delete: Callable,
	on_cancel: Callable = Callable(),
	delete_text: String = "Delete",
	cancel_text: String = "Cancel"
) -> MobileModal:
	var modal = MobileModal.new()

	# Parent FIRST (Godot 4 Parent-First Protocol - iOS safety)
	parent.add_child(modal)

	# Configure AFTER parenting (iOS SIGKILL prevention)
	modal.modal_type = MobileModal.ModalType.ALERT
	modal.allow_tap_outside_dismiss = false  # Prevent accidental dismissal
	modal.title_text = title
	modal.message_text = message

	# Add Cancel button AFTER parenting (button_container exists after _ready())
	modal.add_secondary_button(
		cancel_text,
		func():
			modal.dismiss()
			if on_cancel.is_valid():
				on_cancel.call()
	)

	# Add Delete button AFTER parenting (danger style)
	modal.add_danger_button(
		delete_text,
		func():
			HapticManager.warning()  # Extra warning haptic
			modal.dismiss()
			if on_delete.is_valid():
				on_delete.call()
	)

	modal.show_modal()
	return modal


## Show error message
static func show_error(
	parent: Node,
	title: String = "Error",
	message: String = "An error occurred.",
	on_ok: Callable = Callable()
) -> MobileModal:
	var modal = MobileModal.new()

	# Parent FIRST (Godot 4 Parent-First Protocol - iOS safety)
	parent.add_child(modal)

	# Configure AFTER parenting (iOS SIGKILL prevention)
	modal.modal_type = MobileModal.ModalType.ALERT
	modal.allow_tap_outside_dismiss = true
	modal.title_text = title
	modal.message_text = message

	# Play error sound
	HapticManager.warning()

	# Add OK button AFTER parenting (button_container exists after _ready())
	modal.add_danger_button(
		"OK",
		func():
			modal.dismiss()
			if on_ok.is_valid():
				on_ok.call()
	)

	modal.show_modal()
	return modal


## Create a bottom sheet modal (for complex content)
static func create_sheet(
	parent: Node,
	title: String = "",
	allow_swipe_dismiss: bool = true,
	allow_tap_outside: bool = true
) -> MobileModal:
	var modal = MobileModal.new()

	# Parent FIRST (Godot 4 Parent-First Protocol - iOS safety)
	parent.add_child(modal)

	# Configure AFTER parenting (iOS SIGKILL prevention)
	modal.modal_type = MobileModal.ModalType.SHEET
	modal.allow_swipe_dismiss = allow_swipe_dismiss
	modal.allow_tap_outside_dismiss = allow_tap_outside
	modal.title_text = title

	# Note: Caller must add custom content and call show_modal()
	return modal


## Create a full-screen modal (for onboarding, tutorials)
static func create_fullscreen(parent: Node, title: String = "") -> MobileModal:
	var modal = MobileModal.new()

	# Parent FIRST (Godot 4 Parent-First Protocol - iOS safety)
	parent.add_child(modal)

	# Configure AFTER parenting (iOS SIGKILL prevention)
	modal.modal_type = MobileModal.ModalType.FULLSCREEN
	modal.allow_tap_outside_dismiss = false
	modal.allow_swipe_dismiss = false
	modal.title_text = title

	# Note: Caller must add custom content and call show_modal()
	return modal
