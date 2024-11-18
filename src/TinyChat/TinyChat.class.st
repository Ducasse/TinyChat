"
I'm a chat client.  I can send messages to a server listening on a given host and port. 

I keep an index of the last message that I received from the server so that I can request the sequences of messages that I may have missed and that have been posted while my last connection. 

readMessages gets the new messages that have been posted since the last request.


TCServer stopAll.


|  tco tcs | 
TCServer startOn: 8080.
[tco := TinyChat connect: 'localhost' port: 8080 login: 'olivier'.
tco send: 'hello'.
(Delay forMilliseconds: 100) wait.
tco send: 'hello Stef'.
(Delay forMilliseconds: 2000) wait.
tco inspect.] fork.

[ 
tcs := TinyChat connect: 'localhost' port: 8080 login: 'stef'.
(Delay forMilliseconds: 1000) wait.
tcs send: 'hello olivier'.
(Delay forMilliseconds: 2000) wait.
tcs inspect ] fork
"
Class {
	#name : 'TinyChat',
	#superclass : 'Object',
	#instVars : [
		'url',
		'login',
		'exit',
		'messages',
		'console',
		'lastMessageIndex'
	],
	#category : 'TinyChat-client',
	#package : 'TinyChat',
	#tag : 'client'
}

{ #category : 'initialize' }
TinyChat class >> connect: aHost port: aPort login: aLogin [

	^ self new
		host: aHost port: aPort login: aLogin;
		start
]

{ #category : 'command' }
TinyChat >> cmdLastMessageID [
	^ self command: '/messages/count'
]

{ #category : 'command' }
TinyChat >> cmdMessagesFromLastIndexToEnd [
	"Returns the server messages from my current last index to the last one on the server."
	^ self command: ('/messages?id={1}' format: { lastMessageIndex asString })
]

{ #category : 'command' }
TinyChat >> cmdNewMessage [
	^self command: '/messages/add'
]

{ #category : 'command' }
TinyChat >> command: aPath [
	^'{1}{2}' format: { url . aPath }
]

{ #category : 'command' }
TinyChat >> command: aPath argument: anArgument [
	^'{1}{2}/{3}' format: { url . aPath . anArgument asString }
]

{ #category : 'action' }
TinyChat >> disconnect [
	self sendNewMessage: (TCMessage from: login text: 'I exited from the chat room.').
	exit := true 
]

{ #category : 'private' }
TinyChat >> host: aHost port: aPort login: aLogin [
	url := 'http://' , aHost , ':' , aPort asString.
	login := aLogin
]

{ #category : 'initialization' }
TinyChat >> initialize [
	super initialize.
	exit := false.
	lastMessageIndex := 0.
	messages := OrderedCollection new.
]

{ #category : 'private' }
TinyChat >> readLastMessageID [
	| id |
	id := (ZnClient new url: self cmdLastMessageID; get) asInteger.
	id = 0 ifTrue: [  id := 1 ].
	^ id
]

{ #category : 'private' }
TinyChat >> readMissingMessages [
	"Gets the new messages that have been posted since the last request."
	| response receivedMessages |
	response := (ZnClient new url: self cmdMessagesFromLastIndexToEnd; get).
	^ response 
		ifNil: [ 0 ]
		ifNotNil: [  
			receivedMessages := response subStrings: (String crlf).
			receivedMessages do: [ :msg | messages add: (TCMessage fromString: msg) ].
			receivedMessages size.
		].
]

{ #category : 'private' }
TinyChat >> refreshMessages [
	
	[  
		[ exit ] whileFalse: [  
			(Delay forSeconds: 2) wait.
			lastMessageIndex := lastMessageIndex + (self readMissingMessages).
			console print: messages.
		]
	] fork

]

{ #category : 'action' }
TinyChat >> send: aString [
	"When we send a message, we push it to the server and in addition we update the local list of posted messages."
	
	| msg |
	msg := TCMessage from: login text: aString.
	self sendNewMessage: msg.
	lastMessageIndex := lastMessageIndex + (self readMissingMessages).
	console print: messages.
	
]

{ #category : 'private' }
TinyChat >> sendNewMessage: aMessage [
	^ ZnClient new
		url: self cmdNewMessage;
		formAt: 'sender' put:  (aMessage sender);
		formAt: 'text' put: (aMessage text);
		post
]

{ #category : 'private' }
TinyChat >> start [

	console := TCConsolePresenter attach: self.	
	self sendNewMessage: (TCMessage from: login text: 'I joined the chat room').
	lastMessageIndex := self readLastMessageID.
	self refreshMessages.


]
