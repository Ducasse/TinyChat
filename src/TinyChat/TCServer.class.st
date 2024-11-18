"
I'm a chat server. I'm listening to HTTPRequests and managing a list of messages. 

My clients often request the messages I hold. Indeed, it may happen that client sends a lot of message and another one should request the difference between the messages it knows and the ones published on the server to be able to refresh correctly. 

I register some routes 
	/messages/ aNumber  get all the messages from aNumber to the end.
	/messages/count to get the current number of messages
	/messages/ add to add a message


TCServer startOn: 8080.

TinyChat connect: 'localhost' port: 8080 login: 'olivier'.

"
Class {
	#name : 'TCServer',
	#superclass : 'Object',
	#instVars : [
		'teapotServer',
		'messagesQueue'
	],
	#category : 'TinyChat-server',
	#package : 'TinyChat',
	#tag : 'server'
}

{ #category : 'initialize' }
TCServer class >> startOn: aPortNumber [
	^self new
		initializePort: aPortNumber;
		registerRoutes;
		registerErrorHandlers;
		yourself
]

{ #category : 'initialize' }
TCServer class >> stopAll [

	self allInstancesDo: #stop
]

{ #category : 'action' }
TCServer >> addMessage: aRequest [
	messagesQueue add: (TCMessage from: (aRequest at: #sender) text: (aRequest at: #text)).

]

{ #category : 'initialize-release' }
TCServer >> initialize [
	super initialize.
	messagesQueue := TCMessageQueue new.
]

{ #category : 'initialize-release' }
TCServer >> initializePort: anInteger [
	teapotServer := Teapot configure: { 
		#defaultOutput -> #text.
		#port -> anInteger.
		#debugMode -> true
	}.
	teapotServer start.
]

{ #category : 'action' }
TCServer >> messageCount [
	^ messagesQueue size
]

{ #category : 'action' }
TCServer >> messagesFrom: request [
	^ messagesQueue formattedMessagesFrom: ((request at: #id) asInteger) 
]

{ #category : 'initialize-release' }
TCServer >> registerErrorHandlers [
	teapotServer
		exception: KeyNotFound -> (TeaResponse notFound body: 'No such message')
]

{ #category : 'initialize-release' }
TCServer >> registerRoutes [
	teapotServer
		GET: '/messages/count' -> (Send message: #messageCount to: self);
		GET: '/messages' -> (Send message: #messagesFrom: to: self);
		POST: '/messages/add' -> (Send message: #addMessage: to: self)
]

{ #category : 'server' }
TCServer >> stop [
	teapotServer stop.
	messagesQueue reset.
]
