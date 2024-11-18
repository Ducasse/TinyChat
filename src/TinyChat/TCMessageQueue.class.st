Class {
	#name : 'TCMessageQueue',
	#superclass : 'Object',
	#instVars : [
		'messages'
	],
	#category : 'TinyChat-server',
	#package : 'TinyChat',
	#tag : 'server'
}

{ #category : 'action' }
TCMessageQueue >> add: aMessage [
	messages add: aMessage 
]

{ #category : 'action' }
TCMessageQueue >> formattedMessagesFrom: aMessageNumber [
	
	^ String streamContents: [ :formattedMessagesStream |  
		(self listFrom: aMessageNumber) 
			do: [ :m | formattedMessagesStream << m printString ] 
		]

]

{ #category : 'initialization' }
TCMessageQueue >> initialize [

	super initialize.
	messages := OrderedCollection new.
]

{ #category : 'action' }
TCMessageQueue >> listFrom: aIndex [
	^ (aIndex > 0 and: [ aIndex <= messages size]) 
		ifTrue: [ messages copyFrom: aIndex to: messages size ]
		ifFalse: [ #() ]

]

{ #category : 'action' }
TCMessageQueue >> reset [
	messages removeAll

]

{ #category : 'action' }
TCMessageQueue >> size [
	^messages size
]