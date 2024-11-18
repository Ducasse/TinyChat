Class {
	#name : 'BaselineOfTinyChat',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfTinyChat',
	#package : 'BaselineOfTinyChat'
}

{ #category : 'baselines' }
BaselineOfTinyChat >> baseline: spec [
	<baseline>

	spec for: #'common' do: [
		spec baseline: 'Teapot' with: [
				spec repository: 'github://zeroflag/Teapot/source' ].
		spec 
			package: #'TinyChat' with: [
				spec requires: #('Teapot' ) ] ]
			
]
