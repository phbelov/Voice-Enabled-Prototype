# Handling Voice

inputVolume = undefined
UPDATE_FREQUENCY = 0.15
MAX_VOLUME = 10

# get the volume value
getVolume = (input) ->
	sum = 0.0
	for i in [0...input.length]
		sum += input[i] * input[i]
	volume = Math.sqrt(sum / input.length) * 100
	return volume.toFixed(2)

# handle success in case we were able to get access to the mic
handleSuccess = (stream) ->
	audioCtx = new AudioContext
	source = audioCtx.createMediaStreamSource(stream)
	scriptNode = audioCtx.createScriptProcessor(2048, 1, 1);
	
	source.connect(scriptNode)
	scriptNode.connect(audioCtx.destination)
	
	scriptNode.onaudioprocess = (event) ->
		input = event.inputBuffer.getChannelData(0)
		inputVolume = getVolume(input)
	
	return

# print error in case of error
handleFailure = (error) ->
	print(error)
	return

# set the constraints
constraints = 
	audio: true
	video: false

# check whether or not the browser supports Web Audio API
# if yes, try to get access to the mic
if navigator.mediaDevices
	console.log('getUserMedia supported')
	navigator.mediaDevices.getUserMedia(constraints).then(handleSuccess).catch(handleFailure)
else 
	console.log('getUserMedia is not supported')

# making layer from the startListening function located below respond to voice
respondToVoice = (layer) ->
	
	currentScale = Utils.modulate(inputVolume, [0, MAX_VOLUME], [layer.states.inactive.scale, layer.states.active.scale], true)
	currentBorderWidth = Utils.modulate(inputVolume, [0, MAX_VOLUME], [layer.states.inactive.borderWidth, layer.states.active.borderWidth], true)
	
	layerAnimation = new Animation layer,
		scale: currentScale
		borderWidth: currentBorderWidth
		options: 
			curve: Spring(damping: 0.91)
			time: 0.30
			
	layerAnimation.start()
	layerAnimation.onAnimationEnd ->
		layerAnimation.start()

startListening = () ->
	Utils.interval UPDATE_FREQUENCY, ->
		respondToVoice(vcircle)
		
startListening()

# Layer Setup

Screen.backgroundColor = "#2f2f2f"

vcircle = new Layer
	width: 96
	height: 96
	x: Align.center
	y: Align.center
	borderRadius: 200
	borderWidth: 8
	borderColor: "rgba(50,205,253,1)"
	backgroundColor: ""
	opacity: 1.0

vcircle.states =
	inactive:
		scale: 1
		borderWidth: 12
	active:
		scale: 1.75
		borderWidth: 2

vcircle.stateSwitch("inactive")


# Create slider
slider = new SliderComponent
	point: Align.center
	knobSize: 44
	min: 1
	max: 15

# Listen for slider value updates
slider.onValueChange ->
	


