"
(TinyChat connect: 'localhost' port: 8080 login: 'olivier' ) 
"
Class {
	#name : 'TCConsolePresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'chat',
		'list',
		'input'
	],
	#category : 'TinyChat-client',
	#package : 'TinyChat',
	#tag : 'client'
}

{ #category : 'instance creation' }
TCConsolePresenter class >> attach: aTinyChat [
	| window |
	window := self new chat: aTinyChat.
	window openWithSpec whenClosedDo: [ aTinyChat disconnect ].
	^window
]

{ #category : 'initialize' }
TCConsolePresenter class >> defaultSpec [
	<spec: #default>
    
	^ SpecLayout composed
		newColumn: [ :c | 
			c
				add: #list;
				add: #input height: 30
			];
		yourself

]

{ #category : 'accessing' }
TCConsolePresenter >> chat: anObject [
	chat := anObject
]

{ #category : 'initialization' }
TCConsolePresenter >> defaultLayout [

	^ SpBoxLayout newTopToBottom
			add: list;
			add: input;
			yourself

]

{ #category : 'initialization' }
TCConsolePresenter >> initializeWidgets [

	list := self newList.
	
	input := self newTextInput.
	input	placeholder: 'Type your message here...';
		whenSubmitDo: [ :string |  
			chat send: string. 
			input text: '' ].
	
	self focusOrder add: input.
]

{ #category : 'accessing' }
TCConsolePresenter >> input [
	^ input
]

{ #category : 'accessing' }
TCConsolePresenter >> list [
	^ list
]

{ #category : 'display' }
TCConsolePresenter >> print: aCollectionOfMessages [

	list items: (aCollectionOfMessages collect: [  :m |  m printString ])



]

{ #category : 'configuration' }
TCConsolePresenter >> title [
	^ 'TinyChat'
]
