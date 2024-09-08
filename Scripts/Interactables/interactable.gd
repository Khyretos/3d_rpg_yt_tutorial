extends Area3D

class_name Interactable

@export var interactions : PackedStringArray = []
@export var images : PackedByteArray = []

# Emitted when an Interactor starts looking at me.
signal focused(interactor: Interactor)
# Emitted when an Interactor stops looking at me.
signal unfocused(interactor: Interactor)
# Emitted when an Interactor interacts with me.
signal interacted(interactor: Interactor)
